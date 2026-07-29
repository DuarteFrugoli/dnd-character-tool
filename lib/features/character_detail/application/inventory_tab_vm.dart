import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import '../inventory/inventory_view_model.dart';
import 'vm_reference_utils.dart';

final inventoryTabVmProvider =
    Provider.family<AsyncValue<InventoryTabVm>, String>((ref, characterId) {
      final slice = ref.watch(
        characterDetailProvider(
          characterId,
        ).select((state) => state.whenData(_InventoryTabSlice.fromCharacter)),
      );
      return slice.whenData(InventoryTabVm._fromSlice);
    });

class _InventoryTabSlice {
  const _InventoryTabSlice({
    required this.character,
    required this.strengthScore,
  });

  factory _InventoryTabSlice.fromCharacter(Character character) {
    return _InventoryTabSlice(
      character: character,
      strengthScore: character.abilityScores.strength,
    );
  }

  final Character character;
  final int strengthScore;

  @override
  bool operator ==(Object other) {
    return other is _InventoryTabSlice &&
        sameReference(character.equipment, other.character.equipment) &&
        sameReference(character.currency, other.character.currency) &&
        strengthScore == other.strengthScore &&
        character.armorClass == other.character.armorClass &&
        character.weightTrackingEnabled ==
            other.character.weightTrackingEnabled;
  }

  @override
  int get hashCode => Object.hash(
    referenceHash(character.equipment),
    referenceHash(character.currency),
    strengthScore,
    character.armorClass,
    character.weightTrackingEnabled,
  );
}

class InventoryTabVm {
  InventoryTabVm._({
    required this.character,
    required this.snapshot,
    required this.strengthScore,
  });

  factory InventoryTabVm._fromSlice(_InventoryTabSlice slice) {
    return InventoryTabVm._(
      character: slice.character,
      snapshot: InventorySnapshot.fromEquipment(slice.character.equipment),
      strengthScore: slice.strengthScore,
    );
  }

  final Character character;
  final InventorySnapshot snapshot;
  final int strengthScore;
}
