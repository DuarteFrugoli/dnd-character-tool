# Auditoria de Código — DnD Character Tool

> Gerado após revisão completa do codebase. Cada item tem severidade, localização exata e recomendação de correção.

---

## Bugs / Erros de Correção

### B1 — `firstWhere` sem `orElse` pode lançar `StateError`
**Severidade:** Alta  
**Arquivo:** `lib/features/character_list/character_list_provider.dart` — linhas 105, 114  
**Métodos:** `rename()`, `updateImage()`

```dart
// Linha 105 (rename)
final character = current.firstWhere((c) => c.id == id);

// Linha 114 (updateImage)
final character = current.firstWhere((c) => c.id == id);
```

Ambos os métodos têm guard `if (current == null) return;` mas não verificam se o personagem com o `id` dado existe na lista. Se o personagem foi deletado entre o guard e o `firstWhere` (race condition), a chamada lança `StateError` não tratado, quebrando o provider.

**Fix:**
```dart
final character = current.firstWhereOrNull((c) => c.id == id);
if (character == null) return;
```
*(Requer `package:collection` ou extensão manual de `Iterable`.)*

---

### B2 — `'Unnamed Hero'` hard-coded em inglês na camada de dados
**Severidade:** Média  
**Arquivo:** `lib/features/character_detail/character_detail_provider.dart` — linha 163  
**Contexto:** Chamada via `updateName('')` quando o usuário limpa o nome

```dart
await _save(c.copyWith(name: trimmed.isEmpty ? 'Unnamed Hero' : trimmed));
```

O provider não tem acesso a `BuildContext`, então não pode usar `AppLocalizations`. A ARB key `reviewUnnamedHero` existe em todos os 10 idiomas mas não é usada aqui. Usuários em outros idiomas sempre verão o fallback em inglês.

**Fix (preferível):** O UI layer (`_StatsTab`) deve validar o nome vazio e passar o fallback localizado como argumento, ou expor um método `updateName(String name, {String fallback})`.

**Fix (alternativa simples):** Aceitar string vazia no provider e deixar o fallback ser tratado apenas na exibição.

---

### B3 — Strings hard-coded em `features_tab.dart` não internacionalizadas
**Severidade:** Média  
**Arquivo:** `lib/features/character_detail/tabs/features_tab.dart`

Múltiplos pontos com texto fixo em português ou inglês:

| Linha | String | Idioma | ARB key disponível? |
|-------|--------|--------|---------------------|
| 218 | `'Habilitar'` / `'Desabilitar'` (tooltip do `_FeatureToggleButton`) | Português | Não |
| 506, 674, 778, 1023 | `'Nível ${f.level}'` | Português | Sim — `charCardLevel` |
| 597, 601 | `'Subclass'` / `'ASI'` em `_typeLabel()` | Inglês | Sim — `labelSubclass`, `stepRaceASILabel` |
| 819 | `['Classe', 'Subclasse', 'Racial', 'Background', 'Custom']` (tab labels de `_AddFeatureSheet`) | Português | Não |
| 1366 | `'Custom'` passado como `sourceClass` | Inglês | — |

**Fix para `_typeLabel()`** (linhas 587–601 e 989–1003):
```dart
case 'subclass':
  return l10n.labelSubclass;   // já existe em todos os 10 idiomas
case 'asi':
  return l10n.stepRaceASILabel; // já existe em todos os 10 idiomas
```

**Fix para `'Nível ${f.level}'`:** Usar `l10n.charCardLevel(f.level)` (ARB key `charCardLevel` com placeholder `{level}` já existe).

**Fix para tooltip e tab labels:** Adicionar as ARB keys correspondentes e usá-las via `l10n`.

---

### B4 — Mensagens de erro de importação hard-coded em português
**Severidade:** Média  
**Arquivo:** `lib/data/datasources/local/character_local_data_source.dart` — linhas 97, 101, 111  
**Exibido em:** `character_list_screen.dart` via `ScaffoldMessenger` (usa `e.message` direto)

```dart
throw const FormatException('O texto colado não é um JSON válido.');
throw const FormatException('Formato inválido: esperado um objeto JSON.');
throw const FormatException('JSON inválido: campo "character" corrompido.');
```

Essas mensagens chegam ao usuário via `on FormatException catch (e)` no `character_list_screen.dart` (linha 43), que as exibe com `e.message`. Como a camada de dados não tem acesso a `BuildContext`, elas são sempre em português.

**Fix:** Criar uma exceção tipada (`ImportException`) no lugar de `FormatException`, e tratá-la na UI com mensagens i18n, usando a `message` apenas como código de erro para logging.

---

## Ineficiências

### I1 — `ref.invalidate(characterListProvider)` em todo save da tela de detalhes
**Severidade:** Alta (performance)  
**Arquivo:** `lib/features/character_detail/character_detail_provider.dart` — linha 27

```dart
Future<void> _save(Character updated) async {
  final saved = await ref.read(characterRepositoryProvider).save(updated);
  state = AsyncData(saved);
  ref.invalidate(characterListProvider);  // ← força reload de TODOS os personagens do disco
}
```

`_save()` é chamado em **toda** operação: ajuste de HP, uso de slot de magia, toggle de spell preparada, long rest, etc. Cada uma dessas ações força o `characterListProvider` a reler todos os arquivos JSON do disco.

