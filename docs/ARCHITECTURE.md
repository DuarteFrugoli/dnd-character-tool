# Technical Architecture - DnD Character Tool

This document describes how the app is structured today: runtime boot,
state management, persistence, SRD data loading, feature boundaries, and the
main domain rules. It is meant to be the first technical reference for anyone
changing the project.

---

## Stack

| Layer | Technology |
| --- | --- |
| App framework | Flutter 3.x / Dart 3.x |
| State management | Riverpod 2 (`flutter_riverpod`) |
| Navigation | GoRouter |
| Local persistence | JSON files on native platforms; IndexedDB on web |
| Serialization | `json_serializable` generated `*.g.dart` files |
| UI i18n | Flutter `gen-l10n` from ARB files |
| SRD i18n | Custom JSON overlay service (`SrdI18nService`) |
| Import/export | `.dndchar` and `.dndbackup` JSON payloads, `file_picker`, `share_plus`, platform channels |
| Images | `image_picker`, `image_cropper`, platform-specific storage/export helpers |

---

## Runtime Boot

The app starts in `lib/main.dart`.

1. Flutter bindings are initialized.
2. `IncomingFileService.instance.initialize()` wires the platform channel used
   when Android/iOS opens a `.dndchar` file from outside the app.
3. `SharedPreferences` is read before the first frame.
4. Theme, locale, and unit-system providers are overridden in `ProviderScope`
   with their persisted initial state, avoiding a flash of default UI.
5. `MaterialApp.router` uses `appRouter`, generated localizations, and the
   currently selected theme/locale.

---

## Project Structure

```text
lib/
  core/
    locale/       Locale provider and persistence
    platform/     Conditional platform helpers for web/native behavior
    router/       GoRouter route table
    services/     Platform-channel services, e.g. incoming .dndchar files
    theme/        Theme presets and ThemeNotifier
    units/        Unit-system provider and formatting helpers
    utils/        Platform-aware file export helpers
  data/
    constants/    Domain rules derived from D&D 5e/SRD (AC, level up)
    datasources/
      local/      Character storage facade and platform backends
      srd/        SRD asset readers, SRD models, SRD i18n service
    inventory/    Pure inventory mutation helpers
    migrations/   Versioned character migrations
    models/       Persisted domain models and generated JSON serializers
    repositories/ CharacterRepository facade
    feature_choice_engine.dart
    feature_choice_option_resolver.dart
    feature_usage_engine.dart
    spellcasting_engine.dart
  features/
    character_creation/
    character_detail/
      application/  Per-tab view models and derived providers
      inventory/    Inventory snapshot/search view models
      tabs/         Main tab entry widgets
      widgets/      Detail widgets, feature sheets, inventory sheets, spell widgets
    character_list/
    export_import/      Reserved feature folder; import/export UI currently lives in character_list
    home/
  l10n/           ARB files and generated AppLocalizations classes
  shared/
    providers/    App-wide Riverpod providers
    widgets/      Shared widgets and SRD detail sheets

assets/
  data/
    srd/          Canonical English SRD/game data JSON
    i18n/         Per-locale translation overlays for SRD data

tools/            Translation/patch scripts for data assets
docs/             Project documentation
```

The dependency direction is intentionally simple:

```text
UI widgets -> Riverpod providers/notifiers -> Repository -> DataSource -> disk/assets
```

Widgets should not read or write disk directly. They call notifiers/providers,
which centralize domain updates and persistence.

---

## Core Providers

Shared providers live mostly in `lib/shared/providers/providers.dart`.

| Provider | Responsibility |
| --- | --- |
| `characterRepositoryProvider` | Creates the `CharacterRepository` facade. |
| `srdDataSourceProvider` | Exposes the singleton `SrdDataSource`. |
| `srdItemsProvider` | Loads the normalized item lookup used by creation/inventory. |
| `srdI18nProvider` | Loads SRD translation overlays for the active locale. |
| `srdConditionsProvider` | Loads raw condition names/descriptions from SRD assets. |
| `themeProvider` | Persists and exposes the active app theme. |
| `localeProvider` | Persists and exposes the active UI locale. |
| `unitSystemProvider` | Persists and exposes Imperial, Metric, or Squares display mode. |

