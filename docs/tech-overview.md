# Technical Overview — DnD Character Tool

This document describes the architecture, stack and design decisions behind the project. Useful for contributors, forks, and anyone curious about how it works under the hood.

---

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x / Dart 3.x |
| State management | Riverpod 2 (`flutter_riverpod`) |
| Navigation | GoRouter |
| Local persistence | JSON files on disk (Android/iOS/Desktop) via `path_provider`; `SharedPreferences` on Web |
| Serialization | `json_serializable` + `build_runner` (code generation) |
| Internationalization | Flutter `gen-l10n` (ARB) + custom i18n layer for SRD data |
| Export/Import | `share_plus`, `file_picker`, native MethodChannel |
| Image | `image_picker`, `image_cropper` |

---

## Project Structure

```
lib/
├── core/          # Cross-cutting infrastructure (router, theme, locale, utils, units)
├── data/
│   ├── models/        # Domain models (Character, HitPoints, AbilityScores…)
│   ├── datasources/   # Data access: local (JSON/disk) and SRD (asset JSONs)
│   └── repositories/  # CharacterRepository — single access point for characters
├── features/      # Screens organized by feature (character_list, character_detail, etc.)
├── shared/        # Riverpod providers shared across features
└── l10n/          # ARB files and gen-l10n generated classes

assets/
├── data/
│   ├── srd/       # SRD 5.1 JSON data (spells, races, classes, backgrounds, feats…)
│   └── i18n/      # Translation overlays per locale for SRD data

tools/             # Python scripts for i18n generation and patching
docs/              # Project documentation
```

The project follows a layered architecture loosely inspired by Clean Architecture, adapted to Flutter mobile:

```
UI (Widget) → Provider (Riverpod) → Repository → DataSource → Disk/Assets
```

The UI never accesses disk directly — always through a provider. `CharacterRepository` decouples features from the concrete datasource, making it straightforward to migrate to a remote backend in the future.

---

## State Management — Riverpod

- **`characterListProvider`** — `AsyncNotifierProvider` holding the full character list. Loads from `CharacterRepository` and exposes methods like `create`, `delete`, `updateSingle`.
- **`characterDetailProvider(id)`** — `AsyncNotifierProvider.family` parameterized by ID. Contains all editing logic for a single character: `adjustHp`, `toggleCondition`, `updateSavingThrows`, `updateDeathSaves`, etc. Uses _optimistic update_: state is updated locally before persisting, avoiding UI jank.
- **`srdDataSourceProvider`** / **`srdI18nProvider`** — Providers that load SRD data and translation overlays. `srdI18nProvider` watches `localeProvider` and reloads automatically on locale change.
- **`themeProvider`** / **`localeProvider`** — `NotifierProvider` with initial state injected via `ProviderScope.overrides` in `main()` to prevent a flash of incorrect theme/locale on startup.
- **`unitSystemProvider`** — `NotifierProvider<UnitSystemNotifier, UnitSystem>` persisted in `SharedPreferences`. Controls display of distances (ft/m/sq) and weights (lb/kg) across all screens.

---

## Local Persistence

Storage uses Dart's **platform-conditional import** pattern:

```dart
import 'storage_backend_stub.dart'
    if (dart.library.io)         'storage_backend_native.dart'
    if (dart.library.js_interop) 'storage_backend_web.dart';
```

- **Native (Android/iOS/Desktop):** each character is a `.json` file under `ApplicationDocuments/dnd_character_tool/characters/`. Images are stored separately under `images/`. No database — plain files are easy to back up and inspect.
- **Web:** uses `SharedPreferences` (localStorage) serialized as JSON, since filesystem access is unavailable.

---

## Serialization — Code Generation

Models use `@JsonSerializable(explicitToJson: true)` for nested objects. `build_runner` generates `.g.dart` files with `fromJson`/`toJson`. The main `Character` model has ~30 fields including nested objects like `AbilityScores`, `HitPoints`, `SpellSlots`, and `EquipmentItem`.

