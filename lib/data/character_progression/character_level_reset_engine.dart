import '../constants/armor_class.dart';
import '../constants/level_up_rules.dart';
import '../feature_choice_engine.dart';
import '../feature_choice_option_resolver.dart';
import '../models/models.dart';
import '../rulesets/character_rules_context.dart';
import 'character_progression_engine.dart';
import 'choice_effects.dart';

/// What a 2014 reset cannot undo on a sheet saved before levels recorded
/// their history or class skills were recorded.
enum LevelResetLimitation { abilityIncreasesKept, previousClassSkillsKept }

class CharacterLevelResetResult {
  const CharacterLevelResetResult({
    required this.className,
    required this.hitDie,
    required this.savingThrowProficiencies,
    this.subclassName,
    this.skillProficiencies = const [],
    this.proficiencyFeatureLabels = const [],
    this.featureChoices = const [],
    this.extraFeatures = const [],
    this.spells = const [],
  });

  final String className;
  final String? subclassName;
  final int hitDie;
  final List<String> savingThrowProficiencies;
  final List<String> skillProficiencies;
  final List<String> proficiencyFeatureLabels;
  final List<CharacterFeatureChoice> featureChoices;
  final List<CharacterExtraFeature> extraFeatures;
  final List<KnownSpell> spells;
}

class CharacterLevelResetEngine {
  const CharacterLevelResetEngine._();

  /// Limits of resetting [character], to tell the player before confirming.
  static Set<LevelResetLimitation> limitationsFor(Character character) => {
    if (character.totalLevel > 1 &&
        !CharacterProgressionEngine.hasCompleteHistory(character))
      LevelResetLimitation.abilityIncreasesKept,
    if (!character.featureChoices.any(
      (choice) => choice.featureName == ChoiceEffects.classSkillsFeature,
    ))
      LevelResetLimitation.previousClassSkillsKept,
  };

  /// Rebuilds level 1 in [result]'s class. With [effects], grants of removed
  /// and new feature choices are undone and applied; with a complete level
  /// history, ability increases of later levels are undone too.
  static Character resetToLevelOne(
    Character character,
    CharacterLevelResetResult result, {
    ChoiceEffectsData? effects,
  }) {
    CharacterRulesContext.fromCharacter(character).requireLegacyOperation('Level reset');
    const primaryClassEntryId = 'primary';
    final className = result.className.trim();
    if (className.isEmpty) {
      throw ArgumentError.value(className, 'className', 'Class is required.');
    }

    var scores = character.abilityScores;
    if (CharacterProgressionEngine.hasCompleteHistory(character)) {
      for (final record in character.levelHistory.skip(1)) {
        for (final entry in record.abilityIncreases.entries) {
          scores = scores.increment(entry.key, -entry.value);
        }
      }
    }
    final hitDie = result.hitDie.clamp(1, 100).toInt();
    final maximumHp = hitDie + scores.constitutionModifier;
    final safeMaximumHp = maximumHp.clamp(1, 9999).toInt();

    final classes = [
      CharacterClassEntry(
        id: primaryClassEntryId,
        className: className,
        subclassName: _emptyToNull(result.subclassName),
        level: 1,
        isStartingClass: true,
      ),
    ];

    final preservedLevelOneFeatNames = _levelOneFeatNames(
      character.extraFeatures,
    );
    final preservedFeatureChoices = character.featureChoices
        .where(
          (choice) =>
              _shouldPreserveFeatureChoice(choice, preservedLevelOneFeatNames),
        )
        .toList();
    // Undo what the removed choices granted before rebuilding level 1.
    var base = character.copyWith(featureChoices: preservedFeatureChoices);
    if (effects != null) base = ChoiceEffects.apply(character, base, effects);
    final multiclassLabels = {
      for (final entry in character.classEntries)
        if (!entry.isStartingClass) ..._multiclassLabels(entry.className),
    };
    final preservedExtraFeatures = base.extraFeatures
        .where(_shouldPreserveExtraFeature)
        .toList();
    final preservedSpells = base.spells
        .where(_shouldPreserveSpell)
        .toList();
    final classSkillsChoice = CharacterFeatureChoice(
      sourceType: FeatureChoiceSourceType.classFeature,
      sourceClass: className,
      sourceClassEntryId: primaryClassEntryId,
      featureName: ChoiceEffects.classSkillsFeature,
      choiceId: 'skills',
      values: [
        for (final skill in result.skillProficiencies)
          FeatureChoiceOptionResolver.idFromName(skill),
      ],
    );

    var updated = character.copyWith(
      dataVersion: currentCharacterDataVersion,
      characterClass: className,
      subclass: _emptyToNull(result.subclassName),
      clearSubclass: _emptyToNull(result.subclassName) == null,
      level: 1,
      classes: classes,
      experiencePoints: character.xpTrackingEnabled
          ? levelToMinXp(1)
          : character.experiencePoints,
      abilityScores: scores,
      proficiencyBonus:
          CharacterProgressionEngine.proficiencyBonusForTotalLevel(1),
      hitPoints: HitPoints(maximum: safeMaximumHp, current: safeMaximumHp),
      hitDicePools: [
        CharacterHitDiePool(
          dieSize: hitDie,
          total: 1,
          sourceClass: className,
          sourceClassEntryId: primaryClassEntryId,
        ),
      ],
      savingThrowProficiencies: _uniqueStrings(result.savingThrowProficiencies),
      skillProficiencies: _uniqueStrings([
        ...base.skillProficiencies,
        ...result.skillProficiencies,
      ]),
      skillExpertises: base.skillExpertises,
      languages: base.languages,
      features: _uniqueStrings([
        for (final feature in base.features)
          if (!multiclassLabels.contains(feature)) feature,
        ...result.proficiencyFeatureLabels,
      ]),
      extraFeatures: [...preservedExtraFeatures, ...result.extraFeatures],
      featureChoices: FeatureChoiceEngine.upsertChoices(
        base.featureChoices,
        [classSkillsChoice, ...result.featureChoices],
      ),
      spells: [
        ...preservedSpells,
        ..._withInitialClassSpellSource(
          result.spells,
          className: className,
          subclassName: _emptyToNull(result.subclassName),
          classEntryId: primaryClassEntryId,
        ),
      ],
      spellSlots: const SpellSlots(),
      pactMagicSlots: const SpellSlots(),
      featureResources: const {},
      disabledFeatures: const [],
      disabledSpells: const [],
      concentrationSpell: null,
      // Level 1 Druids have no Wild Shape.
      wildShape: null,
      levelHistory: [
        CharacterLevelRecord(
          characterLevel: 1,
          classEntryId: primaryClassEntryId,
          className: className,
          classLevel: 1,
          hitPointsGained: safeMaximumHp,
          hitPointMethod: HitPointGainMethod.maximum,
          subclassName: _emptyToNull(result.subclassName),
          baseAbilityScores:
              character.levelHistory.firstOrNull?.baseAbilityScores ?? const {},
        ),
      ],
    );
    if (effects != null) {
      // Grants of the new level 1 choices, e.g. Rogue Expertise.
      updated = ChoiceEffects.apply(
        updated.copyWith(featureChoices: base.featureChoices),
        updated,
        effects,
      );
    }
    updated = CharacterProgressionEngine.syncSpellcastingSlotsFor(updated);
    return updated.copyWith(armorClass: calcArmorClass(updated));
  }

