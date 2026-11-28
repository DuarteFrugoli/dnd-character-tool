# Especificacao - Conta e Sync (3.1.0)

Status: rascunho para discussao. Escopo: sincronizar personagens e fotos entre
aparelhos para assinantes Sync ou Mestre. Campanhas, homebrew e dados do
mestre entram depois, reaproveitando o mesmo modelo.

## Principios

1. O aparelho e a fonte da verdade. A nuvem e uma copia controlada pelo
   usuario.
2. Envio automatico, download explicito. O app nunca sobrescreve uma ficha
   local sem o usuario pedir. Excecao: personagem que nao existe no aparelho
   pode ser baixado sem conflito.
3. Nada muda para quem nao tem conta. Todo o codigo de sync fica atras do
   estado "logado + direito ativo".
4. Antes de sobrescrever qualquer ficha local, o app grava um backup local
   (mecanismo atual de `LocalBackupRepository`).

## Pecas

| Peca | Escolha |
| --- | --- |
| Backend | Supabase (Postgres, Auth, Storage, Edge Functions, pg_cron) |
| Login | Google no Android (`signInWithIdToken`); Apple obrigatorio no iOS |
| Billing | RevenueCat sobre Play Billing; StoreKit e Stripe depois |
| Direitos | Tabela `entitlements` gravada apenas pelo webhook do RevenueCat |

Fluxo de compra: o usuario cria a conta primeiro, depois assina. O
`app_user_id` do RevenueCat e o `auth.users.id` do Supabase
(`Purchases.logIn(userId)`), entao a compra fica presa a conta e vale em
qualquer plataforma.

## Produtos e direitos

| Produto | Direitos concedidos |
| --- | --- |
| `sync_monthly`, `sync_annual` | `sync` |
| `gm_monthly`, `gm_annual` | `sync`, `gm` |

O app le o `CustomerInfo` do RevenueCat para a interface (paywall, status).
Quem decide acesso ao banco e o Postgres, pela tabela `entitlements`.

## Banco

```sql
create table entitlements (
  user_id     uuid not null references auth.users on delete cascade,
  entitlement text not null check (entitlement in ('sync', 'gm')),
  expires_at  timestamptz,              -- null = sem expiracao
  product_id  text,
  updated_at  timestamptz not null default now(),
  primary key (user_id, entitlement)
);

create table characters (
  user_id      uuid not null references auth.users on delete cascade,
  id           uuid not null,            -- mesmo id do Character local
  revision     bigint not null default 1,-- incrementado a cada escrita
  data         jsonb,                    -- null quando apagado
  data_version int not null,             -- Character.dataVersion
  ruleset_id   text not null,
  name         text not null,            -- para listar sem baixar tudo
  image_hash   text,                     -- sha256 da foto, null sem foto
  device_id    text not null,            -- aparelho que fez a ultima escrita
  deleted_at   timestamptz,              -- tombstone
  updated_at   timestamptz not null default now(),
  primary key (user_id, id)
);
```

Funcoes auxiliares:

- `has_sync(uid)`: existe `entitlements` com `sync` e `expires_at` nulo ou no
  futuro.
- `can_read_sync(uid)`: `has_sync(uid)` ou ultima expiracao ha menos de 90
  dias (`sync_grace_days()`).

RLS:

- `characters` select: `user_id = auth.uid() and can_read_sync(auth.uid())`.
- `characters` insert/update/delete direto: bloqueado. Escritas so pela RPC
  `push_character`, que exige `has_sync`.
- `entitlements` select: `user_id = auth.uid()`. Escrita apenas pelo
  service role (webhook).

Storage: bucket privado `character-images`, caminho
`{user_id}/{character_id}/{image_hash}.jpg`, com as mesmas regras de leitura
e escrita da tabela.

## Estado local de sync

Fica fora do JSON do personagem, para nao vazar em `.dndchar` e backups.
`CharacterSyncStateStore` (SharedPreferences, que funciona em Android, iOS e
web) guarda, por personagem:

| Campo | Uso |
| --- | --- |
| `baseRevision` | Revisao da nuvem com a qual a copia local foi sincronizada por ultimo |
| `baseHash` | Hash do payload sincronizado por ultimo |
| `excluded` | Usuario tirou este personagem da nuvem |

"Mudou localmente" = hash do payload atual diferente de `baseHash`. Nao e
preciso interceptar cada gravacao.

Payload enviado (`CharacterSyncPayload`): o `Character` serializado sem os
campos do aparelho: `imagePath`, `isPinned` e `sortOrder` (a organizacao da
lista e de cada aparelho). Ao baixar, esses campos continuam os do aparelho.
O hash ignora tambem `updatedAt`. A foto vai separada pelo hash.

## Estados por personagem

Calculados comparando o local com a linha da nuvem:

| Estado | Condicao | Acao |
| --- | --- | --- |
| Em dia | sem mudanca local e `revision == baseRevision` | nada |
| Local mais novo | mudanca local e `revision == baseRevision` | envio automatico |
| Nuvem mais nova | sem mudanca local e `revision > baseRevision` | aviso; usuario baixa quando quiser |
| Divergiu | mudanca local e `revision > baseRevision` | usuario escolhe (abaixo) |
| So na nuvem | nao existe no aparelho | aparece em "Na nuvem"; baixar e livre |
| Apagado na nuvem | `deleted_at` preenchido, local existe | aviso; apagar local ou enviar de novo |
| So no aparelho | nunca enviado, ou apagado da nuvem apos o prazo | envio automatico |
| Fora da nuvem | usuario excluiu da nuvem | nada |
| Atualize o app | a nuvem mudou e tem `data_version` maior que o do app | aviso para atualizar |

