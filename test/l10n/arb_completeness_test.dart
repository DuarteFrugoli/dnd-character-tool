import 'dart:convert';
import 'dart:io';

import 'package:dnd_character_tool/core/locale/locale_provider.dart';
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
  // Every language the app offers, so a new one cannot ship without its ARB.
  final locales = [
    for (final locale in supportedLocales)
      if (locale.languageCode != 'en') locale.languageCode,
  ];

  late Set<String> enKeys;

  setUpAll(() {
    enKeys = _arbKeys('$arbDir/app_en.arb');
  });

  test('every ARB file belongs to a supported locale', () {
    final supported = {for (final locale in supportedLocales) locale.languageCode};
    final arbLocales = {
      for (final file in Directory(arbDir).listSync())
        if (RegExp(r'app_(\w+)\.arb$').firstMatch(file.path) case final match?)
          match.group(1)!,
    };
    expect(arbLocales, supported);
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