Feature-specific providers:

| Provider | File | Responsibility |
| --- | --- | --- |
| `characterListProvider` | `features/character_list/character_list_provider.dart` | Loads, sorts, pins, reorders, imports, exports, renames, deletes, and updates characters in the list. |
| `characterDetailProvider(id)` | `features/character_detail/character_detail_provider.dart` | Owns all editing operations for one character, with optimistic state updates before persistence. |
| `characterDraftProvider` | `features/character_creation/character_draft_provider.dart` | Holds in-progress creation choices and builds/saves the final `Character`. |

`characterDetailProvider(id)` listens to `characterListProvider` so image and
list-level updates can propagate to an already-open detail screen.

The detail screen also uses per-tab view model providers from
`features/character_detail/application/`. These providers select only the
fields needed by each tab before building expensive snapshots or widgets. This
keeps unrelated edits, such as note changes or inventory changes, from forcing
every tab to rebuild against the full `Character` object.

---

## Persistence

`CharacterRepository` is the single public access point for character storage.
It delegates to `CharacterLocalDataSource`, which delegates to a platform
backend selected through conditional imports:

```dart
import 'storage_backend_stub.dart'
    if (dart.library.io) 'storage_backend_native.dart'
    if (dart.library.js_interop) 'storage_backend_web.dart';
```

### Native platforms

`NativeStorageBackend` stores character JSON files under:

```text
ApplicationDocumentsDirectory/dnd_character_tool/characters/<id>.json
```

Images are copied to:

```text
ApplicationDocumentsDirectory/dnd_character_tool/images/
```

Image paths are stored in `Character.imagePath`. The native backend validates
character IDs before creating file paths to prevent path traversal from crafted
imports.

### Web

`WebStorageBackend` stores character JSON in IndexedDB under the `characters`
object store. Character images are stored separately in the `images` object
store, and `Character.imagePath` keeps an `indexeddb:image:<id>` reference.

When exporting `.dndchar` or `.dndbackup`, the data source resolves those image
references and embeds `imageData` plus `imageMimeType` in the exported file.
When importing on web, embedded image data is written back to IndexedDB and the
character receives a new local image reference.

### Repository rules

`CharacterRepository.save()` updates `updatedAt` before writing. Imports always
receive a new generated ID before persistence, which avoids ID conflicts and
prevents imported files from controlling local paths.

`CharacterRepository` also owns character maintenance entry points:

- `previewMigrations()` loads all characters and returns a report without
  writing changes.
- `applyMigrations()` applies all pending migrations and saves only outdated
  characters.
- `exportBackupToFileJson()` exports all characters as `.dndbackup`.
- `importBackupFromFileJson()` imports every character from a `.dndbackup`,
  assigning new IDs just like single-character imports.

The repository does not create the pre-migration backup itself. The Settings UI
exports `.dndbackup` first, then calls `applyMigrations()` after user
confirmation.

---

## Character Migrations

Versioned migrations live in `lib/data/migrations/`.

`Character.dataVersion` stores the last data version applied to each character.
`currentCharacterDataVersion` in `character.dart` is the version assigned to new
characters. The migration runner sorts migrations by `targetVersion`, skips
anything already applied, and always bumps the character to the migration target
version even when the data itself did not need a change.

Current migrations:

| Version | Migration | Purpose |
| --- | --- | --- |
| 1 | `BackfillEquipmentWeightsMigration` | Fills weights for known inventory items that were saved with `0`. |
| 2 | `NormalizeEquipmentItemsMigration` | Updates known items with current type, category, weight, and SRD properties. |
| 3 | `ExpandEquipmentPacksMigration` | Replaces known starting equipment packs with their individual contents. |
| 4 | `NormalizeNoteOrderMigration` | Assigns explicit `sortOrder` values to old notes while preserving their saved order. |
| 5 | `NormalizeEquipmentOrderMigration` | Assigns explicit per-location `sortOrder` values to inventory items and repairs invalid container locations. |

