import 'dart:convert';

import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _markers(String? text) =>
    RegExp(r'\{\{(?:distance|area|volume):([^|}]+)(?:\|[a-z]+)?\}\}')
        .allMatches(text ?? '')
        .map((m) => m[1]!)
        .toList()
      ..sort();

List<String> _dice(String? text) => RegExp(
  r'(?<![A-Za-z0-9])\d+d\d+(?![A-Za-z0-9])',
).allMatches(text ?? '').map((m) => m[0]!).toList()..sort();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Map<String, dynamic>> spells;

  setUpAll(() async {
    final catalog =
        jsonDecode(
              await rootBundle.loadString('assets/data/2024/phb_spells.json'),
            )
            as Map<String, dynamic>;
    spells = (catalog['spells'] as List).cast<Map<String, dynamic>>();
  });

  for (final locale in [
    'pt', 'es', 'fr', 'de', 'it', 'ja', 'ko', 'ru', 'tr', 'zh',
  ]) {
    group('2024 P3 spells $locale', () {
      late SrdI18nService i18n;
      setUpAll(() async {
        i18n = await SrdI18nService.load(
          locale,
          pack: SrdContentPackRegistry.srd521,
        );
      });

      test('all 39 spells have localized names and complete rules', () {
        expect(spells, hasLength(39));
        final names = <String>{};
        for (final spell in spells) {
          final key = spell['name'] as String;
          final name = i18n.spellName(key);
          expect(name, isNot(key), reason: key);
          expect(names.add(name), isTrue, reason: 'duplicate name $name');
          for (final (field, translated) in [
            ('description', i18n.spellDescription(key)),
            ('higherLevels', i18n.spellHigherLevels(key)),
          ]) {
            final english = spell[field] as String?;
            if (english == null) {
              expect(translated, isNull, reason: '$key.$field');
              continue;
            }
            expect(translated, isNotNull, reason: '$key.$field');
            expect(translated, isNot(english), reason: '$key.$field');
            expect(_markers(translated), _markers(english), reason: '$key.$field');
            expect(_dice(translated), _dice(english), reason: '$key.$field');
            expect(translated, isNot(contains('�')), reason: '$key.$field');
          }
          expect(
            i18n.spellMaterial(key) == null,
            spell['material'] == null,
            reason: '$key.material',
          );
        }
      });

      test('new spell names do not repeat another spell name', () async {
        final overlay =
            jsonDecode(
                  await rootBundle.loadString(
                    'assets/data/i18n/$locale/5.2.1/spells.json',
                  ),
                )
                as Map<String, dynamic>;
        final byName = <String, List<String>>{};
        for (final entry in overlay.entries) {
          final name = (entry.value as Map)['name'] as String;
          (byName[name.toLowerCase()] ??= []).add(entry.key);
        }
        final newKeys = {for (final spell in spells) spell['name'] as String};
        expect(
          {
            for (final entry in byName.entries)
              if (entry.value.length > 1 && entry.value.any(newKeys.contains))
                entry.key: entry.value,
          },
          isEmpty,
        );
      });
    });
  }
}
