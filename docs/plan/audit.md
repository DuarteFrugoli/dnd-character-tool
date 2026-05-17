# Auditoria de Código - DnD Character Tool

> Revisão geral do codebase no estado atual. Itens antigos já resolvidos foram removidos. Os achados abaixo foram mantidos apenas quando havia evidência direta no código.

---

## Estruturas atuais do projeto

- **Aplicação Flutter por features:** `lib/features` agrupa fluxos de criação, lista, detalhe, home e export/import; `lib/core` contém router, tema, locale e utilitários; `lib/shared` concentra providers/widgets compartilhados.
- **Estado com Riverpod:** uso de `NotifierProvider`, `AsyncNotifierProvider`, `AsyncNotifierProvider.family`, `FutureProvider` e `ConsumerWidget`/`ConsumerStatefulWidget`.
- **Navegação com GoRouter:** rotas centralizadas em `lib/core/router/app_router.dart`.
- **Persistência em camadas:** `CharacterRepository` -> `CharacterLocalDataSource` -> `StorageBackend` condicional. Nativo usa JSON em arquivos via `path_provider`; web usa `shared_preferences`.
- **Modelos serializáveis:** modelos Dart com `json_annotation`/`json_serializable` e arquivos `.g.dart`, além de alguns modelos manuais para campos específicos.
- **Dados SRD em assets:** `SrdDataSource` lê JSONs de `assets/data/srd`, com cache em memória e exposição via `srdDataSourceProvider`.
- **Internacionalização híbrida:** UI principal usa ARB/gen-l10n (`AppLocalizations`); nomes/descrições do SRD usam overlays JSON via `SrdI18nService`.
- **UI de detalhe por `part` files:** `character_detail_screen.dart` agrega abas em arquivos `part`, mantendo widgets privados dentro do mesmo library scope.

---

## Bugs / Erros de correção

### B1 - ID importado é usado como caminho de arquivo sem validação
**Severidade:** Alta  
**Arquivos:** `lib/data/repositories/character_repository.dart:71`, `lib/data/datasources/local/storage_backend_native.dart:79`

`importFromJson()` preserva o `id` do JSON importado quando não existe colisão local. No backend nativo, `_fileForId()` interpola esse `id` diretamente em `${dir.path}/$id.json`.

Impacto:
- Um JSON/token importado com `id` contendo separadores de caminho pode gravar fora da pasta `characters`.
- IDs com caracteres inválidos para o sistema de arquivos podem quebrar save/load/delete.
- A validação depende da origem do JSON, mas import é uma fronteira externa.

**Correção recomendada:** gerar um novo `Uuid().v4()` para todo import, ou validar o `id` com uma allowlist rígida antes de qualquer acesso ao storage. Mesmo com validação no repository, `_fileForId()` também deveria recusar ids fora do padrão.

---

### B2 - Foto do personagem ignora o fluxo persistente de imagens no nativo
**Severidade:** Alta  
**Arquivos:** `lib/shared/widgets/character_avatar.dart:45`, `lib/features/character_list/character_list_provider.dart:119`, `lib/data/repositories/character_repository.dart:46`, `lib/data/datasources/local/storage_backend_native.dart:87`

No nativo, o cropper retorna `cropped.path` e o list provider salva esse caminho diretamente em `character.imagePath`. O repository já tem `saveImage()` e `resolveImagePath()`, mas esse fluxo não é usado.

Impacto:
- A imagem pode ficar apontando para cache/temporário do picker/cropper e sumir depois.
- `delete()` chama `deleteImage(character.imagePath)`, mas o backend espera um nome de arquivo dentro da pasta `images`, não um caminho absoluto.
- O app tem dois contratos conflitantes: `imagePath` ora é caminho absoluto/data URL, ora deveria ser nome de arquivo persistido.

**Correção recomendada:** centralizar alterações de foto no repository. Em nativo, copiar a imagem para `images/` e salvar só o `fileName`; na UI, resolver o caminho com `resolveImagePath()`. Em web, manter data URL ou criar um contrato explícito separado.

---

### B3 - `SpellSlots` aceita listas inválidas e pode lançar `RangeError`
**Severidade:** Alta  
**Arquivos:** `lib/data/models/spell.dart:11`, `lib/features/character_detail/character_detail_provider.dart:69`, `lib/features/character_detail/tabs/spells_tab.dart:238`