Migrations are intentionally user-triggered from Settings maintenance. They are
not applied invisibly while merely opening a character. Before applying
migrations, the Settings UI exports a `.dndbackup`, then shows a report of what
changed per character.

When adding a persisted field:

1. Give old JSON a safe default in `fromJson`/generated serializers.
2. Add a migration only when old saved data needs to be transformed.
3. Add a localized maintenance report string when users should be told about the
   change.
4. Bump `currentCharacterDataVersion` only when a new migration is added.

---

## Domain Models

Persisted models live in `lib/data/models/`.

Key models:

| Model | Purpose |
| --- | --- |
| `Character` | Root saved object: identity, class/race, stats, HP, AC, equipment, spells, notes, features, settings. |
| `AbilityScores` | Six ability scores and modifiers. |
| `HitPoints` | Current/max/temp HP, hit dice usage, death saves, stabilized/dead state. |
| `EquipmentItem` | Inventory item with mechanical `ItemType`, quantity, weight, equip state, optional `containerId`, and type-specific `properties`. |
| `KnownSpell`, `SpellSlots`, `InnateSpell` | Spell list, slot usage, and innate spell tracking. |
| `CharacterExtraFeature` | Manually added class/subclass/feat/custom feature. |
| `CharacterFeatureChoice` | Persisted option IDs selected for class features, subclass features, racial traits, and feats. |
| `CharacterNote` | Player notes with text, colored tags, pin state, and explicit per-group `sortOrder`. |
| `CharacterAppearance`, `CharacterPersonality` | Detail-screen supporting data for identity and appearance. |

Most models use `@JsonSerializable`. Some older/simple models use manual JSON
methods. New persisted fields should provide a default fallback in generated or
manual `fromJson` code to keep old character files readable.

Important persisted fields on `Character`:

| Field | Purpose |
| --- | --- |
| `dataVersion` | Character data schema/version used by the migration runner. New characters default to `currentCharacterDataVersion`. |
| `featureChoices` | Stable choices made inside feature/trait/feat rules. Values are option IDs from SRD data, not localized labels. |
| `featureResources` | Remaining uses/points for trackable feature resources, keyed by resource ID. Missing values mean "full". |
| `imagePath` | Native file name/path or web image reference such as `indexeddb:image:<id>`. Export formats embed image bytes separately. |
| `sortOrder` | Character-list order inside the pinned or unpinned group. |

`domain_constants.dart` stores string constants that are part of persisted JSON
contracts. Do not rename those values without a migration.

---

## Item Model And Inventory

Inventory behavior is driven by `EquipmentItem.itemType`, not only by the
human-readable category.

Current item types:

```dart
weapon, armor, consumable, ammunition, equippable, container, gear
```

Important conventions:

- `armor` items can affect AC when equipped. Body armor and shields are
  distinguished by `properties['isShield']`.
- `equippable` is for wearable/usable items that are not armor, such as rings,
  cloaks, necklaces, or other magical/custom equipment.
- `container` items can hold other non-container items through
  `EquipmentItem.containerId`. Containers cannot currently be stored inside
  other containers.
- `ammunition` is handled separately in the inventory UI.
- Custom item creation in `inventory_tab.dart` shows different inputs per
  `ItemType` and stores type-specific values in `properties`.
- SRD equipment packs can define `contents`. Character creation expands known
  packs into their individual items. Migrations can also expand old characters
  that still have pack items saved as a single inventory entry.
- Removing a container with contents asks the user whether to move contents back
  to the main inventory, delete everything, or cancel.

