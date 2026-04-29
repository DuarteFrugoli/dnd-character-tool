// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ability_scores.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbilityScores _$AbilityScoresFromJson(Map<String, dynamic> json) =>
    AbilityScores(
      strength: (json['strength'] as num?)?.toInt() ?? 10,
      dexterity: (json['dexterity'] as num?)?.toInt() ?? 10,
      constitution: (json['constitution'] as num?)?.toInt() ?? 10,
      intelligence: (json['intelligence'] as num?)?.toInt() ?? 10,
      wisdom: (json['wisdom'] as num?)?.toInt() ?? 10,
      charisma: (json['charisma'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$AbilityScoresToJson(AbilityScores instance) =>
    <String, dynamic>{
      'strength': instance.strength,
      'dexterity': instance.dexterity,
      'constitution': instance.constitution,
      'intelligence': instance.intelligence,
      'wisdom': instance.wisdom,
      'charisma': instance.charisma,
    };
