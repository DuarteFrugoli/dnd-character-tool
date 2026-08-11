import 'datasources/srd/srd_models.dart';
import 'feature_choice_engine.dart';
import 'models/models.dart';

enum FeatureUsageRest { shortRest, longRest }

class FeatureUsageContext {
  const FeatureUsageContext({
    required this.totalCharacterLevel,
    this.sourceClass,
    this.sourceClassLevel,
  });

  final int totalCharacterLevel;
  final String? sourceClass;
  final int? sourceClassLevel;

  factory FeatureUsageContext.forCharacter(
    Character character, {
    String? sourceClass,
    int? sourceClassLevel,
  }) {
    final totalLevel = character.totalLevel;
    final resolvedSourceClassLevel =
        sourceClassLevel ??
        (sourceClass == null ? null : character.classLevel(sourceClass));
    return FeatureUsageContext(
      totalCharacterLevel: totalLevel,
      sourceClass: sourceClass,
      sourceClassLevel: resolvedSourceClassLevel,
    );
  }

  int get effectiveClassLevel => sourceClassLevel ?? totalCharacterLevel;
}

class FeatureUsageResource {
  const FeatureUsageResource({
    required this.id,
    required this.name,
    required this.maxFormula,
    required this.recharge,
  });

  final String id;
  final String name;
  final String maxFormula;
  final String recharge;

  factory FeatureUsageResource.fromJson(String id, Map<String, dynamic> json) {
    return FeatureUsageResource(
      id: id,
      name: json['name'] as String? ?? id,
      maxFormula: json['max']?.toString() ?? '1',
      recharge: json['recharge'] as String? ?? 'long_rest',
    );
  }
}

class FeatureUsageRef {
  const FeatureUsageRef({required this.resourceId, this.spend = 1});

  final String resourceId;
  final int spend;

  factory FeatureUsageRef.fromJson(Map<String, dynamic> json) {
    return FeatureUsageRef(
      resourceId: json['resourceId'] as String? ?? '',
      spend: (json['spend'] as num?)?.toInt() ?? 1,
    );
  }
}

class FeatureUsageCatalog {
  const FeatureUsageCatalog({
    required this.resources,
    required this.classFeatures,
    required this.subclassFeatures,
    required this.raceTraits,
    required this.feats,
  });

  final Map<String, FeatureUsageResource> resources;
  final Map<String, Map<String, FeatureUsageRef>> classFeatures;
  final Map<String, Map<String, Map<String, FeatureUsageRef>>> subclassFeatures;
  final Map<String, FeatureUsageRef> raceTraits;
  final Map<String, FeatureUsageRef> feats;

  factory FeatureUsageCatalog.fromJson(Map<String, dynamic> json) {
    return FeatureUsageCatalog(
      resources: _parseResources(json['resources']),
      classFeatures: _parseDefinitionMap2(json['classFeatures']),
      subclassFeatures: _parseDefinitionMap3(json['subclassFeatures']),
      raceTraits: _parseDefinitionMap1(json['raceTraits']),
      feats: _parseDefinitionMap1(json['feats']),
    );
  }

  FeatureUsageResource? resource(String id) => resources[id];

  FeatureUsageRef? classFeature(String className, String featureName) {
    return classFeatures[className]?[featureName];
  }

  FeatureUsageRef? subclassFeature(
    String className,
    String subclassName,
    String featureName,
  ) {
    return subclassFeatures[className]?[subclassName]?[featureName];
  }

  FeatureUsageRef? raceTrait(String traitName) => raceTraits[traitName];

  FeatureUsageRef? feat(String featName) => feats[featName];

