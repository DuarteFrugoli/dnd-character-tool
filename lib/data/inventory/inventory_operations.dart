import 'package:collection/collection.dart';

import '../models/models.dart';

enum ContainerRemovalMode { moveContentsToInventory, deleteContents }

typedef BodyArmorPredicate = bool Function(EquipmentItem item);

List<EquipmentItem> addEquipmentItem(
  List<EquipmentItem> equipment,
  EquipmentItem item,
) {
  final updated = List<EquipmentItem>.from(equipment);
  final itemToAdd = item.copyWith(
    isEquipped: false,
    clearContainer: true,
    sortOrder: _nextSortOrder(updated, null),
  );

  if (itemToAdd.itemType == ItemType.container) {
    final quantity = itemToAdd.quantity.clamp(1, 9999).toInt();
    final firstOrder = _nextSortOrder(updated, null);
    updated.addAll([
      for (var i = 0; i < quantity; i++)
        EquipmentItem(
          name: itemToAdd.name,
          category: itemToAdd.category,
          itemType: itemToAdd.itemType,
          quantity: 1,
          description: itemToAdd.description,
          isEquipped: false,
          weight: itemToAdd.weight,
          sortOrder: firstOrder + i,
          properties: itemToAdd.properties,
        ),
    ]);
    return updated;
  }

  final idx = updated.indexWhere(
    (e) =>
        !e.isEquipped &&
        e.containerId == null &&
        e.name == itemToAdd.name &&
        e.itemType == itemToAdd.itemType,
  );
  if (idx >= 0) {
    final existing = updated[idx];
    updated[idx] = existing.copyWith(
      quantity: existing.quantity + itemToAdd.quantity,
      weight: existing.weight == 0 && itemToAdd.weight > 0
          ? itemToAdd.weight
          : null,
      properties: existing.properties == null ? itemToAdd.properties : null,
    );
    return updated;
  }

  updated.add(itemToAdd);
  return updated;
}

List<EquipmentItem> removeEquipmentQuantity(
  List<EquipmentItem> equipment,
  String id,
  int amount, {
  ContainerRemovalMode containerRemovalMode =
      ContainerRemovalMode.moveContentsToInventory,
}) {
  final updated = List<EquipmentItem>.from(equipment);
  final idx = updated.indexWhere((e) => e.id == id);
  if (idx < 0) return updated;

  final removed = updated[idx];
  if (removed.quantity <= 0) {
    updated.removeWhere((e) => e.id == removed.id);
    return updated;
  }

  final removeAmount = amount.clamp(1, removed.quantity).toInt();
  if (removeAmount < removed.quantity) {
    updated[idx] = removed.copyWith(quantity: removed.quantity - removeAmount);
    return updated;
  }

  if (removed.itemType == ItemType.container) {
    if (containerRemovalMode == ContainerRemovalMode.moveContentsToInventory) {
      for (var i = 0; i < updated.length; i++) {
        if (updated[i].containerId == removed.id &&
            updated[i].itemType != ItemType.container) {
          updated[i] = updated[i].copyWith(
            clearContainer: true,
            sortOrder: _nextSortOrder(updated, null),
          );
        }
      }
    } else {
      updated.removeWhere(
        (e) => e.containerId == removed.id && e.itemType != ItemType.container,
      );
    }
  }

  updated.removeWhere((e) => e.id == removed.id);
  return updated;
}

