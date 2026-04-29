import 'package:json_annotation/json_annotation.dart';

part 'hit_points.g.dart';

@JsonSerializable()
class HitPoints {
  final int maximum;
  final int current;
  final int temporary;

  const HitPoints({
    required this.maximum,
    required this.current,
    this.temporary = 0,
  });

  bool get isDead => current <= 0 && temporary <= 0;
  int get effective => current + temporary;

  HitPoints copyWith({int? maximum, int? current, int? temporary}) {
    return HitPoints(
      maximum: maximum ?? this.maximum,
      current: current ?? this.current,
      temporary: temporary ?? this.temporary,
    );
  }

  factory HitPoints.fromJson(Map<String, dynamic> json) =>
      _$HitPointsFromJson(json);

  Map<String, dynamic> toJson() => _$HitPointsToJson(this);
}
