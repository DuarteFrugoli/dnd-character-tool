import '../models/models.dart';

/// Calculates armor class for [c].
///
/// If [equipment] is provided, that list is used instead of [c.equipment],
/// which allows simulating AC with a hypothetical equipment configuration
/// (e.g. the armor-swap preview dialog).
///
/// Rules:
/// - Body armor (non-shield) sets the base AC per its properties.
/// - Shield adds its bonus on top.
/// - Without body armor, applies Unarmored Defense per class:
///   - Barbarian: 10 + DEX mod + CON mod
///   - Monk:      10 + DEX mod + WIS mod
///   - Others:    10 + DEX mod
int calcArmorClass(Character c, {List<EquipmentItem>? equipment}) {
  final items = equipment ?? c.equipment;
  final dexMod = c.abilityScores.dexterityModifier;

  int shieldBonus = 0;
  int? armorBase; // null = no body armor equipped

  for (final item in items) {
    if (!item.isEquipped || item.itemType != ItemType.armor) continue;
    final props = item.properties;
    if (props == null) continue;

    if (props['isShield'] == true) {
      shieldBonus = (props['acBonus'] as num?)?.toInt() ?? 2;
    } else {
      final baseAC = (props['baseAC'] as num?)?.toInt() ?? 10;
      final addDex = props['addDexModifier'] as bool? ?? true;
      final maxDex = (props['maxDexBonus'] as num?)?.toInt();
      int ac = baseAC;
      if (addDex) {
        ac += maxDex != null ? dexMod.clamp(-99, maxDex) : dexMod;
      }
      armorBase = ac;
    }
  }

  final int base;
  if (armorBase != null) {
    base = armorBase;
  } else {
    // Unarmored Defense — class-specific formula
    final cls = c.characterClass.toLowerCase();
    if (cls == 'barbarian') {
      // Barbarians keep Unarmored Defense even with a shield.
      base = 10 + dexMod + c.abilityScores.constitutionModifier;
    } else if (cls == 'monk' && shieldBonus == 0) {
      // Monks lose Unarmored Defense if they equip a shield.
      base = 10 + dexMod + c.abilityScores.wisdomModifier;
    } else {
      base = 10 + dexMod;
    }
  }

  return base + shieldBonus;
}
