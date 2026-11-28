import 'dart:convert';

import 'package:flutter/services.dart';

/// Original English summaries of 2024 PHB options outside the SRD.
/// Kept separately so the SRD files retain their source and attribution.
class Supplemental2024Catalog {
  const Supplemental2024Catalog._();

  static const assetPath = 'assets/data/2024/phb_subclasses.json';

  /// Backgrounds, Origin feats and species outside the SRD.
  static const originsPath = 'assets/data/2024/phb_origins.json';

  /// Fighting Style, general and Epic Boon feats outside the SRD.
  static const featsPath = 'assets/data/2024/phb_feats.json';

  static Future<Map<String, dynamic>> _read(String path) async =>
      jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;

  static Future<Map<String, dynamic>> load() => _read(assetPath);

  static Future<Map<String, dynamic>> origins() => _read(originsPath);

  static Future<Map<String, dynamic>> extraFeats() => _read(featsPath);

  /// Spells outside the SRD that no subclass grants.
  static const spellsPath = 'assets/data/2024/phb_spells.json';

  /// Every supplemental spell: subclass spells and the other PHB spells.
  static Future<List<Map<String, dynamic>>> spells() async => [
    ...await _list(await load(), 'spells'),
    ...await _list(await _read(spellsPath), 'spells'),
  ];

  static Future<List<Map<String, dynamic>>> subclasses() async =>
      ((await load())['subclasses'] as List).cast<Map<String, dynamic>>();

  static Future<List<Map<String, dynamic>>> _list(
    Map<String, dynamic> catalog,
    String key,
  ) async =>
      (catalog[key] as List? ?? const []).cast<Map<String, dynamic>>();

  static Future<List<Map<String, dynamic>>> backgrounds() async =>
      _list(await origins(), 'backgrounds');

  static Future<List<Map<String, dynamic>>> feats() async => [
    ...await _list(await origins(), 'feats'),
    ...await _list(await extraFeats(), 'feats'),
  ];

  static Future<List<Map<String, dynamic>>> species() async =>
      _list(await origins(), 'species');

  static Future<Map<String, String>> raceTraits() async =>
      ((await origins())['raceTraits'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as String));

  /// Merges the supplemental [section] (`featureChoices` or `featureUsages`)
  /// of every 2024 catalog into [target].
  static Future<void> mergeSection(
    Map<String, dynamic> target,
    String section,
  ) async {
    for (final catalog in [await load(), await origins(), await extraFeats()]) {
      final extra = catalog[section] as Map<String, dynamic>?;
      if (extra != null) merge(target, extra);
    }
  }

  /// Adds nested catalog definitions without replacing existing SRD entries.
  /// Lists, such as option sources, gain the new entries; an entry whose `id`
  /// is already listed is a conflict.
  static void merge(Map<String, dynamic> target, Map<String, dynamic> extra) {
    for (final entry in extra.entries) {
      final previous = target[entry.key];
      final value = entry.value;
      if (previous is Map<String, dynamic> && value is Map<String, dynamic>) {
        merge(previous, value);
      } else if (previous is List && value is List) {
        final ids = {for (final item in previous) if (item is Map) item['id']};
        for (final item in value) {
          if (item is Map && ids.contains(item['id'])) {
            throw StateError(
              'Supplemental catalog repeats ${entry.key}/${item['id']}.',
            );
          }
        }
        target[entry.key] = [...previous, ...value];
      } else if (previous == null) {
        target[entry.key] = value;
      } else {
        throw StateError('Supplemental catalog conflicts with ${entry.key}.');
      }
    }
  }
}
