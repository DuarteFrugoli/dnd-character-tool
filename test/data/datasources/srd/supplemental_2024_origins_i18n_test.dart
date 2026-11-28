import 'dart:convert';

import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _markers(String text) =>
    RegExp(r'\{\{[^}]+\}\}').allMatches(text).map((m) => m[0]!).toList()
      ..sort();

List<String> _dice(String text) => RegExp(
  r'(?<![A-Za-z0-9])\d+d\d+(?![A-Za-z0-9])',
).allMatches(text).map((m) => m[0]!).toList()..sort();

Future<Map<String, dynamic>> _overlay(String locale, String name) async =>
    jsonDecode(
          await rootBundle.loadString(
            'assets/data/i18n/$locale/5.2.1/$name.json',
          ),
        )
        as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Map<String, dynamic> source;

  setUpAll(() async {
    source =
        jsonDecode(
              await rootBundle.loadString('assets/data/2024/phb_origins.json'),
            )
            as Map<String, dynamic>;
  });

  for (final locale in [
    'pt',
    'es',
    'fr',
    'de',
    'it',
    'ja',
    'ko',
    'ru',
    'tr',
    'zh',
  ]) {
    group('2024 P1 $locale', () {
      late SrdI18nService i18n;
      setUpAll(() async {
        i18n = await SrdI18nService.load(
          locale,
          pack: SrdContentPackRegistry.srd521,
        );
      });

      test('all six Origin feats have localized names and complete rules', () {
        final feats = source['feats'] as List;
        expect(feats, hasLength(6));
        for (final feat in feats) {
          final key = feat['name'] as String;
          final description = i18n.featDescription(key);
          expect(i18n.featName(key), isNotNull, reason: key);
          expect(i18n.featName(key), isNot(key), reason: key);
          expect(description, isNotNull, reason: key);
          expect(description, isNot(feat['description']), reason: key);
          expect(
            _markers(description!),
            _markers(feat['description'] as String),
            reason: key,
          );
          expect(
            _dice(description),
            _dice(feat['description'] as String),
            reason: key,
          );
          expect(description, isNot(contains('\uFFFD')), reason: key);
        }
      });

      test(
        'Aasimar, its traits and its resources reach the translated sheet',
        () async {
          final races = await _overlay(locale, 'races');
          // Aasimar is also the correct name in several translation languages.
          expect(races['Aasimar'], contains('name'));
          expect(i18n.raceName('Aasimar'), races['Aasimar']['name']);
          for (final entry in (source['raceTraits'] as Map).entries) {
            final key = entry.key as String;
            final description = i18n.raceTraitDescription(key);
            expect(i18n.raceTraitName(key), isNot(key), reason: key);
            expect(description, isNotNull, reason: key);
            expect(description, isNot(entry.value), reason: key);
            expect(
              _markers(description!),
              _markers(entry.value as String),
              reason: key,
            );
            expect(
              _dice(description),
              _dice(entry.value as String),
              reason: key,
            );
            expect(description, isNot(contains('\uFFFD')), reason: key);
          }
          final healing = i18n.raceTraitDescription('Healing Hands')!;
          expect(RegExp(r'(?:d4|W4)').hasMatch(healing), isTrue);
          final resources = source['featureUsages']['resources'] as Map;
          for (final entry in resources.entries) {
            final original = entry.value['name'] as String;
            final name = i18n.featureUsageResourceName(
              entry.key as String,
              original,
            );
            expect(name, isNot(original), reason: entry.key as String);
            expect(name, isNotEmpty);
          }
          expect(
            i18n.featureUsageResourceName(
              '2024_healing_hands',
              'Healing Hands',
            ),
            i18n.raceTraitName('Healing Hands'),
          );
          expect(
            i18n.featureUsageResourceName(
              '2024_celestial_revelation',
              'Celestial Revelation',
            ),
            i18n.raceTraitName('Celestial Revelation'),
          );
        },
      );

      test(
        'all twelve backgrounds and their starting equipment are localized',
        () async {
          final backgrounds = await _overlay(locale, 'backgrounds');
          final equipment = await _overlay(locale, 'equipment');
          final tools = await _overlay(locale, 'tools');
          final names = {
            for (final entry in {...tools, ...equipment}.entries)
              entry.key.toLowerCase(): (entry.value as Map)['name'],
          };
          expect(source['backgrounds'], hasLength(12));
          for (final background in source['backgrounds'] as List) {
            final key = background['name'] as String;
            expect(backgrounds[key], contains('name'), reason: key);
            expect(i18n.backgroundName(key), backgrounds[key]['name']);
            expect(i18n.backgroundName(key), isNotEmpty);
            for (final option in background['equipmentChoices'] as List) {
              for (final item in option['items'] as List) {
                final name = item['name'] as String;
                final variant = item['variant'] as String?;
                final fullName = variant == null ? name : '$name ($variant)';
                expect(names[name.toLowerCase()], isNotNull, reason: name);
                expect(i18n.equipmentName(name), names[name.toLowerCase()]);
                if (variant != null) {
                  expect(
                    names[fullName.toLowerCase()],
                    isNotNull,
                    reason: fullName,
                  );
                  expect(
                    i18n.equipmentName(fullName),
                    names[fullName.toLowerCase()],
                  );
                  expect(i18n.equipmentName(fullName), isNot(fullName));
                }
              }
            }
          }
        },
      );

      test('Crafter and Musician choices use the localized tool names', () {
        final sources = source['featureChoices']['optionSources'] as Map;
        var count = 0;
        for (final entry in sources.entries) {
          final isCrafter = entry.key == 'crafter_tools_2024';
          final feat = isCrafter ? 'Crafter' : 'Musician';
          for (final option in entry.value as List) {
            count++;
            final name = i18n.featureChoiceOptionName(
              sourceType: 'feat',
              sourceClass: '',
              sourceName: feat,
              featureName: feat,
              choiceId: isCrafter ? 'tools' : 'instruments',
              optionId: option['id'] as String,
              optionsSource: entry.key as String,
            );
            expect(name, isNotNull, reason: option['id'] as String);
            expect(name, i18n.toolName(option['name'] as String));
          }
        }
        expect(count, 18);
      });
    });
  }
}
