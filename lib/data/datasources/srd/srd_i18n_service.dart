import 'dart:convert';

import 'package:flutter/services.dart';

/// Provides translated SRD strings for a given locale.
///
/// Keys are always English identifiers; values are localised strings.
/// Returning `null` means "use the original English string".
class SrdI18nService {
  SrdI18nService._(this.locale, this._data, this._subraceNames);

  final String locale;

  // filename (without .json) → englishKey → { "name": ..., "description": ..., ... }
  final Map<String, Map<String, dynamic>> _data;

  // English subrace name → translated name (built by crossing SRD + i18n races)
  final Map<String, String> _subraceNames;

  /// No-op service: every lookup returns null, so callers fall back to English.
  static final SrdI18nService english =
      SrdI18nService._('en', const {}, const {});

  static const _files = [
    'backgrounds',
    'classes',
    'class_features',
    'equipment',
    'languages',
    'magic_items',
    'races',
    'race_traits',
    'skills',
    'spells',
    'subclasses',
    'subclass_features',
  ];

  /// Loads the i18n overlay for [locale] from bundled assets.
  /// Gracefully skips files that are missing, empty, or malformed.
  static Future<SrdI18nService> load(String locale) async {
    if (locale == 'en') return english;
    final data = <String, Map<String, dynamic>>{};
    for (final file in _files) {
      try {
        final raw =
            await rootBundle.loadString('assets/data/i18n/$locale/$file.json');
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
          data[file] = decoded;
        }
      } catch (_) {
        // Missing, empty, or invalid JSON — fall back to English for this file.
      }
    }
    // Build English→translated subrace index by crossing SRD races with the
    // i18n overlay. Subraces in the i18n file are stored as a positional array,
    // so we match them by index against the SRD source.
    final subraceNames = <String, String>{};
    try {
      final srdRaw =
          await rootBundle.loadString('assets/data/srd/races.json');
      final srdRaces = jsonDecode(srdRaw) as List<dynamic>;
      final i18nRaces = data['races'];
      if (i18nRaces != null) {
        for (final srdRace in srdRaces) {
          final raceEnName = srdRace['name'] as String?;
          if (raceEnName == null) continue;
          final srdSubraces = srdRace['subraces'] as List<dynamic>? ?? [];
          final i18nEntry = i18nRaces[raceEnName];
          if (i18nEntry is! Map) continue;
          final i18nSubraces = i18nEntry['subraces'] as List<dynamic>? ?? [];
          for (var i = 0; i < srdSubraces.length; i++) {
            final enName = srdSubraces[i]['name'] as String?;
            final translatedName = i < i18nSubraces.length
                ? i18nSubraces[i]['name'] as String?
                : null;
            if (enName != null && translatedName != null) {
              subraceNames[enName] = translatedName;
            }
          }
        }
      }
    } catch (_) {}

    return SrdI18nService._(locale, data, subraceNames);
  }

  // ── Generic helpers ────────────────────────────────────────────────────────

  String? _str(String file, String key, String field) {
    final entry = _data[file]?[key];
    if (entry is! Map) return null;
    return entry[field] as String?;
  }

  String? _nested2(String file, String k1, String k2, String field) {
    final level1 = _data[file]?[k1];
    if (level1 is! Map) return null;
    final entry = level1[k2];
    if (entry is! Map) return null;
    return entry[field] as String?;
  }

  String? _nested3(
      String file, String k1, String k2, String k3, String field) {
    final level1 = _data[file]?[k1];
    if (level1 is! Map) return null;
    final level2 = level1[k2];
    if (level2 is! Map) return null;
    final entry = level2[k3];
    if (entry is! Map) return null;
    return entry[field] as String?;
  }

  // ── Skills ─────────────────────────────────────────────────────────────────

  String skillName(String en) => _str('skills', en, 'name') ?? en;

  // ── Spells ─────────────────────────────────────────────────────────────────

  String spellName(String en) => _str('spells', en, 'name') ?? en;

  String? spellDescription(String en) => _str('spells', en, 'description');

  String? spellHigherLevels(String en) => _str('spells', en, 'higherLevels');

  // ── Races ──────────────────────────────────────────────────────────────────

  String raceName(String en) => _str('races', en, 'name') ?? en;

  String subraceName(String en) => _subraceNames[en] ?? en;

  // ── Backgrounds ────────────────────────────────────────────────────────────

  String backgroundName(String en) => _str('backgrounds', en, 'name') ?? en;

  // ── Classes ────────────────────────────────────────────────────────────────

  String className(String en) => _str('classes', en, 'name') ?? en;

  String subclassName(String classEn, String subclassEn) =>
      _nested2('subclasses', classEn, subclassEn, 'name') ?? subclassEn;

  // ── Race traits ────────────────────────────────────────────────────────────

  String? raceTraitName(String en) => _str('race_traits', en, 'name');

  String? raceTraitDescription(String en) =>
      _str('race_traits', en, 'description');

  // ── Backgrounds ────────────────────────────────────────────────────────────

  String? backgroundFeatureName(String backgroundEn) {
    final entry = _data['backgrounds']?[backgroundEn];
    if (entry is! Map) return null;
    final feature = entry['feature'];
    if (feature is! Map) return null;
    return feature['name'] as String?;
  }

  String? backgroundFeatureDescription(String backgroundEn) {
    final entry = _data['backgrounds']?[backgroundEn];
    if (entry is! Map) return null;
    final feature = entry['feature'];
    if (feature is! Map) return null;
    return feature['description'] as String?;
  }

  // ── Class features ─────────────────────────────────────────────────────────

  String? classFeatureName(String className, String featureName) =>
      _nested2('class_features', className, featureName, 'name');

  String? classFeatureDescription(String className, String featureName) =>
      _nested2('class_features', className, featureName, 'description');

  // ── Subclass features ──────────────────────────────────────────────────────

  String? subclassFeatureName(
          String className, String subclassName, String featureName) =>
      _nested3(
          'subclass_features', className, subclassName, featureName, 'name');

  String? subclassFeatureDescription(
          String className, String subclassName, String featureName) =>
      _nested3('subclass_features', className, subclassName, featureName,
          'description');

  // ── Equipment ──────────────────────────────────────────────────────────────

  String equipmentName(String en) => _str('equipment', en, 'name') ?? en;

  String magicItemName(String en) => _str('magic_items', en, 'name') ?? en;

  // ── Languages ──────────────────────────────────────────────────────────────

  String languageName(String en) => _str('languages', en, 'name') ?? en;
}
