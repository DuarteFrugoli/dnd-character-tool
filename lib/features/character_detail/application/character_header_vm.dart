import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';

final characterHeaderVmProvider =
    Provider.family<AsyncValue<CharacterHeaderVm>, String>((ref, characterId) {
  return ref.watch(
    characterDetailProvider(characterId).select(
      (state) => state.whenData(CharacterHeaderVm.fromCharacter),
    ),
  );
});

class CharacterHeaderVm {
  const CharacterHeaderVm({
    required this.dataVersion,
    required this.name,
    required this.characterClass,
    required this.subclass,
    required this.race,
    required this.subrace,
    required this.level,
    required this.xpTrackingEnabled,
  });

  factory CharacterHeaderVm.fromCharacter(Character character) {
    return CharacterHeaderVm(
      dataVersion: character.dataVersion,
      name: character.name,
      characterClass: character.characterClass,
      subclass: character.subclass,
      race: character.race,
      subrace: character.subrace,
      level: character.level,
      xpTrackingEnabled: character.xpTrackingEnabled,
    );
  }

  final int dataVersion;
  final String name;
  final String characterClass;
  final String? subclass;
  final String race;
  final String? subrace;
  final int level;
  final bool xpTrackingEnabled;

  @override
  bool operator ==(Object other) {
    return other is CharacterHeaderVm &&
        dataVersion == other.dataVersion &&
        name == other.name &&
        characterClass == other.characterClass &&
        subclass == other.subclass &&
        race == other.race &&
        subrace == other.subrace &&
        level == other.level &&
        xpTrackingEnabled == other.xpTrackingEnabled;
  }

  @override
  int get hashCode => Object.hash(
        dataVersion,
        name,
        characterClass,
        subclass,
        race,
        subrace,
        level,
        xpTrackingEnabled,
      );
}