  static Map<String, FeatureUsageResource> _parseResources(dynamic value) {
    final result = <String, FeatureUsageResource>{};
    if (value is! Map) return result;
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final raw = entry.value;
      if (raw is Map) {
        result[key] = FeatureUsageResource.fromJson(
          key,
          raw.cast<String, dynamic>(),
        );
      }
    }
    return result;
  }

  static Map<String, FeatureUsageRef> _parseDefinitionMap1(dynamic value) {
    final result = <String, FeatureUsageRef>{};
    if (value is! Map) return result;
    for (final entry in value.entries) {
      final raw = entry.value;
      if (raw is Map) {
        result[entry.key.toString()] = FeatureUsageRef.fromJson(
          raw.cast<String, dynamic>(),
        );
      }
    }
    return result;
  }

  static Map<String, Map<String, FeatureUsageRef>> _parseDefinitionMap2(
    dynamic value,
  ) {
    final result = <String, Map<String, FeatureUsageRef>>{};
    if (value is! Map) return result;
    for (final entry in value.entries) {
      result[entry.key.toString()] = _parseDefinitionMap1(entry.value);
    }
    return result;
  }

  static Map<String, Map<String, Map<String, FeatureUsageRef>>>
  _parseDefinitionMap3(dynamic value) {
    final result = <String, Map<String, Map<String, FeatureUsageRef>>>{};
    if (value is! Map) return result;
    for (final entry in value.entries) {
      final nested = <String, Map<String, FeatureUsageRef>>{};
      final rawSubclasses = entry.value;
      if (rawSubclasses is Map) {
        for (final subEntry in rawSubclasses.entries) {
          nested[subEntry.key.toString()] = _parseDefinitionMap1(
            subEntry.value,
          );
        }
      }
      result[entry.key.toString()] = nested;
    }
    return result;
  }
}

class FeatureUsageView {
  const FeatureUsageView({
    required this.resource,
    required this.current,
    required this.max,
    required this.spend,
    required this.recharge,
  });

  final FeatureUsageResource resource;
  final int? current;
  final int? max;
  final int spend;
  final String recharge;

  bool get isUnlimited => max == null;
  bool get canSpend => max != null && current != null && current! >= spend;
  bool get canRecover => max != null && current != null && current! < max!;
}

class FeatureUsageBinding {
  const FeatureUsageBinding({
    required this.resource,
    required this.ref,
    required this.usageContext,
  });

  final FeatureUsageResource resource;
  final FeatureUsageRef ref;
  final FeatureUsageContext usageContext;
}

class FeatureUsageFeatureSet {
  const FeatureUsageFeatureSet({
    required this.classEntry,
    required this.classFeatures,
    required this.subclassFeatures,
  });

  final CharacterClassEntry classEntry;
  final Iterable<SrdClassFeature> classFeatures;
  final Iterable<SrdClassFeature> subclassFeatures;
}

class FeatureUsageEngine {
  const FeatureUsageEngine._();

  static FeatureUsageView? viewForRef({
    required FeatureUsageCatalog catalog,
    required Character character,
    required FeatureUsageRef? ref,
    FeatureUsageContext? usageContext,
  }) {
    if (ref == null || ref.resourceId.isEmpty) return null;
    final resource = catalog.resource(ref.resourceId);
    if (resource == null) return null;
    final resolvedContext =
        usageContext ?? FeatureUsageContext.forCharacter(character);
    final max = maxFor(resource, character, usageContext: resolvedContext);
    final current = currentFor(character, resource, max);
    return FeatureUsageView(
      resource: resource,
      current: current,
      max: max,
      spend: ref.spend < 1 ? 1 : ref.spend,
      recharge: rechargeFor(resource, character, usageContext: resolvedContext),
    );
  }

  static int? currentFor(
    Character character,
    FeatureUsageResource resource,
    int? max,
  ) {
    if (max == null) return null;
    final saved = character.featureResources[resource.id];
    return (saved ?? max).clamp(0, max).toInt();
  }

  static int? maxFor(
    FeatureUsageResource resource,
    Character character, {
    FeatureUsageContext? usageContext,
  }) {
    final formula = resource.maxFormula.trim();
    final staticValue = int.tryParse(formula);
    if (staticValue != null) return _atLeast(0, staticValue);

    final context = usageContext ?? FeatureUsageContext.forCharacter(character);
    final level = context.effectiveClassLevel;
    final scores = character.abilityScores;
    switch (formula) {
      case 'barbarian_rage_uses':
        if (level >= 20) return null;
        if (level >= 17) return 6;
        if (level >= 12) return 5;
        if (level >= 6) return 4;
        if (level >= 3) return 3;
        return 2;
      case 'cleric_channel_divinity_uses':
        if (level >= 18) return 3;
        if (level >= 6) return 2;
        return 1;
      case 'druid_wild_shape_uses':
        return level >= 20 ? null : 2;
      case 'fighter_action_surge_uses':
        return level >= 17 ? 2 : 1;
      case 'fighter_indomitable_uses':
        if (level >= 17) return 3;
        if (level >= 13) return 2;
        return 1;
      case 'battle_master_superiority_dice':
        if (level >= 15) return 6;
        if (level >= 7) return 5;
        return 4;
      case 'warlock_mystic_arcanum_uses':
        if (level >= 17) return 4;
        if (level >= 15) return 3;
        if (level >= 13) return 2;
        return 1;
      case 'wizard_portent_dice':
        return level >= 14 ? 3 : 2;
      case 'monk_level':
      case 'sorcerer_level':
        return level;
      case 'paladin_level_x5':
        return level * 5;
      case 'charisma_modifier_min_1':
        return _atLeast(1, scores.charismaModifier);
      case 'wisdom_modifier_min_1':
        return _atLeast(1, scores.wisdomModifier);
      case '1_plus_charisma_modifier_min_1':
        return _atLeast(1, 1 + scores.charismaModifier);
      default:
        return 1;
    }
  }