Uma copia local sem estado salvo, cujo `id` ja existe na nuvem (por exemplo,
depois de sair e entrar de novo na conta), conta como divergente: o usuario
escolhe, em vez de uma copia sobrescrever a outra.

Opcoes quando diverge:

1. **Manter a local**: grava a versao da nuvem como backup local e envia a
   local com `force`.
2. **Usar a da nuvem**: grava a local como backup e substitui pela da nuvem.
3. **Duplicar**: a versao da nuvem vira um personagem novo (novo `id`, nome
   com sufixo de origem, por exemplo "(nuvem)") e e enviada como nova; a
   local e enviada com `force`. As duas versoes ficam no aparelho e na nuvem.

"Baixar da nuvem" existe tambem como acao manual em qualquer estado, mesmo se
a nuvem estiver atras, sempre com backup local antes.

## Envio

RPC `push_character(id, base_revision, data, data_version, ruleset_id, name,
image_hash, device_id, force default false)`:

- Sem `has_sync`: erro `no_entitlement`.
- Linha nao existe: insere com `revision = 1`.
- `force = false` e `revision <> base_revision`: nao grava, retorna
  `conflict` com a revisao atual. O app marca o personagem como divergente.
- Caso contrario: grava, `revision = revision + 1`, retorna a nova revisao.
  O app atualiza `baseRevision` e `baseHash`.

Gatilhos de envio: depois de gravar localmente (debounce de alguns segundos),
ao voltar o app para primeiro plano e no botao "Sincronizar agora". Sem rede,
nada a fazer: a diferenca de hash ja e a fila.

Foto: antes do envio, se o `image_hash` mudou, faz upload do arquivo. Fotos
antigas do mesmo personagem sao removidas depois do envio bem-sucedido.

Apagar: RPC `delete_character(id, base_revision, device_id, force)` grava
`data = null` e `deleted_at = now()`, com as mesmas regras de revisao do
envio; em seguida o app remove as fotos do personagem no storage. A linha
fica como tombstone por 90 dias para avisar os outros aparelhos (limpeza na
fase 4).

## Download

- Lista: `select id, revision, name, ruleset_id, data_version, image_hash,
  deleted_at, updated_at` para montar os estados sem baixar os JSONs.
- Baixar: busca `data`, baixa a foto se o hash for diferente do local, grava
  backup local, roda as migracoes atuais e salva.
- `data_version` da nuvem maior que `currentCharacterDataVersion`: nao
  aplica. Mostra "atualize o app para abrir esta versao".

## Importacoes e backups

Importar `.dndchar`/`.dndbackup` e restaurar backup local ja geram `id` novo,
entao viram personagens novos na nuvem. Duplicar personagem tambem.

## Assinatura vencida

| Momento | Comportamento |
| --- | --- |
| Ativa | Envio e download |
| Vencida ate 90 dias | Envio pausado; lista e download liberados; banner para renovar |
| Aviso | E-mail aos 30 e aos 7 dias antes de apagar |
| Depois de 90 dias | pg_cron apaga linhas e fotos do usuario; a conta continua |

O app nunca apaga nem trava fichas locais por causa da assinatura.

## Conta

- Excluir conta: no app e numa pagina web publica (exigencia da Play Store).
  Edge Function apaga fotos, linhas e o usuario do Auth. Avisa que a
  assinatura do Google Play precisa ser cancelada na loja.
- Sair da conta: as fichas continuam no aparelho; o estado de sync e apagado.
- Politica de privacidade e formulario de Seguranca de Dados atualizados
  antes do lancamento.

## Edge Functions

| Funcao | Papel |
| --- | --- |
| `revenuecat-webhook` | Valida o segredo do header, faz upsert em `entitlements` |
| `delete-account` | Exclusao completa da conta |
| `purge-expired` (pg_cron diario) | Apaga dados apos 90 dias e envia os avisos |

## Encaixe no app

- `CharacterRepository` continua a unica entrada de leitura e escrita. Um
  `CharacterSyncService` observa as gravacoes e conversa com o Supabase;
  telas nao chamam o Supabase diretamente.
- Providers novos: `authStateProvider`, `entitlementProvider`,
  `characterSyncStatusProvider(id)`.
- Lista de personagens: icone de estado por personagem e secao "Na nuvem".
- Configuracoes: conta, assinatura, "Sincronizar agora", excluir conta.

## Fases

1. Supabase, login e envio/download sem billing, atras de flag interna.
2. Estados, divergencia com as tres opcoes e fotos.
3. RevenueCat, webhook, paywall e RLS por direito.
4. Vencimento, avisos, exclusao de conta, privacidade e Seguranca de Dados.
5. Teste aberto na Play Store e lancamento da 3.1.0.

## Em aberto

- Personagens novos vao para a nuvem automaticamente ou so os marcados?
  Proposta: todos, com opcao de excluir um personagem da nuvem.
- Precos de Sync e Mestre e periodo de teste gratuito na Play Store.
- Limite de personagens/fotos por conta para controlar custo de storage.
