// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_appearance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterAppearance _$CharacterAppearanceFromJson(Map<String, dynamic> json) =>
    CharacterAppearance(
      age: json['age']?.toString(),
      height: json['height'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      eyes: json['eyes'] as String? ?? '',
      skin: json['skin'] as String? ?? '',
      hair: json['hair'] as String? ?? '',
    );

Map<String, dynamic> _$CharacterAppearanceToJson(
  CharacterAppearance instance,
) => <String, dynamic>{
  'age': instance.age,
  'height': instance.height,
  'weight': instance.weight,
  'eyes': instance.eyes,
  'skin': instance.skin,
  'hair': instance.hair,
};