  /// Proficiency labels that multiclassing into [className] adds.
  static Set<String> _multiclassLabels(String className) {
    final rule = multiclassProficiencyRuleFor(className);
    return {
      for (final armor in rule.armorProficiencies) 'Armor Proficiency: $armor',
      for (final weapon in rule.weaponProficiencies) 'Weapon Proficiency: $weapon',
      for (final tool in rule.toolProficiencies) 'Tool Proficiency: $tool',
    };
  }

  static bool _shouldPreserveFeatureChoice(
    CharacterFeatureChoice choice,
    Set<String> preservedLevelOneFeatNames,
  ) {
    switch (choice.sourceType) {
      case FeatureChoiceSourceType.classFeature:
      case FeatureChoiceSourceType.subclassFeature:
      case FeatureChoiceSourceType.multiclassProficiency:
        return false;
      case FeatureChoiceSourceType.feat:
        final sourceName = choice.sourceName?.toLowerCase();
        return (sourceName != null &&
                preservedLevelOneFeatNames.contains(sourceName)) ||
            preservedLevelOneFeatNames.contains(
              choice.featureName.toLowerCase(),
            );
      default:
        return true;
    }
  }

  static Set<String> _levelOneFeatNames(
    Iterable<CharacterExtraFeature> features,
  ) {
    final names = <String>{};
    for (final feature in features) {
      if (feature.effectiveSourceType != FeatureChoiceSourceType.feat ||
          feature.level > 1) {
        continue;
      }
      final sourceFeature = _emptyToNull(feature.sourceFeature);
      if (sourceFeature != null) names.add(sourceFeature.toLowerCase());
      names.add(feature.name.toLowerCase());
    }
    return names;
  }

  static bool _shouldPreserveExtraFeature(CharacterExtraFeature feature) {
    switch (feature.effectiveSourceType) {
      case FeatureChoiceSourceType.classFeature:
      case FeatureChoiceSourceType.subclassFeature:
      case FeatureChoiceSourceType.multiclassProficiency:
        return false;
      case FeatureChoiceSourceType.feat:
        return feature.level <= 1;
      default:
        return true;
    }
  }

  static bool _shouldPreserveSpell(KnownSpell spell) {
    if (spell.sourceClassEntryId != null) return false;
    switch (spell.sourceType) {
      case 'class':
      case FeatureChoiceSourceType.classFeature:
      case FeatureChoiceSourceType.subclassFeature:
        return false;
      default:
        return true;
    }
  }

  static List<KnownSpell> _withInitialClassSpellSource(
    List<KnownSpell> spells, {
    required String className,
    required String? subclassName,
    required String classEntryId,
  }) {
    return [
      for (final spell in spells)
        spell.copyWith(
          sourceType: spell.sourceType.isEmpty || spell.sourceType == 'manual'
              ? 'class'
              : spell.sourceType,
          sourceClass: _emptyToNull(spell.sourceClass) ?? className,
          sourceSubclass: _emptyToNull(spell.sourceSubclass) ?? subclassName,
          sourceClassEntryId:
              _emptyToNull(spell.sourceClassEntryId) ?? classEntryId,
        ),
    ];
  }

  static List<String> _uniqueStrings(Iterable<String> values) {
    final result = <String>[];
    final seen = <String>{};
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed.toLowerCase())) result.add(trimmed);
    }
    return result;
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}
