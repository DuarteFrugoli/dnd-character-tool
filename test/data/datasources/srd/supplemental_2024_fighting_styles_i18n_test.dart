import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _markers(String text) =>
    RegExp(r'\{\{[^}]+\}\}').allMatches(text).map((m) => m[0]!).toList()
      ..sort();

List<String> _dice(String text) => RegExp(
  r'(?<![A-Za-z0-9])\d+d\d+(?![A-Za-z0-9])',
).allMatches(text).map((m) => m[0]!).toList()..sort();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Map<String, dynamic> source;

  setUpAll(() async {
    source =
        jsonDecode(
              await rootBundle.loadString('assets/data/2024/phb_feats.json'),
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
    group('2024 P2 $locale', () {
      late SrdI18nService i18n;
      setUpAll(() async {
        i18n = await SrdI18nService.load(
          locale,
          pack: SrdContentPackRegistry.srd521,
        );
      });

      test('all six feats preserve localized rules, distances and dice', () {
        final styles = (source['feats'] as List).where(
          (feat) => feat['category'] == 'fighting_style',
        );
        expect(styles, hasLength(6));
        for (final style in styles) {
          final key = style['name'] as String;
          final original = style['description'] as String;
          final name = i18n.featName(key);
          final text = i18n.featDescription(key);
          // Some correct names, such as French Protection, match English.
          expect(name, isNotNull, reason: key);
          expect(name, isNotEmpty, reason: key);
          expect(text, isNotNull, reason: key);
          expect(text, isNot(original), reason: key);
          expect(_markers(text!), _markers(original), reason: key);
          expect(_dice(text), _dice(original), reason: key);
          if (original.contains('+2')) {
            expect(text, contains('+2'), reason: key);
          }
          expect(text, isNot(contains('\uFFFD')), reason: key);
        }
      });

      test(
        'all class lists and Champion choices use the translated styles',
        () {
          final sources = source['featureChoices']['optionSources'] as Map;
          var count = 0;
          for (final sourceId in [
            'fighting_styles_2024',
            'paladin_fighting_styles_2024',
            'ranger_fighting_styles_2024',
          ]) {
            final owner = switch (sourceId) {
              'paladin_fighting_styles_2024' => 'Paladin',
              'ranger_fighting_styles_2024' => 'Ranger',
              _ => 'Fighter',
            };
            for (final option in sources[sourceId] as List) {
              count++;
              final optionId = option['id'] as String;
              final name = i18n.featureChoiceOptionName(
                sourceType: 'classFeature',
                sourceClass: owner,
                featureName: 'Fighting Style',
                choiceId: 'fighting_style',
                optionsSource: sourceId,
                optionId: optionId,
              );
              final text = i18n.featureChoiceOptionDescription(
                sourceType: 'classFeature',
                sourceClass: owner,
                featureName: 'Fighting Style',
                choiceId: 'fighting_style',
                optionsSource: sourceId,
                optionId: optionId,
              );
              final original = option['description'] as String;
              expect(
                name,
                i18n.featName(option['name'] as String),
                reason: optionId,
              );
              expect(name, isNotNull, reason: optionId);
              expect(text, isNotNull, reason: optionId);
              expect(text, isNot(original), reason: optionId);
              expect(_markers(text!), _markers(original), reason: optionId);
              expect(_dice(text), _dice(original), reason: optionId);
              if (original.contains('+2')) {
                expect(text, contains('+2'));
              }
              if (owner == 'Fighter') {
                expect(
                  i18n.featureChoiceOptionName(
                    sourceType: 'subclassFeature',
                    sourceClass: 'Fighter',
                    sourceSubclass: 'Champion',
                    featureName: 'Additional Fighting Style',
                    choiceId: 'fighting_style',
                    optionsSource: sourceId,
                    optionId: optionId,
                  ),
                  name,
                );
              }
            }
          }
          expect(count, 18);
        },
      );

      test(
        'feat names agree with the labels shown in weapon roll notes',
        () async {
          final l10n = await AppLocalizations.delegate.load(Locale(locale));
          expect(i18n.featName('Dueling'), l10n.fightingStyleDueling);
          expect(
            i18n.featName('Thrown Weapon Fighting'),
            l10n.fightingStyleThrownWeaponFighting,
          );
        },
      );
    });
  }
}
