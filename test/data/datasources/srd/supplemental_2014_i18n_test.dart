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
  for (final locale in ['pt', 'es']) {
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
            if (spell['higherLevels'] != null) {
              expect(i18n.spellHigherLevels(name), isNotNull, reason: name);
              expect(
                i18n.spellHigherLevels(name),
                isNot(spell['higherLevels']),
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
            }
          }
        },
      );

      test(
        'Wild Magic table and complete discipline feature are displayed in the selected language',
        () {
          final surge = i18n.subclassFeatureDescription(
            'Sorcerer',
            'Wild Magic',
            'Wild Magic Surge',
          )!;
          expect(
            RegExp(r'^\d{2}-\d{2}:', multiLine: true).allMatches(surge),
            hasLength(50),
          );
          expect(
            surge,
            contains(
              locale == 'pt' ? 'pontos de feitiçaria' : 'puntos de hechicería',
            ),
          );
          expect(surge, isNot(contains('Cast Fireball')));
          final disciplines = i18n.subclassFeatureDescription(
            'Monk',
            'Way of the Four Elements',
            'Disciple of the Elements',
          )!;
          expect(
            disciplines,
            contains(locale == 'pt' ? 'Chicote de Água' : 'Látigo de agua'),
          );
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
            locale == 'pt' ? 'Serviçais' : 'Sirvientes',
          );
          expect(
            i18n.backgroundFeatureName('Pirate'),
            locale == 'pt' ? 'Má Reputação' : 'Mala reputación',
          );
          expect(
            i18n.backgroundEquipmentName('Letter of introduction'),
            locale == 'pt' ? 'Carta de apresentação' : 'Carta de presentación',
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
