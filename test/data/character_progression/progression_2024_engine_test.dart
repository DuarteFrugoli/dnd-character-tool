import 'package:dnd_character_tool/data/character_progression/progression_2024_engine.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_2024_creation_catalog.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter_test/flutter_test.dart';

late Rules2024Data _data;

Character _character({
  String cls = 'Fighter',
  int hitDie = 10,
  AbilityScores scores = const AbilityScores(
    strength: 15,
    dexterity: 14,
    constitution: 14,
    intelligence: 13,
    wisdom: 13,
    charisma: 12,
  ),
}) {
  final now = DateTime(2024);
  final hp = hitDie + scores.constitutionModifier;
  return Character(
    id: 'hero',
    rulesetId: RulesetId.dnd2024,
    contentPackId: ContentPackId.srd521,
    name: 'Hero',
    race: 'Human',
    characterClass: cls,
    classes: [
      CharacterClassEntry(
        id: 'primary',
        className: cls,
        level: 1,
        isStartingClass: true,
      ),
    ],
    abilityScores: scores,
    hitPoints: HitPoints(maximum: hp, current: hp),
    hitDicePools: [
      CharacterHitDiePool(
        dieSize: hitDie,
        total: 1,
        sourceClass: cls,
        sourceClassEntryId: 'primary',
      ),
    ],
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

/// Completes every request, keeping saved values and adding placeholders.
List<CharacterFeatureChoice> _fill(
  List<FeatureChoiceRequest> requests,
  Character character,
) => [
  for (final request in requests)
    request.toChoice([
      ...?request.findIn(character.featureChoices)?.values,
      for (var i = 0; i < request.requiredCount; i++) '${request.choiceId}_$i',
    ]),
];

Character _levelUp(
  Character character, {
  String? className,
  String? classEntryId = 'primary',
  String? subclass,
  String? feat,
  Map<String, int> increases = const {},
}) {
  final name = className ?? character.primaryClassName;
  final plan = Progression2024Engine.plan(
    character,
    _data,
    className: name,
    classEntryId: classEntryId,
  );
  final requests = Progression2024Engine.requestsFor(
    character,
    _data,
    plan,
    subclassName: subclass,
    featName: feat,
  );
  return Progression2024Engine.applyLevelUp(
    character,
    _data,
    LevelUp2024Result(
      className: name,
      classEntryId: classEntryId,
      subclassName: subclass,
      featName: feat,
      abilityIncreases: increases,
      featureChoices: _fill(requests, character),
    ),
  );
}

Character _fighterAt(int level) {
  var character = _character();
  for (var next = 2; next <= level; next++) {
    character = _levelUp(
      character,
      subclass: next == 3 ? 'Champion' : null,
      feat: const {4, 6, 8, 12, 14, 16}.contains(next)
          ? 'Ability Score Improvement'
          : null,
      increases: const {4, 6, 8, 12, 14, 16}.contains(next)
          ? const {'charisma': 1, 'intelligence': 1}
          : const {},
    );
  }
  return character;
}

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
      speciesTraits: const ['Resourceful', 'Skillful', 'Versatile'],
    );
  });

  group('level up', () {
    test('adds a level with average hit points, hit die and history', () {
      final leveled = _levelUp(_character());

      expect(leveled.totalLevel, 2);
      expect(leveled.classEntries.single.level, 2);
      expect(leveled.hitPoints.maximum, 12 + 6 + 2);
      expect(leveled.hitDicePools.single.total, 2);
      expect(leveled.levelHistory.map((r) => r.characterLevel), [1, 2]);
      expect(leveled.levelHistory.last.hitPointsGained, 8);
    });

    test('rolled hit points use the die and keep a minimum of 1', () {
      final weak = _character(
        scores: const AbilityScores(constitution: 3),
      );
      final plan = Progression2024Engine.plan(
        weak,
        _data,
        className: 'Fighter',
        classEntryId: 'primary',
      );

      expect(
        Progression2024Engine.hitPointsGained(
          weak,
          _data,
          plan,
          method: HitPointGainMethod.rolled,
          roll: 1,
        ),
        1,
      );
    });

    test('Dwarven Toughness adds 1 hit point per level', () {
      final plan = Progression2024Engine.plan(
        _character(),
        _data,
        className: 'Fighter',
        classEntryId: 'primary',
      );

      expect(
        Progression2024Engine.hitPointsGained(
          _character(),
          _data.withSpeciesTraits(const ['Dwarven Toughness']),
          plan,
          method: HitPointGainMethod.average,
        ),
        9,
      );
    });

    test('subclass is required at level 3', () {
      final level2 = _levelUp(_character());

      expect(
        () => _levelUp(level2),
        throwsArgumentError,
      );
      final level3 = _levelUp(level2, subclass: 'Champion');
      expect(level3.classEntries.single.subclassName, 'Champion');
      expect(level3.subclass, 'Champion');
    });

    test('Ability Score Improvement applies and raises HP retroactively', () {
      final level3 = _fighterAt(3);
      final level4 = _levelUp(
        level3,
        feat: 'Ability Score Improvement',
        increases: const {'constitution': 2},
      );

      expect(level4.abilityScores.constitution, 16);
      // 8 for the level plus 1 extra Constitution point for each of 4 levels.
      expect(level4.hitPoints.maximum, level3.hitPoints.maximum + 8 + 4);
      expect(level4.proficiencyBonus, 2);
      expect(
        level4.extraFeatures.where((f) => f.name == 'Ability Score Improvement'),
        hasLength(1),
      );
      expect(level4.levelHistory.last.abilityIncreases, {'constitution': 2});
    });

    test('rejects invalid ability splits and caps', () {
      final level3 = _fighterAt(3);
      expect(
        () => _levelUp(
          level3,
          feat: 'Ability Score Improvement',
          increases: const {'strength': 1},
        ),
        throwsArgumentError,
      );
      expect(
        () => _levelUp(
          level3.copyWith(
            abilityScores: level3.abilityScores.copyWith(strength: 19),
          ),
          feat: 'Ability Score Improvement',
          increases: const {'strength': 2},
        ),
        throwsArgumentError,
      );
    });

    test('Weapon Mastery count grows cumulatively at level 4', () {
      final level3 = _fighterAt(3);
      final plan = Progression2024Engine.plan(
        level3,
        _data,
        className: 'Fighter',
        classEntryId: 'primary',
      );
      final mastery = Progression2024Engine.requestsFor(
        level3,
        _data,
        plan,
        featName: 'Ability Score Improvement',
      ).where((r) => r.choiceId == 'weapon_masteries').single;

      expect(mastery.requiredCount, 4);
    });

    test('Epic Boon feats are only eligible at level 19', () {
      final level3 = _fighterAt(3);
      final asiPlan = Progression2024Engine.plan(
        level3,
        _data,
        className: 'Fighter',
        classEntryId: 'primary',
      );
      final asiFeats = Progression2024Engine.eligibleFeats(level3, _data, asiPlan)
          .map((f) => f.name);
      expect(asiFeats, contains('Ability Score Improvement'));
      expect(asiFeats, contains('Archery'));
      expect(asiFeats, isNot(contains('Boon of Fate')));

      final level18 = _fighterAt(18);
      final boonPlan = Progression2024Engine.plan(
        level18,
        _data,
        className: 'Fighter',
        classEntryId: 'primary',
      );
      expect(boonPlan.featFeature, Progression2024Engine.epicBoon);
      final boonFeats = Progression2024Engine.eligibleFeats(level18, _data, boonPlan)
          .map((f) => f.name);
      expect(boonFeats, contains('Boon of Fate'));
      expect(boonFeats, isNot(contains('Boon of Spell Recall')));

      final level19 = _levelUp(
        level18,
        feat: 'Boon of Fate',
        increases: const {'strength': 1},
      );
      expect(level19.totalLevel, 19);
      expect(level19.abilityScores.strength, 16);
    });

    test('cannot pass level 20', () {
      expect(() => _levelUp(_fighterAt(20)), throwsArgumentError);
    });
  });

  group('multiclass', () {
    test('checks primary abilities of current and new classes', () {
      final fighter = _character(
        scores: const AbilityScores(strength: 8, dexterity: 13, wisdom: 12),
      );

      expect(
        Progression2024Engine.missingMulticlassAbilities(fighter, _data, 'Monk'),
        ['wisdom'],
      );
      expect(
        Progression2024Engine.missingMulticlassAbilities(fighter, _data, 'Rogue'),
        isEmpty,
      );
    });

    test('adds a class entry, hit die pool and multiclass proficiencies', () {
      final fighter = _character();
      final plan = Progression2024Engine.plan(
        fighter,
        _data,
        className: 'Rogue',
      );
      final requests = Progression2024Engine.requestsFor(fighter, _data, plan);
      final skills = requests.where(
        (r) => r.sourceType == FeatureChoiceSourceType.multiclassProficiency,
      ).single;
      final leveled = Progression2024Engine.applyLevelUp(
        fighter,
        _data,
        LevelUp2024Result(
          className: 'Rogue',
          featureChoices: [
            skills.toChoice(const ['stealth']),
            for (final request in requests)
              if (request != skills) request.toChoice(
                [for (var i = 0; i < request.requiredCount; i++) 'x$i'],
              ),
          ],
        ),
      );

      expect(leveled.classEntries.map((e) => e.className), ['Fighter', 'Rogue']);
      expect(leveled.hitDicePools.map((p) => p.dieSize), [10, 8]);
      expect(leveled.skillProficiencies, contains('stealth'));
      expect(leveled.features, contains("Tool Proficiency: Thieves' Tools"));
      expect(
        Progression2024Engine.weaponProficiencies(leveled, _data.classes),
        containsAll(['simple', 'martial']),
      );
    });

    test('half casters round up in multiclass spell slots', () {
      var character = _character(
        cls: 'Paladin',
        scores: const AbilityScores(
          strength: 15,
          dexterity: 13,
          constitution: 14,
          wisdom: 13,
          charisma: 13,
        ),
      );
      character = _levelUp(character, className: 'Ranger', classEntryId: null);
      final (standard, _) = Progression2024Engine.slotsFor(character, _data);

      // Paladin 1 + Ranger 1 -> caster level 2 -> three level 1 slots.
      expect(standard.total.take(2), [3, 0]);
    });

    test('a single half caster uses its own table', () {
      final paladin = _levelUp(_character(cls: 'Paladin'));
      final (standard, _) = Progression2024Engine.slotsFor(paladin, _data);

      expect(standard.total.first, 2);
    });

    test('Warlock Pact Magic stays separate', () {
      var warlock = _character(cls: 'Warlock', hitDie: 8);
      warlock = _levelUp(warlock);
      warlock = _levelUp(warlock, subclass: 'Fiend Patron');
      final (standard, pact) = Progression2024Engine.slotsFor(warlock, _data);

      expect(standard.total.every((count) => count == 0), isTrue);
      expect(pact.total[1], 2);
      expect(
        warlock.spells.where((s) => s.isAlwaysPrepared).map((s) => s.name),
        containsAll(['Burning Hands', 'Command', 'Scorching Ray', 'Suggestion']),
      );
    });
  });

  group('spellcasting limits', () {
    test('use the class level of each entry', () {
      var wizard = _character(cls: 'Wizard', hitDie: 6);
      wizard = _levelUp(wizard);
      final limits = Progression2024Engine.spellcastingFor(wizard, _data.classes)
          .single;

      expect(limits.cantripsKnown, 3);
      expect(limits.preparedSpells, 5);
      expect(limits.maxSpellLevel, 1);
      expect(limits.spellbookSize, 8);
    });
  });

  group('history and reset', () {
    test('level 1 sheets without history rebuild their first record', () {
      final legacy = _character().copyWith(
        levelHistory: const [],
        featureChoices: const [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.background,
            sourceName: 'Soldier',
            featureName: 'Ability Score Increase',
            choiceId: 'ability_scores',
            values: ['strength:2', 'constitution:1'],
          ),
        ],
      );
      final record = Progression2024Engine.historyFor(legacy).single;

      expect(record.baseAbilityScores['strength'], 13);
      expect(record.baseAbilityScores['constitution'], 13);
      expect(record.hitPointsGained, 12);
    });

    test('reset undoes later levels from the history', () {
      final level1 = _character();
      final level4 = _levelUp(
        _fighterAt(3),
        feat: 'Ability Score Improvement',
        increases: const {'constitution': 2},
      );
      final reset = Progression2024Engine.resetToLevelOne(level4, _data);

      expect(reset.totalLevel, 1);
      expect(reset.classEntries.single.subclassName, isNull);
      expect(reset.abilityScores.constitution, 14);
      expect(reset.hitPoints.maximum, level1.hitPoints.maximum);
      expect(reset.hitDicePools.single.total, 1);
      expect(reset.levelHistory, hasLength(1));
      expect(
        reset.extraFeatures.where((f) => f.name == 'Ability Score Improvement'),
        isEmpty,
      );
      expect(
        reset.featureChoices
            .where((c) => c.choiceId == 'weapon_masteries')
            .single
            .values,
        hasLength(3),
      );
    });

    test('reset needs a complete history', () {
      final unknown = _fighterAt(2).copyWith(levelHistory: const []);

      expect(Progression2024Engine.canResetToLevelOne(unknown), isFalse);
      expect(
        () => Progression2024Engine.resetToLevelOne(unknown, _data),
        throwsStateError,
      );
    });
  });
}
