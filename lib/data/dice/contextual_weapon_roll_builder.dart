import '../datasources/srd/srd_models.dart';
import '../models/models.dart';
import 'contextual_roll.dart';

class ContextualWeaponRollBuilder {
  const ContextualWeaponRollBuilder._();

  static ContextualRollRequest? build({
    required Character character,
    required EquipmentItem item,
    required String displayName,
    required String attackLabel,
    required String damageLabel,
    required String extraDamageLabel,
    required String versatileGripLabel,
    required String versatileOneHandedLabel,
    required String versatileTwoHandedLabel,
    required List<SrdClass> classes,
    String? subtitle,
  }) {
    if (item.itemType != ItemType.weapon) return null;

    final damageDice = _propertyText(item, 'damageDice') ??
        _propertyText(item, 'damage');
    if (damageDice == null || damageDice.isEmpty) return null;

    final abilityModifier = _weaponAbilityModifier(character, item);
    final magicBonus = _propertyInt(item, 'bonus');
    final attackBonus =
        abilityModifier +
        magicBonus +
        (_isProficientWithWeapon(character, item, classes)
            ? character.proficiencyBonus
            : 0);

    final parts = <ContextualRollPart>[
      ContextualRollPart.d20(
        label: attackLabel,
        d20Modifier: attackBonus,
      ),
    ];

    if (!_isZeroExpression(damageDice)) {
      final baseDamageExpression = _withModifier(
        damageDice,
        abilityModifier + magicBonus,
      );
      final versatileDamage = _propertyText(item, 'versatileDamage');
      final choices = versatileDamage != null &&
              versatileDamage.isNotEmpty &&
              !_isZeroExpression(versatileDamage)
          ? [
              ContextualRollExpressionChoice(
                key: 'one_handed',
                label: '$versatileOneHandedLabel ($damageDice)',
                expression: baseDamageExpression,
              ),
              ContextualRollExpressionChoice(
                key: 'two_handed',
                label: '$versatileTwoHandedLabel ($versatileDamage)',
                expression: _withModifier(
                  versatileDamage,
                  abilityModifier + magicBonus,
                ),
              ),
            ]
          : const <ContextualRollExpressionChoice>[];
      parts.add(
        ContextualRollPart.expression(
          id: 'damage',
          label: damageLabel,
          expression: baseDamageExpression,
          critical: true,
          choiceLabel: choices.isEmpty ? null : versatileGripLabel,
          choices: choices,
        ),
      );
    }

    final extraDamage = _propertyText(item, 'extraDamage');
    if (extraDamage != null &&
        extraDamage.isNotEmpty &&
        !_isZeroExpression(extraDamage)) {
      parts.add(
        ContextualRollPart.expression(
          id: 'extra_damage',
          label: extraDamageLabel,
          expression: extraDamage,
          critical: true,
        ),
      );
    }

    return ContextualRollRequest(
      key: 'weapon:${item.id}',
      title: displayName,
      subtitle: subtitle,
      parts: parts,
    );
  }

  static int _weaponAbilityModifier(Character character, EquipmentItem item) {
    final props = _weaponProperties(item);
    if (props.contains('finesse')) {
      return character.abilityScores.strengthModifier >
              character.abilityScores.dexterityModifier
          ? character.abilityScores.strengthModifier
          : character.abilityScores.dexterityModifier;
    }

    final category = item.category.toLowerCase();
    if (category.contains('ranged')) {
      return character.abilityScores.dexterityModifier;
    }
    return character.abilityScores.strengthModifier;
  }

  static bool _isProficientWithWeapon(
    Character character,
    EquipmentItem item,
    List<SrdClass> classes,
  ) {
    final proficiencies = _weaponProficiencies(character, classes);
    final group = _weaponCategoryGroup(item.category);
    if (group != null && proficiencies.contains(group)) return true;

    final weaponNames = _weaponNameAliases(item.name);
    return weaponNames.any(proficiencies.contains);
  }

  static Set<String> _weaponProficiencies(
    Character character,
    List<SrdClass> classes,
  ) {
    final proficiencies = <String>{};
    final startingEntries = character.classEntries
        .where((entry) => entry.isStartingClass)
        .toList();
    final classEntries = startingEntries.isNotEmpty
        ? startingEntries
        : [character.classEntries.first];

    for (final entry in classEntries) {
      SrdClass? srdClass;
      for (final candidate in classes) {
        if (candidate.name.toLowerCase() == entry.className.toLowerCase()) {
          srdClass = candidate;
          break;
        }
      }
      if (srdClass == null) continue;
      proficiencies.addAll(
        srdClass.weaponProficiencies.map(_normalizeWeaponProficiency),
      );
    }

    const prefix = 'weapon proficiency:';
    for (final feature in character.features) {
      final lower = feature.toLowerCase();
      if (!lower.startsWith(prefix)) continue;
      proficiencies.add(
        _normalizeWeaponProficiency(feature.substring(prefix.length)),
      );
    }

    return proficiencies;
  }

  static String? _weaponCategoryGroup(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('simple')) return 'simple';
    if (lower.contains('martial')) return 'martial';
    return null;
  }

  static Set<String> _weaponNameAliases(String name) {
    final lower = name.trim().toLowerCase();
    final aliases = <String>{lower};
    if (lower.contains(',')) {
      final parts = lower.split(',');
      if (parts.length == 2) {
        aliases.add('${parts[1].trim()} ${parts[0].trim()}');
      }
    }
    return aliases.map(_normalizeWeaponProficiency).toSet();
  }

  static String _normalizeWeaponProficiency(String value) {
    var lower = value.trim().toLowerCase();
    if (lower == 'simple weapons') return 'simple';
    if (lower == 'martial weapons') return 'martial';
    lower = lower.replaceAll(',', '').replaceAll(RegExp(r'\s+'), ' ');
    if (lower.endsWith('s') && !lower.endsWith('ss')) {
      lower = lower.substring(0, lower.length - 1);
    }
    return lower;
  }

  static List<String> _weaponProperties(EquipmentItem item) {
    final value = item.properties?['weaponProperties'];
    if (value is List) {
      return value.map((entry) => entry.toString().toLowerCase()).toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((entry) => entry.trim().toLowerCase())
          .where((entry) => entry.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String? _propertyText(EquipmentItem item, String key) {
    final value = item.properties?[key];
    if (value == null) return null;
    return value.toString().trim();
  }

  static int _propertyInt(EquipmentItem item, String key) {
    final value = item.properties?[key];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static bool _isZeroExpression(String expression) {
    return int.tryParse(expression.trim()) == 0;
  }

  static String _withModifier(String expression, int modifier) {
    if (modifier == 0) return expression;
    if (modifier > 0) return '$expression+$modifier';
    return '$expression$modifier';
  }
}
