/// Modelos de leitura dos assets SRD. São somente-leitura, sem necessidade de
/// serialização reversa, portanto usam fromJson manual sem build_runner.
library;

import '../../models/equipment_item.dart';

/// Capitalizes the first letter of a string (e.g. "dexterity" → "Dexterity").
String _titleCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ── Item lookup data ─────────────────────────────────────────────────────────

/// Metadata for a single SRD item loaded from assets/data/srd/items.json.
class SrdItemData {
  final String itemType; // "weapon", "armor", "ammunition", "gear"
  final String category;
  final Map<String, dynamic>? properties;

  const SrdItemData({
    required this.itemType,
    required this.category,
    this.properties,
  });

  factory SrdItemData.fromJson(Map<String, dynamic> json) => SrdItemData(
        itemType: json['itemType'] as String,
        category: json['category'] as String,
        properties: json['properties'] as Map<String, dynamic>?,
      );

  /// Converts the string [itemType] from JSON to the [ItemType] enum.
  ItemType get asItemType {
    switch (itemType) {
      case 'weapon':
        return ItemType.weapon;
      case 'armor':
        return ItemType.armor;
      case 'ammunition':
        return ItemType.ammunition;
      case 'consumable':
        return ItemType.consumable;
      default:
        return ItemType.gear;
    }
  }
}

class SrdSubclass {
  final String name;
  final String description;

  const SrdSubclass({required this.name, required this.description});

