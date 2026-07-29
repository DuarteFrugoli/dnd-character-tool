import 'package:collection/collection.dart';

import '../../datasources/srd/srd_models.dart';
import '../../models/models.dart';
import '../character_migration.dart';

class ExpandEquipmentPacksMigration extends CharacterMigration {
  const ExpandEquipmentPacksMigration();

  static const changeCode = 'equipment_packs_expanded';

  @override
  int get targetVersion => 3;

  @override
  String get id => 'expand_equipment_packs';

  @override
  String get title => 'Expand equipment packs';

  @override
  String get description =>
      'Replaces known starting equipment packs with their individual contents.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext context,
  ) {
    if (character.equipment.isEmpty) {
      return CharacterMigrationResult(character: character);
    }

    var expandedCount = 0;
    final updatedEquipment = <EquipmentItem>[];

    for (final item in character.equipment) {
      final data = _lookupKnownItem(context, item.name);
      if (data == null || data.contents.isEmpty) {
        _addOrStack(updatedEquipment, item);
        continue;
      }

      expandedCount += item.quantity;
      for (final content in data.contents) {
        final contentData = _lookupKnownItem(context, content.name);
        _addOrStack(
          updatedEquipment,
          EquipmentItem(
            name: content.name,
            category: contentData?.category ?? item.category,
            itemType: contentData?.asItemType ?? ItemType.gear,
            quantity: item.quantity * content.quantity,
            weight: contentData?.weight ?? 0.0,
            properties: contentData?.properties,
          ),
        );
      }
    }

    if (expandedCount == 0) {
      return CharacterMigrationResult(character: character);
    }

    return CharacterMigrationResult(
      character: character.copyWith(equipment: updatedEquipment),
      changes: [
        CharacterMigrationChange(code: changeCode, count: expandedCount),
      ],
    );
  }

  void _addOrStack(List<EquipmentItem> items, EquipmentItem item) {
    if (item.isEquipped) {
      items.add(item);
      return;
    }

    final index = items.indexWhere(
      (existing) =>
          !existing.isEquipped &&
          existing.name == item.name &&
          existing.category == item.category &&
          existing.itemType == item.itemType &&
          const DeepCollectionEquality().equals(
            existing.properties,
            item.properties,
          ),
    );
    if (index < 0) {
      items.add(item);
      return;
    }

    final existing = items[index];
    items[index] = existing.copyWith(
      quantity: existing.quantity + item.quantity,
      weight: existing.weight == 0 && item.weight > 0 ? item.weight : null,
      properties: existing.properties ?? item.properties,
    );
  }

  SrdItemData? _lookupKnownItem(
    CharacterMigrationContext context,
    String name,
  ) {
    final lower = name.toLowerCase();
    return context.itemsByName[lower] ??
        (lower.endsWith('s')
            ? context.itemsByName[lower.substring(0, lower.length - 1)]
            : null);
  }
}