Equipment changes that can affect AC call `calcArmorClass`. Body armor is
exclusive: equipping a new body armor unequips/merges the previous one.

Inventory state is intentionally kept as a flat `List<EquipmentItem>` on the
character. Container membership is represented by `containerId`, and visual
order is represented by `sortOrder` within each location:

- root inventory: `containerId == null`;
- container contents: `containerId == container.id`;
- equipped items are treated as root items even if old data contains a
  `containerId`.

Pure inventory mutations live in `data/inventory/inventory_operations.dart`.
The provider delegates add/remove/equip/move/reorder/quantity operations to
those helpers so the rules can be unit-tested without Riverpod or UI widgets.

The detail UI builds an `InventorySnapshot` from the flat equipment list. The
snapshot indexes items, root sections, containers, contents, ammunition,
equipped items, carried items, and total weight in one place. This keeps
`inventory_tab.dart` focused on rendering.

The inventory UI is split by responsibility:

- `tabs/inventory_tab.dart` orchestrates the tab, sections, FAB, and shared
  inventory tile behavior.
- `widgets/inventory/add_item_sheet.dart` owns the add/custom-item flow.
- `widgets/inventory/container_contents_sheet.dart` shows items inside one
  container in a dedicated bottom sheet.
- `widgets/inventory/item_detail_sheet.dart` shows item descriptions and
  mechanical attributes.
- `inventory/inventory_view_model.dart` owns `InventorySnapshot`.
- `inventory/inventory_search_catalog.dart` owns the cached SRD search index.

Container contents intentionally open in a bottom sheet instead of expanding as
a nested reorderable list inside the main inventory list. That keeps the main
tab lighter and avoids building every stored item before the user asks for a
specific container.

Adding existing SRD items uses `SrdInventorySearchCatalog`, a cached search
index that combines weapons, armor, adventuring gear, magic items, and tools.
When the search field is empty, the UI can still show category tabs; when a
query is present, it uses one global result list.

---

## Derived Rules

Rules that should not live in widgets are centralized under `lib/data/`.

### Armor Class

`data/constants/armor_class.dart` is the source of truth for AC:

- Body armor sets the base AC from item properties.
- Shield adds its AC bonus.
- Without body armor, `calcUnarmoredArmorClass` applies Unarmored Defense:
  - Barbarian: `10 + DEX + CON`, shield allowed.
  - Monk: `10 + DEX + WIS`, shield not allowed.
- Extra features can enable Unarmored Defense for multiclass/manual cases.
- Disabling `Unarmored Defense` removes that calculation.

Creation, level changes, ASI/stat changes, feature changes, and equipment
changes should all recalculate AC through this helper.

### Level Up

`data/constants/level_up_rules.dart` owns:

- XP thresholds.
- Subclass unlock levels.
- ASI levels by class.
- Hit die by class.
- `LevelUpResult`, the data object returned by the level-up wizard.

`features/character_detail/level_up_wizard.dart` builds the level-up flow:

- features summary;
- subclass selection when needed;
- ASI or feat;
- HP gain;
- cantrip/spell selection;
- Warlock spell swap;
- summary/confirm.

The wizard sends a `LevelUpResult` to `CharacterDetailNotifier.levelUp`, which
applies all decisions atomically and syncs spell slots, XP, AC, and innate
spells as needed.

### Spellcasting

`data/spellcasting_engine.dart` centralizes spellcasting math:

- spellcasting ability;
- save DC and spell attack;
- prepared spell limits;
- known spell limits;
- cantrip limits;
- slot tables for full, half, pact, and third casters;
- Wizard-list subclass behavior for Eldritch Knight and Arcane Trickster.

Eldritch Knight and Arcane Trickster are modeled as third casters with
`spellListClass == 'wizard'`, plus school restrictions:

- Eldritch Knight: abjuration/evocation.
- Arcane Trickster: enchantment/illusion and fixed `Mage Hand`.
- Levels 8, 14, and 20 allow an unrestricted school pick.