`SpellSlots.fromJson()` aceita `total` e `used` como vierem do JSON. Depois, o app acessa índices `level - 1` assumindo exatamente 9 posições.

Impacto:
- Personagens antigos, importados ou corrompidos com listas menores quebram uso/restauração de slots e renderização da aba de magias.
- `_applySlotSync()` também usa `c.spellSlots.used[i]` em loop de 9 posições.

**Correção recomendada:** normalizar `SpellSlots` na desserialização ou no construtor: padding/truncate para 9 posições, valores não negativos e `used <= total`. Também vale proteger `useSpellSlot()`/`restoreSpellSlot()` contra níveis fora de `1..9`.

---

### B4 - Criação ainda salva fallback de nome em inglês e não trata whitespace
**Severidade:** Média  
**Arquivo:** `lib/features/character_creation/character_draft_provider.dart:596`

Na criação guiada, o personagem é salvo com:

```dart
name: draft.name.isEmpty ? 'Unnamed Hero' : draft.name,
```

Impacto:
- O review mostra `reviewUnnamedHero` localizado, mas o dado persistido usa inglês.
- Um nome com apenas espaços não cai no fallback, porque não há `trim()`.

**Correção recomendada:** salvar `draft.name.trim()` e receber o fallback localizado da UI, ou persistir string vazia e aplicar fallback apenas na apresentação.

---

### B5 - Review mostra CA com armadura, mas o personagem é salvo sem equipamento vestido
**Severidade:** Média  
**Arquivos:** `lib/features/character_creation/steps/step_review.dart:30`, `lib/features/character_creation/character_draft_provider.dart:572`, `lib/features/character_creation/character_draft_provider.dart:619`

O review calcula e exibe uma CA potencial com armadura inicial (`_findArmorAC`). Porém, na criação, todos os `EquipmentItem` entram sem `isEquipped`, e `armorClass` é salvo como `10 + DEX`.

Impacto:
- O usuário pode concluir a criação vendo uma CA com armadura, mas abrir a ficha com CA desarmada.
- Shields/armaduras iniciais precisam ser equipados manualmente depois, mesmo quando vieram do equipamento inicial.

**Correção recomendada:** decidir uma regra única. Ou equipar automaticamente uma armadura corporal e shield iniciais e salvar a CA correspondente, ou deixar claro no review que a CA exibida é apenas potencial.

---

## Ineficiências

### I1 - Carregamento de equipamentos SRD pode parsear o mesmo JSON em paralelo
**Severidade:** Média  
**Arquivos:** `lib/data/datasources/srd/srd_data_source.dart:126`, `lib/data/datasources/srd/srd_data_source.dart:296`, `lib/features/character_detail/tabs/inventory_tab.dart:459`

`getWeapons()`, `getArmors()` e `getGear()` chamam `_loadEquipment()`. Na sheet de inventário, os três são disparados juntos em `Future.wait()`. Como `_loadEquipment()` só cacheia depois de terminar, chamadas simultâneas podem carregar/parsear `equipment.json` mais de uma vez.

**Correção recomendada:** adicionar `Future<void>? _equipmentLoadFuture` e reutilizar a mesma future enquanto o primeiro load estiver em andamento. Outra opção é expor um método combinado para retornar weapons/armors/gear de uma vez.

---

### I2 - Finalizar criação invalida a lista inteira após salvar um personagem
**Severidade:** Baixa  
**Arquivo:** `lib/features/character_creation/character_creation_screen.dart:175`

Depois de `buildAndSave()`, a tela chama `ref.invalidate(characterListProvider)`. Isso força reload completo da lista, embora apenas um personagem novo tenha sido salvo. O list provider já tem `updateSingle()`, usado no import e no detalhe.

**Correção recomendada:** usar o `Character` retornado por `buildAndSave()` e chamar `characterListProvider.notifier.updateSingle(created)` quando o provider existir.

---

### I3 - Buscas em telas localizadas filtram apenas texto fonte em inglês
**Severidade:** Média  
**Arquivos:** `lib/features/character_detail/spell_browser_sheet.dart:161`, `lib/features/character_detail/tabs/features_tab.dart:1156`

O browser de magias exibe nomes localizados com `i18n.spellName()`, mas filtra só por `s.name`. A sheet de adicionar features também filtra por `f.name`, `description`, `subName` e `bg.name`, enquanto a UI pode mostrar nomes/descrições traduzidas.

