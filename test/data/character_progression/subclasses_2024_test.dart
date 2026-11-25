import 'package:dnd_character_tool/data/character_progression/progression_2024_engine.dart';
import 'package:dnd_character_tool/data/constants/armor_class.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/supplemental_2024_catalog.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/feature_choice_option_resolver.dart';
import 'package:dnd_character_tool/data/feature_usage_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/data/rulesets/wild_shape_rules.dart';
import 'package:dnd_character_tool/data/wild_shape/wild_shape_engine.dart';
import 'package:flutter_test/flutter_test.dart';

late Rules2024Data data;
late FeatureUsageCatalog usages;

Character character(String cls, {int level = 2, String? subclass}) => Character(
  id: 'subclass-test',
  rulesetId: RulesetId.dnd2024,
  contentPackId: ContentPackId.srd521,
  name: cls,
  race: 'Human',
  characterClass: cls,
  level: level,
  classes: [
    CharacterClassEntry(
      id: 'primary',
      className: cls,
      level: level,
      subclassName: subclass,
      isStartingClass: true,
    ),
  ],
  abilityScores: const AbilityScores(
    strength: 14,
    dexterity: 14,
    constitution: 14,
    intelligence: 16,
    wisdom: 16,
    charisma: 16,
  ),
  hitPoints: const HitPoints(maximum: 20, current: 20),
  levelHistory: [
    for (var i = 1; i <= level; i++)
      CharacterLevelRecord(
        characterLevel: i,
        classEntryId: 'primary',
        className: cls,
        classLevel: i,
        hitPointsGained: 10,
        hitPointMethod: HitPointGainMethod.average,
      ),
  ],
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

List<CharacterFeatureChoice> completeChoices(
  Character before,
  List<FeatureChoiceRequest> requests,
) {
  var choices = [...before.featureChoices];
  for (final request in requests) {
    if (!request.isApplicable(choices)) continue;
    final resolver = FeatureChoiceOptionResolver(
      request: request,
      catalog: data.choices,
      i18n: SrdI18nService.english,
      skills: data.skills,
      tools: data.tools,
      spells: data.spells,
      languages: data.languages,
      weapons: const [],
      feats: data.feats,
      monsters: data.monsters,
      character: before,
      relatedRequests: requests,
      choices: choices,
    );
    final selected = [...?request.findIn(choices)?.values];
    for (final option in resolver.options) {
      if (selected.length >= request.requiredCount) break;
      if (option.target != null || selected.contains(option.id)) continue;
      selected.add(option.id);
    }
    expect(
      selected.length,
      request.requiredCount,
      reason:
          '${request.sourceClass} ${request.sourceSubclass} '
          '${request.featureName}/${request.choiceId} must be completable',
    );
    choices = FeatureChoiceEngine.upsertChoices(choices, [
      request.toChoice(selected),
    ]);
  }
  return choices;
}

Character gainSubclass(String cls, String subclass) {
  final before = character(cls);
  final plan = Progression2024Engine.plan(
    before,
    data,
    className: cls,
    classEntryId: 'primary',
  );
  final requests = Progression2024Engine.requestsFor(
    before,
    data,
    plan,
    subclassName: subclass,
  );
  return Progression2024Engine.applyLevelUp(
    before,
    data,
    LevelUp2024Result(
      className: cls,
      classEntryId: 'primary',
      subclassName: subclass,
      featureChoices: completeChoices(before, requests),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    data = await Rules2024Data.load();
    usages = await SrdDataSource.forPack(
      SrdContentPackRegistry.srd521,
    ).getFeatureUsageCatalog();
  });

  test('all 12 classes offer four distinct 2024 PHB subclasses', () {
    expect(
      data.subclasses.keys.toSet(),
      data.classes.map((cls) => cls.name).toSet(),
    );
    for (final cls in data.classes) {
      final subclasses = data.subclasses[cls.name]!;
      expect(subclasses, hasLength(4), reason: cls.name);
      expect(subclasses.map((s) => s.name).toSet(), hasLength(4));
      for (final subclass in subclasses) {
        final features = data.subclassFeatures[cls.name]![subclass.name]!;
        expect(features, isNotEmpty);
        expect(
          features.every(
            (f) => f.level >= 3 && f.level <= 20 && f.description.isNotEmpty,
          ),
          isTrue,
        );
        expect(features.any((f) => f.level == 3), isTrue);
      }
    }
  });

  test('every subclass can be selected and applied at level 3', () {
    for (final cls in data.classes) {
      for (final subclass in data.subclasses[cls.name]!) {
        final after = gainSubclass(cls.name, subclass.name);
        expect(after.primaryClass.subclassName, subclass.name);
        expect(after.totalLevel, 3);
        expect(
          Character.fromJson(after.toJson()).primaryClass.subclassName,
          subclass.name,
        );
      }
    }
  });

  test('subclass spell grants resolve to real spells at every milestone', () {
    final spells = {for (final spell in data.spells) spell.name: spell};
    for (final cls in data.classes) {
      for (final subclass in data.subclasses[cls.name]!) {
        for (final milestone in subclass.alwaysPreparedSpells.entries) {
          final sheet = character(
            cls.name,
            level: milestone.key,
            subclass: subclass.name,
          );
          final synced = Progression2024Engine.syncSubclassSpells(sheet, data);
          for (final name in milestone.value) {
            expect(spells.containsKey(name), isTrue, reason: name);
            final known = synced.singleWhere((s) => s.name == name);
            expect(known.level, spells[name]!.level, reason: name);
            expect(known.isAlwaysPrepared, isTrue);
          }
        }
      }
    }
  });

  for (final (cls, subclass) in [
    ('Fighter', 'Eldritch Knight'),
    ('Rogue', 'Arcane Trickster'),
  ]) {
    test(
      '$subclass grants Wizard spell choices and one-third caster slots',
      () {
        final after = gainSubclass(cls, subclass);
        final casting = Progression2024Engine.spellcastingFor(
          after,
          data.classes,
        ).single;
        expect(casting.ability, 'intelligence');
        expect(casting.spellListClass, 'wizard');
        expect(casting.preparedSpells, 3);
        expect(casting.cantripsKnown, 2);
        expect(casting.maxSpellLevel, 1);
        expect(after.spellSlots.total, [2, 0, 0, 0, 0, 0, 0, 0, 0]);
        final selected = after.spells.where(
          (s) => s.sourceFeature == 'Spellcasting',
        );
        expect(selected.where((s) => s.level > 0), hasLength(3));
        expect(selected.where((s) => s.level == 0), hasLength(2));
        expect(selected.any((s) => s.isAlwaysPrepared), isFalse);
        if (cls == 'Rogue') {
          expect(
            after.spells.any((s) => s.name == 'Mage Hand' && s.level == 0),
            isTrue,
          );
        }
        final high = after.copyWith(
          classes: [after.primaryClass.copyWith(level: 19)],
        );
        final limits = Progression2024Engine.spellcastingFor(
          high,
          data.classes,
        ).single;
        expect(limits.maxSpellLevel, 4);
        expect(limits.cantripsKnown, 3);
        expect(Progression2024Engine.slotsFor(high, data).$1.total, [
          4,
          3,
          3,
          1,
          0,
          0,
          0,
          0,
          0,
        ]);
      },
    );
  }

  test('third caster multiclass contributions round down independently', () {
    final sheet = character('Fighter', level: 5, subclass: 'Eldritch Knight')
        .copyWith(
          classes: const [
            CharacterClassEntry(
              id: 'primary',
              className: 'Fighter',
              level: 5,
              subclassName: 'Eldritch Knight',
              isStartingClass: true,
            ),
            CharacterClassEntry(id: 'wizard', className: 'Wizard', level: 2),
          ],
        );
    expect(Progression2024Engine.slotsFor(sheet, data).$1.total, [
      4,
      2,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ]);
    final champion = sheet.copyWith(
      classes: [
        sheet.primaryClass.copyWith(subclassName: 'Champion'),
        sheet.classEntries.last,
      ],
    );
    expect(Progression2024Engine.slotsFor(champion, data).$1.total, [
      3,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ]);
  });

  test('Battle Master maneuver progression keeps earlier choices', () {
    final definition = data.choices
        .subclassFeature('Fighter', 'Battle Master', 'Combat Superiority')!
        .choices
        .single;
    expect(definition.requiredCountAtLevel(3), 3);
    expect(definition.requiredCountAtLevel(7), 5);
    expect(definition.requiredCountAtLevel(10), 7);
    expect(definition.requiredCountAtLevel(15), 9);
    expect(definition.options.length, greaterThanOrEqualTo(9));
  });

  test(
    'Arcane Trickster never spends a selectable cantrip on fixed Mage Hand',
    () {
      final before = character('Rogue');
      final plan = Progression2024Engine.plan(
        before,
        data,
        className: 'Rogue',
        classEntryId: 'primary',
      );
      final requests = Progression2024Engine.requestsFor(
        before,
        data,
        plan,
        subclassName: 'Arcane Trickster',
      );
      final cantrips = requests.singleWhere(
        (r) => r.featureName == 'Spellcasting' && r.choiceId == 'cantrips',
      );
      final resolver = FeatureChoiceOptionResolver(
        request: cantrips,
        catalog: data.choices,
        i18n: SrdI18nService.english,
        skills: data.skills,
        tools: data.tools,
        spells: data.spells,
        languages: data.languages,
        weapons: const [],
        feats: data.feats,
      );
      expect(resolver.options.any((o) => o.id == 'Mage Hand'), isFalse);
      final chosen = completeChoices(before, requests);
      final invalid = FeatureChoiceEngine.upsertChoices(chosen, [
        cantrips.toChoice(['Mage Hand', 'Fire Bolt']),
      ]);
      expect(
        () => Progression2024Engine.applyLevelUp(
          before,
          data,
          LevelUp2024Result(
            className: 'Rogue',
            classEntryId: 'primary',
            subclassName: 'Arcane Trickster',
            featureChoices: invalid,
          ),
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'Eldritch Knight validates class spell levels without school restrictions',
    () {
      final before = character('Fighter');
      final plan = Progression2024Engine.plan(
        before,
        data,
        className: 'Fighter',
        classEntryId: 'primary',
      );
      final requests = Progression2024Engine.requestsFor(
        before,
        data,
        plan,
        subclassName: 'Eldritch Knight',
      );
      final spells = requests.singleWhere(
        (r) =>
            r.featureName == 'Spellcasting' && r.choiceId == 'prepared_spells',
      );
      final chosen = completeChoices(before, requests);
      final allowed = FeatureChoiceEngine.upsertChoices(chosen, [
        spells.toChoice(['Shield', 'Magic Missile', 'Charm Person']),
      ]);
      final after = Progression2024Engine.applyLevelUp(
        before,
        data,
        LevelUp2024Result(
          className: 'Fighter',
          classEntryId: 'primary',
          subclassName: 'Eldritch Knight',
          featureChoices: allowed,
        ),
      );
      expect(after.spells.any((s) => s.name == 'Charm Person'), isTrue);
      final invalid = FeatureChoiceEngine.upsertChoices(chosen, [
        spells.toChoice(['Shield', 'Magic Missile', 'Fireball']),
      ]);
      expect(
        () => Progression2024Engine.applyLevelUp(
          before,
          data,
          LevelUp2024Result(
            className: 'Fighter',
            classEntryId: 'primary',
            subclassName: 'Eldritch Knight',
            featureChoices: invalid,
          ),
        ),
        throwsArgumentError,
      );
    },
  );

  test('Gloom Stalker grants Wisdom saves or an eligible replacement', () {
    for (final already in [false, true]) {
      final before = character('Ranger', level: 6, subclass: 'Gloom Stalker')
          .copyWith(
            savingThrowProficiencies: [
              'strength',
              'dexterity',
              if (already) 'wisdom',
            ],
          );
      final plan = Progression2024Engine.plan(
        before,
        data,
        className: 'Ranger',
        classEntryId: 'primary',
      );
      final requests = Progression2024Engine.requestsFor(before, data, plan);
      final ironMind = requests.singleWhere(
        (r) => r.featureName == 'Iron Mind',
      );
      expect(
        ironMind.requirement.options.map((o) => o.id),
        already ? ['intelligence', 'charisma'] : ['wisdom'],
      );
      final after = Progression2024Engine.applyLevelUp(
        before,
        data,
        LevelUp2024Result(
          className: 'Ranger',
          classEntryId: 'primary',
          featureChoices: completeChoices(before, requests),
        ),
      );
      expect(
        after.savingThrowProficiencies,
        contains(already ? 'intelligence' : 'wisdom'),
      );
    }
  });

  test(
    'Wizard Savant spells enter the spellbook without becoming always prepared',
    () {
      final after = gainSubclass('Wizard', 'Abjurer');
      final spells = after.spells.where(
        (s) => s.sourceFeature == 'Abjuration Savant',
      );
      expect(spells, hasLength(2));
      expect(spells.every((s) => !s.isAlwaysPrepared && !s.isPrepared), isTrue);
      final casting = Progression2024Engine.spellcastingFor(
        after,
        data.classes,
      ).single;
      expect(casting.spellbookSize, 12);
      expect(casting.preparedSpells, 6);
    },
  );

  test(
    'supplemental resources and choices refer to existing subclass features',
    () async {
      final extra = await Supplemental2024Catalog.load();
      for (final section in ['featureUsages', 'featureChoices']) {
        final classes = (extra[section] as Map)['subclassFeatures'] as Map;
        for (final cls in classes.entries) {
          for (final subclass in (cls.value as Map).entries) {
            final names = data.subclassFeatures[cls.key]![subclass.key]!
                .map((f) => f.name)
                .toSet();
            for (final feature in (subclass.value as Map).keys) {
              expect(
                names.contains(feature),
                isTrue,
                reason: '${cls.key}/${subclass.key}/$feature',
              );
              if (section == 'featureUsages') {
                final ref = FeatureUsageRef.fromJson(
                  (subclass.value as Map)[feature] as Map<String, dynamic>,
                );
                for (final binding in ref.eligibleRefs(
                  const FeatureUsageContext(
                    totalCharacterLevel: 20,
                    sourceClassLevel: 20,
                  ),
                )) {
                  expect(
                    usages.resource(binding.resourceId),
                    isNotNull,
                    reason: binding.resourceId,
                  );
                }
              }
            }
          }
        }
      }
    },
  );

  test(
    'psionic dice use class levels and maintain separate multiclass pools',
    () {
      final sheet = character('Fighter', level: 3, subclass: 'Psi Warrior')
          .copyWith(
            classes: const [
              CharacterClassEntry(
                id: 'primary',
                className: 'Fighter',
                level: 3,
                subclassName: 'Psi Warrior',
                isStartingClass: true,
              ),
              CharacterClassEntry(
                id: 'rogue',
                className: 'Rogue',
                level: 17,
                subclassName: 'Soulknife',
              ),
            ],
          );
      final fighter = usages.resource('2024_psi_warrior_psionic_dice')!;
      final rogue = usages.resource('2024_soulknife_psionic_dice')!;
      expect(
        FeatureUsageEngine.maxFor(
          fighter,
          sheet,
          usageContext: FeatureUsageContext.forCharacter(
            sheet,
            sourceClass: 'Fighter',
          ),
        ),
        4,
      );
      expect(
        FeatureUsageEngine.maxFor(
          rogue,
          sheet,
          usageContext: FeatureUsageContext.forCharacter(
            sheet,
            sourceClass: 'Rogue',
          ),
        ),
        12,
      );
    },
  );

  test('College of Dance applies its unarmored Armor Class', () {
    expect(
      calcArmorClass(character('Bard', level: 3, subclass: 'College of Dance')),
      15,
    );
    expect(
      calcArmorClass(character('Bard', level: 3, subclass: 'College of Lore')),
      12,
    );
  });

  test('new subclass features share pools and follow their rest rules', () {
    final shadow = usages.subclassFeature(
      'Monk',
      'Warrior of Shadow',
      'Shadow Arts',
    )!;
    expect(shadow.resourceId, '2024_focus_points');
    expect(shadow.spend, 1);
    final cloak = usages.subclassFeature(
      'Monk',
      'Warrior of Shadow',
      'Cloak of Shadows',
    )!;
    expect(cloak.resourceId, shadow.resourceId);
    expect(cloak.spend, 3);
    final majesty = usages.resource('2024_unbreakable_majesty')!;
    expect(
      FeatureUsageEngine.rechargeFor(majesty, character('Bard')),
      'short_rest',
    );
    final flare = usages.resource('2024_warding_flare')!;
    for (final (level, recharge) in [(3, 'long_rest'), (6, 'short_rest')]) {
      final cleric = character(
        'Cleric',
        level: level,
        subclass: 'Light Domain',
      );
      expect(
        FeatureUsageEngine.rechargeFor(
          flare,
          cleric,
          usageContext: FeatureUsageContext.forCharacter(
            cleric,
            sourceClass: 'Cleric',
          ),
        ),
        recharge,
      );
    }
  });

  test(
    'Circle of the Moon applies its shape limits, vitality, and Armor Class',
    () {
      final moon = character('Druid', level: 3, subclass: 'Circle of the Moon');
      const rules = WildShape2024Rules();
      expect(rules.limitsFor(moon)!.maxChallenge, 1);
      expect(
        rules.limitsAt(12, subclass: 'Circle of the Moon')!.maxChallenge,
        4,
      );
      expect(
        data.monsters.any((m) => m.id == 'mammoth' && m.challengeValue == 6),
        isTrue,
      );
      expect(
        rules
            .limitsAt(18, subclass: 'Circle of the Moon')!
            .allows(data.monsters.singleWhere((m) => m.id == 'mammoth')),
        isTrue,
      );
      final form = data.monsters.firstWhere((m) => m.id == 'brown_bear');
      expect(WildShapeEngine.armorClassFor(moon, form), 16);
      final choices = [
        CharacterFeatureChoice(
          sourceType: FeatureChoiceSourceType.classFeature,
          sourceClass: 'Druid',
          sourceClassEntryId: 'primary',
          featureName: 'Wild Shape',
          choiceId: 'known_forms',
          values: [form.id],
        ),
      ];
      final changed = WildShapeEngine.assume(
        moon.copyWith(featureChoices: choices),
        form,
        data.monsters,
        usages,
      );
      expect(changed.hitPoints.temporary, 9);
    },
  );

  test(
    '2014 catalogs do not receive 2024 supplemental spells or subclasses',
    () async {
      final old = SrdDataSource.forPack(SrdContentPackRegistry.srd51);
      final subclasses = await old.getAllSubclassFeatures();
      expect(subclasses['Fighter']!.containsKey('Psi Warrior'), isFalse);
      expect(
        (await old.getSpells()).any((s) => s.name == 'Fount of Moonlight'),
        isFalse,
      );
    },
  );
}
