import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/features/character_detail/application/character_header_vm.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({required int dataVersion}) {
  final now = DateTime(2024);
  return Character(
    id: 'hero',
    dataVersion: dataVersion,
    name: 'Hero',
    race: 'Human',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CharacterHeaderVm', () {
    test('exposes whether the character data needs an update', () {
      final outdated = CharacterHeaderVm.fromCharacter(
        _character(dataVersion: currentCharacterDataVersion - 1),
      );
      final current = CharacterHeaderVm.fromCharacter(
        _character(dataVersion: currentCharacterDataVersion),
      );

      expect(outdated.needsDataUpdate, isTrue);
      expect(current.needsDataUpdate, isFalse);
    });
  });
}
