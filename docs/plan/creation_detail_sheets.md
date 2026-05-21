# Character Creation — Detail Sheets (Classes, Subclasses, Raças)

## Objetivo

Permitir que o jogador veja todas as features que uma classe, subclasse ou raça oferece
**sem sair da tela de criação**, reduzindo a necessidade de consultar o livro.

---

## Estado atual

| Card | Informação atual | O que falta |
|---|---|---|
| `_ClassCard` | Hit die, saves, spellcasting, nº subclasses | Features por nível, proficiências completas |
| Subclass card | Nome + descrição curta | Features por nível |
| `_RaceCard` | Velocidade, ASI | Traits com descrição |
| Subrace card | Nome, ASI | Traits com descrição |

Os dados já existem no SRD:
- Features de classe: `srd.getClassFeatures(className)` → `List<SrdClassFeature>` (já cacheado após 1ª chamada)
- Features de subclasse: `srd.getAllSubclassFeatures()` → `Map<String, Map<String, List<SrdClassFeature>>>` (já cacheado)
- Traits de raça: `srd.getRaceTraits()` → `Map<String, String>` (já cacheado)

O bottleneck é que nenhum desses dados está embutido nos models `SrdClass`, `SrdSubclass`,
`SrdRace` ou `SrdSubrace` — são carregados separadamente de forma assíncrona.

---

## Solução

Adicionar um **botão `Icons.info_outline`** no lado direito de cada card como área de toque
separada da seleção. Ao tocar, abre um bottom sheet com os detalhes.

O tap principal do card continua sendo **selecionar**. O botão de info é independente.

---

## Sheets a criar

### `_ClassDetailSheet`
Exibe:
- **Cabeçalho**: nome da classe, hit die, proficiências de armadura/arma
- **Saving throws**, **spellcasting ability** (se aplicável)
- **Features por nível** (níveis 1–20), agrupadas com `SliverStickyHeader`:
  - Cada feature como `ExpansionTile` (nome → descrição ao expandir)
  - Features de subclasse marcadas como placeholder "Subclass Feature" nos níveis corretos
- **Subclasses disponíveis** em seção no final (nomes, sem detalhe)

Carrega: `srd.getClassFeatures(className)` com `CircularProgressIndicator` enquanto aguarda.

### `_SubclassDetailSheet`
Exibe:
- **Cabeçalho**: nome da subclasse, nome da feature de subclasse da classe-pai
- **Descrição** da subclasse (já disponível em `SrdSubclass.description`)
- **Features por nível** filtradas para essa subclasse

Carrega: `srd.getAllSubclassFeatures()` — já cacheado se `StepClass` já carregou.

### `_RaceDetailSheet`
Exibe:
- **Cabeçalho**: nome da raça, velocidade, ASI
- **Traits** com nome e descrição (expandable)
- **Subraças disponíveis** em seção no final

Carrega: `srd.getRaceTraits()`.

### `_SubraceDetailSheet`
Exibe:
- **Cabeçalho**: nome da subraça, ASI
- **Traits** específicos da subraça com descrição

Carrega: `srd.getRaceTraits()` — mesmo map, já cacheado.

---

## Localização dos sheets

Todos os quatro sheets ficam em um único arquivo novo:

```
lib/shared/widgets/srd_detail_sheets.dart
```

Motivo: são widgets reutilizáveis — o level up wizard também vai precisar de
`_ClassDetailSheet` e `_SubclassDetailSheet` no passo de features.
Não usam `part of`, são widgets públicos normais.

---

## Mudanças em arquivos existentes

### `step_class.dart`
- `_ClassCard`: trocar o `Icon(Icons.check_circle)` atual por uma `Column` com o check +
  `IconButton(Icons.info_outline)` abaixo (quando não selecionado, apenas o info).
  O info abre `_ClassDetailSheet`.
- Subclass cards em `_SubclassSelector`: adicionar `IconButton(Icons.info_outline)` ao lado
  do nome, abre `_SubclassDetailSheet`.

### `step_race.dart`
- `_RaceCard`: mesmo padrão — info button abre `_RaceDetailSheet`.
- Subrace cards em `_SubraceSelector`: info button abre `_SubraceDetailSheet`.

---

## Layout do card com info button

```
┌──────────────────────────────────────────┐
│  Fighter                          [ℹ]   │
│  Hit Die: d10  ·  Saves: STR, CON  [✓]  │
│  Spellcasting: —                        │
└──────────────────────────────────────────┘
```

Quando selecionado, o `[✓]` aparece. O `[ℹ]` está sempre visível.
Ambos são `IconButton` dentro de uma `Column` à direita do `Expanded`.

---

## Layout do detail sheet (classe)

```
▬▬▬▬▬▬  (handle)
Fighter
d10  ·  STR/CON saves  ·  All armor, shields

─── Nível 1 ───────────────────────────────
  ▶ Fighting Style
  ▶ Second Wind

─── Nível 2 ───────────────────────────────
  ▶ Action Surge

─── Nível 3 ───────────────────────────────
  ▶ [Subclass Feature] Martial Archetype
  ▶ ...
```

Usa `CustomScrollView` + `SliverStickyHeader` (já dependência do projeto).
Features expandem inline com `AnimatedSize`.

---

## Strings novas (app_en.arb)

```json
"detailSheetSubclassFeaturePlaceholder": "Subclass Feature",
"detailSheetProficiencies": "Proficiencies",
"detailSheetTraits": "Traits",
"detailSheetSubclassesAvailable": "Available {feature}",
"detailSheetSubracesAvailable": "Subraces"
```

---

## Ordem de implementação

1. `lib/l10n/app_*.arb` — adicionar strings (10 locales) + `flutter gen-l10n`
2. `lib/shared/widgets/srd_detail_sheets.dart` — criar os 4 sheets
3. `lib/features/character_creation/steps/step_class.dart` — adicionar info buttons
4. `lib/features/character_creation/steps/step_race.dart` — adicionar info buttons
5. Validar com `get_errors`

---

## Fora do escopo desta tarefa

- Background detail sheet (background já mostra a feature diretamente no card de review)
- Reuso no level up wizard (será feito quando o wizard for implementado)
