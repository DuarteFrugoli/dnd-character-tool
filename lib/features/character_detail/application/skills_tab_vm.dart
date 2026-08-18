import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/domain_constants.dart';
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
  const SkillsTabVm({
    required this.character,
    required this.rows,
  });

  factory SkillsTabVm.fromCharacter(Character character) {
    final profSet = character.skillProficiencies
        .map((skill) => skill.toLowerCase())
        .toSet();
    final expertSet = character.skillExpertises
        .map((skill) => skill.toLowerCase())
        .toSet();
    final rows = [
      for (final entry in skillAbility.entries)
        SkillRowVm.fromCharacter(
          character: character,
          skillName: entry.key,
          ability: entry.value,
          proficientSkills: profSet,
          expertSkills: expertSet,
        ),
    ];
    return SkillsTabVm(character: character, rows: rows);
  }

  final Character character;
  final List<SkillRowVm> rows;

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

class SkillRowVm {
  const SkillRowVm({
    required this.skillName,
    required this.ability,
    required this.bonus,
    required this.isProficient,
    required this.isExpert,
  });

  factory SkillRowVm.fromCharacter({
    required Character character,
    required String skillName,
    required String ability,
    required Set<String> proficientSkills,
    required Set<String> expertSkills,
  }) {
    final lower = skillName.toLowerCase();
    final isExpert = expertSkills.contains(lower);
    final isProficient = isExpert || proficientSkills.contains(lower);
    final abilityMod = _abilityModifier(character.abilityScores[ability]);
    var proficiencyBonus = 0;
    if (isExpert) {
      proficiencyBonus = character.proficiencyBonus * 2;
    } else if (isProficient) {
      proficiencyBonus = character.proficiencyBonus;
    }
    final bonus = abilityMod + proficiencyBonus;
    return SkillRowVm(
      skillName: skillName,
      ability: ability,
      bonus: bonus,
      isProficient: isProficient,
      isExpert: isExpert,
    );
  }

  final String skillName;
  final String ability;
  final int bonus;
  final bool isProficient;
  final bool isExpert;
}

int _abilityModifier(int score) => ((score - 10) / 2).floor();
