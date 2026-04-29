/// Modelos de leitura dos assets SRD. São somente-leitura, sem necessidade de
/// serialização reversa, portanto usam fromJson manual sem build_runner.

class SrdSkill {
  final String name;
  final String ability;

  const SrdSkill({required this.name, required this.ability});

  factory SrdSkill.fromJson(Map<String, dynamic> json) => SrdSkill(
        name: json['name'] as String,
        ability: json['ability'] as String,
      );
}

class SrdSubrace {
  final String name;
  final Map<String, int> abilityScoreIncreases;
  final List<String> traits;
  final int? speed;
  final String? damageType;

  const SrdSubrace({
    required this.name,
    required this.abilityScoreIncreases,
    required this.traits,
    this.speed,
    this.damageType,
  });

  factory SrdSubrace.fromJson(Map<String, dynamic> json) => SrdSubrace(
        name: json['name'] as String,
        abilityScoreIncreases:
            (json['abilityScoreIncreases'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v as int)),
        traits: List<String>.from(json['traits'] ?? []),
        speed: json['speed'] as int?,
        damageType: json['damageType'] as String?,
      );
}

class SrdRace {
  final String name;
  final int speed;
  final String size;
  final Map<String, int> abilityScoreIncreases;
  final List<String> traits;
  final List<String> languages;
  final List<SrdSubrace> subraces;

  const SrdRace({
    required this.name,
    required this.speed,
    required this.size,
    required this.abilityScoreIncreases,
    required this.traits,
    required this.languages,
    required this.subraces,
  });

