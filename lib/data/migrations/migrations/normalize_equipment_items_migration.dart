import 'package:collection/collection.dart';

import '../../datasources/srd/srd_models.dart';
import '../../models/models.dart';
import '../character_migration.dart';

class NormalizeEquipmentItemsMigration extends CharacterMigration {
  const NormalizeEquipmentItemsMigration();

  static const changeCode = 'equipment_items_normalized';

  @override
  int get targetVersion => 2;

  @override
  String get id => 'normalize_equipment_items';

  @override
  String get title => 'Normalize equipment items';

  @override
  String get description =>
      'Updates known inventory items with current type, category, weight, and properties.';

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
      final data = _lookupKnownItem(context, item.name);
      if (data == null) return item;

      final normalizedProperties = _normalizedProperties(item, data);
      final normalized = item.copyWith(
        category: data.category,
        itemType: data.asItemType,
        weight: data.weight,
        properties: normalizedProperties,
      );

      if (!_sameItem(item, normalized)) {
        updatedCount += 1;
      }

      return normalized;
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

  Map<String, dynamic>? _normalizedProperties(
    EquipmentItem item,
    SrdItemData data,
  ) {
    final dataProperties = data.properties;
    if (dataProperties == null || dataProperties.isEmpty) {
      return item.properties;
    }
    return {
      ...?item.properties,
      ...dataProperties,
    };
  }

  bool _sameItem(EquipmentItem a, EquipmentItem b) {
    const mapEquality = DeepCollectionEquality();
    return a.category == b.category &&
        a.itemType == b.itemType &&
        a.weight == b.weight &&
        mapEquality.equals(a.properties, b.properties);
  }

  SrdItemData? _lookupKnownItem(CharacterMigrationContext context, String name) {
    final lower = name.toLowerCase();
    return context.itemsByName[lower] ??
        (lower.endsWith('s')
            ? context.itemsByName[lower.substring(0, lower.length - 1)]
            : null);
  }
}
