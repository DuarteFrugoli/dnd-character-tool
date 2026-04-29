// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipmentItem _$EquipmentItemFromJson(Map<String, dynamic> json) =>
    EquipmentItem(
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      description: json['description'] as String?,
      isEquipped: json['isEquipped'] as bool? ?? false,
      properties: json['properties'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EquipmentItemToJson(EquipmentItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'quantity': instance.quantity,
      'description': instance.description,
      'isEquipped': instance.isEquipped,
      'properties': instance.properties,
    };
