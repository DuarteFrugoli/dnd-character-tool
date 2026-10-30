import 'character_progression/choice_effects.dart';
import 'feature_choice_engine.dart';
import 'feature_choice_option_resolver.dart';
import 'models/models.dart';

/// A background the player builds instead of picking one from the catalog.
/// Its picks are saved as background feature choices, so the sheet does not
/// need the background to exist in the SRD catalog.
class CustomBackground {
  const CustomBackground._();

  /// 2014: background whose feature the custom background uses.
  static const featureChoiceName = 'Background Feature';

  static const skillCount = 2;

  /// 2014: tool proficiencies and languages add up to this total.
  static const toolsAndLanguages2014 = 2;

  /// 2024: three abilities, an Origin feat, one tool and 50 GP of equipment.
  static const abilityCount2024 = 3;
  static const gold2024 = 50;

  static CharacterFeatureChoice skillsChoice(String background, Iterable<String> skills) =>
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.background,
        sourceName: background,
        featureName: ChoiceEffects.classSkillsFeature,
        choiceId: 'skills',
        values: [for (final skill in skills) FeatureChoiceOptionResolver.idFromName(skill)],
      );

  static CharacterFeatureChoice featureChoice(String background, String featureSource) =>
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.background,
        sourceName: background,
        featureName: featureChoiceName,
        choiceId: 'feature',
        values: [featureSource],
      );

  /// Catalog background whose feature [character] uses: the source chosen for
  /// a custom 2014 background, otherwise the background itself.
  static String featureSourceFor(Character character) {
    for (final choice in character.featureChoices) {
      if (choice.sourceType == FeatureChoiceSourceType.background &&
          choice.featureName == featureChoiceName &&
          choice.values.isNotEmpty) {
        return choice.values.first;
      }
    }
    return character.background;
  }
}
