import 'datasources/srd/srd_models.dart';
import 'models/models.dart';

enum FeatureUsageRest { shortRest, longRest }

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

  factory FeatureUsageResource.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return FeatureUsageResource(
      id: id,
      name: json['name'] as String? ?? id,
      maxFormula: json['max']?.toString() ?? '1',
      recharge: json['recharge'] as String? ?? 'long_rest',
    );
  }
}

class FeatureUsageRef {
  const FeatureUsageRef({
    required this.resourceId,
    this.spend = 1,
  });

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
  final Map<String, Map<String, Map<String, FeatureUsageRef>>>
      subclassFeatures;
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
        result[entry.key.toString()] =
            FeatureUsageRef.fromJson(raw.cast<String, dynamic>());
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
          nested[subEntry.key.toString()] =
              _parseDefinitionMap1(subEntry.value);
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

class FeatureUsageEngine {
  const FeatureUsageEngine._();

  static FeatureUsageView? viewForRef({
    required FeatureUsageCatalog catalog,
    required Character character,
    required FeatureUsageRef? ref,
  }) {
    if (ref == null || ref.resourceId.isEmpty) return null;
    final resource = catalog.resource(ref.resourceId);
    if (resource == null) return null;
    final max = maxFor(resource, character);
    final current = currentFor(character, resource, max);
    return FeatureUsageView(
      resource: resource,
      current: current,
      max: max,
      spend: ref.spend < 1 ? 1 : ref.spend,
      recharge: rechargeFor(resource, character),
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

  static int? maxFor(FeatureUsageResource resource, Character character) {
    final formula = resource.maxFormula.trim();
    final staticValue = int.tryParse(formula);
    if (staticValue != null) return _atLeast(0, staticValue);

    final level = character.level;
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
    Character character,
  ) {
    if (resource.recharge == 'bardic_inspiration_recharge') {
      return character.level >= 5 ? 'short_rest' : 'long_rest';
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
    required Iterable<SrdClassFeature> classFeatures,
    required Iterable<SrdClassFeature> subclassFeatures,
    required Iterable<String> raceTraits,
  }) sync* {
    final seen = <String>{};

    FeatureUsageResource? add(FeatureUsageRef? ref) {
      if (ref == null ||
          ref.resourceId.isEmpty ||
          seen.contains(ref.resourceId)) {
        return null;
      }
      final resource = catalog.resource(ref.resourceId);
      if (resource == null) return null;
      seen.add(resource.id);
      return resource;
    }

    for (final feature in classFeatures) {
      final resource = add(
        catalog.classFeature(character.characterClass, feature.name),
      );
      if (resource != null) yield resource;
    }

    final subclassName = character.subclass ?? '';
    for (final feature in subclassFeatures) {
      final resource = add(
        catalog.subclassFeature(
          character.characterClass,
          subclassName,
          feature.name,
        ),
      );
      if (resource != null) yield resource;
    }

    for (final trait in raceTraits) {
      final resource = add(catalog.raceTrait(trait));
      if (resource != null) yield resource;
    }

    for (final feature in character.extraFeatures) {
      FeatureUsageRef? ref;
      if (feature.sourceClass == 'Feat') {
        ref = catalog.feat(feature.name);
      } else {
        ref = catalog.classFeature(feature.sourceClass, feature.name) ??
            catalog.subclassFeature(
              character.characterClass,
              feature.sourceClass,
              feature.name,
            ) ??
            catalog.raceTrait(feature.name);
      }
      final resource = add(ref);
      if (resource != null) yield resource;
    }
  }
}
