import 'package:json_annotation/json_annotation.dart';

part 'equipment_item.g.dart';

@JsonSerializable()
class EquipmentItem {
  final String name;
  final String category;
  final int quantity;
  final String? description;
  final bool isEquipped;
  final Map<String, dynamic>? properties;

  const EquipmentItem({
    required this.name,
    required this.category,
    this.quantity = 1,
    this.description,
    this.isEquipped = false,
    this.properties,
  });

  EquipmentItem copyWith({
    String? name,
    String? category,
    int? quantity,
    String? description,
    bool? isEquipped,
    Map<String, dynamic>? properties,
  }) {
    return EquipmentItem(
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      isEquipped: isEquipped ?? this.isEquipped,
      properties: properties ?? this.properties,
    );
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentItemToJson(this);
}