  static int _atLeast(int minimum, int value) {
    return value < minimum ? minimum : value;
  }

  static String rechargeFor(
    FeatureUsageResource resource,
    Character character, {
    FeatureUsageContext? usageContext,
  }) {
    if (resource.recharge == 'bardic_inspiration_recharge') {
      final context =
          usageContext ?? FeatureUsageContext.forCharacter(character);
      return context.effectiveClassLevel >= 5 ? 'short_rest' : 'long_rest';
    }
    return resource.recharge;
  }

  static bool restoresOn(String recharge, FeatureUsageRest rest) {
    switch (recharge) {
      case 'short_rest':
      case 'short_or_long_rest':
        return true;
      case 'long_rest':
        return rest == FeatureUsageRest.longRest;
      default:
        return false;
    }
  }

  static Iterable<FeatureUsageResource> activeResources({
    required Character character,
    required FeatureUsageCatalog catalog,
    Iterable<SrdClassFeature> classFeatures = const [],
    Iterable<SrdClassFeature> subclassFeatures = const [],
    Iterable<FeatureUsageFeatureSet> classFeatureSets = const [],
    Iterable<String> raceTraits = const [],
  }) sync* {
    for (final binding in activeResourceBindings(
      character: character,
      catalog: catalog,
      classFeatures: classFeatures,
      subclassFeatures: subclassFeatures,
      classFeatureSets: classFeatureSets,
      raceTraits: raceTraits,
    )) {
      yield binding.resource;
    }
  }

