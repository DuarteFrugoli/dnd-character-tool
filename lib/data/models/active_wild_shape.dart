/// Beast form a Druid is in. The stat block comes from the character's
/// content pack by [monsterId].
class ActiveWildShape {
  const ActiveWildShape({
    required this.monsterId,
    this.hitPoints,
    this.maxHitPoints,
  });

  final String monsterId;

  /// 2014 only: the form's own hit points; 2024 forms keep the character's.
  final int? hitPoints;
  final int? maxHitPoints;

  ActiveWildShape copyWith({int? hitPoints}) => ActiveWildShape(
    monsterId: monsterId,
    hitPoints: hitPoints ?? this.hitPoints,
    maxHitPoints: maxHitPoints,
  );

  factory ActiveWildShape.fromJson(Map<String, dynamic> json) => ActiveWildShape(
    monsterId: json['monsterId'] as String,
    hitPoints: (json['hitPoints'] as num?)?.toInt(),
    maxHitPoints: (json['maxHitPoints'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'monsterId': monsterId,
    if (hitPoints != null) 'hitPoints': hitPoints,
    if (maxHitPoints != null) 'maxHitPoints': maxHitPoints,
  };
}
