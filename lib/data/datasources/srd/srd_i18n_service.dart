import 'dart:convert';

import 'package:flutter/services.dart';

/// Provides translated SRD strings for a given locale.
///
/// Keys are always English identifiers; values are localised strings.
/// Returning `null` means "use the original English string".
class SrdI18nService {
  SrdI18nService._(this.locale, this._data);

  final String locale;

  // filename (without .json) → englishKey → { "name": ..., "description": ..., ... }
  final Map<String, Map<String, dynamic>> _data;

  /// No-op service: every lookup returns null, so callers fall back to English.
  static final SrdI18nService english = SrdI18nService._('en', const {});

  static const _files = [
    'backgrounds',
    'classes',
    'class_features',
    'equipment',
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
    return SrdI18nService._(locale, data);
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
}
