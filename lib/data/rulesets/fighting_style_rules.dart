import '../feature_choice_engine.dart';
import '../feature_choice_option_resolver.dart';
import '../models/models.dart';

/// Fighting Styles a character has and their effect on weapon rolls.
///
/// Styles come from the Fighting Style features (both editions save them as
/// `fighting_style`; the 2024 Champion uses `additional_fighting_style`) and,
/// in 2024, from Fighting Style feats taken at feat levels.
class FightingStyleRules {
  const FightingStyleRules._();

  static const choiceIds = {'fighting_style', 'additional_fighting_style'};

  static const archery = 'archery';
  static const dueling = 'dueling';
  static const thrownWeaponFighting = 'thrown_weapon_fighting';

  static const archeryAttackBonus = 2;
  static const duelingDamageBonus = 2;
  static const thrownDamageBonus = 2;

  static bool isStyleChoice(CharacterFeatureChoice choice) =>
      choiceIds.contains(choice.choiceId);

  /// Option ids of every style the character has, from [choices] (the saved
  /// ones by default) and feats.
  static Set<String> stylesOf(
    Character character, {
    Iterable<CharacterFeatureChoice>? choices,
  }) => {
    for (final choice in choices ?? character.featureChoices)
      if (isStyleChoice(choice)) ...choice.values,
    for (final feature in character.extraFeatures)
      if (feature.effectiveSourceType == FeatureChoiceSourceType.feat)
        FeatureChoiceOptionResolver.idFromName(feature.name),
  };

  static bool has(Character character, String style) =>
      stylesOf(character).contains(style);

  /// What the character's styles add when attacking with [item].
  static FightingStyleWeaponEffect weaponEffect(
    Character character,
    EquipmentItem item,
  ) {
    final styles = stylesOf(character);
    final properties = _properties(item);
    final ranged = _isRanged(item);
    final thrown = properties.contains('thrown');
    final otherMeleeWeapon = character.equipment.any(
      (other) =>
          other.id != item.id &&
          other.isEquipped &&
          other.itemType == ItemType.weapon &&
          !_isRanged(other),
    );
    return FightingStyleWeaponEffect(
      archeryAttackBonus:
          ranged && styles.contains(archery) ? archeryAttackBonus : 0,
      duelingDamageBonus: !ranged &&
              !properties.contains('two-handed') &&
              !otherMeleeWeapon &&
              styles.contains(dueling)
          ? duelingDamageBonus
          : 0,
      thrownDamageBonus:
          thrown && styles.contains(thrownWeaponFighting) ? thrownDamageBonus : 0,
      alwaysThrown: ranged && thrown,
    );
  }

  static bool _isRanged(EquipmentItem item) =>
      item.category.toLowerCase().contains('ranged');

  static List<String> _properties(EquipmentItem item) {
    final value = item.properties?['weaponProperties'];
    final raw = value is List
        ? value.map((entry) => entry.toString())
        : value is String
            ? value.split(',')
            : const <String>[];
    return [
      for (final entry in raw)
        if (entry.trim().isNotEmpty) entry.trim().toLowerCase(),
    ];
  }
}

class FightingStyleWeaponEffect {
  const FightingStyleWeaponEffect({
    this.archeryAttackBonus = 0,
    this.duelingDamageBonus = 0,
    this.thrownDamageBonus = 0,
    this.alwaysThrown = false,
  });

  /// Archery: added to attack rolls with Ranged weapons.
  final int archeryAttackBonus;

  /// Dueling: added to one-handed damage of a Melee weapon while no other
  /// Melee weapon is equipped.
  final int duelingDamageBonus;

  /// Thrown Weapon Fighting: added to the damage of ranged attacks made with
  /// a Thrown weapon.
  final int thrownDamageBonus;

  /// True for Ranged weapons with the Thrown property (Dart), whose attacks
  /// are always thrown; Melee Thrown weapons offer a thrown attack option.
  final bool alwaysThrown;

  bool get isEmpty =>
      archeryAttackBonus == 0 && duelingDamageBonus == 0 && thrownDamageBonus == 0;
}
