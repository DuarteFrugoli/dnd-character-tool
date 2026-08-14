import '../character_spellcasting_summary.dart';
import '../constants/armor_class.dart';
import '../constants/level_up_rules.dart';
import '../datasources/srd/srd_models.dart';
import '../feature_choice_engine.dart';
import '../models/models.dart';

class CharacterProgressionEngine {
  const CharacterProgressionEngine._();

  static int proficiencyBonusForTotalLevel(int totalLevel) {
    if (totalLevel <= 4) return 2;
    if (totalLevel <= 8) return 3;
    if (totalLevel <= 12) return 4;
    if (totalLevel <= 16) return 5;
    return 6;
  }

  static Character applyLevelUp(Character character, LevelUpResult result) {
    final targetSubclass = _targetSubclassAfterLevelUp(character, result);
    final classes = classEntriesAfterLevelUp(
      character: character,
      result: result,
      targetSubclass: targetSubclass,
    );
    final hitDicePools = hitDicePoolsAfterLevelUp(
      character: character,
      result: result,
    );
    final totalLevel = totalLevelFor(classes);
    if (totalLevel > 20) {
      throw ArgumentError.value(
        totalLevel,
        'totalLevel',
        'A character cannot exceed level 20.',
      );
    }

    final startingClass = startingClassEntry(classes);
    final hpGained = result.hpGained.clamp(0, 9999).toInt();
    final newMaxHp = character.hitPoints.maximum + hpGained;
    final newCurrentHp = (character.hitPoints.current + hpGained)
        .clamp(0, newMaxHp)
        .toInt();

    var abilityScores = character.abilityScores;
    for (final entry in result.asiChanges.entries) {
      abilityScores = abilityScores.increment(entry.key, entry.value);
    }

    var extraFeatures = character.extraFeatures;
    if (result.featChosen != null) {
      extraFeatures = _extraFeaturesWithFeat(
        extraFeatures,
        result.featChosen!,
        totalLevel,
      );
    }

    final spells = _spellsAfterLevelUp(
      character.spells,
      result,
      targetSubclass,
    );
    final featureChoices = FeatureChoiceEngine.upsertChoices(
      character.featureChoices,
      result.featureChoices,
    );
    final skillProficiencies = _withUniqueStrings(
      character.skillProficiencies,
      result.skillProficienciesGained,
    );
    final features = _withUniqueStrings(
      character.features,
      result.proficiencyFeatureLabelsGained,
    );

    var updated = character.copyWith(
      level: totalLevel,
      characterClass: startingClass.className,
      subclass: startingClass.subclassName,
      clearSubclass: startingClass.subclassName == null,
      classes: classes,
      proficiencyBonus: proficiencyBonusForTotalLevel(totalLevel),
      hitPoints: character.hitPoints.copyWith(
        maximum: newMaxHp,
        current: newCurrentHp,
      ),
      hitDicePools: hitDicePools,
      abilityScores: abilityScores,
      skillProficiencies: skillProficiencies,
      features: features,
      extraFeatures: extraFeatures,
      featureChoices: featureChoices,
      spells: spells,
    );

    updated = syncSpellcastingSlotsFor(updated);
    return updated.copyWith(armorClass: calcArmorClass(updated));
  }

  static List<CharacterClassEntry> classEntriesAfterLevelUp({
    required Character character,
    required LevelUpResult result,
    String? targetSubclass,
  }) {
    final entries = normalizeClassEntries(character);
    final updated = <CharacterClassEntry>[];
    var foundTarget = false;

    for (final entry in entries) {
      if (entry.id == result.targetClassEntryId) {
        foundTarget = true;
        updated.add(
          entry.copyWith(
            level: result.newClassLevel.clamp(1, 20).toInt(),
            subclassName: targetSubclass,
          ),
        );
      } else {
        updated.add(entry);
      }
    }

    if (!foundTarget) {
      updated.add(
        CharacterClassEntry(
          id: result.targetClassEntryId,
          className: result.targetClassName,
          subclassName: targetSubclass,
          level: result.newClassLevel.clamp(1, 20).toInt(),
          isStartingClass: updated.isEmpty,
        ),
      );
    }

    return _withSingleStartingClass(updated);
  }

  static List<CharacterHitDiePool> hitDicePoolsAfterLevelUp({
    required Character character,
    required LevelUpResult result,
  }) {
    final pools = character.hitDicePools.isEmpty
        ? [
            CharacterHitDiePool(
              dieSize: levelUpHitDie(character.primaryClassName),
              total: character.totalLevel,
              used: character.totalHitDiceUsed,
              sourceClass: character.primaryClassName,
              sourceClassEntryId: character.primaryClass.id,
            ),
          ]
        : character.hitDicePools;
    final updated = <CharacterHitDiePool>[];
    var foundTarget = false;

    for (final pool in pools) {
      if (pool.sourceClassEntryId == result.targetClassEntryId) {
        foundTarget = true;
        updated.add(pool.copyWith(total: pool.total + 1));
      } else {
        updated.add(pool);
      }
    }

    if (!foundTarget) {
      updated.add(
        CharacterHitDiePool(
          dieSize: result.targetHitDie,
          total: result.newClassLevel.clamp(1, 20).toInt(),
          sourceClass: result.targetClassName,
          sourceClassEntryId: result.targetClassEntryId,
        ),
      );
    }

    return [for (final pool in updated) _normalizedHitDiePool(pool)];
  }

