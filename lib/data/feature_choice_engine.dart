import 'datasources/srd/srd_models.dart';
import 'models/models.dart';

class FeatureChoiceSourceType {
  static const classFeature = 'classFeature';
  static const subclassFeature = 'subclassFeature';
  static const raceTrait = 'raceTrait';
  static const feat = 'feat';
  static const multiclassProficiency = 'multiclassProficiency';
}

class FeatureChoiceRequest {
  final String sourceType;
  final String sourceClass;
  final String? sourceClassEntryId;
  final String? sourceSubclass;
  final String? sourceName;
  final String featureName;
  final int level;
  final SrdFeatureChoiceRequirement requirement;
  final int requiredCount;

  const FeatureChoiceRequest({
    required this.sourceType,
    this.sourceClass = '',
    this.sourceClassEntryId,
    this.sourceSubclass,
    this.sourceName,
    required this.featureName,
    required this.level,
    required this.requirement,
    required this.requiredCount,
  });

  String get choiceId => requirement.id;

  String get key =>
      '$sourceType|$sourceClass|${sourceClassEntryId ?? ''}|'
      '${sourceSubclass ?? ''}|${sourceName ?? ''}|'
      '$featureName|$choiceId';

  CharacterFeatureChoice emptyChoice() => CharacterFeatureChoice(
    sourceType: sourceType,
    sourceClass: sourceClass,
    sourceClassEntryId: sourceClassEntryId,
    sourceSubclass: sourceSubclass,
    sourceName: sourceName,
    featureName: featureName,
    choiceId: choiceId,
  );

  CharacterFeatureChoice? findIn(List<CharacterFeatureChoice> choices) {
    for (final choice in choices) {
      if (choice.matches(
        sourceType: sourceType,
        sourceClass: sourceClass,
        sourceClassEntryId: sourceClassEntryId,
        sourceSubclass: sourceSubclass,
        sourceName: sourceName,
        featureName: featureName,
        choiceId: choiceId,
      )) {
        return choice;
      }
    }
    return null;
  }

  bool isComplete(List<CharacterFeatureChoice> choices) {
    return _uniqueValues(findIn(choices)?.values ?? const []).length >=
        requiredCount;
  }

  CharacterFeatureChoice toChoice(List<String> values) {
    return emptyChoice().copyWith(
      values: _uniqueValues(values).take(requiredCount).toList(),
    );
  }

  static List<String> _uniqueValues(List<String> values) {
    final seen = <String>{};
    return [
      for (final value in values)
        if (seen.add(value)) value,
    ];
  }
}

class FeatureChoiceEngine {
  static List<FeatureChoiceRequest> requestsForLevelUp({
    required SrdFeatureChoiceCatalog catalog,
    required Character character,
    required int newLevel,
    required List<SrdClassFeature> newClassFeatures,
    required List<SrdClassFeature> newSubclassFeatures,
    String? targetClassEntryId,
    String? targetClassName,
    String? subclassName,
    SrdFeat? featChosen,
  }) {
    final requests = <FeatureChoiceRequest>[];
    final seen = <String>{};
    final className = targetClassName ?? character.primaryClass.className;

    void addAll(Iterable<FeatureChoiceRequest> items) {
      for (final item in items) {
        if (seen.add(item.key)) requests.add(item);
      }
    }

    for (final feature in newClassFeatures) {
      addAll(
        requestsForClassFeature(
          catalog: catalog,
          className: className,
          sourceClassEntryId: targetClassEntryId,
          featureName: feature.name,
          level: newLevel,
        ),
      );
    }
    addAll(
      _levelTriggeredClassRequests(
        catalog: catalog,
        className: className,
        sourceClassEntryId: targetClassEntryId,
        level: newLevel,
      ),
    );

    final effectiveSubclass = subclassName ?? character.subclassFor(className);
    if (effectiveSubclass != null) {
      for (final feature in newSubclassFeatures) {
        addAll(
          requestsForSubclassFeature(
            catalog: catalog,
            className: className,
            sourceClassEntryId: targetClassEntryId,
            subclassName: effectiveSubclass,
            featureName: feature.name,
            level: newLevel,
          ),
        );
      }

      addAll(
        _levelTriggeredSubclassRequests(
          catalog: catalog,
          className: className,
          sourceClassEntryId: targetClassEntryId,
          subclassName: effectiveSubclass,
          level: newLevel,
        ),
      );
    }

    if (featChosen != null) {
      addAll(
        requestsForFeat(
          catalog: catalog,
          featName: featChosen.name,
          level: newLevel,
        ),
      );
    }

    return requests;
  }

  static List<FeatureChoiceRequest> requestsForClassFeature({
    required SrdFeatureChoiceCatalog catalog,
    required String className,
    String? sourceClassEntryId,
    required String featureName,
    required int level,
  }) {
    final definition = catalog.classFeature(className, featureName);
    if (definition == null) return const [];
    return _requestsForDefinition(
      definition: definition,
      sourceType: FeatureChoiceSourceType.classFeature,
      sourceClass: className,
      sourceClassEntryId: sourceClassEntryId,
      featureName: featureName,
      level: level,
    );
  }