  static Iterable<FeatureUsageBinding> activeResourceBindings({
    required Character character,
    required FeatureUsageCatalog catalog,
    Iterable<SrdClassFeature> classFeatures = const [],
    Iterable<SrdClassFeature> subclassFeatures = const [],
    Iterable<FeatureUsageFeatureSet> classFeatureSets = const [],
    Iterable<String> raceTraits = const [],
  }) sync* {
    final seen = <String>{};

    FeatureUsageBinding? add(
      FeatureUsageRef? ref,
      FeatureUsageContext usageContext,
    ) {
      if (ref == null ||
          ref.resourceId.isEmpty ||
          seen.contains(ref.resourceId)) {
        return null;
      }
      final resource = catalog.resource(ref.resourceId);
      if (resource == null) return null;
      seen.add(resource.id);
      return FeatureUsageBinding(
        resource: resource,
        ref: ref,
        usageContext: usageContext,
      );
    }

    final effectiveClassFeatureSets = classFeatureSets.isNotEmpty
        ? classFeatureSets
        : [
            FeatureUsageFeatureSet(
              classEntry: character.primaryClass,
              classFeatures: classFeatures,
              subclassFeatures: subclassFeatures,
            ),
          ];

    for (final set in effectiveClassFeatureSets) {
      final classEntry = set.classEntry;
      final classContext = FeatureUsageContext.forCharacter(
        character,
        sourceClass: classEntry.className,
        sourceClassLevel: classEntry.level,
      );
      for (final feature in set.classFeatures) {
        final binding = add(
          catalog.classFeature(classEntry.className, feature.name),
          classContext,
        );
        if (binding != null) yield binding;
      }

      final subclassName = classEntry.subclassName ?? '';
      if (subclassName.isEmpty) continue;
      final subclassContext = FeatureUsageContext.forCharacter(
        character,
        sourceClass: classEntry.className,
        sourceClassLevel: classEntry.level,
      );
      for (final feature in set.subclassFeatures) {
        final binding = add(
          catalog.subclassFeature(
            classEntry.className,
            subclassName,
            feature.name,
          ),
          subclassContext,
        );
        if (binding != null) yield binding;
      }
    }

    final characterContext = FeatureUsageContext.forCharacter(character);
    for (final trait in raceTraits) {
      final binding = add(catalog.raceTrait(trait), characterContext);
      if (binding != null) yield binding;
    }

    for (final feature in character.extraFeatures) {
      final sourceType = feature.effectiveSourceType;
      final sourceFeature = feature.sourceFeature ?? feature.name;

      if (sourceType == FeatureChoiceSourceType.feat ||
          feature.sourceClass == 'Feat') {
        final binding = add(catalog.feat(feature.name), characterContext);
        if (binding != null) yield binding;
        continue;
      }

      if (sourceType == FeatureChoiceSourceType.classFeature) {
        final sourceClass = _extraFeatureSourceClass(character, feature);
        final classRef = catalog.classFeature(
          sourceClass,
          sourceFeature,
        );
        if (classRef != null) {
          final binding = add(
            classRef,
            FeatureUsageContext.forCharacter(
              character,
              sourceClass: sourceClass,
              sourceClassLevel: _extraFeatureSourceLevel(character, feature),
            ),
          );
          if (binding != null) yield binding;
          continue;
        }
      }

      if (sourceType == FeatureChoiceSourceType.subclassFeature) {
        final subclassName = _extraFeatureSourceSubclass(character, feature);
        final sourceClass = _extraFeatureSourceClass(character, feature);
        final subclassRef = catalog.subclassFeature(
          sourceClass,
          subclassName,
          sourceFeature,
        );
        if (subclassRef != null) {
          final binding = add(
            subclassRef,
            FeatureUsageContext.forCharacter(
              character,
              sourceClass: sourceClass,
              sourceClassLevel: _extraFeatureSourceLevel(character, feature),
            ),
          );
          if (binding != null) yield binding;
          continue;
        }
      }

      final sourceClass = _extraFeatureSourceClass(character, feature);
      final classRef = catalog.classFeature(sourceClass, feature.name);
      if (classRef != null) {
        final binding = add(
          classRef,
          FeatureUsageContext.forCharacter(
            character,
            sourceClass: sourceClass,
            sourceClassLevel: _extraFeatureSourceLevel(character, feature),
          ),
        );
        if (binding != null) yield binding;
        continue;
      }

      final subclassRef = catalog.subclassFeature(
        sourceClass,
        _extraFeatureSourceSubclass(character, feature),
        feature.name,
      );
      if (subclassRef != null) {
        final binding = add(
          subclassRef,
          FeatureUsageContext.forCharacter(
            character,
            sourceClass: sourceClass,
            sourceClassLevel: _extraFeatureSourceLevel(character, feature),
          ),
        );
        if (binding != null) yield binding;
        continue;
      }

      final binding = add(catalog.raceTrait(feature.name), characterContext);
      if (binding != null) yield binding;
    }
  }

  static int _extraFeatureSourceLevel(
    Character character,
    CharacterExtraFeature feature,
  ) {
    final sourceClassEntryId = feature.sourceClassEntryId;
    if (sourceClassEntryId != null) {
      for (final entry in character.classEntries) {
        if (entry.id == sourceClassEntryId) return entry.level;
      }
    }
    final classLevel = character.classLevel(
      _extraFeatureSourceClass(character, feature),
    );
    if (classLevel > 0) return classLevel;
    return feature.level;
  }

  static String _extraFeatureSourceClass(
    Character character,
    CharacterExtraFeature feature,
  ) {
    final sourceClassEntryId = feature.sourceClassEntryId;
    if (sourceClassEntryId != null) {
      for (final entry in character.classEntries) {
        if (entry.id == sourceClassEntryId) return entry.className;
      }
    }
    final subclassName = _extraFeatureSourceSubclass(character, feature);
    if (feature.effectiveSourceType ==
            FeatureChoiceSourceType.subclassFeature &&
        (feature.sourceClass.isEmpty || feature.sourceClass == subclassName)) {
      return character.primaryClassName;
    }
    if (feature.sourceClass.isEmpty) return character.primaryClassName;
    return feature.sourceClass;
  }

  static String _extraFeatureSourceSubclass(
    Character character,
    CharacterExtraFeature feature,
  ) {
    final sourceClassEntryId = feature.sourceClassEntryId;
    if (sourceClassEntryId != null) {
      for (final entry in character.classEntries) {
        if (entry.id == sourceClassEntryId) {
          return feature.sourceSubclass ?? entry.subclassName ?? '';
        }
      }
    }
    return feature.sourceSubclass ?? feature.sourceClass;
  }
}