  static List<CharacterClassEntry> normalizeClassEntries(Character character) {
    final entries = character.classEntries;
    return _withSingleStartingClass([
      for (var i = 0; i < entries.length; i++)
        entries[i].copyWith(
          id: entries[i].id.isEmpty ? 'class_${i + 1}' : entries[i].id,
          className: entries[i].className.isEmpty
              ? character.characterClass
              : entries[i].className,
          level: entries[i].level.clamp(1, 20).toInt(),
        ),
    ]);
  }

  static CharacterClassEntry startingClassEntry(
    List<CharacterClassEntry> entries,
  ) {
    for (final entry in entries) {
      if (entry.isStartingClass) return entry;
    }
    return entries.first;
  }

  static int totalLevelFor(List<CharacterClassEntry> entries) {
    return entries.fold<int>(0, (sum, entry) => sum + entry.level);
  }

  static SpellSlots syncedSpellSlotsFor(Character character) {
    return syncSpellcastingSlotsFor(character).spellSlots;
  }

  static Character syncSpellcastingSlotsFor(Character character) {
    final summary = CharacterSpellcastingSummary.fromCharacter(character);
    if (!summary.hasSpellcasting) return character;
    return character.copyWith(
      spellSlots: summary.standardSlots,
      pactMagicSlots: summary.pactMagicSlots,
    );
  }

  static SpellSlots pactMagicSlotsAfterShortRest(Character character) {
    final summary = CharacterSpellcastingSummary.fromCharacter(character);
    final pactSlots = summary.pactMagicSlots;
    if (!pactSlots.total.any((total) => total > 0)) {
      return character.pactMagicSlots;
    }
    return pactSlots.copyWith(used: List<int>.filled(9, 0));
  }

  static String classLevelSummary(Character character) {
    return normalizeClassEntries(
      character,
    ).map((entry) => '${entry.className} ${entry.level}').join(' / ');
  }

  static String? _targetSubclassAfterLevelUp(
    Character character,
    LevelUpResult result,
  ) {
    if (result.subclassChosen != null) return result.subclassChosen;
    for (final entry in character.classEntries) {
      if (entry.id == result.targetClassEntryId) return entry.subclassName;
    }
    return null;
  }

  static List<CharacterClassEntry> _withSingleStartingClass(
    List<CharacterClassEntry> entries,
  ) {
    if (entries.isEmpty) return entries;
    final startingIndex = entries.indexWhere((entry) => entry.isStartingClass);
    final effectiveStartingIndex = startingIndex < 0 ? 0 : startingIndex;
    return [
      for (var i = 0; i < entries.length; i++)
        entries[i].copyWith(isStartingClass: i == effectiveStartingIndex),
    ];
  }

  static CharacterHitDiePool _normalizedHitDiePool(CharacterHitDiePool pool) {
    final total = pool.total.clamp(0, 20).toInt();
    return pool.copyWith(total: total, used: pool.used.clamp(0, total).toInt());
  }

  static List<CharacterExtraFeature> _extraFeaturesWithFeat(
    List<CharacterExtraFeature> current,
    SrdFeat feat,
    int totalLevel,
  ) {
    final alreadyHas = current.any(
      (feature) =>
          feature.name == feat.name &&
          feature.effectiveSourceType == FeatureChoiceSourceType.feat,
    );
    if (alreadyHas) return current;
    return [
      ...current,
      CharacterExtraFeature(
        sourceClass: 'Feat',
        sourceType: FeatureChoiceSourceType.feat,
        sourceFeature: feat.name,
        name: feat.name,
        level: totalLevel,
        type: 'passive',
        description: feat.description,
      ),
    ];
  }

  static List<KnownSpell> _spellsAfterLevelUp(
    List<KnownSpell> current,
    LevelUpResult result,
    String? targetSubclass,
  ) {
    final withoutSwapped = result.spellSwapped == null
        ? current
        : current.where((spell) => spell.name != result.spellSwapped).toList();
    return [
      ...withoutSwapped,
      ...result.cantripsLearned.map(
        (spell) => _withTargetSpellSource(spell, result, targetSubclass),
      ),
      ...result.spellsLearned.map(
        (spell) => _withTargetSpellSource(spell, result, targetSubclass),
      ),
    ];
  }

  static List<String> _withUniqueStrings(
    List<String> existing,
    List<String> additions,
  ) {
    if (additions.isEmpty) return existing;
    final result = List<String>.from(existing);
    final seen = {for (final value in result) value.toLowerCase()};
    for (final value in additions) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed.toLowerCase())) result.add(trimmed);
    }
    return result;
  }

  static KnownSpell _withTargetSpellSource(
    KnownSpell spell,
    LevelUpResult result,
    String? targetSubclass,
  ) {
    return spell.copyWith(
      sourceType: spell.sourceType.isEmpty || spell.sourceType == 'manual'
          ? 'class'
          : spell.sourceType,
      sourceClass: _emptyToNull(spell.sourceClass) ?? result.targetClassName,
      sourceSubclass: _emptyToNull(spell.sourceSubclass) ?? targetSubclass,
      sourceClassEntryId:
          _emptyToNull(spell.sourceClassEntryId) ?? result.targetClassEntryId,
    );
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }
}
