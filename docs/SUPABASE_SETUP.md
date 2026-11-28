# Configuracao do Supabase (Sync 3.1.0)

Passo a passo para criar o backend da sincronizacao descrita em
`docs/SYNC_SPEC.md`. O esquema do banco esta em
`supabase/migrations/20261128120000_character_sync.sql`.

## 1. Criar o projeto

1. Em https://supabase.com/dashboard, crie um projeto (o plano gratuito serve
   para os testes).
2. Regiao: a mais proxima da maioria dos jogadores. Para jogadores
   principalmente no Brasil, `South America (Sao Paulo)`.
3. Guarde a senha do banco no seu gerenciador de senhas. Ela nao vai para o
   app nem para o chat.

## 2. Dar acesso para aplicar a migracao

Escolha uma das opcoes:

- **Conector do Supabase no claude.ai (recomendado):** em claude.ai, abra
  Configuracoes > Conectores e autorize o Supabase. Assim consigo aplicar a
  migracao, conferir tabelas, politicas e logs.
- **CLI nesta maquina:** rode `supabase login` e depois
  `supabase link --project-ref <ref-do-projeto>` na pasta do projeto. O CLI
  guarda o token localmente; nao cole tokens no chat. Depois disso eu rodo
  `supabase db push`.

## 3. Chaves usadas pelo app

Copie `config/sync.example.json` para `config/sync.json` (ignorado pelo git)
e preencha:

- `SUPABASE_URL`: Project Settings > API > Project URL.
- `SUPABASE_ANON_KEY`: a chave publica (publishable ou anon).

O app roda com `--dart-define-from-file=config/sync.json`. Sem esse arquivo, o
app continua igual a hoje, sem conta e sem sync.

Nunca coloque a chave `service_role` / secret no app, no repositorio ou no
chat. Ela so sera usada nas Edge Functions (webhook de assinatura e exclusao
de conta), configurada direto no painel do Supabase.

## 4. Login com Google

No Google Cloud Console (pode ser o projeto ligado ao Play Console):

1. Configure a tela de consentimento OAuth (tipo externo, nome do app, e-mail
   de suporte).
2. Crie um cliente OAuth do tipo **Aplicativo da Web**. Anote o Client ID e o
   Client secret.
3. Crie clientes OAuth do tipo **Android** com o pacote
   `com.duartefrugoli.dnd_character_tool` e o SHA-1 de cada chave que assina o
   app:
   - chave de assinatura do Google Play: Play Console > Testar e lancar >
     Integridade do app > Assinatura de apps;
   - chave de upload (a mesma pagina);
   - chave de debug, para testes locais:
     `keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android`.

No Supabase, em Authentication > Sign In / Providers > Google:

1. Ative o provedor.
2. Informe o Client ID e o Client secret do cliente **Web**.
3. Em Client IDs autorizados, inclua tambem os Client IDs **Android**.

Em Authentication > Sign In / Providers > Email, desative o cadastro por
e-mail: o app so entra com Google (e Apple, quando houver iOS).

## 5. Direito de uso para testes

Enquanto a cobranca nao existe (fase 3), o acesso de escrita depende de uma
linha em `entitlements`. Depois do primeiro login pelo app, rode no SQL Editor,
trocando o e-mail:

```sql
insert into public.entitlements (user_id, entitlement, product_id)
select id, 'sync', 'internal_test'
from auth.users
where email = 'seu-email@exemplo.com'
on conflict (user_id, entitlement) do update
set expires_at = null, updated_at = now();
```

## 6. O que vem depois

Com o acesso liberado:

1. Aplicar e testar a migracao (RLS, `push_character`, `delete_character`,
   bucket `character-images`).
2. Implementar `CharacterSyncRemote` com `supabase_flutter`.
3. Login com Google no Android e o servico de sincronizacao, atras de
   `SYNC_ENABLED`.
4. Estados por personagem na lista e a tela de divergencia.

Billing (RevenueCat), vencimento, exclusao de conta e Seguranca de Dados ficam
para as fases 3 e 4 da especificacao.