Impacto:
- Em idiomas diferentes de inglês, o usuário digita o termo visível na tela e não encontra o item.
- A experiência fica inconsistente com o inventário, que já compara texto traduzido e texto original.

**Correção recomendada:** montar o texto de busca com nome/descrição original e localizado, normalizado uma vez por item.

---

## Problemas estruturais

### S1 - Internacionalização ainda está incompleta em fluxos importantes
**Severidade:** Média  
**Arquivos:** `lib/features/character_list/character_list_screen.dart:368`, `lib/features/character_detail/spell_browser_sheet.dart:313`, `lib/shared/widgets/character_avatar.dart:17`, `lib/features/character_detail/tabs/features_tab.dart:1501`, `lib/features/character_creation/steps/step_review.dart:1043`

Há várias strings visíveis ao usuário fora de `AppLocalizations`, especialmente em export/import, QR, browser de magias, avatar, feature customizada e escolhas de idioma.

Exemplos atuais:
- `Export`, `Token`, `Copy token`, `Show QR Code`, `Import Character`, `Scan QR Code`
- `Browse Spells`, `Filters`, `No spells match the current filters.`, `Remove spell`
- `Choose photo`, `Remove photo`, `Crop photo`, `Alterar foto`
- `${f.name} adicionada!`, `Adicionar Feature`
- `Language Choices`, `Type a language...`

**Correção recomendada:** mover textos para ARB e manter SRD/i18n de domínio em `SrdI18nService`. Também vale adicionar uma regra de revisão para impedir novos `Text('...')` hard-coded em telas localizadas.

---

### S2 - Strings mágicas persistidas ainda representam conceitos de domínio
**Severidade:** Baixa  
**Arquivos:** `lib/features/character_detail/tabs/features_tab.dart:1495`, `lib/features/character_creation/character_draft_provider.dart:46`

Ainda existem valores como `'Custom'`, categorias de item (`'weapon'`, `'armor'`, `'adventuring gear'`) e features textuais (`'Tool Proficiency: $t'`) usados como contrato entre UI, modelo e persistência.

Impacto:
- Alterar uma string quebra dados existentes ou filtros.
- Fica difícil distinguir texto de exibição de identificador interno.

**Correção recomendada:** extrair constantes/enum/value objects para identificadores persistidos e traduzir só na borda de UI.

---

### S3 - Não há testes automatizados no workspace
**Severidade:** Média  
**Evidência:** `rg --files -g "*_test.dart"` não encontrou arquivos.

O projeto tem lógica sensível em import/export, storage, slots de magia, criação de equipamento e i18n. Sem testes, regressões nesses fluxos tendem a aparecer só manualmente.

**Correção recomendada:** começar por testes unitários de baixo custo:
- normalização de `SpellSlots`;
- import/export com ids inválidos e colisão;
- criação guiada com armadura/shield;
- busca localizada em magias/features;
- parsing de equipamentos iniciais.

---

### S4 - Arquivos de UI acumulam muita lógica de domínio e estado local
**Severidade:** Informativa  
**Arquivos:** `features_tab.dart` (~1682 linhas), `spell_browser_sheet.dart` (~1210 linhas), `step_review.dart` (~1115 linhas), `character_list_screen.dart` (~740 linhas)

Esses arquivos misturam renderização, filtros, parsing, regras de domínio e ações de persistência. Isso não é um bug imediato, mas aumenta custo de manutenção e facilita inconsistências como busca localizada, textos hard-coded e regras duplicadas.

**Correção recomendada:** extrair view models/helpers testáveis para filtros, normalização de busca, cálculo/equipamento inicial, contratos de import/export e ações de foto.

---

## Resumo

| ID | Tipo | Severidade | Área principal |
|----|------|------------|----------------|
| B1 | Bug | Alta | Import/storage |
| B2 | Bug | Alta | Fotos/avatar |
| B3 | Bug | Alta | Spell slots |
| B4 | Bug | Média | Criação/i18n |
| B5 | Bug | Média | Criação/equipamento |
| I1 | Ineficiência | Média | SRD/equipment |
| I2 | Ineficiência | Baixa | Criação/lista |
| I3 | Ineficiência/UX | Média | Busca localizada |
| S1 | Estrutural | Média | i18n |
| S2 | Estrutural | Baixa | Contratos de domínio |
| S3 | Estrutural | Média | Testes |
| S4 | Estrutural | Informativa | Organização de UI |