  factory SrdSubclass.fromJson(Map<String, dynamic> json) => SrdSubclass(
        name: json['name'] as String,
        description: json['description'] as String,
      );
}

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
  final List<SrdInnateSpellDef> innateSpells;

  const SrdSubrace({
    required this.name,
    required this.abilityScoreIncreases,
    required this.traits,
    this.speed,
    this.damageType,
    this.innateSpells = const [],
  });

  factory SrdSubrace.fromJson(Map<String, dynamic> json) => SrdSubrace(
        name: json['name'] as String,
        abilityScoreIncreases:
            (json['abilityScoreIncreases'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(_titleCase(k), v as int)),
        traits: List<String>.from(json['traits'] ?? []),
        speed: json['speed'] as int?,
        damageType: json['damageType'] as String?,
        innateSpells: (json['innateSpells'] as List<dynamic>? ?? [])
            .map((e) => SrdInnateSpellDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// Atributos reais que podem receber bônus diretos.
const _realAttributes = {
  'strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma',
};

class SrdRace {
  final String name;
  final int speed;
  final String size;
  final Map<String, int> abilityScoreIncreases;
  /// Pontos de ASI livres (ex: Half-Elf "twoOthers": 1 = 2 pontos de +1 livres).
  final int freeAsiPoints;
  final List<String> traits;
  final List<String> languages;
  final List<SrdSubrace> subraces;
  final List<SrdInnateSpellDef> innateSpells;

  const SrdRace({
    required this.name,
    required this.speed,
    required this.size,
    required this.abilityScoreIncreases,
    this.freeAsiPoints = 0,
    required this.traits,
    required this.languages,
    required this.subraces,
    this.innateSpells = const [],
  });

  factory SrdRace.fromJson(Map<String, dynamic> json) {
    final raw = json['abilityScoreIncreases'] as Map<String, dynamic>? ?? {};
    final asi = <String, int>{};
    int freePoints = 0;
    raw.forEach((k, v) {
      final lower = k.toLowerCase();
      if (_realAttributes.contains(lower)) {
        asi[_titleCase(k)] = v as int;
      } else if (lower == 'twoothers') {
        // "twoOthers": 1 → 2 atributos ganham +1 à escolha do jogador
        freePoints += 2 * (v as int);
      } else if (lower == 'oneother') {
        freePoints += 1 * (v as int);
      }
    });
    return SrdRace(
      name: json['name'] as String,
      speed: json['speed'] as int,
      size: json['size'] as String,
      abilityScoreIncreases: asi,
      freeAsiPoints: freePoints,
      traits: List<String>.from(json['traits'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      subraces: (json['subraces'] as List<dynamic>? ?? [])
          .map((e) => SrdSubrace.fromJson(e as Map<String, dynamic>))
          .toList(),
      innateSpells: (json['innateSpells'] as List<dynamic>? ?? [])
          .map((e) => SrdInnateSpellDef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SrdSkillChoice {
  final int count;
  final List<String> from;

  const SrdSkillChoice({required this.count, required this.from});

  /// True when the class allows choosing from any skill (e.g. Bard).
  bool get isAny => from.isEmpty || from.contains('any');

  factory SrdSkillChoice.fromJson(Map<String, dynamic> json) => SrdSkillChoice(
        count: json['count'] as int,
        from: List<String>.from(json['from']),
      );
}

// ── Class starting equipment ─────────────────────────────────────────────────

/// One choice group: player picks exactly one option from the list.
/// Each option is a list of items (a "package").
/// Items that start with "any " (e.g. "any martial weapon") require a
/// further sub-selection in the UI.
class SrdEquipmentChoiceGroup {
  final List<List<String>> options;
  const SrdEquipmentChoiceGroup({required this.options});
  factory SrdEquipmentChoiceGroup.fromJson(Map<String, dynamic> json) =>
      SrdEquipmentChoiceGroup(
        options: (json['options'] as List<dynamic>)
            .map((opt) => List<String>.from(opt as List<dynamic>))
            .toList(),
      );
}

class SrdClassStartingEquipment {
  final List<String> fixed;
  final List<SrdEquipmentChoiceGroup> choices;
  const SrdClassStartingEquipment({required this.fixed, required this.choices});
  factory SrdClassStartingEquipment.fromJson(Map<String, dynamic> json) =>
      SrdClassStartingEquipment(
        fixed: List<String>.from(json['fixed'] as List<dynamic>? ?? []),
        choices: (json['choices'] as List<dynamic>? ?? [])
            .map((c) => SrdEquipmentChoiceGroup
                .fromJson(c as Map<String, dynamic>))
            .toList(),
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
  final SrdClassStartingEquipment? startingEquipment;
  final List<SrdSubclass> subclasses;

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
    this.startingEquipment,
    this.subclasses = const [],
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
        startingEquipment: json['startingEquipment'] != null
            ? SrdClassStartingEquipment.fromJson(
                json['startingEquipment'] as Map<String, dynamic>)
            : null,
        subclasses: (json['subclasses'] as List<dynamic>? ?? [])
            .map((e) => SrdSubclass.fromJson(e as Map<String, dynamic>))
            .toList(),
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

// ── Spell helper types ────────────────────────────────────────────────────────

class SpellAreaOfEffect {
  /// sphere | cone | cube | cylinder | line | wall | circle
  final String type;

  /// Size in feet (radius for sphere/cylinder, length for cone/line/wall, etc.)
  final int size;

  const SpellAreaOfEffect({required this.type, required this.size});

  factory SpellAreaOfEffect.fromJson(Map<String, dynamic> json) =>
      SpellAreaOfEffect(
        type: json['type'] as String,
        size: json['size'] as int,
      );
}

class SubclassSpellRef {
  final String className;
  final String subclass;

  const SubclassSpellRef({required this.className, required this.subclass});

  factory SubclassSpellRef.fromJson(Map<String, dynamic> json) =>
      SubclassSpellRef(
        className: json['class'] as String,
        subclass: json['subclass'] as String,
      );
}

class RaceSpellRef {
  final String race;
  final String? subrace;

  const RaceSpellRef({required this.race, this.subrace});

  factory RaceSpellRef.fromJson(Map<String, dynamic> json) => RaceSpellRef(
        race: json['race'] as String,
        subrace: json['subrace'] as String?,
      );
}

/// Racial innate spell definition as stored in races.json.
/// [usesPerDay] == null means the spell is at-will.
class SrdInnateSpellDef {
  final String name;
  final int? usesPerDay;

  const SrdInnateSpellDef({required this.name, this.usesPerDay});

  factory SrdInnateSpellDef.fromJson(Map<String, dynamic> json) =>
      SrdInnateSpellDef(
        name: json['name'] as String,
        usesPerDay: (json['usesPerDay'] as num?)?.toInt(),
      );
}

// ── SrdSpell ─────────────────────────────────────────────────────────────────

class SrdSpell {
  final String name;
  final int level;
  final String school;

  /// Human-readable casting time string (e.g. "1 action", "10 minutes").
  final String castingTime;

  /// Machine-readable casting time type for filtering/icons.
  /// Values: action | bonus_action | reaction | minute | hour | special
  final String castingTimeType;

  final bool ritual;
  final String range;
  final List<String> components;

  /// Material component description (null if no M component or no description).
  final String? material;

  /// Material cost in GP (null if no cost).
  final int? materialCost;

  /// Whether the material is consumed when the spell is cast.
  final bool materialConsumed;

  final String duration;
  final bool concentration;
  final SpellAreaOfEffect? areaOfEffect;

  /// null for save-based spells; "melee" or "ranged" for attack roll spells.
  final String? attackType;

  /// Saving throw attribute (STR/DEX/CON/INT/WIS/CHA), null if no save.
  final String? saveAttribute;

  final List<String> damageTypes;
  final String description;

  /// Text describing upcast behaviour; null if the spell doesn't scale.
  final String? higherLevels;

  final List<String> classes;

  /// Subclass expanded spell lists (e.g. Cleric domains, Paladin oaths).
  /// Currently empty — to be populated in a future pass.
  final List<SubclassSpellRef> subclassSpells;

  /// Racial spell grants (e.g. Tiefling, Drow).
  /// Currently empty — to be populated in a future pass.
  final List<RaceSpellRef> raceSpells;

  const SrdSpell({
    required this.name,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.castingTimeType,
    required this.ritual,
    required this.range,
    required this.components,
    this.material,
    this.materialCost,
    required this.materialConsumed,
    required this.duration,
    required this.concentration,
    this.areaOfEffect,
    this.attackType,
    this.saveAttribute,
    required this.damageTypes,
    required this.description,
    this.higherLevels,
    required this.classes,
    required this.subclassSpells,
    required this.raceSpells,
  });

  bool get isCantrip => level == 0;

  bool get requiresMaterial => components.contains('M') && material != null;

  factory SrdSpell.fromJson(Map<String, dynamic> json) => SrdSpell(
        name: json['name'] as String,
        level: json['level'] as int,
        school: json['school'] as String,
        castingTime: json['castingTime'] as String,
        castingTimeType: json['castingTimeType'] as String? ?? 'action',
        ritual: json['ritual'] as bool? ?? false,
        range: json['range'] as String,
        components: List<String>.from(json['components']),
        material: json['material'] as String?,
        materialCost: json['materialCost'] as int?,
        materialConsumed: json['materialConsumed'] as bool? ?? false,
        duration: json['duration'] as String,
        concentration: json['concentration'] as bool,
        areaOfEffect: json['areaOfEffect'] != null
            ? SpellAreaOfEffect.fromJson(
                json['areaOfEffect'] as Map<String, dynamic>)
            : null,
        attackType: json['attackType'] as String?,
        saveAttribute: json['saveAttribute'] as String?,
        damageTypes: List<String>.from(json['damageTypes'] ?? []),
        description: json['description'] as String,
        higherLevels: json['higherLevels'] as String?,
        classes: List<String>.from(json['classes']),
        subclassSpells: (json['subclassSpells'] as List<dynamic>? ?? [])
            .map((e) => SubclassSpellRef.fromJson(e as Map<String, dynamic>))
            .toList(),
        raceSpells: (json['raceSpells'] as List<dynamic>? ?? [])
            .map((e) => RaceSpellRef.fromJson(e as Map<String, dynamic>))
            .toList(),
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
        name: (json['name'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
        damage: (json['damage'] as String?) ?? '0',
        damageType: (json['damageType'] as String?) ?? '',
        weight: (json['weight'] as num? ?? 0).toDouble(),
        cost: (json['cost'] as String?) ?? '',
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
        name: (json['name'] as String?) ?? '',
        type: (json['type'] as String?) ?? '',
        baseAC: json['baseAC'] as int?,
        acBonus: json['acBonus'] as int?,
        addDexModifier: json['addDexModifier'] as bool? ?? false,
        maxDexBonus: json['maxDexBonus'] as int?,
        stealthDisadvantage: json['stealthDisadvantage'] as bool? ?? false,
        strengthRequired: json['strengthRequired'] as int?,
        weight: (json['weight'] as num? ?? 0).toDouble(),
        cost: (json['cost'] as String?) ?? '',
      );
}

class SrdGearItem {
  final String name;
  final String category;
  final double weight;
  final String cost;
  final String description;

  const SrdGearItem({
    required this.name,
    required this.category,
    required this.weight,
    required this.cost,
    required this.description,
  });

  factory SrdGearItem.fromJson(Map<String, dynamic> json) => SrdGearItem(
        name: (json['name'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
        weight: (json['weight'] as num? ?? 0).toDouble(),
        cost: (json['cost'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
      );
}

// ── Tools ─────────────────────────────────────────────────────────────────────

class SrdTool {
  final String name;
  final String category;

  const SrdTool({required this.name, required this.category});

  factory SrdTool.fromJson(Map<String, dynamic> json) => SrdTool(
        name: (json['name'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
      );
}

class SrdMagicItem {
  final String name;
  final String type;
  final String rarity;
  final bool requiresAttunement;
  final String description;
  final ItemType itemType;

  const SrdMagicItem({
    required this.name,
    required this.type,
    required this.rarity,
    required this.requiresAttunement,
    required this.description,
    this.itemType = ItemType.gear,
  });

  factory SrdMagicItem.fromJson(Map<String, dynamic> json) => SrdMagicItem(
        name: (json['name'] as String?) ?? '',
        type: (json['type'] as String?) ?? '',
        rarity: (json['rarity'] as String?) ?? '',
        requiresAttunement: json['requiresAttunement'] as bool? ?? false,
        description: json['description'] as String? ?? '',
        itemType: ItemType.values.firstWhere(
          (e) => e.name == (json['itemType'] as String? ?? ''),
          orElse: () => ItemType.gear,
        ),
      );
}

// ── Feats ─────────────────────────────────────────────────────────────────────

class SrdFeat {
  final String name;
  final String? prerequisite;
  final String description;

  const SrdFeat({
    required this.name,
    this.prerequisite,
    required this.description,
  });

  factory SrdFeat.fromJson(Map<String, dynamic> json) => SrdFeat(
        name: json['name'] as String,
        prerequisite: json['prerequisite'] as String?,
        description: json['description'] as String,
      );
}

// ── Class Features ────────────────────────────────────────────────────────────

class SrdFeatureUses {
  final String amount; // e.g. "2" or "charisma_modifier"
  final String rechargeOn; // "short_rest" | "long_rest"

  const SrdFeatureUses({required this.amount, required this.rechargeOn});

  factory SrdFeatureUses.fromJson(Map<String, dynamic> json) => SrdFeatureUses(
        amount: json['amount'].toString(),
        rechargeOn: (json['rechargeOn'] as String?) ?? '',
      );

  String get rechargeLabel {
    switch (rechargeOn) {
      case 'short_rest':
        return 'Short Rest';
      case 'long_rest':
        return 'Long Rest';
      default:
        return rechargeOn;
    }
  }
}

class SrdClassFeature {
  final String name;
  final int level;
  final String type; // "active" | "passive" | "subclass" | "asi"
  final String description;
  final SrdFeatureUses? uses;

  const SrdClassFeature({
    required this.name,
    required this.level,
    required this.type,
    required this.description,
    this.uses,
  });

  factory SrdClassFeature.fromJson(Map<String, dynamic> json) =>
      SrdClassFeature(
        name: (json['name'] as String?) ?? '',
        level: (json['level'] as int?) ?? 1,
        type: (json['type'] as String?) ?? 'passive',
        description: (json['description'] as String?) ?? '',
        uses: json['uses'] != null
            ? SrdFeatureUses.fromJson(json['uses'] as Map<String, dynamic>)
            : null,
      );
}
