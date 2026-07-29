class CharacterHitDiePool {
  final int dieSize;
  final int total;
  final int used;
  final String? sourceClass;
  final String? sourceClassEntryId;

  const CharacterHitDiePool({
    required this.dieSize,
    required this.total,
    this.used = 0,
    this.sourceClass,
    this.sourceClassEntryId,
  });

  int get remaining {
    final safeTotal = total.clamp(0, 9999).toInt();
    final safeUsed = used.clamp(0, safeTotal).toInt();
    return safeTotal - safeUsed;
  }

  CharacterHitDiePool copyWith({
    int? dieSize,
    int? total,
    int? used,
    Object? sourceClass = _keep,
    Object? sourceClassEntryId = _keep,
  }) {
    return CharacterHitDiePool(
      dieSize: dieSize ?? this.dieSize,
      total: total ?? this.total,
      used: used ?? this.used,
      sourceClass: sourceClass == _keep
          ? this.sourceClass
          : sourceClass as String?,
      sourceClassEntryId: sourceClassEntryId == _keep
          ? this.sourceClassEntryId
          : sourceClassEntryId as String?,
    );
  }

  factory CharacterHitDiePool.fromJson(Map<String, dynamic> json) {
    final total = (json['total'] as num?)?.toInt() ?? 0;
    final used = (json['used'] as num?)?.toInt() ?? 0;
    return CharacterHitDiePool(
      dieSize: (json['dieSize'] as num?)?.toInt() ?? 8,
      total: total.clamp(0, 20).toInt(),
      used: used.clamp(0, total.clamp(0, 20)).toInt(),
      sourceClass: json['sourceClass'] as String?,
      sourceClassEntryId: json['sourceClassEntryId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'dieSize': dieSize,
    'total': total,
    'used': used,
    if (sourceClass != null) 'sourceClass': sourceClass,
    if (sourceClassEntryId != null) 'sourceClassEntryId': sourceClassEntryId,
  };

  static const _keep = Object();
}
