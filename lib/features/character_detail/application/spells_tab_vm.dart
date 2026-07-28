import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import 'vm_reference_utils.dart';

final spellsTabVmProvider =
    Provider.family<AsyncValue<SpellsTabVm>, String>((ref, characterId) {
  return ref.watch(
    characterDetailProvider(characterId).select(
      (state) => state.whenData(SpellsTabVm.fromCharacter),
    ),
  );
});

class SpellsTabVm {
  const SpellsTabVm(this.character);

  factory SpellsTabVm.fromCharacter(Character character) {
    return SpellsTabVm(character);
  }

  final Character character;

  @override
  bool operator ==(Object other) {
    return other is SpellsTabVm &&
        character.characterClass == other.character.characterClass &&
        character.subclass == other.character.subclass &&
        character.level == other.character.level &&
        sameReference(character.abilityScores, other.character.abilityScores) &&
        character.proficiencyBonus == other.character.proficiencyBonus &&
        sameReference(character.spells, other.character.spells) &&
        sameReference(character.spellSlots, other.character.spellSlots) &&
        sameReference(character.innateSpells, other.character.innateSpells) &&
        sameReference(character.disabledSpells, other.character.disabledSpells) &&
        character.concentrationSpell == other.character.concentrationSpell;
  }

  @override
  int get hashCode => Object.hashAll([
        character.characterClass,
        character.subclass,
        character.level,
        referenceHash(character.abilityScores),
        character.proficiencyBonus,
        referenceHash(character.spells),
        referenceHash(character.spellSlots),
        referenceHash(character.innateSpells),
        referenceHash(character.disabledSpells),
        character.concentrationSpell,
      ]);
}
