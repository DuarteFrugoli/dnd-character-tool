import 'dart:convert';
import 'dart:io';

import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/supplemental_2014_catalog.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> markers(String s) =>
    RegExp(r'\{\{[^}]+\}\}').allMatches(s).map((m) => m.group(0)!).toList()
      ..sort();

List<String> dice(String s) => RegExp(
  r'(?<![A-Za-z0-9])\d+d\d+(?![A-Za-z0-9])',
).allMatches(s).map((m) => m.group(0)!).toList()..sort();

// Grammar flags such as |adj vary by language; values and units must not.
List<String> distances(String s) => markers(
  s,
).map((marker) => marker.replaceAll(RegExp(r'\|[^}]+'), '')).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'supplemental interface labels retain Unicode in every app language',
    () {
      for (final locale in [
        'en',
        'pt',
        'es',
        'de',
        'fr',
        'it',
        'ja',
        'ko',
        'ru',
        'tr',
        'zh',
      ]) {
        final arb =
            jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
                as Map;
        for (final key in [
          'backgroundPersonalitySuggestions',
          'featureChoiceReplacementLimit',
          'monsterNonmagicalAttacks',
        ]) {
          final text = arb[key] as String;
          expect(
            text,
            isNot(contains('?')),
            reason: '$locale.$key has replacement question marks',
          );
          expect(
            text,
            isNot(contains('\uFFFD')),
            reason: '$locale.$key has invalid Unicode',
          );
        }
      }
    },
  );
  final source = SrdDataSource.forPack(SrdContentPackRegistry.srd51);
  const localized = {
    'pt': {
      'sorceryPoints': 'pontos de feitiçaria',
      'waterWhip': 'Chicote de Água',
      'retainers': 'Serviçais',
      'badReputation': 'Má Reputação',
      'letter': 'Carta de apresentação',
    },
    'es': {
      'sorceryPoints': 'puntos de hechicería',
      'waterWhip': 'Látigo de agua',
      'retainers': 'Sirvientes',
      'badReputation': 'Mala reputación',
      'letter': 'Carta de presentación',
    },
    'fr': {
      'sorceryPoints': 'points de sorcellerie',
      'waterWhip': "Fouet d'eau",
      'retainers': 'Serviteurs',
      'badReputation': 'Mauvaise réputation',
      'letter': 'Lettre de recommandation',
    },
    'it': {
      'sorceryPoints': 'punti stregoneria',
      'waterWhip': "Frusta d'Acqua",
      'retainers': 'Servitori',
      'badReputation': 'Cattiva Reputazione',
      'letter': 'Lettera di presentazione',
    },
    'de': {
      'sorceryPoints': 'Zaubereipunkte',
      'waterWhip': 'Wasserpeitsche',
      'retainers': 'Gefolgsleute',
      'badReputation': 'Schlechter Ruf',
      'letter': 'Empfehlungsschreiben',
    },
    'ja': {
      'sorceryPoints': '魔力点',
      'waterWhip': '水の鞭',
      'retainers': '従者',
      'badReputation': '悪名',
      'letter': '紹介状',
    },
  };
  for (final locale in localized.keys) {
    group('2014 supplemental $locale', () {
      late SrdI18nService i18n;
      setUpAll(() async {
        i18n = await SrdI18nService.load(locale);
      });

      test(
        'all 30 spells have localized names, rules, scaling and materials',
        () async {
          final spells = await Supplemental2014Catalog.spells();
          for (final spell in spells) {
            final name = spell['name'] as String;
            final text = i18n.spellDescription(name);
            expect(text, isNotNull, reason: name);
            expect(text, isNot(spell['description']), reason: name);
            expect(i18n.spellName(name), isNot(name), reason: name);
            expect(
              markers(text!),
              markers(spell['description'] as String),
              reason: name,
            );
            expect(
              dice(text),
              dice(spell['description'] as String),
              reason: name,
            );
            if (spell['higherLevels'] != null) {
              expect(i18n.spellHigherLevels(name), isNotNull, reason: name);
              expect(
                i18n.spellHigherLevels(name),
                isNot(spell['higherLevels']),
                reason: name,
              );
              expect(
                dice(i18n.spellHigherLevels(name)!),
                dice(spell['higherLevels'] as String),
                reason: name,
              );
            }
            if (spell['material'] != null) {
              expect(i18n.spellMaterial(name), isNotNull, reason: name);
              expect(
                i18n.spellMaterial(name),
                isNot(spell['material']),
                reason: name,
              );
            }
          }
        },
      );

      test(
        'every invocation, discipline, terrain and totem has a translated option',
        () async {
          final extra = await Supplemental2014Catalog.options();
          final choices = extra['featureChoices'] as Map;
          for (final entry in (choices['optionSources'] as Map).entries) {
            for (final row in entry.value as List) {
              final text = i18n.featureChoiceOptionDescription(
                sourceType: 'classFeature',
                sourceClass: 'Warlock',
                featureName: 'Eldritch Invocations',
                choiceId: 'invocations',
                optionId: row['id'] as String,
                optionsSource: entry.key as String,
              );
              expect(text, isNotNull, reason: '${entry.key}.${row['id']}');
              expect(
                text,
                isNot(row['description']),
                reason: row['id'] as String,
              );
              expect(
                markers(text!),
                markers(row['description'] as String),
                reason: row['id'] as String,
              );
              expect(
                dice(text),
                dice(row['description'] as String),
                reason: row['id'] as String,
              );
            }
          }
        },
      );

      test(
        'Wild Magic table and complete discipline feature are displayed in the selected language',
        () async {
          final surge = i18n.subclassFeatureDescription(
            'Sorcerer',
            'Wild Magic',
            'Wild Magic Surge',
          )!;
          expect(
            RegExp(r'^\d{2}-\d{2}:', multiLine: true).allMatches(surge),
            hasLength(50),
          );
          expect(surge, contains(localized[locale]!['sorceryPoints']));
          expect(surge, isNot(contains('Cast Fireball')));
          final original = await Supplemental2014Catalog.options();
          final outcomes =
              (original['wildMagicSurge'] as Map)['outcomes'] as List;
          final rows = RegExp(
            r'^(\d{2}-\d{2}): (.*)$',
            multiLine: true,
          ).allMatches(surge).toList();
          for (var i = 0; i < outcomes.length; i++) {
            final outcome = outcomes[i] as Map;
            final min = (outcome['min'] as int).toString().padLeft(2, '0');
            final max = outcome['max'] == 100
                ? '00'
                : (outcome['max'] as int).toString().padLeft(2, '0');
            expect(rows[i].group(1), '$min-$max');
            final text = rows[i].group(2)!;
            final reference = outcome['description'] as String;
            expect(
              distances(text),
              distances(reference),
              reason: '$locale.$min',
            );
            expect(dice(text), dice(reference), reason: '$locale.$min');
            expect(text, isNot(reference), reason: '$locale.$min');
          }
          final disciplines = i18n.subclassFeatureDescription(
            'Monk',
            'Way of the Four Elements',
            'Disciple of the Elements',
          )!;
          expect(disciplines, contains(localized[locale]!['waterWhip']));
          expect(disciplines, contains('17-20: 6'));
          expect(
            i18n.subclassFeatureDescription(
              'Druid',
              'Circle of the Land',
              'Circle Spells',
            ),
            isNotNull,
          );
        },
      );

      test(
        'background variants, their equipment and all personality categories are translated',
        () async {
          for (final bg in await source.getBackgrounds()) {
            final suggestions = i18n.backgroundPersonalitySuggestions(
              bg.name,
              bg.personalitySuggestions,
            );
            for (final category in bg.personalitySuggestions.entries) {
              expect(
                suggestions[category.key],
                hasLength(category.value.length),
              );
              for (var i = 0; i < category.value.length; i++) {
                expect(
                  suggestions[category.key]![i],
                  isNot(category.value[i]),
                  reason: '${bg.name}.${category.key}.$i',
                );
              }
            }
          }
          expect(
            i18n.backgroundFeatureName('Knight'),
            localized[locale]!['retainers'],
          );
          expect(
            i18n.backgroundFeatureName('Pirate'),
            localized[locale]!['badReputation'],
          );
          expect(
            i18n.backgroundEquipmentName('Letter of introduction'),
            localized[locale]!['letter'],
          );
        },
      );

      test(
        'all new equipment reaches translated inventory names and descriptions',
        () async {
          final extra =
              jsonDecode(
                    await rootBundle.loadString(
                      'assets/data/2014/phb_equipment.json',
                    ),
                  )
                  as Map;
          for (final gear in extra['gear'] as List) {
            final name = gear['name'] as String;
            expect(i18n.equipmentDescription(name), isNotNull, reason: name);
            expect(
              i18n.equipmentDescription(name),
              isNot(gear['description']),
              reason: name,
            );
            expect(
              markers(i18n.equipmentDescription(name)!),
              markers(gear['description'] as String),
              reason: name,
            );
          }
        },
      );

      test(
        'new creature trait and action translations preserve every distance marker',
        () async {
          const names = {
            'Imp',
            'Pseudodragon',
            'Quasit',
            'Sprite',
            'Air Elemental',
            'Earth Elemental',
            'Fire Elemental',
            'Water Elemental',
            'Elephant',
            'Giant Boar',
            'Giant Constrictor Snake',
            'Giant Crocodile',
            'Giant Elk',
            'Giant Scorpion',
            'Giant Shark',
            'Hunter Shark',
            'Killer Whale',
            'Mammoth',
            'Plesiosaurus',
            'Polar Bear',
            'Rhinoceros',
            'Saber-Toothed Tiger',
            'Swarm of Poisonous Snakes',
            'Triceratops',
          };
          for (final monster in await source.getMonsters()) {
            if (!names.contains(monster.name)) continue;
            for (final (section, entries) in [
              ('traits', monster.traits),
              ('actions', monster.actions),
            ]) {
              for (final entry in entries) {
                final text = i18n.monsterEntryDescription(
                  monster.name,
                  section,
                  entry.id,
                );
                expect(text, isNotNull, reason: '${monster.name}.${entry.id}');
                expect(
                  text,
                  isNot(entry.description),
                  reason: '${monster.name}.${entry.id}',
                );
                expect(
                  markers(text!),
                  markers(entry.description),
                  reason: '${monster.name}.${entry.id}',
                );
                expect(
                  dice(text),
                  dice(entry.description),
                  reason: '${monster.name}.${entry.id}',
                );
                expect(
                  i18n.monsterEntryName(monster.name, section, entry.id),
                  isNotNull,
                );
              }
            }
          }
        },
      );
    });
  }
}
