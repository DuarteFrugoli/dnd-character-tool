import 'package:json_annotation/json_annotation.dart';

part 'hit_points.g.dart';

@JsonSerializable()
class HitPoints {
  final int maximum;
  final int current;
  final int temporary;
  final int deathSaveSuccesses;
  final int deathSaveFailures;

  const HitPoints({
    required this.maximum,
    required this.current,
    this.temporary = 0,
    this.deathSaveSuccesses = 0,
    this.deathSaveFailures = 0,
  });

  bool get isDead => current <= 0 && temporary <= 0;
  int get effective => current + temporary;

  HitPoints copyWith({
    int? maximum,
    int? current,
    int? temporary,
    int? deathSaveSuccesses,
    int? deathSaveFailures,
  }) {
    return HitPoints(
      maximum: maximum ?? this.maximum,
      current: current ?? this.current,
      temporary: temporary ?? this.temporary,
      deathSaveSuccesses: deathSaveSuccesses ?? this.deathSaveSuccesses,
      deathSaveFailures: deathSaveFailures ?? this.deathSaveFailures,
    );
  }

  factory HitPoints.fromJson(Map<String, dynamic> json) =>
      _$HitPointsFromJson(json);

  Map<String, dynamic> toJson() => _$HitPointsToJson(this);
}