  factory SrdRace.fromJson(Map<String, dynamic> json) => SrdRace(
        name: json['name'] as String,
        speed: json['speed'] as int,
        size: json['size'] as String,
        abilityScoreIncreases:
            (json['abilityScoreIncreases'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v as int)),
        traits: List<String>.from(json['traits'] ?? []),
        languages: List<String>.from(json['languages'] ?? []),
        subraces: (json['subraces'] as List<dynamic>? ?? [])
            .map((e) => SrdSubrace.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SrdSkillChoice {
  final int count;
  final List<String> from;

  const SrdSkillChoice({required this.count, required this.from});

  factory SrdSkillChoice.fromJson(Map<String, dynamic> json) => SrdSkillChoice(
        count: json['count'] as int,
        from: List<String>.from(json['from']),
      );
}

class SrdClass {
  final String name;
  final int hitDie;
  final List<String> primaryAbility;
  final List<String> savingThrows;
  final List<String> armorProficiencies;
  final List<String> weaponProficiencies;
  final List<String> toolProficiencies;
  final SrdSkillChoice skillChoices;
  final String? spellcastingAbility;
  final String? spellcastingType;
  final int subclassLevel;
  final String subclassFeatureName;
  final String startingGoldDice;

  const SrdClass({
    required this.name,
    required this.hitDie,
    required this.primaryAbility,
    required this.savingThrows,
    required this.armorProficiencies,
    required this.weaponProficiencies,
    required this.toolProficiencies,
    required this.skillChoices,
    this.spellcastingAbility,
    this.spellcastingType,
    required this.subclassLevel,
    required this.subclassFeatureName,
    required this.startingGoldDice,
  });

  bool get isSpellcaster => spellcastingAbility != null;

  factory SrdClass.fromJson(Map<String, dynamic> json) => SrdClass(
        name: json['name'] as String,
        hitDie: json['hitDie'] as int,
        primaryAbility: List<String>.from(json['primaryAbility']),
        savingThrows: List<String>.from(json['savingThrows']),
        armorProficiencies: List<String>.from(json['armorProficiencies']),
        weaponProficiencies: List<String>.from(json['weaponProficiencies']),
        toolProficiencies: List<String>.from(json['toolProficiencies']),
        skillChoices:
            SrdSkillChoice.fromJson(json['skillChoices'] as Map<String, dynamic>),
        spellcastingAbility: json['spellcastingAbility'] as String?,
        spellcastingType: json['spellcastingType'] as String?,
        subclassLevel: json['subclassLevel'] as int,
        subclassFeatureName: json['subclassFeatureName'] as String,
        startingGoldDice: json['startingGoldDice'] as String,
      );
}

class SrdBackgroundFeature {
  final String name;
  final String description;

  const SrdBackgroundFeature({required this.name, required this.description});

  factory SrdBackgroundFeature.fromJson(Map<String, dynamic> json) =>
      SrdBackgroundFeature(
        name: json['name'] as String,
        description: json['description'] as String,
      );
}

class SrdBackground {
  final String name;
  final List<String> skillProficiencies;
  final List<String> toolProficiencies;
  final int languages;
  final List<String> startingEquipment;
  final SrdBackgroundFeature feature;
  final List<String> variants;

  const SrdBackground({
    required this.name,
    required this.skillProficiencies,
    required this.toolProficiencies,
    required this.languages,
    required this.startingEquipment,
    required this.feature,
    required this.variants,
  });

  factory SrdBackground.fromJson(Map<String, dynamic> json) => SrdBackground(
        name: json['name'] as String,
        skillProficiencies: List<String>.from(json['skillProficiencies']),
        toolProficiencies: List<String>.from(json['toolProficiencies']),
        languages: json['languages'] as int,
        startingEquipment: List<String>.from(json['startingEquipment']),
        feature: SrdBackgroundFeature.fromJson(
            json['feature'] as Map<String, dynamic>),
        variants: List<String>.from(json['variants'] ?? []),
      );
}

class SrdSpell {
  final String name;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final List<String> components;
  final String duration;
  final bool concentration;
  final List<String> classes;
  final String description;

  const SrdSpell({
    required this.name,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.components,
    required this.duration,
    required this.concentration,
    required this.classes,
    required this.description,
  });

  bool get isCantrip => level == 0;

  factory SrdSpell.fromJson(Map<String, dynamic> json) => SrdSpell(
        name: json['name'] as String,
        level: json['level'] as int,
        school: json['school'] as String,
        castingTime: json['castingTime'] as String,
        range: json['range'] as String,
        components: List<String>.from(json['components']),
        duration: json['duration'] as String,
        concentration: json['concentration'] as bool,
        classes: List<String>.from(json['classes']),
        description: json['description'] as String,
      );
}

class SrdWeaponRange {
  final int normal;
  final int long;

  const SrdWeaponRange({required this.normal, required this.long});

  factory SrdWeaponRange.fromJson(Map<String, dynamic> json) => SrdWeaponRange(
        normal: json['normal'] as int,
        long: json['long'] as int,
      );
}

class SrdWeapon {
  final String name;
  final String category;
  final String damage;
  final String damageType;
  final double weight;
  final String cost;
  final List<String> properties;
  final String? versatileDamage;
  final SrdWeaponRange? range;

  const SrdWeapon({
    required this.name,
    required this.category,
    required this.damage,
    required this.damageType,
    required this.weight,
    required this.cost,
    required this.properties,
    this.versatileDamage,
    this.range,
  });

  factory SrdWeapon.fromJson(Map<String, dynamic> json) => SrdWeapon(
        name: json['name'] as String,
        category: json['category'] as String,
        damage: json['damage'] as String,
        damageType: json['damageType'] as String,
        weight: (json['weight'] as num).toDouble(),
        cost: json['cost'] as String,
        properties: List<String>.from(json['properties']),
        versatileDamage: json['versatileDamage'] as String?,
        range: json['range'] != null
            ? SrdWeaponRange.fromJson(json['range'] as Map<String, dynamic>)
            : null,
      );
}

class SrdArmor {
  final String name;
  final String type;
  final int? baseAC;
  final int? acBonus;
  final bool addDexModifier;
  final int? maxDexBonus;
  final bool stealthDisadvantage;
  final int? strengthRequired;
  final double weight;
  final String cost;

  const SrdArmor({
    required this.name,
    required this.type,
    this.baseAC,
    this.acBonus,
    required this.addDexModifier,
    this.maxDexBonus,
    required this.stealthDisadvantage,
    this.strengthRequired,
    required this.weight,
    required this.cost,
  });

  bool get isShield => type == 'shield';

  factory SrdArmor.fromJson(Map<String, dynamic> json) => SrdArmor(
        name: json['name'] as String,
        type: json['type'] as String,
        baseAC: json['baseAC'] as int?,
        acBonus: json['acBonus'] as int?,
        addDexModifier: json['addDexModifier'] as bool? ?? false,
        maxDexBonus: json['maxDexBonus'] as int?,
        stealthDisadvantage: json['stealthDisadvantage'] as bool? ?? false,
        strengthRequired: json['strengthRequired'] as int?,
        weight: (json['weight'] as num).toDouble(),
        cost: json['cost'] as String,
      );
}