UI code should ask `SpellcastingEngine` for limits and spell-list class instead
of duplicating tables.

### Feature Choices

`data/feature_choice_engine.dart` turns SRD feature-choice definitions into
runtime requests for the creation wizard, level-up wizard, and Features tab.

The canonical data lives in:

```text
assets/data/srd/feature_choices.json
assets/data/i18n/<locale>/feature_choices.json
```

`SrdFeatureChoiceCatalog` supports choices for:

- class features;
- subclass features;
- racial traits;
- feats;
- shared option sources.

`FeatureChoiceRequest` identifies one required choice by source type, source
class/subclass/name, feature name, choice ID, level, and required count.
Requests are complete when the matching `CharacterFeatureChoice` contains
enough unique option IDs.

Persisted choices use `CharacterFeatureChoice`:

```text
sourceType       classFeature | subclassFeature | raceTrait | feat
sourceClass      class name when relevant
sourceSubclass   subclass name when relevant
sourceName       trait/feat source name when relevant
featureName      feature/trait/feat display source
choiceId         requirement ID inside feature_choices.json
values           stable option IDs, not localized text
```

Creation uses `StepFeatureChoices` near the end of the wizard, after the
class/race/background/skills/attributes/name steps and before review. It also
handles choices triggered by a feat selected from another feature, such as
Variant Human choosing a bonus feat that then has its own required options.

Level up uses the same engine. The wizard asks for choices newly unlocked by
new class features, subclass features, level-triggered counts, and the selected
feat when an ASI is spent on a feat.

The Features tab reads saved choices, shows pending choices, lets the user edit
them later, and shows localized option descriptions through `SrdI18nService`.

### Feature Usages

`data/feature_usage_engine.dart` centralizes limited-use resources for class
features, subclass features, racial traits, and feats.

The canonical data lives in:

```text
assets/data/srd/feature_usages.json
assets/data/i18n/<locale>/feature_usages.json
```

`FeatureUsageCatalog` maps feature names to `FeatureUsageRef` entries. A ref
points to a resource ID and optionally declares how many points/uses that
feature spends. The resource definition stores:

- display name;
- max formula;
- recharge rule;
- resource ID used as the persistence key.

`FeatureUsageEngine.maxFor()` evaluates formulas such as Barbarian Rage uses,
Monk level for Ki, Paladin level x5 for Lay on Hands, ability modifiers, and
static values. `FeatureUsageEngine.rechargeFor()` handles special recharge
rules, such as Bardic Inspiration switching to short-rest recovery at level 5.

Remaining uses are stored in `Character.featureResources`. Missing entries are
treated as full, which keeps old characters readable and avoids saving noise.
Short and long rests call `CharacterDetailNotifier._featureResourcesAfterRest`
to restore resources whose recharge rules apply. Manual adjustments go through
`CharacterDetailNotifier.adjustFeatureResource()`.

The Features tab renders usage controls next to any feature/trait/feat that has
an active usage reference. It asks the engine for the current/max/spend view
instead of duplicating formulas in UI code.

---

## SRD Data And Translation Data

`SrdDataSource` loads canonical English JSON assets from `assets/data/srd/`.
It parses data into `Srd*` models and caches loaded lists/maps in memory.

Important SRD files:

- `classes.json`, `subclasses.json`
- `class_features.json`, `subclass_features.json`
- `races.json`, `race_traits.json`
- `backgrounds.json`
- `spells.json`
- `equipment.json`, `magic_items.json`, `tools.json`
- `feats.json`, `conditions.json`, `skills.json`
- `languages.json`
- `feature_choices.json`, `feature_usages.json`

`getItems()` builds a normalized item lookup used by creation and inventory. It
adds aliases for common starting-equipment strings, such as stripped ammunition
names and armor suffix variants.

`equipment.json` is also the source for structured pack contents. Pack contents
are plain item references plus quantities. Starting equipment is expanded into
the main inventory; the user decides later which items should go into
containers.

