import 'package:dnd_character_tool/data/custom_background.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/initiative_rules.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  RulesetId rulesetId = RulesetId.dnd2014,
  bool alert = false,
  int proficiencyBonus = 2,
  List<CharacterFeatureChoice> choices = const [],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'hero',
    rulesetId: rulesetId,
    contentPackId: rulesetId == RulesetId.dnd2024
        ? ContentPackId.srd521
        : ContentPackId.srd51,
    name: 'Hero',
    race: 'Human',
    background: 'Ship Hand',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(dexterity: 14),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    proficiencyBonus: proficiencyBonus,
    featureChoices: choices,
    extraFeatures: [
      if (alert)
        const CharacterExtraFeature(
          sourceClass: 'Feat',
          sourceType: FeatureChoiceSourceType.feat,
          name: 'Alert',
          level: 1,
          type: 'passive',
          description: '',
        ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('Initiative', () {
    test('is the Dexterity modifier without Alert', () {
      expect(InitiativeRules.modifierFor(_character()), 2);
    });

    test('2014 Alert adds 5', () {
      expect(InitiativeRules.modifierFor(_character(alert: true)), 7);
    });

    test('2024 Alert adds the Proficiency Bonus', () {
      expect(
        InitiativeRules.modifierFor(
          _character(rulesetId: RulesetId.dnd2024, alert: true, proficiencyBonus: 3),
        ),
        5,
      );
    });
  });

  group('Custom background', () {
    test('the feature comes from the chosen catalog background', () {
      final custom = _character(
        choices: [CustomBackground.featureChoice('Ship Hand', 'Sailor')],
      );

      expect(CustomBackground.featureSourceFor(custom), 'Sailor');
      expect(CustomBackground.featureSourceFor(_character()), 'Ship Hand');
    });

    test('skills are recorded as option ids', () {
      final choice = CustomBackground.skillsChoice('Ship Hand', const [
        'animal handling',
        'Perception',
      ]);

      expect(choice.values, ['animal_handling', 'perception']);
      expect(choice.sourceType, FeatureChoiceSourceType.background);
    });
  });
}
