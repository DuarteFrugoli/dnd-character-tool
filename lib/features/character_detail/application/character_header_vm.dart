import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import 'vm_reference_utils.dart';

final characterHeaderVmProvider =
    Provider.family<AsyncValue<CharacterHeaderVm>, String>((ref, characterId) {
      return ref.watch(
        characterDetailProvider(
          characterId,
        ).select((state) => state.whenData(CharacterHeaderVm.fromCharacter)),
      );
    });

class CharacterHeaderVm {
  const CharacterHeaderVm({
    required this.dataVersion,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.classes,
    required this.race,
    required this.subrace,
    required this.level,
    required this.xpTrackingEnabled,
  });

  factory CharacterHeaderVm.fromCharacter(Character character) {
    return CharacterHeaderVm(
      dataVersion: character.dataVersion,
      id: character.id,
      name: character.name,
      imagePath: character.imagePath,
      classes: character.classEntries,
      race: character.race,
      subrace: character.subrace,
      level: character.totalLevel,
      xpTrackingEnabled: character.xpTrackingEnabled,
    );
  }

  final int dataVersion;
  final String id;
  final String name;
  final String? imagePath;
  final List<CharacterClassEntry> classes;
  final String race;
  final String? subrace;
  final int level;
  final bool xpTrackingEnabled;

  @override
  bool operator ==(Object other) {
    return other is CharacterHeaderVm &&
        dataVersion == other.dataVersion &&
        id == other.id &&
        name == other.name &&
        imagePath == other.imagePath &&
        sameReference(classes, other.classes) &&
        race == other.race &&
        subrace == other.subrace &&
        level == other.level &&
        xpTrackingEnabled == other.xpTrackingEnabled;
  }

  @override
  int get hashCode => Object.hash(
    dataVersion,
    id,
    name,
    imagePath,
    referenceHash(classes),
    race,
    subrace,
    level,
    xpTrackingEnabled,
  );
}
