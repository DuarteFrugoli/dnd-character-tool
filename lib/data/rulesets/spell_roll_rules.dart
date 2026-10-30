import '../feature_choice_engine.dart';
import '../feature_choice_option_resolver.dart';
import '../models/models.dart';
import 'ruleset_ids.dart';

/// Class features that change spell rolls.
class SpellRollRules {
  const SpellRollRules._();

  static const invocationsFeature = 'Eldritch Invocations';
  static const agonizingBlast = 'agonizing_blast';
  static const eldritchBlast = 'Eldritch Blast';

  /// SRD 5.2.1 Agonizing Blast: the Charisma modifier added to the damage of
  /// each cantrip chosen as its target (`agonizing_blast@<cantrip>`). A
  /// modifier of 0 or less adds nothing, since adding it is optional.
  static int damageBonus(Character character, String spellName) {
    if (character.rulesetId != RulesetId.dnd2024) return 0;
    final modifier = character.abilityScores.charismaModifier;
    if (modifier <= 0) return 0;
    final target = spellName.toLowerCase();
    for (final choice in character.featureChoices) {
      if (choice.sourceType != FeatureChoiceSourceType.classFeature ||
          choice.featureName != invocationsFeature) {
        continue;
      }
      for (final value in choice.values) {
        if (ChoiceTargetValue.optionId(value) == agonizingBlast &&
            ChoiceTargetValue.target(value)?.toLowerCase() == target) {
          return modifier;
        }
      }
    }
    return 0;
  }

  /// Eldritch Blast fires one beam, plus one at character levels 5, 11
  /// and 17; each beam has its own attack and damage roll.
  static int beams(String spellName, int characterLevel) {
    if (spellName.toLowerCase() != eldritchBlast.toLowerCase()) return 1;
    if (characterLevel >= 17) return 4;
    if (characterLevel >= 11) return 3;
    if (characterLevel >= 5) return 2;
    return 1;
  }
}
