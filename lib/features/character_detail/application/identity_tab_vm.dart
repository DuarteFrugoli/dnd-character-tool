import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import 'vm_reference_utils.dart';

final identityTabVmProvider =
    Provider.family<AsyncValue<IdentityTabVm>, String>((ref, characterId) {
      return ref.watch(
        characterDetailProvider(
          characterId,
        ).select((state) => state.whenData(IdentityTabVm.fromCharacter)),
      );
    });

class IdentityTabVm {
  const IdentityTabVm(this.character);

  factory IdentityTabVm.fromCharacter(Character character) {
    return IdentityTabVm(character);
  }

  final Character character;

  @override
  bool operator ==(Object other) {
    return other is IdentityTabVm &&
        character.name == other.character.name &&
        character.playerName == other.character.playerName &&
        character.race == other.character.race &&
        character.subrace == other.character.subrace &&
        character.characterClass == other.character.characterClass &&
        character.subclass == other.character.subclass &&
        character.level == other.character.level &&
        character.background == other.character.background &&
        character.alignment == other.character.alignment &&
        sameReference(character.languages, other.character.languages) &&
        sameReference(character.personality, other.character.personality) &&
        sameReference(character.appearance, other.character.appearance) &&
        character.backstory == other.character.backstory &&
        character.imagePath == other.character.imagePath &&
        character.xpTrackingEnabled == other.character.xpTrackingEnabled;
  }

  @override
  int get hashCode => Object.hash(
    character.name,
    character.playerName,
    character.race,
    character.subrace,
    character.characterClass,
    character.subclass,
    character.level,
    character.background,
    character.alignment,
    referenceHash(character.languages),
    referenceHash(character.personality),
    referenceHash(character.appearance),
    character.backstory,
    character.imagePath,
    character.xpTrackingEnabled,
  );
}
