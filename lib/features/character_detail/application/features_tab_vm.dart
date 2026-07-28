import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import 'vm_reference_utils.dart';

final featuresTabVmProvider =
    Provider.family<AsyncValue<FeaturesTabVm>, String>((ref, characterId) {
  return ref.watch(
    characterDetailProvider(characterId).select(
      (state) => state.whenData(FeaturesTabVm.fromCharacter),
    ),
  );
});

class FeaturesTabVm {
  const FeaturesTabVm(this.character);

  factory FeaturesTabVm.fromCharacter(Character character) {
    return FeaturesTabVm(character);
  }

  final Character character;

  @override
  bool operator ==(Object other) {
    return other is FeaturesTabVm &&
        character.characterClass == other.character.characterClass &&
        character.subclass == other.character.subclass &&
        character.level == other.character.level &&
        character.race == other.character.race &&
        character.subrace == other.character.subrace &&
        character.background == other.character.background &&
        character.proficiencyBonus == other.character.proficiencyBonus &&
        sameReference(character.abilityScores, other.character.abilityScores) &&
        sameReference(character.features, other.character.features) &&
        sameReference(character.extraFeatures, other.character.extraFeatures) &&
        sameReference(
          character.featureChoices,
          other.character.featureChoices,
        ) &&
        sameReference(
          character.featureResources,
          other.character.featureResources,
        ) &&
        sameReference(
          character.disabledFeatures,
          other.character.disabledFeatures,
        );
  }

  @override
  int get hashCode => Object.hashAll([
        character.characterClass,
        character.subclass,
        character.level,
        character.race,
        character.subrace,
        character.background,
        character.proficiencyBonus,
        referenceHash(character.abilityScores),
        referenceHash(character.features),
        referenceHash(character.extraFeatures),
        referenceHash(character.featureChoices),
        referenceHash(character.featureResources),
        referenceHash(character.disabledFeatures),
      ]);
}
