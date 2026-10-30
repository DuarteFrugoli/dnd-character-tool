import '../feature_choice_engine.dart';
import '../feature_choice_option_resolver.dart';
import '../models/models.dart';
import 'ruleset_ids.dart';

/// Numbers of one attack that mastery effects reuse.
class WeaponAttackStats {
  const WeaponAttackStats({
    required this.abilityModifier,
    required this.magicBonus,
    required this.attackBonus,
    required this.damageDice,
    this.damageType,
  });

  final int abilityModifier;
  final int magicBonus;
  final int attackBonus;
  final String damageDice;
  final String? damageType;
}

/// A mastery property the character can use with a weapon, with the values
/// its effect needs.
class WeaponMasteryEffect {
  const WeaponMasteryEffect({
    required this.mastery,
    this.alternatives = const [],
    this.grazeDamage,
    this.toppleDc,
    this.cleaveAttackBonus,
    this.cleaveDamage,
  });

  /// `cleave`, `graze`, `nick`, `push`, `sap`, `slow`, `topple` or `vex`.
  final String mastery;

  /// Masteries that Tactical Master can use instead for one attack.
  final List<String> alternatives;

  /// Graze: damage of the weapon's type on a miss (never below 0).
  final int? grazeDamage;

  /// Topple: Constitution save DC.
  final int? toppleDc;

  /// Cleave: the second attack, whose damage has no positive ability modifier.
  final int? cleaveAttackBonus;
  final String? cleaveDamage;
}

/// SRD 5.2.1 Weapon Mastery: Barbarians, Fighters, Paladins, Rangers and
/// Rogues use the mastery property of the weapon kinds they chose.
class WeaponMasteryRules {
  const WeaponMasteryRules._();

  static const featureName = 'Weapon Mastery';
  static const choiceId = 'weapon_masteries';
  static const _tacticalMasterLevel = 9;
  static const tacticalMasterOptions = ['push', 'sap', 'slow'];

  /// Weapon kinds (IDs such as `longsword`) from every class's choice.
  static Set<String> masteredWeapons(Character character) => {
    if (character.rulesetId == RulesetId.dnd2024)
      for (final choice in character.featureChoices)
        if (choice.sourceType == FeatureChoiceSourceType.classFeature &&
            choice.featureName == featureName &&
            choice.choiceId == choiceId)
          ...choice.values,
  };

  /// Mastery property of [item] if the character mastered its kind. Items
  /// keep the English catalog name, so the kind is the ID of that name.
  static String? masteryOf(Character character, EquipmentItem item) {
    if (item.itemType != ItemType.weapon) return null;
    final mastery = item.properties?['mastery'];
    if (mastery is! String || mastery.isEmpty) return null;
    final kind = FeatureChoiceOptionResolver.idFromName(item.name);
    return masteredWeapons(character).contains(kind) ? mastery : null;
  }

  static WeaponMasteryEffect? effectFor(
    Character character,
    EquipmentItem item,
    WeaponAttackStats stats,
  ) {
    final mastery = masteryOf(character, item);
    if (mastery == null) return null;
    final tacticalMaster = character.classLevel('Fighter') >= _tacticalMasterLevel;
    final cleaveModifier = stats.abilityModifier > 0 ? 0 : stats.abilityModifier;
    return WeaponMasteryEffect(
      mastery: mastery,
      alternatives: tacticalMaster
          ? [for (final option in tacticalMasterOptions) if (option != mastery) option]
          : const [],
      grazeDamage: mastery == 'graze'
          ? (stats.abilityModifier > 0 ? stats.abilityModifier : 0)
          : null,
      toppleDc: mastery == 'topple'
          ? 8 + stats.abilityModifier + character.proficiencyBonus
          : null,
      cleaveAttackBonus: mastery == 'cleave' ? stats.attackBonus : null,
      cleaveDamage: mastery == 'cleave'
          ? _withModifier(stats.damageDice, cleaveModifier + stats.magicBonus)
          : null,
    );
  }

  static String _withModifier(String expression, int modifier) {
    if (modifier == 0) return expression;
    return modifier > 0 ? '$expression+$modifier' : '$expression$modifier';
  }
}
