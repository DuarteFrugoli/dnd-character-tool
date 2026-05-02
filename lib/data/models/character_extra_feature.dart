/// Feature adicionada manualmente pelo usuário (ex: multiclasse).
class CharacterExtraFeature {
  final String sourceClass;
  final String name;
  final int level;
  final String type; // "active" | "passive" | "subclass" | "asi"
  final String description;

  const CharacterExtraFeature({
    required this.sourceClass,
    required this.name,
    required this.level,
    required this.type,
    required this.description,
  });

  factory CharacterExtraFeature.fromJson(Map<String, dynamic> json) =>
      CharacterExtraFeature(
        sourceClass: json['sourceClass'] as String? ?? '',
        name: json['name'] as String? ?? '',
        level: (json['level'] as num?)?.toInt() ?? 1,
        type: json['type'] as String? ?? 'passive',
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'sourceClass': sourceClass,
        'name': name,
        'level': level,
        'type': type,
        'description': description,
      };
}