  static List<FeatureChoiceRequest> requestsForSubclassFeature({
    required SrdFeatureChoiceCatalog catalog,
    required String className,
    String? sourceClassEntryId,
    required String subclassName,
    required String featureName,
    required int level,
  }) {
    final definition = catalog.subclassFeature(
      className,
      subclassName,
      featureName,
    );
    if (definition == null) return const [];
    return _requestsForDefinition(
      definition: definition,
      sourceType: FeatureChoiceSourceType.subclassFeature,
      sourceClass: className,
      sourceClassEntryId: sourceClassEntryId,
      sourceSubclass: subclassName,
      featureName: featureName,
      level: level,
    );
  }

  static List<FeatureChoiceRequest> requestsForFeat({
    required SrdFeatureChoiceCatalog catalog,
    required String featName,
    required int level,
  }) {
    final definition = catalog.feat(featName);
    if (definition == null) return const [];
    return _requestsForDefinition(
      definition: definition,
      sourceType: FeatureChoiceSourceType.feat,
      sourceName: featName,
      featureName: featName,
      level: level,
    );
  }

  static List<FeatureChoiceRequest> requestsForRaceTrait({
    required SrdFeatureChoiceCatalog catalog,
    required String traitName,
    required int level,
  }) {
    final definition = catalog.raceTrait(traitName);
    if (definition == null) return const [];
    return _requestsForDefinition(
      definition: definition,
      sourceType: FeatureChoiceSourceType.raceTrait,
      sourceName: traitName,
      featureName: traitName,
      level: level,
    );
  }

  static List<FeatureChoiceRequest> _requestsForDefinition({
    required SrdFeatureChoiceDefinition definition,
    required String sourceType,
    String sourceClass = '',
    String? sourceClassEntryId,
    String? sourceSubclass,
    String? sourceName,
    required String featureName,
    required int level,
  }) {
    return definition.choices
        .where((choice) => choice.isActiveAtLevel(level))
        .map(
          (choice) => FeatureChoiceRequest(
            sourceType: sourceType,
            sourceClass: sourceClass,
            sourceClassEntryId: sourceClassEntryId,
            sourceSubclass: sourceSubclass,
            sourceName: sourceName,
            featureName: featureName,
            level: level,
            requirement: choice,
            requiredCount: choice.requiredCountAtLevel(level),
          ),
        )
        .where((request) => request.requiredCount > 0)
        .toList();
  }

  static List<FeatureChoiceRequest> _levelTriggeredSubclassRequests({
    required SrdFeatureChoiceCatalog catalog,
    required String className,
    String? sourceClassEntryId,
    required String subclassName,
    required int level,
  }) {
    final subMap = catalog.subclassFeatures[className]?[subclassName];
    if (subMap == null) return const [];
    final requests = <FeatureChoiceRequest>[];
    for (final entry in subMap.entries) {
      for (final choice in entry.value.choices) {
        if (!choice.countByLevel.containsKey(level)) continue;
        requests.add(
          FeatureChoiceRequest(
            sourceType: FeatureChoiceSourceType.subclassFeature,
            sourceClass: className,
            sourceClassEntryId: sourceClassEntryId,
            sourceSubclass: subclassName,
            featureName: entry.key,
            level: level,
            requirement: choice,
            requiredCount: choice.requiredCountAtLevel(level),
          ),
        );
      }
    }
    return requests;
  }

  static List<FeatureChoiceRequest> _levelTriggeredClassRequests({
    required SrdFeatureChoiceCatalog catalog,
    required String className,
    String? sourceClassEntryId,
    required int level,
  }) {
    final classMap = catalog.classFeatures[className];
    if (classMap == null) return const [];
    final requests = <FeatureChoiceRequest>[];
    for (final entry in classMap.entries) {
      for (final choice in entry.value.choices) {
        if (!choice.countByLevel.containsKey(level)) continue;
        requests.add(
          FeatureChoiceRequest(
            sourceType: FeatureChoiceSourceType.classFeature,
            sourceClass: className,
            sourceClassEntryId: sourceClassEntryId,
            featureName: entry.key,
            level: level,
            requirement: choice,
            requiredCount: choice.requiredCountAtLevel(level),
          ),
        );
      }
    }
    return requests;
  }

  static bool allComplete(
    List<FeatureChoiceRequest> requests,
    List<CharacterFeatureChoice> choices,
  ) {
    return requests.every((request) => request.isComplete(choices));
  }

  static List<CharacterFeatureChoice> upsertChoices(
    List<CharacterFeatureChoice> current,
    Iterable<CharacterFeatureChoice> updates,
  ) {
    var result = List<CharacterFeatureChoice>.from(current);
    for (final update in updates) {
      final index = result.indexWhere(
        (choice) => choice.matches(
          sourceType: update.sourceType,
          sourceClass: update.sourceClass,
          sourceClassEntryId: update.sourceClassEntryId,
          sourceSubclass: update.sourceSubclass,
          sourceName: update.sourceName,
          featureName: update.featureName,
          choiceId: update.choiceId,
        ),
      );
      if (index >= 0) {
        result[index] = update;
      } else {
        result.add(update);
      }
    }
    return result;
  }

  static List<FeatureChoiceRequest> pendingRequests(
    List<FeatureChoiceRequest> requests,
    List<CharacterFeatureChoice> choices,
  ) {
    return requests.where((request) => !request.isComplete(choices)).toList();
  }
}
