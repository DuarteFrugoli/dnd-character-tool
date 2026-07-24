import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'equipment_item.g.dart';

const _uuid = Uuid();

/// Tipos mecanicos de item que definem comportamento na UI e no provider.
enum ItemType {
  weapon,
  armor,
  consumable,
  ammunition,
  equippable,
  container,
  gear,
}

@JsonSerializable()
class EquipmentItem {
  /// UUID único por entrada na lista (não por nome).
  @JsonKey(fromJson: _idFromJson)
  final String id;

  final String name;
  final String category;

  @JsonKey(fromJson: _itemTypeFromJson, toJson: _itemTypeToJson)
  final ItemType itemType;

  final int quantity;
  final String? description;
  final bool isEquipped;
  final double weight;
  final String? containerId;
  final int sortOrder;

  /// Dados extras por tipo:
  /// armor  → {baseAC, addDexModifier, maxDexBonus, isShield, acBonus}
  /// weapon → {damageDice, damageType}  (usado em sprint futuro)
  final Map<String, dynamic>? properties;

  EquipmentItem({
    String? id,
    required this.name,
    required this.category,
    this.itemType = ItemType.gear,
    this.quantity = 1,
    this.description,
    this.isEquipped = false,
    this.weight = 0.0,
    this.containerId,
    this.sortOrder = 0,
    this.properties,
  }) : id = id ?? _uuid.v4();

  EquipmentItem copyWith({
    String? id,
    String? name,
    String? category,
    ItemType? itemType,
    int? quantity,
    String? description,
    bool? isEquipped,
    double? weight,
    String? containerId,
    bool clearContainer = false,
    int? sortOrder,
    Map<String, dynamic>? properties,
  }) {
    return EquipmentItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      isEquipped: isEquipped ?? this.isEquipped,
      weight: weight ?? this.weight,
      containerId: clearContainer ? null : containerId ?? this.containerId,
      sortOrder: sortOrder ?? this.sortOrder,
      properties: properties ?? this.properties,
    );
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentItemToJson(this);
}

// ── Helpers de serialização ───────────────────────────────────────────────────

String _idFromJson(dynamic v) => (v is String && v.isNotEmpty) ? v : _uuid.v4();

ItemType _itemTypeFromJson(dynamic v) =>
    ItemType.values.firstWhere((e) => e.name == v, orElse: () => ItemType.gear);

String _itemTypeToJson(ItemType t) => t.name;