`feature_choices.json` stores selectable options and requirements. It should
use stable option IDs and English source text. Locale overlays translate names
and descriptions, but saved characters keep the stable IDs.

`feature_usages.json` stores resource definitions and mappings from
features/traits/feats to resources. UI labels are localized through
`SrdI18nService.featureUsageResourceName()`.

### UI strings

UI strings are generated from ARB files in `lib/l10n/` through Flutter
`gen-l10n`. App widgets access them with:

```dart
AppLocalizations.of(context)!
```

### SRD strings

SRD/game content uses translation overlays in:

```text
assets/data/i18n/<locale>/
```

`SrdI18nService.load(locale)` loads those overlays and normalizes lookup keys to
lowercase. Missing translations fall back to English SRD values in the UI.

This split is intentional: ARB handles app chrome and controls; JSON overlays
handle game data that mirrors SRD asset structure.

---

## Feature Modules

### Character List

`features/character_list/` owns the home screen:

- list loading via `characterListProvider`;
- pinning/reordering;
- rename/delete;
- import/export dialog;
- `.dndchar` file import from platform open intents;
- avatar display and list-level image updates.

The list provider keeps pinned characters first, then applies `sortOrder` and
`updatedAt`. The UI uses `CustomScrollView` plus `SliverReorderableList` with an
explicit drag handle. Reordering is limited to the current pinned/unpinned
group; changing groups happens through pin/unpin.

### Character Creation

`features/character_creation/` is a guided wizard backed by `CharacterDraft`.

Main steps:

- class/subclass;
- race/subrace;
- background;
- skills;
- attributes;
- name/player;
- feature choices;
- review.

`CharacterDraftNotifier.buildAndSave()` resolves equipment choices, starting
gold, languages/tools, feature choices, initial HP, and AC before saving the
final `Character`.

Race and attribute rules:

- PHB-style fixed racial bonuses are read from `abilityScoreIncreases`.
- Free racial points, such as Half-Elf and Variant Human `twoOthers`, are
  chosen explicitly and must go to valid different attributes.
- The optional Tasha-style toggle redistributes racial ASI increments while
  preserving the same increment sizes.
- Variant Human is modeled as its own race and uses feature choices for the
  bonus skill, extra language, and level-1 feat.

### Character Detail

`features/character_detail/` is the main sheet/editor for an existing character.
`character_detail_screen.dart` owns the shared tab layout, app bar actions,
rest/level-up entry points, maintenance gate, and edit-mode discard
coordination.

The detail feature is split into:

- `application/`: per-tab view models and derived providers.
- `tabs/`: main tab entry widgets.
- `widgets/detail_widgets.dart`: reusable detail widgets imported normally.
- `widgets/features/`: feature sections and feature add/detail sheets.
- `widgets/inventory/`: inventory add, container-content, and detail sheets.
- `widgets/spells/`: spell tab helper widgets.
- `inventory/`: inventory snapshot and SRD search catalog.

The tab entry files are still part files under `tabs/`:

- `stats_tab.dart`
- `skills_tab.dart`
- `spells_tab.dart`
- `inventory_tab.dart`
- `features_tab.dart`
- `identity_tab.dart`
- `notes_tab.dart`

`character_detail_provider.dart` owns mutations: HP, rests, spell slots,
prepared spells, concentration, level up, identity, stats, inventory, features,
notes, conditions, XP, and settings flags.

Heavy tabs use a combination of per-tab providers, cached SRD providers,
`AutomaticKeepAliveClientMixin`, and sliver lists. The goal is to keep tab
switching responsive and avoid rebuilding large lists when unrelated character
data changes.

The Notes tab supports search, colored tags, pin/unpin, detail viewing, and
drag reordering. Notes are ordered by pinned group and `CharacterNote.sortOrder`.
The UI uses `CustomScrollView` plus `SliverReorderableList`; reordering is
disabled while a search or tag filter is active so a filtered subset does not
rewrite the underlying order unexpectedly.

