import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/character_spellcasting_summary.dart';
import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import 'vm_reference_utils.dart';

final spellsTabVmProvider = Provider.family<AsyncValue<SpellsTabVm>, String>((
  ref,
  characterId,
) {
  return ref.watch(
    characterDetailProvider(
      characterId,
    ).select((state) => state.whenData(SpellsTabVm.fromCharacter)),
  );
});

class SpellsTabVm {
  const SpellsTabVm({
    required this.character,
    required this.spellcastingSummary,
  });

  factory SpellsTabVm.fromCharacter(Character character) {
    return SpellsTabVm(
      character: character,
      spellcastingSummary: CharacterSpellcastingSummary.fromCharacter(
        character,
      ),
    );
  }

  final Character character;
  final CharacterSpellcastingSummary spellcastingSummary;

  @override
  bool operator ==(Object other) {
    return other is SpellsTabVm &&
        character.characterClass == other.character.characterClass &&
        character.subclass == other.character.subclass &&
        character.level == other.character.level &&
        sameReference(character.classes, other.character.classes) &&
        sameReference(character.abilityScores, other.character.abilityScores) &&
        character.proficiencyBonus == other.character.proficiencyBonus &&
        sameReference(character.spells, other.character.spells) &&
        sameReference(character.spellSlots, other.character.spellSlots) &&
        sameReference(
          character.pactMagicSlots,
          other.character.pactMagicSlots,
        ) &&
        sameReference(character.innateSpells, other.character.innateSpells) &&
        sameReference(
          character.disabledSpells,
          other.character.disabledSpells,
        ) &&
        character.concentrationSpell == other.character.concentrationSpell;
  }

  @override
  int get hashCode => Object.hashAll([
    character.characterClass,
    character.subclass,
    character.level,
    referenceHash(character.classes),
    referenceHash(character.abilityScores),
    character.proficiencyBonus,
    referenceHash(character.spells),
    referenceHash(character.spellSlots),
    referenceHash(character.pactMagicSlots),
    referenceHash(character.innateSpells),
    referenceHash(character.disabledSpells),
    character.concentrationSpell,
  ]);
}
