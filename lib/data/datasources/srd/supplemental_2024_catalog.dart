import 'dart:convert';

import 'package:flutter/services.dart';

/// Original English summaries of 2024 PHB options outside the SRD.
/// Kept separately so the SRD files retain their source and attribution.
class Supplemental2024Catalog {
  const Supplemental2024Catalog._();

  static const assetPath = 'assets/data/2024/phb_subclasses.json';

  static Future<Map<String, dynamic>> load() async =>
      jsonDecode(await rootBundle.loadString(assetPath))
          as Map<String, dynamic>;

  static Future<List<Map<String, dynamic>>> subclasses() async =>
      ((await load())['subclasses'] as List).cast<Map<String, dynamic>>();

  /// Adds nested catalog definitions without replacing existing SRD entries.
  static void merge(Map<String, dynamic> target, Map<String, dynamic> extra) {
    for (final entry in extra.entries) {
      final previous = target[entry.key];
      final value = entry.value;
      if (previous is Map<String, dynamic> && value is Map<String, dynamic>) {
        merge(previous, value);
      } else if (previous == null) {
        target[entry.key] = value;
      } else {
        throw StateError('Supplemental catalog conflicts with ${entry.key}.');
      }
    }
  }
}
