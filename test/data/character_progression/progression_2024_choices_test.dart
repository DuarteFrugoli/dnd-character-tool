import 'package:dnd_character_tool/data/character_progression/choice_effects.dart';
import 'package:dnd_character_tool/data/character_progression/progression_2024_engine.dart';
import 'package:dnd_character_tool/data/custom_background.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_2024_creation_catalog.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/feature_choice_option_resolver.dart';
import 'package:dnd_character_tool/data/feature_usage_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/speed_rules.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter_test/flutter_test.dart';

late Rules2024Data _data;
late FeatureUsageCatalog _usages;

const _scores = AbilityScores(
  strength: 14,
  dexterity: 14,
  constitution: 14,
  intelligence: 13,
  wisdom: 13,
  charisma: 16,
);

Character _character(
  String cls, {
  int hitDie = 8,
  List<KnownSpell> spells = const [],
  List<CharacterFeatureChoice> choices = const [],
}) {
  final now = DateTime(2024);
  final hp = hitDie + _scores.constitutionModifier;
  return Character(
    id: 'hero',
    rulesetId: RulesetId.dnd2024,
    contentPackId: ContentPackId.srd521,
    name: 'Hero',
    race: 'Human',
    background: 'Sage',
    characterClass: cls,
    classes: [
      CharacterClassEntry(id: 'primary', className: cls, level: 1, isStartingClass: true),
    ],
    abilityScores: _scores,
    hitPoints: HitPoints(maximum: hp, current: hp),
    hitDicePools: [
      CharacterHitDiePool(
        dieSize: hitDie,
        total: 1,
        sourceClass: cls,
        sourceClassEntryId: 'primary',
      ),
    ],
    spells: spells,
    featureChoices: choices,
    levelHistory: [
      CharacterLevelRecord(
        characterLevel: 1,
        classEntryId: 'primary',
        className: cls,
        classLevel: 1,
        hitPointsGained: hp,
        hitPointMethod: HitPointGainMethod.maximum,
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

KnownSpell _classSpell(String name, int level, String cls) => KnownSpell(
  name: name,
  level: level,
  isPrepared: true,
  sourceType: FeatureChoiceSourceType.classFeature,
  sourceClass: cls,
  sourceFeature: cls == 'Warlock' ? 'Pact Magic' : 'Spellcasting',
  sourceClassEntryId: 'primary',
);

CharacterFeatureChoice _invocations(List<String> values) => CharacterFeatureChoice(
  sourceType: FeatureChoiceSourceType.classFeature,
  sourceClass: 'Warlock',
  sourceClassEntryId: 'primary',
  featureName: 'Eldritch Invocations',
  choiceId: 'invocations',
  values: values,
);

Character _warlock({List<String> invocations = const ['pact_of_the_blade']}) =>
    _character(
      'Warlock',
      spells: [
        _classSpell('Eldritch Blast', 0, 'Warlock'),
        _classSpell('Prestidigitation', 0, 'Warlock'),
        _classSpell('Hex', 1, 'Warlock'),
        _classSpell('Armor of Agathys', 1, 'Warlock'),
      ],
      choices: [_invocations(invocations)],
    );

LevelUp2024Plan _plan(Character character) => Progression2024Engine.plan(
  character,
  _data,
  className: character.primaryClassName,
  classEntryId: 'primary',
);

/// Completes every request with [overrides] or placeholders.
List<CharacterFeatureChoice> _choicesFor(
  Character character,
  List<FeatureChoiceRequest> requests, [
  Map<String, List<String>> overrides = const {},
]) => [
  for (final request in requests)
    request.toChoice(
      overrides[request.choiceId] ??
          [
            ...?request.findIn(character.featureChoices)?.values,
            for (var i = 0; i < request.requiredCount; i++) '${request.choiceId}_$i',
          ],
    ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final srd = SrdDataSource.forPack(SrdContentPackRegistry.srd521);
    _data = Rules2024Data(
      classes: await Creation2024Catalog.loadClasses(),
      subclasses: await Creation2024Catalog.loadSubclasses(),
      subclassFeatures: await srd.getAllSubclassFeatures(),
      feats: await srd.getFeats(),
      choices: await srd.getFeatureChoiceCatalog(),
      spells: await srd.getSpells(),
      skills: await srd.getSkills(),
      tools: await srd.getTools(),
      languages: await srd.getLanguages(),
      backgrounds: await Creation2024Catalog.loadBackgrounds(),
      speciesTraits: const [],
    );
    _usages = await srd.getFeatureUsageCatalog();
  });

  group('level-up replacements', () {
    test('a Warlock replaces one cantrip and one spell', () {
      final warlock = _warlock();
      final requests = Progression2024Engine.requestsFor(warlock, _data, _plan(warlock));
      final leveled = Progression2024Engine.applyLevelUp(
        warlock,
        _data,
        LevelUp2024Result(
          className: 'Warlock',
          classEntryId: 'primary',
          featureChoices: _choicesFor(warlock, requests, {
            'invocations': ['pact_of_the_blade', 'devils_sight', 'misty_visions'],
          }),
          spellSwaps: const [
            SpellSwap2024(forget: 'Prestidigitation', learn: 'Minor Illusion'),
            SpellSwap2024(forget: 'Hex', learn: 'Charm Person'),
          ],
        ),
      );
      final names = leveled.spells.map((s) => s.name);

      expect(names, containsAll(['Minor Illusion', 'Charm Person', 'Eldritch Blast']));
      expect(names, isNot(contains('Hex')));
    });

    test('rejects a second swap of the same kind and non-swapping classes', () {
      final warlock = _warlock();
      final requests = Progression2024Engine.requestsFor(warlock, _data, _plan(warlock));
      final choices = _choicesFor(warlock, requests, {
        'invocations': ['pact_of_the_blade', 'devils_sight', 'misty_visions'],
      });
      expect(
        () => Progression2024Engine.applyLevelUp(
          warlock,
          _data,
          LevelUp2024Result(
            className: 'Warlock',
            classEntryId: 'primary',
            featureChoices: choices,
            spellSwaps: const [
              SpellSwap2024(forget: 'Hex', learn: 'Charm Person'),
              SpellSwap2024(forget: 'Armor of Agathys', learn: 'Hellish Rebuke'),
            ],
          ),
        ),
        throwsArgumentError,
      );

      final cleric = _character('Cleric', spells: [_classSpell('Bless', 1, 'Cleric')]);
      final clericRequests = Progression2024Engine.requestsFor(cleric, _data, _plan(cleric));
      expect(
        () => Progression2024Engine.applyLevelUp(
          cleric,
          _data,
          LevelUp2024Result(
            className: 'Cleric',
            classEntryId: 'primary',
            featureChoices: _choicesFor(cleric, clericRequests),
            spellSwaps: const [SpellSwap2024(forget: 'Bless', learn: 'Command')],
          ),
        ),
        throwsArgumentError,
      );
    });

    test('one invocation may change on gaining a level, not two', () {
      var warlock = _warlock(invocations: ['pact_of_the_blade', 'devils_sight', 'misty_visions'])
          .copyWith(
            classes: const [
              CharacterClassEntry(id: 'primary', className: 'Warlock', level: 2, isStartingClass: true),
            ],
            levelHistory: const [
              CharacterLevelRecord(
                characterLevel: 1,
                classEntryId: 'primary',
                className: 'Warlock',
                classLevel: 1,
                hitPointsGained: 10,
              ),
              CharacterLevelRecord(
                characterLevel: 2,
                classEntryId: 'primary',
                className: 'Warlock',
                classLevel: 2,
                hitPointsGained: 7,
              ),
            ],
          );
      final requests = Progression2024Engine.requestsFor(warlock, _data, _plan(warlock));
      final invocations = requests.singleWhere((r) => r.choiceId == 'invocations');
      expect(invocations.requiredCount, 3);

      final swapped = Progression2024Engine.applyLevelUp(
        warlock,
        _data,
        LevelUp2024Result(
          className: 'Warlock',
          classEntryId: 'primary',
          subclassName: 'Fiend Patron',
          featureChoices: _choicesFor(warlock, requests, {
            'invocations': ['pact_of_the_blade', 'devils_sight', 'otherworldly_leap'],
          }),
        ),
      );
      expect(
        swapped.featureChoices.singleWhere((c) => c.choiceId == 'invocations').values,
        contains('otherworldly_leap'),
      );

      expect(
        () => Progression2024Engine.applyLevelUp(
          warlock,
          _data,
          LevelUp2024Result(
            className: 'Warlock',
            classEntryId: 'primary',
            subclassName: 'Fiend Patron',
            featureChoices: _choicesFor(warlock, requests, {
              'invocations': ['pact_of_the_blade', 'otherworldly_leap', 'mask_of_many_faces'],
            }),
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('invocations with targets', () {
    test('Agonizing Blast needs a target and repeats with different ones', () {
      final warlock = _warlock();
      final requests = Progression2024Engine.requestsFor(warlock, _data, _plan(warlock));
      LevelUp2024Result result(List<String> invocations) => LevelUp2024Result(
        className: 'Warlock',
        classEntryId: 'primary',
        featureChoices: _choicesFor(warlock, requests, {'invocations': invocations}),
      );

      expect(
        () => Progression2024Engine.applyLevelUp(
          warlock,
          _data,
          result(['pact_of_the_blade', 'agonizing_blast', 'devils_sight']),
        ),
        throwsArgumentError,
      );
      final leveled = Progression2024Engine.applyLevelUp(
        warlock,
        _data,
        result([
          'pact_of_the_blade',
          ChoiceTargetValue.withTarget('agonizing_blast', 'Eldritch Blast'),
          ChoiceTargetValue.withTarget('agonizing_blast', 'Prestidigitation'),
        ]),
      );
      expect(leveled.totalLevel, 2);
    });

    test('target options follow the Warlock cantrips the sheet knows', () {
      final warlock = _warlock();
      final request = Progression2024Engine.requestsFor(warlock, _data, _plan(warlock))
          .singleWhere((r) => r.choiceId == 'invocations');
      final resolver = FeatureChoiceOptionResolver(
        request: request,
        catalog: _data.choices,
        i18n: SrdI18nService.english,
        skills: _data.skills,
        tools: _data.tools,
        spells: _data.spells,
        languages: _data.languages,
        weapons: const [],
        feats: _data.feats,
        character: warlock,
      );

      expect(
        resolver.targetOptions('warlock_damage_cantrip').map((o) => o.id),
        ['Eldritch Blast'],
      );
      expect(
        resolver.targetOptions('origin_feat').map((o) => o.id),
        containsAll(['Alert', 'Skilled']),
      );
    });

    test('Lessons of the First Ones grants and removes its Origin feat', () {
      final warlock = _warlock();
      final requests = Progression2024Engine.requestsFor(warlock, _data, _plan(warlock));
      final leveled = Progression2024Engine.applyLevelUp(
        warlock,
        _data,
        LevelUp2024Result(
          className: 'Warlock',
          classEntryId: 'primary',
          featureChoices: _choicesFor(warlock, requests, {
            'invocations': [
              'pact_of_the_blade',
              'devils_sight',
              ChoiceTargetValue.withTarget('lessons_of_the_first_ones', 'Alert'),
            ],
          }),
        ),
      );
      expect(leveled.extraFeatures.map((f) => f.name), contains('Alert'));

      final edited = leveled.copyWith(
        featureChoices: [
          for (final choice in leveled.featureChoices)
            choice.choiceId == 'invocations'
                ? choice.copyWith(values: ['pact_of_the_blade', 'devils_sight', 'misty_visions'])
                : choice,
        ],
      );
      final undone = Progression2024Engine.applyChoiceEdits(leveled, edited, _data);
      expect(undone.extraFeatures.map((f) => f.name), isNot(contains('Alert')));
    });
  });

  group('Pact of the Tome', () {
    test('its cantrips and rituals are requested and granted', () {
      final warlock = _warlock(invocations: ['devils_sight']);
      final requests = Progression2024Engine.requestsFor(warlock, _data, _plan(warlock));
      expect(requests.map((r) => r.choiceId), containsAll(['tome_cantrips', 'tome_rituals']));

      final leveled = Progression2024Engine.applyLevelUp(
        warlock,
        _data,
        LevelUp2024Result(
          className: 'Warlock',
          classEntryId: 'primary',
          featureChoices: _choicesFor(warlock, requests, {
            'invocations': ['devils_sight', 'pact_of_the_tome', 'misty_visions'],
            'tome_cantrips': ['Guidance', 'Light', 'Thaumaturgy'],
            'tome_rituals': ['Detect Magic', 'Identify'],
          }),
        ),
      );
      final names = leveled.spells.map((s) => s.name);
      expect(names, containsAll(['Guidance', 'Light', 'Thaumaturgy', 'Detect Magic', 'Identify']));

      final withoutTome = Progression2024Engine.applyChoiceEdits(
        leveled,
        leveled.copyWith(
          featureChoices: [
            for (final choice in leveled.featureChoices)
              choice.choiceId == 'invocations'
                  ? choice.copyWith(values: ['devils_sight', 'misty_visions', 'otherworldly_leap'])
                  : choice,
          ],
        ),
        _data,
      );
      expect(withoutTome.spells.map((s) => s.name), isNot(contains('Guidance')));
      expect(
        withoutTome.featureChoices.map((c) => c.choiceId),
        isNot(contains('tome_cantrips')),
      );
    });
  });

  group('Magic Initiate instances', () {
    test('a new instance cannot reuse a spell list', () {
      final character = _character('Fighter', hitDie: 10, choices: const [
        CharacterFeatureChoice(
          sourceType: FeatureChoiceSourceType.feat,
          sourceClassEntryId: 'background',
          sourceName: 'Magic Initiate',
          featureName: 'Magic Initiate',
          choiceId: 'spell_class',
          values: ['wizard'],
        ),
      ]);
      final spellClass = Progression2024Engine.featRequests(_data, 'Magic Initiate', 4, character)
          .singleWhere((r) => r.choiceId == 'spell_class');

      expect(spellClass.requirement.options.map((o) => o.id), isNot(contains('wizard')));
      expect(spellClass.sourceClassEntryId, 'level-4');
    });

    test('each instance has its own free cast', () {
      final character = _character('Fighter', hitDie: 10, choices: const [
        CharacterFeatureChoice(
          sourceType: FeatureChoiceSourceType.feat,
          sourceClassEntryId: 'background',
          sourceName: 'Magic Initiate',
          featureName: 'Magic Initiate',
          choiceId: 'spell_class',
          values: ['wizard'],
        ),
        CharacterFeatureChoice(
          sourceType: FeatureChoiceSourceType.feat,
          sourceClassEntryId: 'species',
          sourceName: 'Magic Initiate',
          featureName: 'Magic Initiate',
          choiceId: 'spell_class',
          values: ['cleric'],
        ),
      ]).copyWith(
        extraFeatures: const [
          CharacterExtraFeature(
            sourceClass: 'Feat',
            sourceType: FeatureChoiceSourceType.feat,
            sourceClassEntryId: 'background',
            name: 'Magic Initiate',
            level: 1,
            type: 'passive',
            description: '',
          ),
          CharacterExtraFeature(
            sourceClass: 'Feat',
            sourceType: FeatureChoiceSourceType.feat,
            sourceClassEntryId: 'species',
            name: 'Magic Initiate',
            level: 1,
            type: 'passive',
            description: '',
          ),
        ],
      );
      final ids = FeatureUsageEngine.activeResourceBindings(
        character: character,
        catalog: _usages,
      ).map((b) => b.resource.id);

      expect(
        ids,
        containsAll(['2024_magic_initiate_spell:wizard', '2024_magic_initiate_spell:cleric']),
      );
    });
  });

  group('feature resources', () {
    test('selected invocations activate their resources', () {
      final warlock = _warlock(invocations: ['pact_of_the_tome', 'gift_of_the_depths']).copyWith(
        classes: const [
          CharacterClassEntry(id: 'primary', className: 'Warlock', level: 5, isStartingClass: true),
        ],
      );
      final ids = FeatureUsageEngine.activeResourceBindings(
        character: warlock,
        catalog: _usages,
        classFeatureSets: [
          FeatureUsageFeatureSet(
            classEntry: warlock.classEntries.single,
            classFeatures: const [],
            subclassFeatures: const [],
          ),
        ],
      ).map((b) => b.resource.id);

      expect(ids, contains('2024_gift_of_the_depths'));
    });

    test('rolling Initiative recharges Boon of Fate', () {
      final character = _character('Fighter', hitDie: 10).copyWith(
        extraFeatures: const [
          CharacterExtraFeature(
            sourceClass: 'Feat',
            sourceType: FeatureChoiceSourceType.feat,
            sourceClassEntryId: 'level-19',
            name: 'Boon of Fate',
            level: 19,
            type: 'passive',
            description: '',
          ),
        ],
        featureResources: const {'2024_boon_of_fate': 0},
      );
      final bindings = FeatureUsageEngine.activeResourceBindings(
        character: character,
        catalog: _usages,
      );

      expect(
        FeatureUsageEngine.resourcesAfterInitiative(character, bindings)['2024_boon_of_fate'],
        1,
      );
    });

    test('Uncanny Metabolism heals Monk level plus a Martial Arts die', () {
      final monk = _character('Monk', hitDie: 8).copyWith(
        classes: const [
          CharacterClassEntry(id: 'primary', className: 'Monk', level: 2, isStartingClass: true),
        ],
      );
      final heal = Progression2024Engine.healForSpendEffect(
        'monk_level_plus_martial_arts_die',
        monk,
        _data,
      );

      expect(heal, inInclusiveRange(3, 8));
      expect(_usages.resource('2024_uncanny_metabolism')?.onSpend?.restoreResource,
          '2024_focus_points');
    });
  });

  group('speed', () {
    test('Monk Unarmored Movement needs no armor or Shield', () {
      final monk = _character('Monk').copyWith(
        speed: 30,
        classes: const [
          CharacterClassEntry(id: 'primary', className: 'Monk', level: 6, isStartingClass: true),
        ],
      );
      expect(SpeedRules.speedFor(monk, classes2024: _data.classes), 45);

      final shielded = monk.copyWith(
        equipment: [
          EquipmentItem(
            id: 'shield',
            name: 'Shield',
            category: 'armor',
            itemType: ItemType.armor,
            isEquipped: true,
            properties: {'isShield': true, 'acBonus': 2},
          ),
        ],
      );
      expect(SpeedRules.speedFor(shielded, classes2024: _data.classes), 30);
    });

    test('Barbarian Fast Movement stops in Heavy armor', () {
      final barbarian = _character('Barbarian', hitDie: 12).copyWith(
        speed: 30,
        classes: const [
          CharacterClassEntry(id: 'primary', className: 'Barbarian', level: 5, isStartingClass: true),
        ],
      );
      expect(SpeedRules.speedFor(barbarian, classes2024: _data.classes), 40);

      final plated = barbarian.copyWith(
        equipment: [
          EquipmentItem(
            id: 'plate',
            name: 'Plate Armor',
            category: 'armor',
            itemType: ItemType.armor,
            isEquipped: true,
            properties: {'baseAC': 18, 'addDexModifier': false},
          ),
        ],
      );
      expect(SpeedRules.speedFor(plated, classes2024: _data.classes), 30);
    });
  });

  group('custom background', () {
    test('its skills stay through a reset into another class', () {
      final fighter = _character(
        'Fighter',
        hitDie: 10,
        choices: [
          const CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.classFeature,
            sourceClass: 'Fighter',
            sourceClassEntryId: 'primary',
            featureName: ChoiceEffects.classSkillsFeature,
            choiceId: 'skills',
            values: ['acrobatics', 'intimidation'],
          ),
          CustomBackground.skillsChoice('Ship Hand', const ['athletics', 'perception']),
        ],
      ).copyWith(
        background: 'Ship Hand',
        skillProficiencies: const ['athletics', 'perception', 'acrobatics', 'intimidation'],
      );
      final requests = Progression2024Engine.levelOneRequests(fighter, _data, 'Wizard');
      final wizard = Progression2024Engine.resetToLevelOne(
        fighter,
        _data,
        className: 'Wizard',
        choices: _choicesFor(fighter, requests, {
          'skills': ['arcana', 'history'],
          'cantrips': ['Fire Bolt', 'Light', 'Mage Hand'],
          'prepared_spells': ['Magic Missile', 'Shield', 'Sleep', 'Detect Magic', 'Identify', 'Mage Armor'],
        }),
      );

      expect(
        wizard.skillProficiencies,
        unorderedEquals(['athletics', 'perception', 'arcana', 'history']),
      );
    });
  });

  group('reset into another class', () {
    test('swaps class grants and rebuilds level 1 choices', () {
      final fighter = _character(
        'Fighter',
        hitDie: 10,
        choices: const [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.classFeature,
            sourceClass: 'Fighter',
            sourceClassEntryId: 'primary',
            featureName: ChoiceEffects.classSkillsFeature,
            choiceId: 'skills',
            values: ['athletics', 'perception'],
          ),
        ],
      ).copyWith(
        savingThrowProficiencies: const ['strength', 'constitution'],
        skillProficiencies: const ['arcana', 'history', 'athletics', 'perception'],
      );
      final requests = Progression2024Engine.levelOneRequests(fighter, _data, 'Wizard');
      final skills = requests.singleWhere((r) => r.featureName == ChoiceEffects.classSkillsFeature);
      expect(skills.requirement.options.map((o) => o.id), isNot(contains('arcana')));

      final wizard = Progression2024Engine.resetToLevelOne(
        fighter,
        _data,
        className: 'Wizard',
        choices: _choicesFor(fighter, requests, {
          'skills': ['investigation', 'medicine'],
          'cantrips': ['Fire Bolt', 'Light', 'Mage Hand'],
          'prepared_spells': ['Magic Missile', 'Shield', 'Sleep', 'Detect Magic', 'Identify', 'Mage Armor'],
        }),
      );

      expect(wizard.primaryClassName, 'Wizard');
      expect(wizard.savingThrowProficiencies, ['intelligence', 'wisdom']);
      expect(wizard.hitPoints.maximum, 6 + 2);
      expect(wizard.hitDicePools.single.dieSize, 6);
      // Sage keeps Arcana and History; Fighter skills are replaced.
      expect(wizard.skillProficiencies, containsAll(['arcana', 'history', 'investigation', 'medicine']));
      expect(wizard.skillProficiencies, isNot(contains('athletics')));
      expect(wizard.spells.where((s) => s.level == 1), hasLength(6));
      expect(wizard.spells.where((s) => s.level == 1 && s.isPrepared), hasLength(4));
      expect(wizard.levelHistory.single.className, 'Wizard');
    });
  });
}
