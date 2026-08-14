import '../constants/armor_class.dart';
import '../feature_choice_engine.dart';
import '../models/models.dart';
import 'character_progression_engine.dart';

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

  static Character resetToLevelOne(
    Character character,
    CharacterLevelResetResult result,
  ) {
    const primaryClassEntryId = 'primary';
    final className = result.className.trim();
    if (className.isEmpty) {
      throw ArgumentError.value(className, 'className', 'Class is required.');
    }

    final hitDie = result.hitDie.clamp(1, 100).toInt();
    final maximumHp = hitDie + character.abilityScores.constitutionModifier;
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
          (choice) => _shouldPreserveFeatureChoice(
            choice,
            preservedLevelOneFeatNames,
          ),
        )
        .toList();
    final preservedExtraFeatures = character.extraFeatures
        .where(_shouldPreserveExtraFeature)
        .toList();
    final preservedSpells = character.spells.where(_shouldPreserveSpell).toList();

    var updated = character.copyWith(
      dataVersion: currentCharacterDataVersion,
      characterClass: className,
      subclass: _emptyToNull(result.subclassName),
      clearSubclass: _emptyToNull(result.subclassName) == null,
      level: 1,
      classes: classes,
      experiencePoints: 0,
      proficiencyBonus: CharacterProgressionEngine.proficiencyBonusForTotalLevel(
        1,
      ),
      hitPoints: HitPoints(maximum: safeMaximumHp, current: safeMaximumHp),
      hitDicePools: [
        CharacterHitDiePool(
          dieSize: hitDie,
          total: 1,
          sourceClass: className,
          sourceClassEntryId: primaryClassEntryId,
        ),
      ],
      savingThrowProficiencies: _uniqueStrings(
        result.savingThrowProficiencies,
      ),
      skillProficiencies: _uniqueStrings([
        ...character.skillProficiencies,
        ...result.skillProficiencies,
      ]),
      features: _uniqueStrings([
        ...character.features,
        ...result.proficiencyFeatureLabels,
      ]),
      extraFeatures: [
        ...preservedExtraFeatures,
        ...result.extraFeatures,
      ],
      featureChoices: FeatureChoiceEngine.upsertChoices(
        preservedFeatureChoices,
        result.featureChoices,
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
    );

    updated = CharacterProgressionEngine.syncSpellcastingSlotsFor(updated);
    return updated.copyWith(armorClass: calcArmorClass(updated));
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
            preservedLevelOneFeatNames.contains(choice.featureName.toLowerCase());
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
