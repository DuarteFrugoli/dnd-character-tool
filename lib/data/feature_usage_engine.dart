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

/// Uses regained when the character rolls Initiative.
class FeatureUsageInitiativeRule {
  const FeatureUsageInitiativeRule({
    required this.minimumRemaining,
    this.minClassLevel,
  });

  /// Uses are raised to at least this value.
  final int minimumRemaining;
  final int? minClassLevel;

  factory FeatureUsageInitiativeRule.fromJson(Map<String, dynamic> json) =>
      FeatureUsageInitiativeRule(
        minimumRemaining: (json['minimumRemaining'] as num?)?.toInt() ?? 1,
        minClassLevel: (json['minClassLevel'] as num?)?.toInt(),
      );
}

/// What happens when one use of a resource is spent.
class FeatureUsageSpendEffect {
  const FeatureUsageSpendEffect({this.restoreResource, this.heal});

  /// Resource refilled to its maximum.
  final String? restoreResource;

  /// Healing formula id, evaluated by the ruleset.
  final String? heal;

  factory FeatureUsageSpendEffect.fromJson(Map<String, dynamic> json) =>
      FeatureUsageSpendEffect(
        restoreResource: json['restoreResource'] as String?,
        heal: json['heal'] as String?,
      );
}

class FeatureUsageResource {
  const FeatureUsageResource({
    required this.id,
    required this.name,
    required this.maxFormula,
    required this.recharge,
    this.maxByLevel = const {},
    this.onInitiative,
    this.onSpend,
  });

  final String id;
  final String name;
  final String maxFormula;
  final String recharge;
  final Map<int, int> maxByLevel;
  final FeatureUsageInitiativeRule? onInitiative;
  final FeatureUsageSpendEffect? onSpend;

  /// The same resource tracked separately for one feat instance.
  FeatureUsageResource scopedTo(String instanceKey) => FeatureUsageResource(
    id: '$id:$instanceKey',
    name: name,
    maxFormula: maxFormula,
    recharge: recharge,
    maxByLevel: maxByLevel,
    onInitiative: onInitiative,
    onSpend: onSpend,
  );

