import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import 'vm_reference_utils.dart';

final statsTabVmProvider = Provider.family<AsyncValue<StatsTabVm>, String>((
  ref,
  characterId,
) {
  return ref.watch(
    characterDetailProvider(
      characterId,
    ).select((state) => state.whenData(StatsTabVm.fromCharacter)),
  );
});

class StatsTabVm {
  const StatsTabVm(this.character);

  factory StatsTabVm.fromCharacter(Character character) {
    return StatsTabVm(character);
  }

  final Character character;

  @override
  bool operator ==(Object other) {
    return other is StatsTabVm &&
        character.characterClass == other.character.characterClass &&
        character.level == other.character.level &&
        sameReference(character.classes, other.character.classes) &&
        character.experiencePoints == other.character.experiencePoints &&
        sameReference(character.hitPoints, other.character.hitPoints) &&
        sameReference(character.hitDicePools, other.character.hitDicePools) &&
        sameReference(character.equipment, other.character.equipment) &&
        sameReference(character.abilityScores, other.character.abilityScores) &&
        character.armorClass == other.character.armorClass &&
        character.speed == other.character.speed &&
        character.proficiencyBonus == other.character.proficiencyBonus &&
        sameReference(
          character.savingThrowProficiencies,
          other.character.savingThrowProficiencies,
        ) &&
        sameReference(
          character.skillProficiencies,
          other.character.skillProficiencies,
        ) &&
        sameReference(
          character.skillExpertises,
          other.character.skillExpertises,
        ) &&
        sameReference(
          character.activeConditions,
          other.character.activeConditions,
        ) &&
        character.inspiration == other.character.inspiration &&
        character.xpTrackingEnabled == other.character.xpTrackingEnabled;
  }

  @override
  int get hashCode => Object.hashAll([
    character.characterClass,
    character.level,
    referenceHash(character.classes),
    character.experiencePoints,
    referenceHash(character.hitPoints),
    referenceHash(character.hitDicePools),
    referenceHash(character.equipment),
    referenceHash(character.abilityScores),
    character.armorClass,
    character.speed,
    character.proficiencyBonus,
    referenceHash(character.savingThrowProficiencies),
    referenceHash(character.skillProficiencies),
    referenceHash(character.skillExpertises),
    referenceHash(character.activeConditions),
    character.inspiration,
    character.xpTrackingEnabled,
  ]);
}
