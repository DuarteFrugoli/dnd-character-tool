import '../../datasources/srd/srd_models.dart';
import '../../models/models.dart';
import '../character_migration.dart';

class BackfillEquipmentWeightsMigration extends CharacterMigration {
  const BackfillEquipmentWeightsMigration();

  static const changeCode = 'equipment_weights_backfilled';

  @override
  int get targetVersion => 1;

  @override
  String get id => 'backfill_equipment_weights';

  @override
  String get title => 'Backfill equipment weights';

  @override
  String get description =>
      'Updates known inventory items that were saved with zero weight.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext context,
  ) {
    if (character.equipment.isEmpty) {
      return CharacterMigrationResult(character: character);
    }

    var updatedCount = 0;
    final updatedEquipment = character.equipment.map((item) {
      if (item.weight != 0) return item;

      final data = _lookupKnownItem(context, item.name);
      if (data == null || data.weight <= 0) return item;

      updatedCount += 1;
      return item.copyWith(
        weight: data.weight,
        properties: item.properties == null ? data.properties : null,
      );
    }).toList();

    if (updatedCount == 0) {
      return CharacterMigrationResult(character: character);
    }

    return CharacterMigrationResult(
      character: character.copyWith(equipment: updatedEquipment),
      changes: [
        CharacterMigrationChange(
          code: changeCode,
          count: updatedCount,
        ),
      ],
    );
  }

  SrdItemData? _lookupKnownItem(CharacterMigrationContext context, String name) {
    final lower = name.toLowerCase();
    return context.itemsByName[lower] ??
        (lower.endsWith('s')
            ? context.itemsByName[lower.substring(0, lower.length - 1)]
            : null);
  }
}