New fields follow the nullable-with-fallback pattern for backwards compatibility:
```dart
activeConditions: (json['activeConditions'] as List<dynamic>?)
    ?.map((e) => e as String).toList() ?? const [],
```

---

## Internationalization (i18n)

The project has **two independent i18n layers**:

### 1. UI strings — Flutter gen-l10n
- 10 languages: en, pt, es, fr, de, it, ja, ko, ru, zh
- `.arb` files in `lib/l10n/`
- `flutter gen-l10n` generates typed classes in `app_localizations.dart`
- Accessed via `AppLocalizations.of(context)!`

### 2. SRD data — SrdI18nService
- Game data (spell names, races, conditions, etc.) comes from English JSONs in assets
- `SrdI18nService` loads translation overlays per locale from `assets/data/i18n/{locale}/`
- Pattern: `_str('conditions', 'Blinded', 'name')` → returns translated string or `null` (falls back to English)
- Keys are normalized to lowercase internally via `_lowercaseKeys`

Translation overlays are generated by Python scripts in `tools/`:
- `translate_i18n.py` — bulk translation via `deep-translator` (Google Translate)
- `patch_spell_material.py` — safe patching of the `material` field without overwriting existing translations

---

## Navigation — GoRouter

Declarative routes with path parameters:

| Route | Screen |
|-------|--------|
| `/` | Character list |
| `/character/:id` | Character detail / editing |
| `/create` | Creation wizard |
| `/settings` | Settings |

Includes a `redirect` guard to prevent crashes when Android/iOS passes `content://` or `file://` URIs directly to the router (`.dndchar` file opening scenario).

---

## Export/Import — .dndchar Format

- Proprietary `.dndchar` file = character JSON + base64-encoded image, compressed and encoded.
- **Export (Android):** `share_plus` opens the native share sheet with the file attached.
- **Import (Android):** `MethodChannel` (`dnd.character/file_import`) captures file-open intents and emits via `IncomingFileService.fileStream` (Singleton + broadcast Stream pattern).
- **Import (iOS):** `SceneDelegate` forwards the URL to the same channel.
- Base64 encoding and JSON serialization run in a separate isolate via `compute()` to avoid blocking the UI thread with large character photos.
- Also supports a **share token**: a compact, URL-safe string derived from character data (gzip + base64url on native; base64url-only on web for cross-platform compatibility).

---

## Unit System

Three display modes configurable in Settings:
- **Imperial** — feet (ft) and pounds (lb) — default for `en` locale
- **Metric** — metres (m) and kilograms (kg) — default for all other locales
- **Squares** — square units (sq) for grid-based play

Applied consistently across character speed, inventory weight, and spell ranges. Persisted in `SharedPreferences` via `unitSystemProvider`.

---

## Themes

- Multiple `ThemeData` presets defined in `app_themes.dart`
- `ThemeNotifier` persists the selection in `SharedPreferences`
- Initialized before the first frame (`ProviderScope.overrides`) to prevent a default-theme flash

---

## Key Features — Implementation Notes

| Feature | Notable detail |
|---------|---------------|
| **Character creation** | Multi-step wizard pulling race, class, background, and spell data from SRD asset JSONs |
| **Level Up Wizard** | Fullscreen slide-up flow: HP roll, ASI/Feat selection, subclass, spells |
| **XP tracking** | Automatic level-up detection with guard against double-tap race condition |
| **HP tracker** | Adjust +/-, temporary HP, death saves (3 successes/3 failures) with auto-reset on heal |
| **Active conditions** | 15 SRD conditions persisted as `List<String>` on the model; chip UI + detail bottom sheet |
| **Saving throws** | Calculated values (modifier + proficiency bonus); unified layout between view and edit modes |
| **Concentration** | "C" badge on active spell, warning banner on second concentration cast, manual end button |
| **Short rest** | Spends available Hit Dice (d + CON modifier) to recover HP, with HD availability validation |
| **Inventory** | Equippable section separate from carried items; item description on tap; carry weight bar |
| **Spells** | Filter by level/school, slots per level, innate spells, spell range unit conversion |
| **Notes** | Free-form multi-note field per character |
