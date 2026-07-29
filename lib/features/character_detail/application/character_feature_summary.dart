import '../../../data/models/models.dart';

class CharacterFeatureClassGroup {
  final CharacterClassEntry classEntry;
  final List<CharacterFeatureChoice> choices;

  const CharacterFeatureClassGroup({
    required this.classEntry,
    required this.choices,
  });
}

class CharacterFeatureSummary {
  final List<CharacterFeatureClassGroup> classGroups;
  final List<CharacterExtraFeature> extraFeatures;
  final List<CharacterFeatureChoice> globalChoices;
  final List<String> legacyFeatureLabels;

  const CharacterFeatureSummary({
    required this.classGroups,
    required this.extraFeatures,
    required this.globalChoices,
    required this.legacyFeatureLabels,
  });

  factory CharacterFeatureSummary.fromCharacter(Character character) {
    return CharacterFeatureSummary(
      classGroups: [
        for (final entry in character.classEntries)
          CharacterFeatureClassGroup(
            classEntry: entry,
            choices: character.featureChoices
                .where((choice) => choice.sourceClassEntryId == entry.id)
                .toList(),
          ),
      ],
      extraFeatures: character.extraFeatures,
      globalChoices: character.featureChoices
          .where((choice) => choice.sourceClassEntryId == null)
          .toList(),
      legacyFeatureLabels: character.features,
    );
  }
}
