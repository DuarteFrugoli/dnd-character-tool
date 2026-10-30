import '../conditions/exhaustion_rules.dart';
import '../datasources/srd/srd_2024_creation_catalog.dart';
import '../json_helpers.dart';
import '../models/models.dart';
import 'ruleset_ids.dart';

/// Speed shown on the sheet: the saved base Speed plus class features that
/// raise it, then Exhaustion.
class SpeedRules {
  const SpeedRules._();

  static const _fastMovement = 'Fast Movement';
  static const _fastMovementFeet = 10;

  /// [classes2024] is required for 2024 sheets so class bonuses come from the
  /// 2024 class tables.
  static int speedFor(Character character, {List<Creation2024Class>? classes2024}) {
    final exhaustion = ExhaustionRules.forCharacter(character);
    if (character.rulesetId != RulesetId.dnd2024 || classes2024 == null) {
      return exhaustion.speedFor(character);
    }
    final bonus = classSpeedBonus(character, classes2024);
    return exhaustion.speedFor(character.copyWith(speed: character.speed + bonus));
  }

  /// 2024 Unarmored Movement (no armor or Shield) and Fast Movement (no
  /// Heavy armor).
  static int classSpeedBonus(Character character, List<Creation2024Class> classes) {
    final armor = [
      for (final item in character.equipment)
        if (item.isEquipped && item.itemType == ItemType.armor) item,
    ];
    final wearsArmor = armor.any((item) => !_isShield(item));
    final hasShield = armor.any(_isShield);
    final wearsHeavy = armor.any(_isHeavy);
    var bonus = 0;
    for (final entry in character.classEntries) {
      final cls = classes.where((c) => c.name == entry.className).firstOrNull;
      if (cls == null) continue;
      final unarmored =
          (cls.rowAt(entry.level)['unarmoredMovementBonusFeet'] as num?)?.toInt() ?? 0;
      if (unarmored > 0 && !wearsArmor && !hasShield) bonus += unarmored;
      final fastMovement = [
        for (var level = 1; level <= entry.level; level++) ...cls.featuresAt(level),
      ].contains(_fastMovement);
      if (fastMovement && !wearsHeavy) bonus += _fastMovementFeet;
    }
    return bonus;
  }

  static bool _isShield(EquipmentItem item) =>
      readBool(item.properties?['isShield']);

  /// Saved items record `armorType`; older ones are heavy when the armor does
  /// not add Dexterity, which holds for every SRD armor.
  static bool _isHeavy(EquipmentItem item) {
    if (_isShield(item)) return false;
    final type = item.properties?['armorType'];
    if (type is String) return type == 'heavy';
    final props = item.properties;
    return props != null &&
        props.containsKey('baseAC') &&
        !readBool(props['addDexModifier'], defaultValue: true);
  }
}
