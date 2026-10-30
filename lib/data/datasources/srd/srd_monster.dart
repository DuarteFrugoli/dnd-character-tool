/// Stat blocks of `monsters.json`. The catalog holds the Beasts Wild Shape can
/// use for now; the schema already carries what a tabletop needs (defenses,
/// senses, structured attacks, saves and recharges), see docs/ARCHITECTURE.md.
library;

import '../../json_helpers.dart';

class SrdMonster {
  const SrdMonster({
    required this.id,
    required this.name,
    required this.sizes,
    required this.type,
    this.tags = const [],
    this.swarmMemberSize,
    required this.alignment,
    required this.armorClass,
    this.armorSource,
    this.initiativeModifier,
    required this.hitPoints,
    required this.hitPointsFormula,
    required this.speed,
    required this.abilities,
    this.savingThrows = const {},
    this.skills = const {},
    this.damageVulnerabilities = const [],
    this.damageResistances = const [],
    this.damageImmunities = const [],
    this.conditionImmunities = const [],
    this.senses = const {},
    this.passivePerception = 10,
    this.languages = const [],
    required this.challengeRating,
    required this.experience,
    required this.proficiencyBonus,
    this.traits = const [],
    this.actions = const [],
    this.bonusActions = const [],
    this.reactions = const [],
    this.legendaryActions = const [],
  });

  final String id;
  final String name;

  /// Lowercase sizes; more than one when the stat block offers a choice.
  final List<String> sizes;
  final String type;
  final List<String> tags;

  /// Size of each creature of a swarm, e.g. `tiny`.
  final String? swarmMemberSize;
  final String alignment;
  final int armorClass;
  final String? armorSource;

  /// 2024 stat blocks print an initiative modifier.
  final int? initiativeModifier;
  final int hitPoints;
  final String hitPointsFormula;
  final SrdMonsterSpeed speed;

  /// Scores by lowercase ability name, e.g. `strength`.
  final Map<String, int> abilities;
  final Map<String, int> savingThrows;

  /// Bonuses by lowercase skill name, e.g. `perception`.
  final Map<String, int> skills;
  final List<String> damageVulnerabilities;
  final List<String> damageResistances;
  final List<String> damageImmunities;
  final List<String> conditionImmunities;

  /// Ranges in feet by sense, e.g. `darkvision`.
  final Map<String, int> senses;
  final int passivePerception;
  final List<String> languages;

  /// As printed: `0`, `1/8`, `1/4`, `1/2`, `1`, …
  final String challengeRating;
  final int experience;
  final int proficiencyBonus;
  final List<SrdMonsterEntry> traits;
  final List<SrdMonsterEntry> actions;
  final List<SrdMonsterEntry> bonusActions;
  final List<SrdMonsterEntry> reactions;
  final List<SrdMonsterEntry> legendaryActions;

  bool get isBeast => type == 'beast';
  bool get isSwarm => swarmMemberSize != null;

  double get challengeValue => challengeRatingValue(challengeRating);

  int score(String ability) => abilities[ability] ?? 10;

  int modifier(String ability) => ((score(ability) - 10) / 2).floor();

  int savingThrow(String ability) =>
      savingThrows[ability] ?? modifier(ability);

  List<SrdMonsterEntry> get attacks => [
    for (final entry in [...actions, ...bonusActions])
      if (entry.attack != null) entry,
  ];

  static double challengeRatingValue(String rating) {
    final parts = rating.split('/');
    final numerator = double.tryParse(parts.first) ?? 0;
    final denominator = parts.length > 1 ? double.tryParse(parts[1]) ?? 1 : 1;
    return numerator / denominator;
  }