List<EquipmentItem> toggleEquipped(
  List<EquipmentItem> equipment,
  String id, {
  required BodyArmorPredicate isBodyArmor,
  bool forceArmorSwap = false,
}) {
  final updated = List<EquipmentItem>.from(equipment);
  var idx = updated.indexWhere((e) => e.id == id);
  if (idx < 0) return updated;

  var target = updated[idx];
  final targetIsBodyArmor = isBodyArmor(target);

  if (!target.isEquipped) {
    if (targetIsBodyArmor && forceArmorSwap) {
      _unequipOtherBodyArmors(updated, isBodyArmor, exceptId: target.id);

      idx = updated.indexWhere((e) => e.id == id);
      if (idx < 0) return updated;
      target = updated[idx];
    }

    if (target.quantity > 1) {
      updated[idx] = target.copyWith(quantity: target.quantity - 1);
      updated.add(
        EquipmentItem(
          name: target.name,
          category: target.category,
          itemType: target.itemType,
          quantity: 1,
          description: target.description,
          isEquipped: true,
          weight: target.weight,
          sortOrder: _nextSortOrder(updated, null),
          properties: target.properties,
        ),
      );
    } else {
      updated[idx] = target.copyWith(
        isEquipped: true,
        clearContainer: true,
        sortOrder: target.containerId == null
            ? target.sortOrder
            : _nextSortOrder(updated, null),
      );
    }
  } else {
    updated.removeAt(idx);
    _mergeIntoCarried(
      updated,
      target.copyWith(
        isEquipped: false,
        clearContainer: true,
        sortOrder: _nextSortOrder(updated, null),
      ),
    );
  }

  return updated;
}

List<EquipmentItem> moveItemToContainer(
  List<EquipmentItem> equipment,
  String itemId,
  String? containerId,
) {
  final updated = List<EquipmentItem>.from(equipment);
  final idx = updated.indexWhere((e) => e.id == itemId);
  if (idx < 0) return updated;

  final item = updated[idx];
  if (item.itemType == ItemType.container && containerId != null) {
    return updated;
  }
  if (item.isEquipped && containerId != null) return updated;

  if (containerId != null) {
    final container = updated.firstWhereOrNull((e) => e.id == containerId);
    if (container == null || container.itemType != ItemType.container) {
      return updated;
    }
    if (container.id == item.id) return updated;
  }

  updated.removeAt(idx);
  final moved = item.copyWith(
    containerId: containerId,
    clearContainer: containerId == null,
    sortOrder: _nextSortOrder(updated, containerId),
  );
  final mergeIdx = updated.indexWhere(
    (e) =>
        !e.isEquipped &&
        e.itemType != ItemType.container &&
        e.containerId == containerId &&
        e.name == moved.name &&
        e.itemType == moved.itemType,
  );

  if (mergeIdx >= 0) {
    final existing = updated[mergeIdx];
    updated[mergeIdx] = existing.copyWith(
      quantity: existing.quantity + moved.quantity,
      weight: existing.weight == 0 && moved.weight > 0 ? moved.weight : null,
      properties: existing.properties == null ? moved.properties : null,
    );
  } else {
    updated.add(moved);
  }

  return updated;
}

List<EquipmentItem> reorderEquipmentItems({
  required List<EquipmentItem> equipment,
  required List<String> itemIds,
  required int oldIndex,
  required int newIndex,
}) {
  if (itemIds.length < 2) return equipment;

  final currentById = {for (final item in equipment) item.id: item};
  final groupIds = itemIds
      .where((id) => currentById.containsKey(id))
      .toList(growable: true);
  if (oldIndex < 0 || oldIndex >= groupIds.length) return equipment;

  var insertIndex = newIndex;
  if (insertIndex > oldIndex) insertIndex--;
  insertIndex = insertIndex.clamp(0, groupIds.length - 1).toInt();
  if (oldIndex == insertIndex) return equipment;

  final movedId = groupIds.removeAt(oldIndex);
  groupIds.insert(insertIndex, movedId);
  final sortOrderById = {
    for (var i = 0; i < groupIds.length; i++) groupIds[i]: i,
  };

  return [
    for (final item in equipment)
      if (sortOrderById.containsKey(item.id))
        item.copyWith(sortOrder: sortOrderById[item.id])
      else
        item,
  ];
}

List<EquipmentItem> adjustItemQuantity(
  List<EquipmentItem> equipment,
  String id,
  int delta,
) {
  final updated = equipment.map((e) {
    if (e.id != id) return e;
    final newQty = (e.quantity + delta).clamp(0, 9999).toInt();
    return e.copyWith(quantity: newQty);
  }).toList();

  return updated
      .where((e) => e.quantity > 0 || e.itemType == ItemType.ammunition)
      .toList();
}

