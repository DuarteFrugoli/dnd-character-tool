/// Feature added outside the base class/subclass progression.
class CharacterExtraFeature {
  final String sourceClass;
  final String sourceType;
  final String? sourceSubclass;
  final String? sourceFeature;
  final String? sourceClassEntryId;
  final String name;
  final int level;
  final String type; // "active" | "passive" | "subclass" | "asi"
  final String description;

  const CharacterExtraFeature({
    required this.sourceClass,
    this.sourceType = 'manual',
    this.sourceSubclass,
    this.sourceFeature,
    this.sourceClassEntryId,
    required this.name,
    required this.level,
    required this.type,
    required this.description,
  });

  String get effectiveSourceType {
    if (sourceClass == 'Feat' &&
        (sourceType.isEmpty || sourceType == 'manual')) {
      return 'feat';
    }
    if (sourceType.isNotEmpty) return sourceType;
    return 'manual';
  }

  CharacterExtraFeature copyWith({
    String? sourceClass,
    String? sourceType,
    Object? sourceSubclass = _keep,
    Object? sourceFeature = _keep,
    Object? sourceClassEntryId = _keep,
    String? name,
    int? level,
    String? type,
    String? description,
  }) {
    return CharacterExtraFeature(
      sourceClass: sourceClass ?? this.sourceClass,
      sourceType: sourceType ?? this.sourceType,
      sourceSubclass: sourceSubclass == _keep
          ? this.sourceSubclass
          : sourceSubclass as String?,
      sourceFeature: sourceFeature == _keep
          ? this.sourceFeature
          : sourceFeature as String?,
      sourceClassEntryId: sourceClassEntryId == _keep
          ? this.sourceClassEntryId
          : sourceClassEntryId as String?,
      name: name ?? this.name,
      level: level ?? this.level,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  factory CharacterExtraFeature.fromJson(Map<String, dynamic> json) {
    final legacySourceClass = json['sourceClass'] as String? ?? '';
    return CharacterExtraFeature(
      sourceClass: legacySourceClass,
      sourceType:
          json['sourceType'] as String? ??
          (legacySourceClass == 'Feat' ? 'feat' : 'manual'),
      sourceSubclass: json['sourceSubclass'] as String?,
      sourceFeature: json['sourceFeature'] as String?,
      sourceClassEntryId: json['sourceClassEntryId'] as String?,
      name: json['name'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      type: json['type'] as String? ?? 'passive',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'sourceClass': sourceClass,
    'sourceType': sourceType,
    if (sourceSubclass != null) 'sourceSubclass': sourceSubclass,
    if (sourceFeature != null) 'sourceFeature': sourceFeature,
    if (sourceClassEntryId != null) 'sourceClassEntryId': sourceClassEntryId,
    'name': name,
    'level': level,
    'type': type,
    'description': description,
  };

  static const _keep = Object();
}