  factory SrdMonster.fromJson(Map<String, dynamic> json) {
    final senses = _intMap(json['senses']);
    return SrdMonster(
      id: json['id'] as String,
      name: json['name'] as String,
      sizes: _strings(json['size']),
      type: json['type'] as String? ?? '',
      tags: _strings(json['tags']),
      swarmMemberSize: (json['swarm'] as Map?)?['memberSize'] as String?,
      alignment: json['alignment'] as String? ?? '',
      armorClass: ((json['armorClass'] as Map?)?['value'] as num?)?.toInt() ?? 10,
      armorSource: (json['armorClass'] as Map?)?['source'] as String?,
      initiativeModifier:
          ((json['initiative'] as Map?)?['modifier'] as num?)?.toInt(),
      hitPoints: ((json['hitPoints'] as Map?)?['average'] as num?)?.toInt() ?? 1,
      hitPointsFormula: (json['hitPoints'] as Map?)?['formula'] as String? ?? '',
      speed: SrdMonsterSpeed.fromJson(
        (json['speed'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      abilities: _intMap(json['abilities']),
      savingThrows: _intMap(json['savingThrows']),
      skills: _intMap(json['skills']),
      damageVulnerabilities: _strings(json['damageVulnerabilities']),
      damageResistances: _strings(json['damageResistances']),
      damageImmunities: _strings(json['damageImmunities']),
      conditionImmunities: _strings(json['conditionImmunities']),
      senses: {...senses}..remove('passivePerception'),
      passivePerception: senses['passivePerception'] ?? 10,
      languages: _strings(json['languages']),
      challengeRating: json['challengeRating'] as String? ?? '0',
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      proficiencyBonus: (json['proficiencyBonus'] as num?)?.toInt() ?? 2,
      traits: _entries(json['traits']),
      actions: _entries(json['actions']),
      bonusActions: _entries(json['bonusActions']),
      reactions: _entries(json['reactions']),
      legendaryActions: _entries(json['legendaryActions']),
    );
  }
}

/// Speeds in feet by mode (`walk`, `burrow`, `climb`, `fly`, `swim`).
class SrdMonsterSpeed {
  const SrdMonsterSpeed({
    this.modes = const {},
    this.hover = false,
    this.oneOf = const [],
  });

  final Map<String, int> modes;
  final bool hover;

  /// Modes of which the GM picks one, e.g. Climb or Fly of a swarm.
  final List<String> oneOf;

  int get walk => modes['walk'] ?? 0;
  int? get fly => modes['fly'];
  int? get swim => modes['swim'];
  int? get climb => modes['climb'];
  int? get burrow => modes['burrow'];

  factory SrdMonsterSpeed.fromJson(Map<String, dynamic> json) =>
      SrdMonsterSpeed(
        modes: {
          for (final entry in json.entries)
            if (entry.value is num) entry.key: (entry.value as num).toInt(),
        },
        hover: readBool(json['hover']),
        oneOf: _strings(json['oneOf']),
      );
}

/// A trait or action. [attack], [damage] and [save] are structured copies of
/// numbers in [description] so a tabletop can roll them.
class SrdMonsterEntry {
  const SrdMonsterEntry({
    required this.id,
    required this.name,
    required this.description,
    this.usage,
    this.attack,
    this.damage = const [],
    this.save,
  });

  final String id;
  final String name;
  final String description;
  final SrdMonsterUsage? usage;
  final SrdMonsterAttack? attack;
  final List<SrdMonsterDamage> damage;
  final SrdMonsterSave? save;

  factory SrdMonsterEntry.fromJson(Map<String, dynamic> json) =>
      SrdMonsterEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        usage: json['usage'] is Map
            ? SrdMonsterUsage.fromJson((json['usage'] as Map).cast())
            : null,
        attack: json['attack'] is Map
            ? SrdMonsterAttack.fromJson((json['attack'] as Map).cast())
            : null,
        damage: _damage(json['damage']),
        save: json['save'] is Map
            ? SrdMonsterSave.fromJson((json['save'] as Map).cast())
            : null,
      );
}

class SrdMonsterAttack {
  const SrdMonsterAttack({
    required this.kind,
    required this.bonus,
    this.reach,
    this.rangeNormal,
    this.rangeLong,
  });

  /// `melee`, `ranged` or `melee_or_ranged`.
  final String kind;
  final int bonus;
  final int? reach;
  final int? rangeNormal;
  final int? rangeLong;

  factory SrdMonsterAttack.fromJson(Map<String, dynamic> json) {
    final range = json['range'] as Map?;
    return SrdMonsterAttack(
      kind: json['kind'] as String? ?? 'melee',
      bonus: (json['bonus'] as num?)?.toInt() ?? 0,
      reach: (json['reach'] as num?)?.toInt(),
      rangeNormal: (range?['normal'] as num?)?.toInt(),
      rangeLong: (range?['long'] as num?)?.toInt(),
    );
  }
}

class SrdMonsterDamage {
  const SrdMonsterDamage({
    required this.average,
    required this.formula,
    required this.type,
  });

  final int average;

  /// Dice expression such as `1d6+3`; a flat number for fixed damage.
  final String formula;
  final String type;

  factory SrdMonsterDamage.fromJson(Map<String, dynamic> json) =>
      SrdMonsterDamage(
        average: (json['average'] as num?)?.toInt() ?? 0,
        formula: json['formula'] as String? ?? '0',
        type: json['type'] as String? ?? '',
      );
}

class SrdMonsterSave {
  const SrdMonsterSave({
    required this.ability,
    required this.dc,
    this.damage = const [],
    this.halfOnSuccess = false,
  });

  final String ability;
  final int dc;

  /// Damage on a failed save.
  final List<SrdMonsterDamage> damage;
  final bool halfOnSuccess;

  factory SrdMonsterSave.fromJson(Map<String, dynamic> json) => SrdMonsterSave(
    ability: json['ability'] as String? ?? '',
    dc: (json['dc'] as num?)?.toInt() ?? 10,
    damage: _damage(json['damage']),
    halfOnSuccess: readBool(json['halfOnSuccess']),
  );
}

/// `recharge` (on a d6 of [rechargeMin]+), `per_day` ([uses]) or `per_rest`.
class SrdMonsterUsage {
  const SrdMonsterUsage({required this.type, this.rechargeMin, this.uses});

  final String type;
  final int? rechargeMin;
  final int? uses;

  factory SrdMonsterUsage.fromJson(Map<String, dynamic> json) =>
      SrdMonsterUsage(
        type: json['type'] as String? ?? '',
        rechargeMin: (json['min'] as num?)?.toInt(),
        uses: (json['uses'] as num?)?.toInt(),
      );
}

List<String> _strings(dynamic value) =>
    [for (final item in value as List? ?? const []) if (item is String) item];

Map<String, int> _intMap(dynamic value) => {
  for (final entry in (value as Map? ?? const {}).entries)
    if (entry.value is num) entry.key as String: (entry.value as num).toInt(),
};

List<SrdMonsterEntry> _entries(dynamic value) => [
  for (final item in value as List? ?? const [])
    if (item is Map) SrdMonsterEntry.fromJson(item.cast<String, dynamic>()),
];

List<SrdMonsterDamage> _damage(dynamic value) => [
  for (final item in value as List? ?? const [])
    if (item is Map) SrdMonsterDamage.fromJson(item.cast<String, dynamic>()),
];