List<EquipmentItem> normalizeEquipmentSortOrders(
  List<EquipmentItem> equipment,
) {
  if (equipment.isEmpty) return equipment;

  final containerIds = equipment
      .where((item) => item.itemType == ItemType.container)
      .map((item) => item.id)
      .toSet();
  final indexed = equipment.mapIndexed((index, item) {
    final normalizedContainerId = _effectiveContainerId(item, containerIds);
    final normalized = normalizedContainerId == item.containerId
        ? item
        : item.copyWith(
            containerId: normalizedContainerId,
            clearContainer: normalizedContainerId == null,
          );
    return _IndexedEquipmentItem(index, normalized);
  }).toList();

  final byLocation = <String?, List<_IndexedEquipmentItem>>{};
  for (final entry in indexed) {
    final locationId = entry.item.containerId;
    (byLocation[locationId] ??= []).add(entry);
  }

  final normalizedById = <String, EquipmentItem>{};
  for (final group in byLocation.values) {
    group.sort((a, b) {
      final byOrder = a.item.sortOrder.compareTo(b.item.sortOrder);
      if (byOrder != 0) return byOrder;
      return a.index.compareTo(b.index);
    });
    for (var i = 0; i < group.length; i++) {
      final item = group[i].item;
      normalizedById[item.id] = item.sortOrder == i
          ? item
          : item.copyWith(sortOrder: i);
    }
  }

  return indexed
      .map((entry) => normalizedById[entry.item.id] ?? entry.item)
      .toList();
}

String? _effectiveContainerId(EquipmentItem item, Set<String> containerIds) {
  if (item.itemType == ItemType.container) return null;
  if (item.isEquipped) return null;
  final containerId = item.containerId;
  if (containerId == null || !containerIds.contains(containerId)) return null;
  return containerId;
}

int _nextSortOrder(List<EquipmentItem> equipment, String? containerId) {
  final containerIds = equipment
      .where((item) => item.itemType == ItemType.container)
      .map((item) => item.id)
      .toSet();
  final sortOrders = equipment
      .where((item) => _effectiveContainerId(item, containerIds) == containerId)
      .map((item) => item.sortOrder);
  if (sortOrders.isEmpty) return 0;
  return sortOrders.reduce((a, b) => a > b ? a : b) + 1;
}

void _unequipOtherBodyArmors(
  List<EquipmentItem> items,
  BodyArmorPredicate isBodyArmor, {
  required String exceptId,
}) {
  final toUnequip = items
      .where((e) => e.id != exceptId && e.isEquipped && isBodyArmor(e))
      .toList();
  items.removeWhere((e) => e.id != exceptId && e.isEquipped && isBodyArmor(e));
  for (final armor in toUnequip) {
    _mergeIntoCarried(
      items,
      armor.copyWith(
        isEquipped: false,
        clearContainer: true,
        sortOrder: _nextSortOrder(items, null),
      ),
    );
  }
}

void _mergeIntoCarried(List<EquipmentItem> items, EquipmentItem item) {
  final carryIdx = items.indexWhere(
    (e) =>
        !e.isEquipped &&
        e.containerId == null &&
        e.name == item.name &&
        e.itemType == item.itemType,
  );
  if (carryIdx >= 0) {
    items[carryIdx] = items[carryIdx].copyWith(
      quantity: items[carryIdx].quantity + item.quantity,
    );
    return;
  }

  items.add(
    EquipmentItem(
      name: item.name,
      category: item.category,
      itemType: item.itemType,
      quantity: item.quantity,
      description: item.description,
      isEquipped: false,
      weight: item.weight,
      sortOrder: item.sortOrder,
      properties: item.properties,
    ),
  );
}

class _IndexedEquipmentItem {
  const _IndexedEquipmentItem(this.index, this.item);

  final int index;
  final EquipmentItem item;
}