**Fix:** Em vez de invalidar, atualizar o estado da lista em-place, da mesma forma que `rename()` e `updateImage()` já fazem em `character_list_provider.dart`:
```dart
// No detail provider, após salvar:
final listNotifier = ref.read(characterListProvider.notifier);
listNotifier.updateSingle(saved); // método a ser adicionado no list provider
```

---

### I2 — `importCharacter` usa `refresh()` para adicionar um personagem
**Severidade:** Baixa  
**Arquivo:** `lib/features/character_list/character_list_provider.dart`

```dart
Future<Character> importCharacter(String jsonString) async {
  final character = await ref.read(characterRepositoryProvider).importFromJson(jsonString);
  await refresh();   // ← reload completo do disco
  return character;
}
```

Após importar um único personagem, o provider faz reload completo de todos os personagens do disco. Deveria adicionar o personagem diretamente ao estado:
```dart
state = AsyncData([character, ...current]);
```

---

### I3 — `_FeaturesTab._load()` não é re-executado quando subclasse muda
**Severidade:** Média  
**Arquivo:** `lib/features/character_detail/tabs/features_tab.dart`

`_future` é calculado em `initState` e nunca atualizado. Se o usuário muda a subclasse do personagem no modo de edição (que é possível via `_StatsTab`), a aba de Features continua mostrando as features da subclasse anterior até o widget ser reconstruído do zero.

**Fix:** Adicionar `didUpdateWidget`:
```dart
@override
void didUpdateWidget(_FeaturesTab old) {
  super.didUpdateWidget(old);
  if (widget.character.characterClass != old.character.characterClass ||
      widget.character.subclass != old.character.subclass ||
      widget.character.level != old.character.level) {
    _future = _load();
  }
}
```

---

### I4 — `_typeLabel()` duplicada em `features_tab.dart`
**Severidade:** Baixa  
**Arquivo:** `lib/features/character_detail/tabs/features_tab.dart` — linhas 587 e 989

O método `_typeLabel(String type, BuildContext context)` é implementado de forma idêntica em duas classes diferentes (`_ClassFeaturesSection` e `_AddFeatureSheetState`). Além de ser duplicação, ambas têm o mesmo bug do B3 (hard-coded `'Subclass'` e `'ASI'`).

**Fix:** Extrair para uma função top-level ou helper e corrigir os valores hard-coded conforme B3.

---

### I5 — Acesso direto a `SrdDataSource.instance` fora do Riverpod
**Severidade:** Baixa  
**Arquivos:**
- `features_tab.dart` — linha 29
- `stats_tab.dart` — linha 275
- `character_detail_provider.dart` — linha 128
- `spell_browser_sheet.dart` — linha 145
- Steps de criação: `step_class.dart`, `step_race.dart`, `step_background.dart`, `step_skills.dart`

Esses locais usam `SrdDataSource.instance` diretamente em vez do `srdDataSourceProvider`. Funcionalmente equivalente (singleton), mas:
- Inconsistente com o padrão do projeto
- Impede substituição por mock em testes
- O Riverpod não conhece essas dependências

**Fix:** Substituir chamadas diretas por `ref.read(srdDataSourceProvider).getXxx()`.

---

## Problemas Estruturais

### S1 — Camada de dados produz strings visíveis ao usuário
**Severity:** Média  
**Arquivo:** `character_local_data_source.dart` (importFromJson)

A camada de dados não deveria produzir strings exibidas ao usuário. As mensagens de erro de importação devem ser geradas na UI layer com suporte a i18n. Ver B4.

---

### S2 — `'Custom'` como string mágica para sourceClass de features extras
**Severidade:** Baixa  
**Arquivo:** `features_tab.dart` — linha 1366

```dart
await notifier.addExtraFeature(f, 'Custom');
```

A string `'Custom'` é persistida em JSON como `character.extraFeatures[].sourceClass`. Não há validação, constante definida ou enum. Se mudar o valor em algum lugar, dados existentes ficam incompatíveis.

**Fix:** Definir uma constante `const kCustomSourceClass = 'Custom';` ou adicionar ao enum se existir algum.

---

### S3 — `characterDetailProvider._save()` sempre invalida a lista, criando acoplamento implícito
**Severidade:** Informativa  
**Ver:** I1

O detail provider depende de invalidar o list provider após cada save. Isso cria acoplamento indireto: o detalhe conhece a existência da lista. Uma abordagem mais limpa seria o list provider observar o detail provider via `ref.listen` ou o detail provider notificar a lista de forma explícita.

---

## Resumo

| ID | Tipo | Severidade | Arquivo Principal |
|----|------|------------|-------------------|
| B1 | Bug | Alta | `character_list_provider.dart` |
| B2 | Bug | Média | `character_detail_provider.dart` |
| B3 | Bug | Média | `features_tab.dart` |
| B4 | Bug | Média | `character_local_data_source.dart` |
| I1 | Ineficiência | Alta | `character_detail_provider.dart` |
| I2 | Ineficiência | Baixa | `character_list_provider.dart` |
| I3 | Ineficiência | Média | `features_tab.dart` |
| I4 | Ineficiência | Baixa | `features_tab.dart` |
| I5 | Ineficiência | Baixa | múltiplos |
| S1 | Estrutural | Média | `character_local_data_source.dart` |
| S2 | Estrutural | Baixa | `features_tab.dart` |
| S3 | Estrutural | Informativa | `character_detail_provider.dart` |
