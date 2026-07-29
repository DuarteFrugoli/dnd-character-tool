class CharacterClassEntry {
  final String id;
  final String className;
  final String? subclassName;
  final int level;
  final bool isStartingClass;

  const CharacterClassEntry({
    required this.id,
    required this.className,
    this.subclassName,
    required this.level,
    this.isStartingClass = false,
  });

  CharacterClassEntry copyWith({
    String? id,
    String? className,
    Object? subclassName = _keep,
    int? level,
    bool? isStartingClass,
  }) {
    return CharacterClassEntry(
      id: id ?? this.id,
      className: className ?? this.className,
      subclassName: subclassName == _keep
          ? this.subclassName
          : subclassName as String?,
      level: level ?? this.level,
      isStartingClass: isStartingClass ?? this.isStartingClass,
    );
  }

  factory CharacterClassEntry.fromJson(Map<String, dynamic> json) {
    return CharacterClassEntry(
      id: json['id'] as String? ?? 'primary',
      className: json['className'] as String? ?? '',
      subclassName: json['subclassName'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      isStartingClass: json['isStartingClass'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'className': className,
    if (subclassName != null) 'subclassName': subclassName,
    'level': level,
    'isStartingClass': isStartingClass,
  };

  static const _keep = Object();
}
