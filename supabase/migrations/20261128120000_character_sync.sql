-- Character sync (docs/SYNC_SPEC.md): entitlements, characters, write RPCs
-- and the private character-images bucket. The app never writes the tables
-- directly; all writes go through push_character / delete_character.

-- ── Entitlements ────────────────────────────────────────────────────────────
-- Written only by the service role (RevenueCat webhook). A GM purchase grants
-- both the 'sync' and the 'gm' rows.
create table public.entitlements (
  user_id     uuid not null references auth.users (id) on delete cascade,
  entitlement text not null check (entitlement in ('sync', 'gm')),
  expires_at  timestamptz,            -- null = does not expire
  product_id  text,
  updated_at  timestamptz not null default now(),
  primary key (user_id, entitlement)
);

alter table public.entitlements enable row level security;

create policy "Users read their own entitlements"
  on public.entitlements for select
  to authenticated
  using (user_id = (select auth.uid()));

revoke insert, update, delete on public.entitlements from anon, authenticated;

-- Days an expired subscriber can still read and download their cloud copy.
create or replace function public.sync_grace_days()
returns integer
language sql
immutable
set search_path = ''
as $$ select 90 $$;

create or replace function public.has_sync(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.entitlements e
    where e.user_id = uid
      and e.entitlement = 'sync'
      and (e.expires_at is null or e.expires_at > now())
  );
$$;

create or replace function public.can_read_sync(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.entitlements e
    where e.user_id = uid
      and e.entitlement = 'sync'
      and (
        e.expires_at is null
        or e.expires_at > now() - make_interval(days => public.sync_grace_days())
      )
  );
$$;

-- ── Characters ──────────────────────────────────────────────────────────────
create table public.characters (
  user_id      uuid not null references auth.users (id) on delete cascade,
  id           uuid not null,                    -- Character.id on the device
  revision     bigint not null default 1 check (revision >= 1),
  data         jsonb,                            -- null once deleted
  data_version integer not null check (data_version >= 0),
  ruleset_id   text not null check (char_length(ruleset_id) <= 32),
  name         text not null check (char_length(name) <= 200),
  image_hash   text check (image_hash ~ '^[0-9a-f]{64}$'),
  device_id    text not null check (char_length(device_id) <= 64),
  deleted_at   timestamptz,                      -- tombstone
  updated_at   timestamptz not null default now(),
  primary key (user_id, id),
  constraint characters_deleted_without_data
    check ((deleted_at is null) = (data is not null)),
  constraint characters_data_size
    check (data is null or pg_column_size(data) <= 2000000)
);

create index characters_user_updated_idx
  on public.characters (user_id, updated_at desc);

alter table public.characters enable row level security;

-- Reads stay available during the grace period; writes use the RPCs below.
create policy "Users read their own characters"
  on public.characters for select
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.can_read_sync((select auth.uid()))
  );

revoke insert, update, delete on public.characters from anon, authenticated;

-- Uploads a character. Without p_force the write only happens when the cloud
-- revision is still p_base_revision (null for a character never uploaded);
-- otherwise it returns the current revision as a conflict.
-- Returns {"status": "pushed" | "conflict" | "no_entitlement", "revision": n}.
create or replace function public.push_character(
  p_id            uuid,
  p_base_revision bigint,
  p_data          jsonb,
  p_data_version  integer,
  p_ruleset_id    text,
  p_name          text,
  p_image_hash    text,
  p_device_id     text,
  p_force         boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
  current_revision bigint;
begin
  if uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'invalid_data' using errcode = '22023';
  end if;
  if not public.has_sync(uid) then
    return jsonb_build_object('status', 'no_entitlement');
  end if;

  select c.revision into current_revision
  from public.characters c
  where c.user_id = uid and c.id = p_id
  for update;

  if not found then
    insert into public.characters (
      user_id, id, revision, data, data_version, ruleset_id, name,
      image_hash, device_id
    )
    values (
      uid, p_id, 1, p_data, p_data_version, p_ruleset_id, p_name,
      p_image_hash, p_device_id
    )
    on conflict (user_id, id) do nothing;
    if found then
      return jsonb_build_object('status', 'pushed', 'revision', 1);
    end if;
    -- Another device inserted it first.
    select c.revision into current_revision
    from public.characters c
    where c.user_id = uid and c.id = p_id
    for update;
  end if;

  if not p_force and current_revision is distinct from p_base_revision then
    return jsonb_build_object('status', 'conflict', 'revision', current_revision);
  end if;

  update public.characters c
  set revision     = current_revision + 1,
      data         = p_data,
      data_version = p_data_version,
      ruleset_id   = p_ruleset_id,
      name         = p_name,
      image_hash   = p_image_hash,
      device_id    = p_device_id,
      deleted_at   = null,
      updated_at   = now()
  where c.user_id = uid and c.id = p_id;

  return jsonb_build_object('status', 'pushed', 'revision', current_revision + 1);
end;
$$;

-- Turns a character into a tombstone so other devices learn about the delete.
-- Same revision rules and result shape as push_character.
create or replace function public.delete_character(
  p_id            uuid,
  p_base_revision bigint,
  p_device_id     text,
  p_force         boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
  current_revision bigint;
begin
  if uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not public.has_sync(uid) then
    return jsonb_build_object('status', 'no_entitlement');
  end if;

  select c.revision into current_revision
  from public.characters c
  where c.user_id = uid and c.id = p_id
  for update;

  if not found then
    return jsonb_build_object('status', 'pushed', 'revision', null);
  end if;
  if not p_force and current_revision is distinct from p_base_revision then
    return jsonb_build_object('status', 'conflict', 'revision', current_revision);
  end if;

  update public.characters c
  set revision   = current_revision + 1,
      data       = null,
      image_hash = null,
      device_id  = p_device_id,
      deleted_at = now(),
      updated_at = now()
  where c.user_id = uid and c.id = p_id;

  return jsonb_build_object('status', 'pushed', 'revision', current_revision + 1);
end;
$$;

revoke all on function public.push_character(uuid, bigint, jsonb, integer, text, text, text, text, boolean) from public, anon;
revoke all on function public.delete_character(uuid, bigint, text, boolean) from public, anon;
grant execute on function public.push_character(uuid, bigint, jsonb, integer, text, text, text, text, boolean) to authenticated;
grant execute on function public.delete_character(uuid, bigint, text, boolean) to authenticated;

revoke all on function public.has_sync(uuid) from public, anon;
revoke all on function public.can_read_sync(uuid) from public, anon;
grant execute on function public.has_sync(uuid) to authenticated;
grant execute on function public.can_read_sync(uuid) to authenticated;

-- ── Character images ────────────────────────────────────────────────────────
-- Objects live at {user_id}/{character_id}/{image_hash}.jpg.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('character-images', 'character-images', false, 2097152, array['image/jpeg', 'image/png'])
on conflict (id) do nothing;

create policy "Users read their own character images"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'character-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and public.can_read_sync((select auth.uid()))
  );

create policy "Subscribers upload their own character images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'character-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and public.has_sync((select auth.uid()))
  );

create policy "Subscribers replace their own character images"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'character-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and public.has_sync((select auth.uid()))
  );

create policy "Users delete their own character images"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'character-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