Feature choices and feature usages both surface mainly in `features_tab.dart`:

- choices are displayed as localized chips and can be edited;
- tapping a saved choice can show its localized option description;
- usage resources show current/max controls and spend/recover actions;
- rests restore usage resources through `FeatureUsageEngine`.

### Settings

`features/home/settings_screen.dart` exposes:

- theme;
- locale;
- unit-system preferences;
- `.dndbackup` export/import;
- character maintenance and migration previews/applies.

Theme, locale, and unit-system state lives in `core/theme`, `core/locale`, and
`core/units`. Backup and maintenance actions go through `CharacterRepository`.
Settings maintenance must export a backup before applying migrations.

---

## Navigation

Routes live in `core/router/app_router.dart`.

| Route | Screen |
| --- | --- |
| `/` | Character list |
| `/character/:id` | Character detail |
| `/create` | Character creation wizard |
| `/settings` | Settings |

On web, `main.dart` calls a platform-specific URL strategy helper. Native
platforms use a no-op implementation, while web calls `usePathUrlStrategy()` so
browser URLs use real paths instead of hash fragments.

The GitHub Pages build uses `--base-href /dnd-character-tool/`. Because GitHub
Pages does not support route rewrites, `web/404.html` stores the requested URL
in `sessionStorage`, redirects to the app base path, and `web/index.html`
restores the original path before Flutter boots. This keeps direct access to
`/create`, `/settings`, and `/character/:id` working on the hosted preview.

The router redirects `content://` and `file://` URIs to `/` so Android/iOS file
open intents for `.dndchar` do not crash GoRouter.

---

## Import And Export

Export from the character card prepares two user-facing representations:

1. `.dndchar` file JSON from `exportToFileJson()`, which can include base64
   image data and is the primary sharing format.
2. Plain JSON from `CharacterRepository.exportToJson()`, kept as an advanced
   copy/paste fallback without embedded image data.

`.dndchar` payload encoding runs in `compute()` where needed to avoid UI jank.

Settings can export a `.dndbackup` file through `exportBackupToFileJson()`.
The backup payload contains:

```text
version
type: dnd-character-tool-backup
exportedAt
characterCount
characters[]
```

Each backup entry uses the same inner shape as a `.dndchar` payload:
`character`, optional `imageData`, and optional `imageMimeType`. Imports assign
fresh IDs to every character in the backup.

Platform export is selected through `core/utils/file_exporter.dart`:

- Native: writes a temporary `.dndchar` file and opens `share_plus`.
- Native backup: writes a temporary `.dndbackup` file and opens `share_plus`.
- Web: creates a browser download for `.dndchar`, raw JSON, or `.dndbackup`.

Import paths:

- Raw JSON paste/import from the character list dialog.
- File picker from the character list.
- Backup file picker from Settings.
- Platform channel `dnd.character/file_import` through `IncomingFileService`
  when the app is opened from a `.dndchar` file.

Imported characters are assigned fresh IDs before saving.

---

## Units

`UnitSystem` controls display-only unit conversion:

- Imperial: feet and pounds.
- Metric: meters and kilograms.
- Squares: grid-square distance labels.

The selected unit system is persisted in `SharedPreferences`. It affects speed,
inventory weights/capacities, and spell range/area display. Stored mechanical
values remain canonical where needed; conversion happens at formatting or input
boundaries.

---

## UI Patterns

- Use `SafeArea`, `useSafeArea: true`, `viewPadding`, and/or `viewInsets` for
  bottom sheets with bottom actions so Android navigation and keyboards do not
  cover controls.
- Detail tabs should call methods on `CharacterDetailNotifier`; they should not
  persist directly.
- For reorderable lists with headers, search, or sections, prefer
  `CustomScrollView` with `SliverReorderableList` and explicit drag handles.
  Avoid nested `ReorderableListView` with `shrinkWrap` for long lists.