  factory FeatureUsageResource.fromJson(String id, Map<String, dynamic> json) {
    return FeatureUsageResource(
      id: id,
      name: json['name'] as String? ?? id,
      maxFormula: json['max']?.toString() ?? '1',
      recharge: json['recharge'] as String? ?? 'long_rest',
      maxByLevel: _parseMaxByLevel(json['maxByLevel']),
      onInitiative: json['onInitiative'] is Map
          ? FeatureUsageInitiativeRule.fromJson(
              (json['onInitiative'] as Map).cast<String, dynamic>(),
            )
          : null,
      onSpend: json['onSpend'] is Map
          ? FeatureUsageSpendEffect.fromJson(
              (json['onSpend'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }

  static Map<int, int> _parseMaxByLevel(dynamic value) {
    if (value is! Map) return const {};
    final result = <int, int>{};
    for (final entry in value.entries) {
      final level = int.tryParse(entry.key.toString());
      if (level != null && entry.value is num) {
        result[level] = (entry.value as num).toInt();
      }
    }
    return result;
  }
}

class FeatureUsageRef {
  const FeatureUsageRef({
    required this.resourceId,
    this.spend = 1,
    this.minClassLevel,
    this.minCharacterLevel,
    this.additionalResources = const [],
    this.instanceKeyFromChoice,
  });

  final String resourceId;
  final int spend;
  final int? minClassLevel;
  final int? minCharacterLevel;
  final List<FeatureUsageRef> additionalResources;

  /// Repeatable feats keep one resource per value of this choice, e.g. one
  /// Magic Initiate free cast per spell list.
  final String? instanceKeyFromChoice;

  factory FeatureUsageRef.fromJson(Map<String, dynamic> json) {
    return FeatureUsageRef(
      resourceId: json['resourceId'] as String? ?? '',
      spend: (json['spend'] as num?)?.toInt() ?? 1,
      minClassLevel: (json['minClassLevel'] as num?)?.toInt(),
      minCharacterLevel: (json['minCharacterLevel'] as num?)?.toInt(),
      additionalResources: (json['additionalResources'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((entry) => FeatureUsageRef.fromJson(entry.cast<String, dynamic>()))
          .toList(),
      instanceKeyFromChoice: json['instanceKeyFromChoice'] as String?,
    );
  }

  Iterable<FeatureUsageRef> eligibleRefs(FeatureUsageContext context) sync* {
    if ((minClassLevel == null || context.effectiveClassLevel >= minClassLevel!) &&
        (minCharacterLevel == null || context.totalCharacterLevel >= minCharacterLevel!)) {
      yield this;
    }
    for (final ref in additionalResources) {
      yield* ref.eligibleRefs(context);
    }
  }
}

class FeatureUsageCatalog {
  const FeatureUsageCatalog({
    required this.resources,
    required this.classFeatures,
    required this.subclassFeatures,
    required this.raceTraits,
    required this.feats,
    this.choiceOptions = const {},
  });

  final Map<String, FeatureUsageResource> resources;

  /// Resources granted by a selected option, by class, feature and option id.
  final Map<String, Map<String, Map<String, FeatureUsageRef>>> choiceOptions;
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
      choiceOptions: _parseDefinitionMap3(json['choiceOptions']),
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
    final resolvedContext =
        usageContext ?? FeatureUsageContext.forCharacter(character);
    final eligibleRef = ref?.eligibleRefs(resolvedContext).firstOrNull;
    if (eligibleRef == null || eligibleRef.resourceId.isEmpty) return null;
    final resource = catalog.resource(eligibleRef.resourceId);
    if (resource == null) return null;
    final max = maxFor(resource, character, usageContext: resolvedContext);
    final current = currentFor(character, resource, max);
    return FeatureUsageView(
      resource: resource,
      current: current,
      max: max,
      spend: eligibleRef.spend < 1 ? 1 : eligibleRef.spend,
      recharge: rechargeFor(resource, character, usageContext: resolvedContext),
    );
  }

  static List<FeatureUsageView> viewsForRef({
    required FeatureUsageCatalog catalog,
    required Character character,
    required FeatureUsageRef? ref,
    FeatureUsageContext? usageContext,
  }) {
    final context = usageContext ?? FeatureUsageContext.forCharacter(character);
    if (ref == null) return const [];
    return [
      for (final eligibleRef in ref.eligibleRefs(context))
        ?viewForRef(
          catalog: catalog,
          character: character,
          ref: eligibleRef,
          usageContext: context,
        ),
    ];
  }

  /// Value of the feat choice that separates instances of a repeatable feat.
  static String? featInstanceKey(
    Character character,
    FeatureUsageRef ref,
    CharacterExtraFeature feat,
  ) {
    final choiceId = ref.instanceKeyFromChoice;
    if (choiceId == null) return null;
    for (final choice in character.featureChoices) {
      if (choice.sourceType == FeatureChoiceSourceType.feat &&
          choice.sourceName == feat.name &&
          choice.sourceClassEntryId == feat.sourceClassEntryId &&
          choice.choiceId == choiceId &&
          choice.values.isNotEmpty) {
        return choice.values.first;
      }
    }
    return null;
  }

  /// Usage views of one feat instance.
  static List<FeatureUsageView> viewsForFeat({
    required FeatureUsageCatalog catalog,
    required Character character,
    required CharacterExtraFeature feat,
  }) {
    final ref = catalog.feat(feat.name);
    if (ref == null) return const [];
    final instanceKey = featInstanceKey(character, ref, feat);
    return [
      for (final view in viewsForRef(
        catalog: catalog,
        character: character,
        ref: ref,
      ))
        instanceKey == null
            ? view
            : FeatureUsageView(
                resource: view.resource.scopedTo(instanceKey),
                current: currentFor(
                  character,
                  view.resource.scopedTo(instanceKey),
                  view.max,
                ),
                max: view.max,
                spend: view.spend,
                recharge: view.recharge,
              ),
    ];
  }

  /// Values of class feature choices, without `@target` suffixes.
  static Iterable<String> _selectedOptionIds(
    Character character,
    String className,
    String? classEntryId,
    String featureName,
  ) sync* {
    for (final choice in character.featureChoices) {
      if (choice.sourceType != FeatureChoiceSourceType.classFeature ||
          choice.featureName != featureName ||
          choice.sourceClass != className ||
          (classEntryId != null &&
              choice.sourceClassEntryId != null &&
              choice.sourceClassEntryId != classEntryId)) {
        continue;
      }
      for (final value in choice.values) {
        yield value.split('@').first;
      }
    }
  }

  /// Usage views of resources granted by selected options of a class feature,
  /// such as Gift of the Depths for Eldritch Invocations.
  static List<FeatureUsageView> viewsForChoiceOptions({
    required FeatureUsageCatalog catalog,
    required Character character,
    required String className,
    required String featureName,
    String? classEntryId,
    FeatureUsageContext? usageContext,
  }) {
    final options = catalog.choiceOptions[className]?[featureName];
    if (options == null) return const [];
    return [
      for (final optionId in _selectedOptionIds(
        character,
        className,
        classEntryId,
        featureName,
      ).toSet())
        ...viewsForRef(
          catalog: catalog,
          character: character,
          ref: options[optionId],
          usageContext: usageContext,
        ),
    ];
  }

  /// Feature resources after rolling Initiative: uses with an initiative rule
  /// are raised to their minimum, within the maximum.
  static Map<String, int> resourcesAfterInitiative(
    Character character,
    Iterable<FeatureUsageBinding> bindings,
  ) {
    final result = Map<String, int>.from(character.featureResources);
    for (final binding in bindings) {
      final rule = binding.resource.onInitiative;
      if (rule == null) continue;
      final minLevel = rule.minClassLevel;
      if (minLevel != null && binding.usageContext.effectiveClassLevel < minLevel) {
        continue;
      }
      final max = maxFor(
        binding.resource,
        character,
        usageContext: binding.usageContext,
      );
      if (max == null) continue;
      final current = currentFor(character, binding.resource, max) ?? max;
      final target = rule.minimumRemaining < max ? rule.minimumRemaining : max;
      if (current < target) result[binding.resource.id] = target;
    }
    return result;
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
    final context = usageContext ?? FeatureUsageContext.forCharacter(character);
    if (resource.maxByLevel.isNotEmpty) {
      final level = context.effectiveClassLevel;
      final eligible = resource.maxByLevel.keys.where((key) => key <= level);
      if (eligible.isNotEmpty) {
        final threshold = eligible.reduce((a, b) => a > b ? a : b);
        return resource.maxByLevel[threshold];
      }
    }
    final formula = resource.maxFormula.trim();
    final staticValue = int.tryParse(formula);
    if (staticValue != null) return _atLeast(0, staticValue);

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
      case 'proficiency_bonus':
        return character.proficiencyBonus;
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
      case 'short_rest_one':
        return true;
      case 'long_rest':
        return rest == FeatureUsageRest.longRest;
      default:
        return false;
    }
  }

  static int restoredCurrent({
    required String recharge,
    required FeatureUsageRest rest,
    required int current,
    required int max,
  }) {
    if (recharge == 'short_rest_one' && rest == FeatureUsageRest.shortRest) {
      return (current + 1).clamp(0, max).toInt();
    }
    return restoresOn(recharge, rest) ? max : current.clamp(0, max).toInt();
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

    Iterable<FeatureUsageBinding> add(
      FeatureUsageRef? ref,
      FeatureUsageContext usageContext, {
      String? instanceKey,
    }) sync* {
      if (ref == null) return;
      for (final eligibleRef in ref.eligibleRefs(usageContext)) {
        if (eligibleRef.resourceId.isEmpty) continue;
        final base = catalog.resource(eligibleRef.resourceId);
        if (base == null) continue;
        final resource = instanceKey == null ? base : base.scopedTo(instanceKey);
        if (!seen.add(resource.id)) continue;
        yield FeatureUsageBinding(
          resource: resource,
          ref: eligibleRef,
          usageContext: usageContext,
        );
      }
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
        yield* add(
          catalog.classFeature(classEntry.className, feature.name),
          classContext,
        );
      }

      final optionRefs = catalog.choiceOptions[classEntry.className];
      if (optionRefs != null) {
        for (final entry in optionRefs.entries) {
          for (final optionId in _selectedOptionIds(
            character,
            classEntry.className,
            classEntry.id,
            entry.key,
          ).toSet()) {
            yield* add(entry.value[optionId], classContext);
          }
        }
      }

      final subclassName = classEntry.subclassName ?? '';
      if (subclassName.isEmpty) continue;
      final subclassContext = FeatureUsageContext.forCharacter(
        character,
        sourceClass: classEntry.className,
        sourceClassLevel: classEntry.level,
      );
      for (final feature in set.subclassFeatures) {
        yield* add(
          catalog.subclassFeature(
            classEntry.className,
            subclassName,
            feature.name,
          ),
          subclassContext,
        );
      }
    }

    final characterContext = FeatureUsageContext.forCharacter(character);
    for (final trait in raceTraits) {
      yield* add(catalog.raceTrait(trait), characterContext);
    }

    for (final feature in character.extraFeatures) {
      final sourceType = feature.effectiveSourceType;
      final sourceFeature = feature.sourceFeature ?? feature.name;

      if (sourceType == FeatureChoiceSourceType.feat ||
          feature.sourceClass == 'Feat') {
        final ref = catalog.feat(feature.name);
        final instanceKey = ref == null
            ? null
            : featInstanceKey(character, ref, feature);
        yield* add(ref, characterContext, instanceKey: instanceKey);
        continue;
      }

      if (sourceType == FeatureChoiceSourceType.classFeature) {
        final sourceClass = _extraFeatureSourceClass(character, feature);
        final classRef = catalog.classFeature(sourceClass, sourceFeature);
        if (classRef != null) {
          yield* add(
            classRef,
            FeatureUsageContext.forCharacter(
              character,
              sourceClass: sourceClass,
              sourceClassLevel: _extraFeatureSourceLevel(character, feature),
            ),
          );
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
          yield* add(
            subclassRef,
            FeatureUsageContext.forCharacter(
              character,
              sourceClass: sourceClass,
              sourceClassLevel: _extraFeatureSourceLevel(character, feature),
            ),
          );
          continue;
        }
      }

      final sourceClass = _extraFeatureSourceClass(character, feature);
      final classRef = catalog.classFeature(sourceClass, feature.name);
      if (classRef != null) {
        yield* add(
          classRef,
          FeatureUsageContext.forCharacter(
            character,
            sourceClass: sourceClass,
            sourceClassLevel: _extraFeatureSourceLevel(character, feature),
          ),
        );
        continue;
      }

      final subclassRef = catalog.subclassFeature(
        sourceClass,
        _extraFeatureSourceSubclass(character, feature),
        feature.name,
      );
      if (subclassRef != null) {
        yield* add(
          subclassRef,
          FeatureUsageContext.forCharacter(
            character,
            sourceClass: sourceClass,
            sourceClassLevel: _extraFeatureSourceLevel(character, feature),
          ),
        );
        continue;
      }

      yield* add(catalog.raceTrait(feature.name), characterContext);
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
