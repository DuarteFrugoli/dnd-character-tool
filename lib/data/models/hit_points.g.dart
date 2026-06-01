// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hit_points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HitPoints _$HitPointsFromJson(Map<String, dynamic> json) => HitPoints(
  maximum: (json['maximum'] as num).toInt(),
  current: (json['current'] as num).toInt(),
  temporary: (json['temporary'] as num?)?.toInt() ?? 0,
  deathSaveSuccesses: (json['deathSaveSuccesses'] as num?)?.toInt() ?? 0,
  deathSaveFailures: (json['deathSaveFailures'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HitPointsToJson(HitPoints instance) => <String, dynamic>{
  'maximum': instance.maximum,
  'current': instance.current,
  'temporary': instance.temporary,
  'deathSaveSuccesses': instance.deathSaveSuccesses,
  'deathSaveFailures': instance.deathSaveFailures,
};
