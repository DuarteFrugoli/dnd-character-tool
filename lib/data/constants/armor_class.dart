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
/// - Defense Fighting Style adds +1 while wearing body armor.
/// - Without body armor, applies Unarmored Defense when available:
///   - Barbarian: 10 + DEX mod + CON mod
///   - Monk:      10 + DEX mod + WIS mod
///   - Draconic Resilience: 13 + DEX mod
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
      var ac = baseAC;
      if (addDex) {
        ac += maxDex != null ? dexMod.clamp(-99, maxDex) : dexMod;
      }
      armorBase = ac;
    }
  }

  if (armorBase != null) {
    final defenseBonus = _hasDefenseFightingStyle(c.featureChoices) ? 1 : 0;
    return armorBase + shieldBonus + defenseBonus;
  }

  final unarmoredAc = calcUnarmoredArmorClass(
    characterClass: c.characterClass,
    classEntries: c.classEntries,
    abilityScores: c.abilityScores,
    shieldBonus: shieldBonus,
    extraFeatures: c.extraFeatures,
    disabledFeatures: c.disabledFeatures,
  );
  final draconicAc = _hasDraconicResilience(c)
      ? 13 + dexMod + shieldBonus
      : unarmoredAc;
  return unarmoredAc > draconicAc ? unarmoredAc : draconicAc;
}

int calcUnarmoredArmorClass({
  required String characterClass,
  Iterable<CharacterClassEntry> classEntries = const [],
  required AbilityScores abilityScores,
  int shieldBonus = 0,
  Iterable<CharacterExtraFeature> extraFeatures = const [],
  Iterable<String> disabledFeatures = const [],
}) {
  final dexMod = abilityScores.dexterityModifier;
  if (_hasUnarmoredDefense(
    characterClass: characterClass,
    classEntries: classEntries,
    sourceClass: 'Barbarian',
    extraFeatures: extraFeatures,
    disabledFeatures: disabledFeatures,
  )) {
    // Barbarians keep Unarmored Defense even with a shield.
    return 10 + dexMod + abilityScores.constitutionModifier + shieldBonus;
  }
  if (shieldBonus == 0 &&
      _hasUnarmoredDefense(
        characterClass: characterClass,
        classEntries: classEntries,
        sourceClass: 'Monk',
        extraFeatures: extraFeatures,
        disabledFeatures: disabledFeatures,
      )) {
    // Monks lose Unarmored Defense if they equip a shield.
    return 10 + dexMod + abilityScores.wisdomModifier;
  }
  return 10 + dexMod + shieldBonus;
}

bool _hasUnarmoredDefense({
  required String characterClass,
  required Iterable<CharacterClassEntry> classEntries,
  required String sourceClass,
  required Iterable<CharacterExtraFeature> extraFeatures,
  required Iterable<String> disabledFeatures,
}) {
  const featureName = 'Unarmored Defense';
  if (disabledFeatures.contains(featureName)) return false;

  final source = sourceClass.toLowerCase();
  if (characterClass.toLowerCase() == source) return true;
  if (classEntries.any((entry) => entry.className.toLowerCase() == source)) {
    return true;
  }

  return extraFeatures.any(
    (f) =>
        f.name.toLowerCase() == featureName.toLowerCase() &&
        f.sourceClass.toLowerCase() == source,
  );
}

bool _hasDefenseFightingStyle(Iterable<CharacterFeatureChoice> choices) {
  return choices.any(
    (choice) =>
        choice.choiceId == 'fighting_style' &&
        choice.values.any((value) => value.toLowerCase() == 'defense'),
  );
}

bool _hasDraconicResilience(Character c) {
  const featureName = 'Draconic Resilience';
  if (c.disabledFeatures.contains(featureName)) return false;

  if (c.characterClass.toLowerCase() == 'sorcerer' &&
      c.subclass?.toLowerCase() == 'draconic bloodline') {
    return true;
  }
  if (c.classEntries.any(
    (entry) =>
        entry.className.toLowerCase() == 'sorcerer' &&
        entry.subclassName?.toLowerCase() == 'draconic bloodline',
  )) {
    return true;
  }

  return c.extraFeatures.any(
    (feature) => feature.name.toLowerCase() == featureName.toLowerCase(),
  );
}
