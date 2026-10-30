import '../feature_choice_engine.dart';
import '../models/models.dart';
import 'ruleset_ids.dart';

/// Initiative modifier: Dexterity plus feats that raise it.
class InitiativeRules {
  const InitiativeRules._();

  static const alertFeat = 'Alert';

  /// 2014 Alert grants +5; 2024 Alert adds the Proficiency Bonus.
  static int modifierFor(Character character) {
    final hasAlert = character.extraFeatures.any(
      (feature) =>
          feature.effectiveSourceType == FeatureChoiceSourceType.feat &&
          feature.name == alertFeat,
    );
    if (!hasAlert) return character.initiative;
    return character.initiative +
        switch (character.rulesetId) {
          RulesetId.dnd2014 => 5,
          RulesetId.dnd2024 => character.proficiencyBonus,
        };
  }
}
