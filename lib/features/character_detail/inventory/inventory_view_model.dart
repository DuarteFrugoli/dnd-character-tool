import 'package:collection/collection.dart';

import '../../../data/models/models.dart';

const inventoryEquippableTypes = {
  ItemType.weapon,
  ItemType.armor,
  ItemType.equippable,
};

class InventorySnapshot {
  InventorySnapshot._({
    required this.allItems,
    required this.itemById,
    required this.containers,
    required this.containerIds,
    required this.rootItems,
    required this.contentsByContainer,
    required this.ammunition,
    required this.equipped,
    required this.equippable,
    required this.carried,
    required this.totalWeight,
    required this.weightlessContainerIds,
  });

  factory InventorySnapshot.fromEquipment(List<EquipmentItem> equipment) {
    final containerIds = equipment
        .where((item) => item.itemType == ItemType.container)
        .map((item) => item.id)
        .toSet();
    final weightlessContainerIds = equipment
        .where(
          (item) =>
              item.itemType == ItemType.container &&
              inventoryContainerIgnoresContentWeight(item),
        )
        .map((item) => item.id)
        .toSet();

    final rootEntries = <_IndexedEquipmentItem>[];
    final contentsEntries = <String, List<_IndexedEquipmentItem>>{
      for (final id in containerIds) id: [],
    };
    final itemById = <String, EquipmentItem>{};
    var totalWeight = 0.0;

    for (final entry in equipment.mapIndexed(_IndexedEquipmentItem.new)) {
      final item = entry.item;
      itemById[item.id] = item;
      final effectiveContainerId = _effectiveContainerId(item, containerIds);
      if (effectiveContainerId == null) {
        rootEntries.add(entry);
      } else {
        (contentsEntries[effectiveContainerId] ??= []).add(entry);
      }

      if (effectiveContainerId != null &&
          weightlessContainerIds.contains(effectiveContainerId)) {
        continue;
      }
      totalWeight += item.weight * item.quantity;
    }

    final rootItems = _sortEntries(rootEntries);
    final contentsByContainer = {
      for (final entry in contentsEntries.entries)
        entry.key: _sortEntries(entry.value),
    };
    final containers = rootItems
        .where((item) => item.itemType == ItemType.container)
        .toList();
    final ammunition = rootItems
        .where((item) => item.itemType == ItemType.ammunition)
        .toList();
    final nonAmmo = rootItems.where(
      (item) => item.itemType != ItemType.ammunition,
    );
    final equipped = nonAmmo.where((item) => item.isEquipped).toList();
    final equippable = nonAmmo
        .where(
          (item) =>
              !item.isEquipped &&
              inventoryEquippableTypes.contains(item.itemType),
        )
        .toList();
    final carried = nonAmmo
        .where(
          (item) =>
              !item.isEquipped &&
              item.itemType != ItemType.container &&
              !inventoryEquippableTypes.contains(item.itemType),
        )
        .toList();

    return InventorySnapshot._(
      allItems: [
        ...rootItems,
        for (final group in contentsByContainer.values) ...group,
      ],
      itemById: itemById,
      containers: containers,
      containerIds: containerIds,
      rootItems: rootItems,
      contentsByContainer: contentsByContainer,
      ammunition: ammunition,
      equipped: equipped,
      equippable: equippable,
      carried: carried,
      totalWeight: totalWeight,
      weightlessContainerIds: weightlessContainerIds,
    );
  }

  final List<EquipmentItem> allItems;
  final Map<String, EquipmentItem> itemById;
  final List<EquipmentItem> containers;
  final Set<String> containerIds;
  final List<EquipmentItem> rootItems;
  final Map<String, List<EquipmentItem>> contentsByContainer;
  final List<EquipmentItem> ammunition;
  final List<EquipmentItem> equipped;
  final List<EquipmentItem> equippable;
  final List<EquipmentItem> carried;
  final double totalWeight;
  final Set<String> weightlessContainerIds;

  bool get isEmpty =>
      equipped.isEmpty &&
      equippable.isEmpty &&
      containers.isEmpty &&
      ammunition.isEmpty &&
      carried.isEmpty;
}

double inventoryItemsTotalWeight(Iterable<EquipmentItem> items) {
  return items.fold<double>(
    0.0,
    (sum, item) => sum + item.weight * item.quantity,
  );
}

int inventoryItemsTotalQuantity(Iterable<EquipmentItem> items) {
  return items.fold<int>(0, (sum, item) => sum + item.quantity);
}

double? inventoryContainerCapacityWeight(EquipmentItem container) {
  final value = container.properties?['capacityWeight'];
  return value is num ? value.toDouble() : null;
}

bool inventoryContainerIgnoresContentWeight(EquipmentItem container) {
  return container.properties?['contentsWeightIgnored'] == true;
}

List<EquipmentItem> _sortEntries(List<_IndexedEquipmentItem> entries) {
  entries.sort((a, b) {
    final byOrder = a.item.sortOrder.compareTo(b.item.sortOrder);
    if (byOrder != 0) return byOrder;
    return a.index.compareTo(b.index);
  });
  return entries.map((entry) => entry.item).toList();
}

String? _effectiveContainerId(
  EquipmentItem item,
  Set<String> containerIds,
) {
  if (item.itemType == ItemType.container) return null;
  if (item.isEquipped) return null;
  final containerId = item.containerId;
  if (containerId == null || !containerIds.contains(containerId)) return null;
  return containerId;
}

class _IndexedEquipmentItem {
  const _IndexedEquipmentItem(this.index, this.item);

  final int index;
  final EquipmentItem item;
}
