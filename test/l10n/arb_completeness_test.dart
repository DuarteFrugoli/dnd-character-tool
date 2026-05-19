import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads all non-@ keys from an ARB file.
Set<String> _arbKeys(String path) {
  final content = File(path).readAsStringSync();
  final Map<String, dynamic> json = jsonDecode(content) as Map<String, dynamic>;
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  // Project root = cwd when running `flutter test`.
  const arbDir = 'lib/l10n';
  const locales = ['pt', 'de', 'es', 'fr', 'it', 'ja', 'ko', 'ru', 'zh'];

  late Set<String> enKeys;

  setUpAll(() {
    enKeys = _arbKeys('$arbDir/app_en.arb');
  });

  for (final locale in locales) {
    test('$locale has all keys present in en', () {
      final path = '$arbDir/app_$locale.arb';
      expect(File(path).existsSync(), isTrue, reason: '$path not found');

      final localeKeys = _arbKeys(path);
      final missing = enKeys.difference(localeKeys);
      expect(
        missing,
        isEmpty,
        reason: 'app_$locale.arb is missing: ${missing.join(', ')}',
      );
    });

    test('$locale has no keys absent from en (no stale keys)', () {
      final path = '$arbDir/app_$locale.arb';
      if (!File(path).existsSync()) return; // caught by test above

      final localeKeys = _arbKeys(path);
      final extra = localeKeys.difference(enKeys);
      expect(
        extra,
        isEmpty,
        reason: 'app_$locale.arb has stale keys not in en: ${extra.join(', ')}',
      );
    });
  }
}
