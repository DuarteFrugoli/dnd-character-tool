import '../../inventory/inventory_operations.dart';
import '../../models/models.dart';
import '../character_migration.dart';

class NormalizeEquipmentOrderMigration extends CharacterMigration {
  const NormalizeEquipmentOrderMigration();

  static const changeCode = 'equipment_order_normalized';

  @override
  int get targetVersion => 5;

  @override
  String get id => 'normalize_equipment_order';

  @override
  String get title => 'Normalize equipment order';

  @override
  String get description => 'Assigns explicit order values to inventory items.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext _,
  ) {
    if (character.equipment.isEmpty) {
      return CharacterMigrationResult(character: character);
    }

    final updatedEquipment = normalizeEquipmentSortOrders(character.equipment);
    var changedCount = 0;
    for (var i = 0; i < character.equipment.length; i++) {
      final before = character.equipment[i];
      final after = updatedEquipment[i];
      if (before.containerId != after.containerId ||
          before.sortOrder != after.sortOrder) {
        changedCount += 1;
      }
    }

    if (changedCount == 0) {
      return CharacterMigrationResult(character: character);
    }

    return CharacterMigrationResult(
      character: character.copyWith(equipment: updatedEquipment),
      changes: [
        CharacterMigrationChange(code: changeCode, count: changedCount),
      ],
    );
  }
}
