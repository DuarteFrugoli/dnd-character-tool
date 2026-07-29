import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import 'vm_reference_utils.dart';

final skillsTabVmProvider = Provider.family<AsyncValue<SkillsTabVm>, String>((
  ref,
  characterId,
) {
  return ref.watch(
    characterDetailProvider(
      characterId,
    ).select((state) => state.whenData(SkillsTabVm.fromCharacter)),
  );
});

class SkillsTabVm {
  const SkillsTabVm(this.character);

  factory SkillsTabVm.fromCharacter(Character character) {
    return SkillsTabVm(character);
  }

  final Character character;

  @override
  bool operator ==(Object other) {
    return other is SkillsTabVm &&
        sameReference(character.abilityScores, other.character.abilityScores) &&
        character.proficiencyBonus == other.character.proficiencyBonus &&
        sameReference(
          character.skillProficiencies,
          other.character.skillProficiencies,
        ) &&
        sameReference(
          character.skillExpertises,
          other.character.skillExpertises,
        );
  }

  @override
  int get hashCode => Object.hash(
    referenceHash(character.abilityScores),
    character.proficiencyBonus,
    referenceHash(character.skillProficiencies),
    referenceHash(character.skillExpertises),
  );
}