- Item, spell, feature, and SRD detail displays should use localized names from
  `SrdI18nService`, falling back to English.
- Prefer existing shared widgets in `shared/widgets/` and
  `character_detail/widgets/` before adding new one-off components.

---

## Code Generation And Tests

Generated files are committed:

- `*.g.dart` from `json_serializable`.
- `lib/l10n/app_localizations*.dart` from Flutter gen-l10n.

Common validation commands:

```powershell
flutter analyze
flutter test
```

Focused tests currently cover repository import/export behavior, character
model logic, stats editing, spellcasting rules, armor-class rules, feature
choices, feature usage resources, character draft rules, inventory operations,
inventory snapshots/search, and character migrations.

High-risk domain rules should be tested in pure Dart layers first:

- inventory behavior in `data/inventory/inventory_operations.dart`;
- character migrations in `data/migrations/`;
- feature choices/usages in their engine files;
- creation draft rules in `character_draft_provider.dart`;
- import/export payload parsing in repository/data-source tests.

When changing persisted models, generated serializers, or l10n keys, regenerate
the affected files before committing.

---

## Where To Change Things

| Change | Start here |
| --- | --- |
| Character save/load/import/export | `CharacterRepository`, `CharacterLocalDataSource`, storage backends |
| Character detail mutation | `CharacterDetailNotifier` |
| Character detail tab rebuild/performance | `features/character_detail/application/`, `_CharacterTabHost`, relevant tab file |
| Creation wizard state | `CharacterDraftNotifier` and `features/character_creation/steps/` |
| AC calculation | `data/constants/armor_class.dart` |
| Level-up thresholds/ASI/subclass unlocks | `data/constants/level_up_rules.dart` |
| Spellcasting slots/known/prepared/cantrips | `data/spellcasting_engine.dart` |
| Feature choices | `data/feature_choice_engine.dart`, `assets/data/srd/feature_choices.json`, `character_detail/widgets/feature_choice_editor.dart` |
| Feature usage tracking | `data/feature_usage_engine.dart`, `assets/data/srd/feature_usages.json`, `features/character_detail/widgets/features/feature_sections.dart` |
| Character migrations | `data/migrations/`, `CharacterRepository.previewMigrations()`, `CharacterRepository.applyMigrations()` |
| Backup export/import | `CharacterRepository`, `CharacterLocalDataSource`, `features/home/settings_screen.dart`, `core/utils/file_exporter.dart` |
| Inventory rules and ordering | `data/inventory/inventory_operations.dart`, `features/character_detail/inventory/inventory_view_model.dart` |
| Inventory search | `features/character_detail/inventory/inventory_search_catalog.dart`, `features/character_detail/widgets/inventory/add_item_sheet.dart` |
| Inventory item UI and custom item forms | `features/character_detail/tabs/inventory_tab.dart`, `features/character_detail/widgets/inventory/` |
| Notes, note tags, and note ordering | `features/character_detail/tabs/notes_tab.dart`, `CharacterDetailNotifier`, `CharacterNote` |
| Starting equipment packs | `assets/data/srd/equipment.json`, `SrdPackContent`, `ExpandEquipmentPacksMigration` |
| Creation racial ASI/Tasha/Variant Human | `features/character_creation/character_draft_provider.dart`, `steps/step_attributes.dart`, `steps/step_feature_choices.dart`, `assets/data/srd/races.json` |
| SRD canonical data | `assets/data/srd/` |
| SRD translations | `assets/data/i18n/` and `SrdI18nService` |
| App UI strings | `lib/l10n/*.arb` |
| Routes | `core/router/app_router.dart` |
| Web URL strategy/PWA/GitHub Pages fallback | `core/platform/url_strategy*.dart`, `web/index.html`, `web/manifest.json`, `web/404.html` |
| Theme/locale/unit preferences | `core/theme`, `core/locale`, `core/units` |
