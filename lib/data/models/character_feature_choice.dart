/// A choice made for a class feature, subclass feature, racial trait, or feat.
///
/// Values store stable option IDs from SRD data, never localized display text.
class CharacterFeatureChoice {
  final String sourceType; // classFeature | subclassFeature | raceTrait | feat
  final String sourceClass;
  final String? sourceSubclass;
  final String? sourceName;
  final String featureName;
  final String choiceId;
  final List<String> values;

  const CharacterFeatureChoice({
    required this.sourceType,
    this.sourceClass = '',
    this.sourceSubclass,
    this.sourceName,
    required this.featureName,
    required this.choiceId,
    this.values = const [],
  });

  bool matches({
    required String sourceType,
    String sourceClass = '',
    String? sourceSubclass,
    String? sourceName,
    required String featureName,
    String? choiceId,
  }) {
    return this.sourceType == sourceType &&
        this.sourceClass == sourceClass &&
        this.sourceSubclass == sourceSubclass &&
        this.sourceName == sourceName &&
        this.featureName == featureName &&
        (choiceId == null || this.choiceId == choiceId);
  }

  CharacterFeatureChoice copyWith({
    String? sourceType,
    String? sourceClass,
    String? sourceSubclass,
    String? sourceName,
    String? featureName,
    String? choiceId,
    List<String>? values,
  }) {
    return CharacterFeatureChoice(
      sourceType: sourceType ?? this.sourceType,
      sourceClass: sourceClass ?? this.sourceClass,
      sourceSubclass: sourceSubclass ?? this.sourceSubclass,
      sourceName: sourceName ?? this.sourceName,
      featureName: featureName ?? this.featureName,
      choiceId: choiceId ?? this.choiceId,
      values: values ?? this.values,
    );
  }

  factory CharacterFeatureChoice.fromJson(Map<String, dynamic> json) {
    return CharacterFeatureChoice(
      sourceType: json['sourceType'] as String? ?? '',
      sourceClass: json['sourceClass'] as String? ?? '',
      sourceSubclass: json['sourceSubclass'] as String?,
      sourceName: json['sourceName'] as String?,
      featureName: json['featureName'] as String? ?? '',
      choiceId: json['choiceId'] as String? ?? '',
      values: (json['values'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'sourceType': sourceType,
        if (sourceClass.isNotEmpty) 'sourceClass': sourceClass,
        if (sourceSubclass != null) 'sourceSubclass': sourceSubclass,
        if (sourceName != null) 'sourceName': sourceName,
        'featureName': featureName,
        'choiceId': choiceId,
        'values': values,
      };
}
