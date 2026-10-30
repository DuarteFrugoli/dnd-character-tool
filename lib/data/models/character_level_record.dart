/// How the hit points of one level were determined.
class HitPointGainMethod {
  static const maximum = 'maximum';
  static const average = 'average';
  static const rolled = 'rolled';
}

/// One gained character level, kept so 2024 sheets can review, reset and
/// rebuild their progression without guessing where values came from.
///
/// Feature choices made at the level stay in [Character.featureChoices];
/// this record keeps what those choices cannot reconstruct.
class CharacterLevelRecord {
  const CharacterLevelRecord({
    required this.characterLevel,
    required this.classEntryId,
    required this.className,
    required this.classLevel,
    required this.hitPointsGained,
    this.hitPointMethod = HitPointGainMethod.average,
    this.subclassName,
    this.featName,
    this.featFeature,
    this.abilityIncreases = const {},
    this.baseAbilityScores = const {},
  });

  final int characterLevel;
  final String classEntryId;
  final String className;
  final int classLevel;

  /// Hit die result plus the Constitution modifier at that level.
  final int hitPointsGained;
  final String hitPointMethod;

  /// Subclass chosen at this level, if any.
  final String? subclassName;

  /// Feat gained from Ability Score Improvement or Epic Boon at this level.
  final String? featName;
  final String? featFeature;

  /// Ability increases from the feat of this level.
  final Map<String, int> abilityIncreases;

  /// Level 1 only: ability scores before background increases.
  final Map<String, int> baseAbilityScores;

  factory CharacterLevelRecord.fromJson(Map<String, dynamic> json) {
    Map<String, int> intMap(Object? value) => value is Map
        ? {
            for (final entry in value.entries)
              if (entry.value is num)
                entry.key.toString(): (entry.value as num).toInt(),
          }
        : const {};
    return CharacterLevelRecord(
      characterLevel: (json['characterLevel'] as num?)?.toInt() ?? 1,
      classEntryId: json['classEntryId'] as String? ?? 'primary',
      className: json['className'] as String? ?? '',
      classLevel: (json['classLevel'] as num?)?.toInt() ?? 1,
      hitPointsGained: (json['hitPointsGained'] as num?)?.toInt() ?? 0,
      hitPointMethod:
          json['hitPointMethod'] as String? ?? HitPointGainMethod.average,
      subclassName: json['subclassName'] as String?,
      featName: json['featName'] as String?,
      featFeature: json['featFeature'] as String?,
      abilityIncreases: intMap(json['abilityIncreases']),
      baseAbilityScores: intMap(json['baseAbilityScores']),
    );
  }

  Map<String, dynamic> toJson() => {
    'characterLevel': characterLevel,
    'classEntryId': classEntryId,
    'className': className,
    'classLevel': classLevel,
    'hitPointsGained': hitPointsGained,
    'hitPointMethod': hitPointMethod,
    if (subclassName != null) 'subclassName': subclassName,
    if (featName != null) 'featName': featName,
    if (featFeature != null) 'featFeature': featFeature,
    if (abilityIncreases.isNotEmpty) 'abilityIncreases': abilityIncreases,
    if (baseAbilityScores.isNotEmpty) 'baseAbilityScores': baseAbilityScores,
  };
}
