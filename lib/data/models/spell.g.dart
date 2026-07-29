// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpellSlots _$SpellSlotsFromJson(Map<String, dynamic> json) => SpellSlots(
  total:
      (json['total'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [0, 0, 0, 0, 0, 0, 0, 0, 0],
  used:
      (json['used'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [0, 0, 0, 0, 0, 0, 0, 0, 0],
);

Map<String, dynamic> _$SpellSlotsToJson(SpellSlots instance) =>
    <String, dynamic>{'total': instance.total, 'used': instance.used};

KnownSpell _$KnownSpellFromJson(Map<String, dynamic> json) => KnownSpell(
  name: json['name'] as String,
  level: (json['level'] as num).toInt(),
  isPrepared: json['isPrepared'] as bool? ?? false,
  isAlwaysPrepared: json['isAlwaysPrepared'] as bool? ?? false,
  sourceType: json['sourceType'] as String? ?? 'manual',
  sourceClass: json['sourceClass'] as String?,
  sourceSubclass: json['sourceSubclass'] as String?,
  sourceFeature: json['sourceFeature'] as String?,
  sourceClassEntryId: json['sourceClassEntryId'] as String?,
  // 'school' field removed — old saved characters with school in JSON load fine
);

Map<String, dynamic> _$KnownSpellToJson(KnownSpell instance) =>
    <String, dynamic>{
      'name': instance.name,
      'level': instance.level,
      'isPrepared': instance.isPrepared,
      'isAlwaysPrepared': instance.isAlwaysPrepared,
      'sourceType': instance.sourceType,
      'sourceClass': instance.sourceClass,
      'sourceSubclass': instance.sourceSubclass,
      'sourceFeature': instance.sourceFeature,
      'sourceClassEntryId': instance.sourceClassEntryId,
    };
