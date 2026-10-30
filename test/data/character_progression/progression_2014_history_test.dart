import 'package:dnd_character_tool/data/character_change_summary.dart';
import 'package:dnd_character_tool/data/character_progression/character_progression.dart';
import 'package:dnd_character_tool/data/character_progression/choice_effects.dart';
import 'package:dnd_character_tool/data/character_progression/choice_effects_2014.dart';
import 'package:dnd_character_tool/data/constants/level_up_rules.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter_test/flutter_test.dart';

late ChoiceEffects2014Data _effects;

const _classSkills = CharacterFeatureChoice(
  sourceType: FeatureChoiceSourceType.classFeature,
  sourceClass: 'Rogue',
  sourceClassEntryId: 'primary',
  featureName: ChoiceEffects.classSkillsFeature,
  choiceId: 'skills',
  values: ['stealth', 'acrobatics', 'perception', 'deception'],
);

/// A level 1 Rogue as 2014 creation now saves it.
Character _rogue({bool withHistory = true, bool recordClassSkills = true}) {
  final now = DateTime(2024);
  return Character(
    id: 'rogue',
    name: 'Rogue',
    race: 'Human',
    background: 'Acolyte',
    characterClass: 'Rogue',
    classes: const [
      CharacterClassEntry(id: 'primary', className: 'Rogue', level: 1, isStartingClass: true),
    ],
    abilityScores: const AbilityScores(dexterity: 16, constitution: 14, wisdom: 13),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    hitDicePools: const [
      CharacterHitDiePool(dieSize: 8, total: 1, sourceClass: 'Rogue', sourceClassEntryId: 'primary'),
    ],
    savingThrowProficiencies: const ['dexterity', 'intelligence'],
    skillProficiencies: const [
      'Insight',
      'Religion',
      'stealth',
      'acrobatics',
      'perception',
      'deception',
    ],
    skillExpertises: const ['Stealth', 'Perception'],
    featureChoices: [
      if (recordClassSkills) _classSkills,
      const CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Rogue',
        sourceClassEntryId: 'primary',
        featureName: 'Expertise',
        choiceId: 'expertise',
        values: ['skill:stealth', 'skill:perception'],
      ),
    ],
    levelHistory: [
      if (withHistory)
        const CharacterLevelRecord(
          characterLevel: 1,
          classEntryId: 'primary',
          className: 'Rogue',
          classLevel: 1,
          hitPointsGained: 10,
          hitPointMethod: HitPointGainMethod.maximum,
        ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

LevelUpResult _rogueLevel(
  int level, {
  Map<String, int> asi = const {},
  List<CharacterFeatureChoice> choices = const [],
}) => LevelUpResult(
  targetClassEntryId: 'primary',
  targetClassName: 'Rogue',
  oldTotalLevel: level - 1,
  newTotalLevel: level,
  oldClassLevel: level - 1,
  newClassLevel: level,
  targetHitDie: 8,
  hpGained: 7,
  hitPointMethod: HitPointGainMethod.rolled,
  asiChanges: asi,
  featureChoices: choices,
);

Character _rogueAt(int level, Character start) {
  var character = start;
  for (var next = 2; next <= level; next++) {
    character = CharacterProgressionEngine.applyLevelUp(
      character,
      _rogueLevel(
        next,
        asi: next == 4 ? const {'dexterity': 2} : const {},
        choices: next == 6
            ? const [
                CharacterFeatureChoice(
                  sourceType: FeatureChoiceSourceType.classFeature,
                  sourceClass: 'Rogue',
                  sourceClassEntryId: 'primary',
                  featureName: 'Expertise',
                  choiceId: 'expertise',
                  values: [
                    'skill:stealth',
                    'skill:perception',
                    'skill:acrobatics',
                    'skill:deception',
                  ],
                ),
              ]
            : const [],
      ),
      effects: _effects,
    );
  }
  return character;
}

CharacterLevelResetResult _resetTo(String className, List<String> skills) =>
    CharacterLevelResetResult(
      className: className,
      hitDie: className == 'Wizard' ? 6 : 8,
      savingThrowProficiencies: className == 'Wizard'
          ? const ['intelligence', 'wisdom']
          : const ['dexterity', 'intelligence'],
      skillProficiencies: skills,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    _effects = await ChoiceEffects2014Data.load(
      SrdDataSource.forPack(SrdContentPackRegistry.srd51),
    );
  });

  group('2014 level up', () {
    test('records each level and applies the expertise chosen on it', () {
      final rogue = _rogueAt(6, _rogue());

      expect(rogue.levelHistory.map((r) => r.characterLevel), [1, 2, 3, 4, 5, 6]);
      expect(rogue.levelHistory[3].abilityIncreases, {'dexterity': 2});
      expect(rogue.levelHistory.last.hitPointMethod, HitPointGainMethod.rolled);
      expect(
        rogue.skillExpertises.map((s) => s.toLowerCase()),
        containsAll(['stealth', 'perception', 'acrobatics', 'deception']),
      );
      expect(CharacterProgressionEngine.hasCompleteHistory(rogue), isTrue);
    });
  });

  group('2014 reset', () {
    test('a complete history undoes increases, class skills and expertise', () {
      final rogue = _rogueAt(6, _rogue()).copyWith(
        xpTrackingEnabled: false,
        experiencePoints: 14000,
      );
      expect(CharacterLevelResetEngine.limitationsFor(rogue), isEmpty);

      final wizard = CharacterLevelResetEngine.resetToLevelOne(
        rogue,
        _resetTo('Wizard', const ['arcana', 'history']),
        effects: _effects,
      );

      expect(wizard.abilityScores.dexterity, 16);
      expect(wizard.hitPoints.maximum, 6 + 2);
      // Acolyte keeps Insight and Religion; Rogue skills and Expertise go.
      expect(
        wizard.skillProficiencies.map((s) => s.toLowerCase()),
        unorderedEquals(['insight', 'religion', 'arcana', 'history']),
      );
      expect(wizard.skillExpertises, isEmpty);
      expect(wizard.experiencePoints, 14000);
      expect(wizard.levelHistory.single.className, 'Wizard');
      expect(
        wizard.featureChoices
            .singleWhere((c) => c.featureName == ChoiceEffects.classSkillsFeature)
            .values,
        ['arcana', 'history'],
      );
    });

    test('multiclass proficiencies leave with their class', () {
      final fighter = _rogue().copyWith(
        classes: const [
          CharacterClassEntry(id: 'primary', className: 'Rogue', level: 1, isStartingClass: true),
          CharacterClassEntry(id: 'fighter', className: 'Fighter', level: 1),
        ],
        features: const [
          'Armor Proficiency: light armor',
          'Armor Proficiency: medium armor',
          'Armor Proficiency: shields',
          'Weapon Proficiency: simple weapons',
          'Weapon Proficiency: martial weapons',
          'Tool Proficiency: Brewer\'s supplies',
        ],
      );
      final reset = CharacterLevelResetEngine.resetToLevelOne(
        fighter,
        _resetTo('Rogue', const ['stealth', 'acrobatics', 'perception', 'deception']),
        effects: _effects,
      );

      expect(reset.features, ['Tool Proficiency: Brewer\'s supplies']);
    });

    test('sheets without history or class skills keep them and say so', () {
      final legacy = _rogue(withHistory: false, recordClassSkills: false).copyWith(
        level: 5,
        classes: const [
          CharacterClassEntry(id: 'primary', className: 'Rogue', level: 5, isStartingClass: true),
        ],
        abilityScores: const AbilityScores(dexterity: 18, constitution: 14),
      );
      expect(
        CharacterLevelResetEngine.limitationsFor(legacy),
        {
          LevelResetLimitation.abilityIncreasesKept,
          LevelResetLimitation.previousClassSkillsKept,
        },
      );

      final reset = CharacterLevelResetEngine.resetToLevelOne(
        legacy,
        _resetTo('Wizard', const ['arcana', 'history']),
        effects: _effects,
      );
      expect(reset.abilityScores.dexterity, 18);
      expect(
        reset.skillProficiencies.map((s) => s.toLowerCase()),
        containsAll(['stealth', 'arcana']),
      );
    });

    test('XP resets only when XP is tracked', () {
      final tracked = _rogue().copyWith(xpTrackingEnabled: true, experiencePoints: 300);
      expect(
        CharacterLevelResetEngine.resetToLevelOne(
          tracked,
          _resetTo('Rogue', const ['stealth', 'acrobatics', 'perception', 'deception']),
          effects: _effects,
        ).experiencePoints,
        0,
      );
    });
  });

  group('change summary', () {
    test('lists value and list changes, counting repeated feats', () {
      final rogue = _rogueAt(6, _rogue());
      final withFeats = rogue.copyWith(
        extraFeatures: const [
          CharacterExtraFeature(
            sourceClass: 'Feat',
            sourceType: FeatureChoiceSourceType.feat,
            name: 'Grappler',
            level: 4,
            type: 'passive',
            description: '',
          ),
          CharacterExtraFeature(
            sourceClass: 'Feat',
            sourceType: FeatureChoiceSourceType.feat,
            name: 'Grappler',
            level: 8,
            type: 'passive',
            description: '',
          ),
        ],
      );
      final reset = CharacterLevelResetEngine.resetToLevelOne(
        withFeats,
        _resetTo('Wizard', const ['arcana', 'history']),
        effects: _effects,
      );
      final changes = CharacterChangeSummary.compare(withFeats, reset);
      CharacterChange kind(CharacterChangeKind kind, {String? ability}) =>
          changes.singleWhere((c) => c.kind == kind && c.ability == ability);

      expect(kind(CharacterChangeKind.level).before, '6');
      expect(kind(CharacterChangeKind.level).after, '1');
      expect(kind(CharacterChangeKind.ability, ability: 'dexterity').after, '16');
      expect(kind(CharacterChangeKind.skills).removed, contains('stealth'));
      expect(kind(CharacterChangeKind.skills).added, contains('arcana'));
      expect(kind(CharacterChangeKind.feats).removed, ['Grappler', 'Grappler']);
      expect(
        changes.where((c) => c.kind == CharacterChangeKind.experience),
        isEmpty,
      );
    });
  });
}
