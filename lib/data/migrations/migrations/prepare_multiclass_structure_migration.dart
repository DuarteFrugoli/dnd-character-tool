import '../../constants/level_up_rules.dart';
import '../../feature_choice_engine.dart';
import '../../models/models.dart';
import '../character_migration.dart';

class PrepareMulticlassStructureMigration extends CharacterMigration {
  const PrepareMulticlassStructureMigration();

  static const changeCode = 'multiclass_structure_prepared';
  static const primaryClassEntryId = 'primary';

  @override
  int get targetVersion => 7;

  @override
  String get id => 'prepare_multiclass_structure';

  @override
  String get title => 'Prepare multiclass structure';

  @override
  String get description =>
      'Adds class entries, spell origins, and hit die pools.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext _,
  ) {
    final primaryEntry = _primaryClassEntry(character);
    final classes = character.classes.isEmpty
        ? [primaryEntry]
        : _normalizeClassEntries(character.classes, character);
    final hitDicePools = character.hitDicePools.isEmpty
        ? [_primaryHitDiePool(character, primaryEntry)]
        : _normalizeHitDicePools(character.hitDicePools);
    final spells = character.spells
        .map((spell) => _normalizeSpell(spell, character, primaryEntry))
        .toList();
    final extraFeatures = character.extraFeatures
        .map(
          (feature) => _normalizeExtraFeature(feature, character, primaryEntry),
        )
        .toList();
    final featureChoices = character.featureChoices
        .map((choice) => _normalizeFeatureChoice(choice, primaryEntry))
        .toList();

    return CharacterMigrationResult(
      character: character.copyWith(
        classes: classes,
        hitDicePools: hitDicePools,
        spells: spells,
        extraFeatures: extraFeatures,
        featureChoices: featureChoices,
      ),
      changes: const [CharacterMigrationChange(code: changeCode, count: 1)],
    );
  }

  CharacterClassEntry _primaryClassEntry(Character character) {
    return CharacterClassEntry(
      id: primaryClassEntryId,
      className: character.characterClass,
      subclassName: character.subclass,
      level: character.level,
      isStartingClass: true,
    );
  }

  List<CharacterClassEntry> _normalizeClassEntries(
    List<CharacterClassEntry> entries,
    Character character,
  ) {
    if (entries.isEmpty) return [_primaryClassEntry(character)];
    final startingIndex = entries.indexWhere((entry) => entry.isStartingClass);
    final effectiveStartingIndex = startingIndex < 0 ? 0 : startingIndex;
    final normalized = <CharacterClassEntry>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      normalized.add(
        entry.copyWith(
          id: entry.id.isEmpty ? 'class_${i + 1}' : entry.id,
          level: entry.level.clamp(1, 20).toInt(),
          isStartingClass: i == effectiveStartingIndex,
        ),
      );
    }
    return normalized;
  }

  CharacterHitDiePool _primaryHitDiePool(
    Character character,
    CharacterClassEntry primaryEntry,
  ) {
    return CharacterHitDiePool(
      dieSize: levelUpHitDie(character.characterClass),
      total: character.level,
      used: character.hitPoints.hitDiceUsed.clamp(0, character.level).toInt(),
      sourceClass: character.characterClass,
      sourceClassEntryId: primaryEntry.id,
    );
  }

  List<CharacterHitDiePool> _normalizeHitDicePools(
    List<CharacterHitDiePool> pools,
  ) {
    final normalized = <CharacterHitDiePool>[];
    for (final pool in pools) {
      final total = pool.total.clamp(0, 20).toInt();
      normalized.add(
        pool.copyWith(
          dieSize: pool.dieSize.clamp(4, 20).toInt(),
          total: total,
          used: pool.used.clamp(0, total).toInt(),
        ),
      );
    }
    return normalized;
  }

  KnownSpell _normalizeSpell(
    KnownSpell spell,
    Character character,
    CharacterClassEntry primaryEntry,
  ) {
    if (spell.sourceClassEntryId != null || spell.sourceClass != null) {
      return spell;
    }
    return spell.copyWith(
      sourceType: 'class',
      sourceClass: character.characterClass,
      sourceSubclass: character.subclass,
      sourceClassEntryId: primaryEntry.id,
    );
  }

  CharacterExtraFeature _normalizeExtraFeature(
    CharacterExtraFeature feature,
    Character character,
    CharacterClassEntry primaryEntry,
  ) {
    if (feature.sourceClassEntryId != null && feature.sourceFeature != null) {
      return feature;
    }
    if (feature.effectiveSourceType == FeatureChoiceSourceType.feat ||
        feature.sourceClass == 'Feat') {
      return feature.copyWith(
        sourceType: FeatureChoiceSourceType.feat,
        sourceFeature: feature.name,
      );
    }
    if (feature.sourceClass == character.characterClass) {
      return feature.copyWith(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceFeature: feature.name,
        sourceClassEntryId: primaryEntry.id,
      );
    }
    if (feature.sourceClass == character.subclass) {
      return feature.copyWith(
        sourceType: FeatureChoiceSourceType.subclassFeature,
        sourceSubclass: feature.sourceClass,
        sourceFeature: feature.name,
        sourceClassEntryId: primaryEntry.id,
      );
    }
    return feature.copyWith(sourceFeature: feature.name);
  }

  CharacterFeatureChoice _normalizeFeatureChoice(
    CharacterFeatureChoice choice,
    CharacterClassEntry primaryEntry,
  ) {
    if (choice.sourceClassEntryId != null) return choice;
    if (choice.sourceType == FeatureChoiceSourceType.classFeature ||
        choice.sourceType == FeatureChoiceSourceType.subclassFeature) {
      return choice.copyWith(sourceClassEntryId: primaryEntry.id);
    }
    return choice;
  }
}
