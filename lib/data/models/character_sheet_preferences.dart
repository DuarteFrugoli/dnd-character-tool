import '../json_helpers.dart';

const kDefaultSkillAbilityOrder = [
  'Strength',
  'Dexterity',
  'Constitution',
  'Intelligence',
  'Wisdom',
  'Charisma',
];

enum SkillDisplayMode { byAbility, proficiencyFirst, alphabetical }

enum InventoryDisplayMode { sections, singleListByType }

class InventorySectionId {
  static const ammunition = 'ammunition';
  static const equipped = 'equipped';
  static const containers = 'containers';
  static const equippable = 'equippable';
  static const carried = 'carried';

  static const defaults = [
    ammunition,
    equipped,
    equippable,
    containers,
    carried,
  ];
}

class CharacterSheetPreferences {
  const CharacterSheetPreferences({
    this.skills = const SkillDisplayPreferences(),
    this.inventory = const InventoryDisplayPreferences(),
    this.spells = const SpellDisplayPreferences(),
  });

  final SkillDisplayPreferences skills;
  final InventoryDisplayPreferences inventory;
  final SpellDisplayPreferences spells;

  CharacterSheetPreferences copyWith({
    SkillDisplayPreferences? skills,
    InventoryDisplayPreferences? inventory,
    SpellDisplayPreferences? spells,
  }) {
    return CharacterSheetPreferences(
      skills: skills ?? this.skills,
      inventory: inventory ?? this.inventory,
      spells: spells ?? this.spells,
    );
  }

  factory CharacterSheetPreferences.fromJson(Object? json) {
    if (json is! Map) return const CharacterSheetPreferences();
    final map = json.cast<String, dynamic>();
    return CharacterSheetPreferences(
      skills: SkillDisplayPreferences.fromJson(map['skills']),
      inventory: InventoryDisplayPreferences.fromJson(map['inventory']),
      spells: SpellDisplayPreferences.fromJson(map['spells']),
    );
  }

  Map<String, dynamic> toJson() => {
    'skills': skills.toJson(),
    'inventory': inventory.toJson(),
    'spells': spells.toJson(),
  };
}

class SkillDisplayPreferences {
  const SkillDisplayPreferences({
    this.mode = SkillDisplayMode.byAbility,
    this.abilityOrder = defaultAbilityOrder,
    this.proficientFirstInsideGroups = false,
  });

  static const defaultAbilityOrder = kDefaultSkillAbilityOrder;

  final SkillDisplayMode mode;
  final List<String> abilityOrder;
  final bool proficientFirstInsideGroups;

  SkillDisplayPreferences copyWith({
    SkillDisplayMode? mode,
    List<String>? abilityOrder,
    bool? proficientFirstInsideGroups,
  }) {
    return SkillDisplayPreferences(
      mode: mode ?? this.mode,
      abilityOrder: abilityOrder ?? this.abilityOrder,
      proficientFirstInsideGroups:
          proficientFirstInsideGroups ?? this.proficientFirstInsideGroups,
    );
  }

  factory SkillDisplayPreferences.fromJson(Object? json) {
    if (json is! Map) return const SkillDisplayPreferences();
    final map = json.cast<String, dynamic>();
    return SkillDisplayPreferences(
      mode: _enumByName(
        SkillDisplayMode.values,
        map['mode'],
        SkillDisplayMode.byAbility,
      ),
      abilityOrder: _normalizedOrder(
        map['abilityOrder'],
        defaultAbilityOrder,
      ),
      proficientFirstInsideGroups: readBool(
        map['proficientFirstInsideGroups'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'abilityOrder': abilityOrder,
    'proficientFirstInsideGroups': proficientFirstInsideGroups,
  };
}

class InventoryDisplayPreferences {
  const InventoryDisplayPreferences({
    this.mode = InventoryDisplayMode.sections,
    this.sectionOrder = InventorySectionId.defaults,
    this.zeroQuantityLast = false,
    this.equippedFirst = false,
  });

  final InventoryDisplayMode mode;
  final List<String> sectionOrder;
  final bool zeroQuantityLast;
  final bool equippedFirst;

  InventoryDisplayPreferences copyWith({
    InventoryDisplayMode? mode,
    List<String>? sectionOrder,
    bool? zeroQuantityLast,
    bool? equippedFirst,
  }) {
    return InventoryDisplayPreferences(
      mode: mode ?? this.mode,
      sectionOrder: sectionOrder ?? this.sectionOrder,
      zeroQuantityLast: zeroQuantityLast ?? this.zeroQuantityLast,
      equippedFirst: equippedFirst ?? this.equippedFirst,
    );
  }

  factory InventoryDisplayPreferences.fromJson(Object? json) {
    if (json is! Map) {
      return const InventoryDisplayPreferences();
    }
    final map = json.cast<String, dynamic>();
    return InventoryDisplayPreferences(
      mode: _enumByName(
        InventoryDisplayMode.values,
        map['mode'],
        InventoryDisplayMode.sections,
      ),
      sectionOrder: _normalizedOrder(
        map['sectionOrder'],
        InventorySectionId.defaults,
      ),
      zeroQuantityLast: readBool(map['zeroQuantityLast']),
      equippedFirst: readBool(map['equippedFirst']),
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'sectionOrder': sectionOrder,
    'zeroQuantityLast': zeroQuantityLast,
    'equippedFirst': equippedFirst,
  };
}

class SpellDisplayPreferences {
  const SpellDisplayPreferences({this.showLevelShortcuts = true});

  final bool showLevelShortcuts;

  SpellDisplayPreferences copyWith({bool? showLevelShortcuts}) {
    return SpellDisplayPreferences(
      showLevelShortcuts: showLevelShortcuts ?? this.showLevelShortcuts,
    );
  }

  factory SpellDisplayPreferences.fromJson(Object? json) {
    if (json is! Map) return const SpellDisplayPreferences();
    final map = json.cast<String, dynamic>();
    return SpellDisplayPreferences(
      showLevelShortcuts: readBool(
        map['showLevelShortcuts'],
        defaultValue: true,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'showLevelShortcuts': showLevelShortcuts,
  };
}

T _enumByName<T extends Enum>(List<T> values, Object? value, T fallback) {
  final name = value?.toString();
  if (name == null || name.isEmpty) return fallback;
  for (final option in values) {
    if (option.name == name) return option;
  }
  return fallback;
}

List<String> _normalizedOrder(Object? value, List<String> defaults) {
  final parsed = value is List
      ? value.whereType<String>().where((id) => id.trim().isNotEmpty).toList()
      : const <String>[];
  final allowed = defaults.toSet();
  final seen = <String>{};
  final result = <String>[];
  for (final id in parsed) {
    if (!allowed.contains(id) || !seen.add(id)) continue;
    result.add(id);
  }
  for (final id in defaults) {
    if (seen.add(id)) result.add(id);
  }
  return result;
}
