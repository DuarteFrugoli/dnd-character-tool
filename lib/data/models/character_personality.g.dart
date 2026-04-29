// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_personality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterPersonality _$CharacterPersonalityFromJson(
  Map<String, dynamic> json,
) => CharacterPersonality(
  traits: json['traits'] as String? ?? '',
  ideals: json['ideals'] as String? ?? '',
  bonds: json['bonds'] as String? ?? '',
  flaws: json['flaws'] as String? ?? '',
);

Map<String, dynamic> _$CharacterPersonalityToJson(
  CharacterPersonality instance,
) => <String, dynamic>{
  'traits': instance.traits,
  'ideals': instance.ideals,
  'bonds': instance.bonds,
  'flaws': instance.flaws,
};
