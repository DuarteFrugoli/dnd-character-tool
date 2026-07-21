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
| Local persistence | JSON files on native platforms; `SharedPreferences` on web |
| Serialization | `json_serializable` generated `*.g.dart` files |
| UI i18n | Flutter `gen-l10n` from ARB files |
| SRD i18n | Custom JSON overlay service (`SrdI18nService`) |
| Import/export | `.dndchar` JSON payloads, `file_picker`, `share_plus`, platform channels |
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
    models/       Persisted domain models and generated JSON serializers
    repositories/ CharacterRepository facade
    spellcasting_engine.dart
  features/
    character_creation/
    character_detail/
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

`WebStorageBackend` stores each character JSON string in `SharedPreferences`
using the `dnd_char_` prefix and keeps an ID index in `dnd_char_ids`.

The web storage backend does not manage image files. Imported `.dndchar` images
can still be preserved as `data:<mime>;base64,...` URLs stored directly in the
character JSON.

### Repository rules

`CharacterRepository.save()` updates `updatedAt` before writing. Imports always
receive a new generated ID before persistence, which avoids ID conflicts and
prevents imported files from controlling local paths.

---

## Domain Models

Persisted models live in `lib/data/models/`.

Key models:

| Model | Purpose |
| --- | --- |
| `Character` | Root saved object: identity, class/race, stats, HP, AC, equipment, spells, notes, features, settings. |
| `AbilityScores` | Six ability scores and modifiers. |
| `HitPoints` | Current/max/temp HP, hit dice usage, death saves, stabilized/dead state. |
| `EquipmentItem` | Inventory item with mechanical `ItemType`, quantity, weight, equip state, and type-specific `properties`. |
| `KnownSpell`, `SpellSlots`, `InnateSpell` | Spell list, slot usage, and innate spell tracking. |
| `CharacterExtraFeature` | Manually added class/subclass/feat/custom feature. |
| `CharacterNote`, `CharacterAppearance`, `CharacterPersonality` | Detail-screen supporting data. |

Most models use `@JsonSerializable`. Some older/simple models use manual JSON
methods. New persisted fields should provide a default fallback in generated or
manual `fromJson` code to keep old character files readable.

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
- `container` is reserved for storage-style behavior and stores capacity-related
  properties.
- `ammunition` is handled separately in the inventory UI.
- Custom item creation in `inventory_tab.dart` shows different inputs per
  `ItemType` and stores type-specific values in `properties`.

Equipment changes that can affect AC call `calcArmorClass`. Body armor is
exclusive: equipping a new body armor unequips/merges the previous one.

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

`getItems()` builds a normalized item lookup used by creation and inventory. It
adds aliases for common starting-equipment strings, such as stripped ammunition
names and armor suffix variants.

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
`updatedAt`.

### Character Creation

`features/character_creation/` is a guided wizard backed by `CharacterDraft`.

Main steps:

- class/subclass;
- race/subrace;
- background;
- skills;
- attributes;
- name/player;
- review.

`CharacterDraftNotifier.buildAndSave()` resolves equipment choices, starting
gold, languages/tools, initial HP, and AC before saving the final `Character`.

### Character Detail

`features/character_detail/` is the main sheet/editor for an existing character.
The screen is split into part files under `tabs/`:

- `stats_tab.dart`
- `skills_tab.dart`
- `spells_tab.dart`
- `inventory_tab.dart`
- `features_tab.dart`
- `identity_tab.dart`
- `notes_tab.dart`

`character_detail_screen.dart` owns the shared tab layout and edit-mode discard
coordination. `character_detail_provider.dart` owns mutations: HP, rests, spell
slots, prepared spells, concentration, level up, identity, stats, inventory,
features, notes, conditions, XP, and settings flags.

### Settings

`features/home/settings_screen.dart` exposes theme, locale, and unit-system
preferences. The actual state lives in `core/theme`, `core/locale`, and
`core/units`.

---

## Navigation

Routes live in `core/router/app_router.dart`.

| Route | Screen |
| --- | --- |
| `/` | Character list |
| `/character/:id` | Character detail |
| `/create` | Character creation wizard |
| `/settings` | Settings |

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

Platform export is selected through `core/utils/file_exporter.dart`:

- Native: writes a temporary `.dndchar` file and opens `share_plus`.
- Web: creates a browser download.

Import paths:

- Raw JSON paste/import from the character list dialog.
- File picker from the character list.
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
dart analyze
flutter test
```

Focused tests currently cover repository import/export behavior, character model
logic, stats editing, spellcasting rules, and armor-class rules.

When changing persisted models, generated serializers, or l10n keys, regenerate
the affected files before committing.

---

## Where To Change Things

| Change | Start here |
| --- | --- |
| Character save/load/import/export | `CharacterRepository`, `CharacterLocalDataSource`, storage backends |
| Character detail mutation | `CharacterDetailNotifier` |
| Creation wizard state | `CharacterDraftNotifier` and `features/character_creation/steps/` |
| AC calculation | `data/constants/armor_class.dart` |
| Level-up thresholds/ASI/subclass unlocks | `data/constants/level_up_rules.dart` |
| Spellcasting slots/known/prepared/cantrips | `data/spellcasting_engine.dart` |
| Inventory item UI and custom item forms | `features/character_detail/tabs/inventory_tab.dart` |
| SRD canonical data | `assets/data/srd/` |
| SRD translations | `assets/data/i18n/` and `SrdI18nService` |
| App UI strings | `lib/l10n/*.arb` |
| Routes | `core/router/app_router.dart` |
| Theme/locale/unit preferences | `core/theme`, `core/locale`, `core/units` |
