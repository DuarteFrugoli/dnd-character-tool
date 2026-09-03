import '../../character_progression/character_progression.dart';
import '../../constants/armor_class.dart';
import '../../constants/level_up_rules.dart';
import '../../feature_choice_engine.dart';
import '../../models/models.dart';
import '../character_migration.dart';
import 'prepare_multiclass_structure_migration.dart';
import 'sync_multiclass_spell_slots_migration.dart';
import 'sync_spell_slots_and_armor_class_migration.dart';

class NormalizeMulticlassStateMigration extends CharacterMigration {
  const NormalizeMulticlassStateMigration();

  @override
  int get targetVersion => 9;

  @override
  String get id => 'normalize_multiclass_state';

  @override
  String get title => 'Normalize multiclass state';

  @override
  String get description =>
      'Synchronizes class mirrors, hit dice, origins, slots, and armor class.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext _,
  ) {
    final changes = <CharacterMigrationChange>[];
    final classes = _normalizeClassEntries(character);
    final startingClass = CharacterProgressionEngine.startingClassEntry(
      classes,
    );
    final totalLevel = CharacterProgressionEngine.totalLevelFor(classes);
    final hitDicePools = _normalizeHitDicePools(character, classes);
    final spells = character.spells
        .map((spell) => _normalizeSpell(spell, classes, startingClass))
        .toList();
    final extraFeatures = character.extraFeatures
        .map((feature) => _normalizeExtraFeature(feature, classes))
        .toList();
    final featureChoices = character.featureChoices
        .map(
          (choice) => _normalizeFeatureChoice(choice, classes, startingClass),
        )
        .toList();
    final expectedProficiency =
        CharacterProgressionEngine.proficiencyBonusForTotalLevel(totalLevel);

    final structureChanged =
        character.characterClass != startingClass.className ||
        character.subclass != startingClass.subclassName ||
        character.level != totalLevel ||
        character.proficiencyBonus != expectedProficiency ||
        !_sameClassEntries(character.classes, classes) ||
        !_sameHitDicePools(character.hitDicePools, hitDicePools) ||
        !_sameSpells(character.spells, spells) ||
        !_sameExtraFeatures(character.extraFeatures, extraFeatures) ||
        !_sameFeatureChoices(character.featureChoices, featureChoices);

    var updated = character.copyWith(
      characterClass: startingClass.className,
      subclass: startingClass.subclassName,
      clearSubclass: startingClass.subclassName == null,
      level: totalLevel,
      classes: classes,
      proficiencyBonus: expectedProficiency,
      hitDicePools: hitDicePools,
      spells: spells,
      extraFeatures: extraFeatures,
      featureChoices: featureChoices,
    );
    if (structureChanged) {
      changes.add(
        const CharacterMigrationChange(
          code: PrepareMulticlassStructureMigration.changeCode,
          count: 1,
        ),
      );
    }

    final synced = CharacterProgressionEngine.syncSpellcastingSlotsFor(updated);
    if (!_sameSlots(updated.spellSlots, synced.spellSlots)) {
      changes.add(
        const CharacterMigrationChange(
          code: SyncMulticlassSpellSlotsMigration.standardSlotsChangeCode,
          count: 1,
        ),
      );
    }
    if (!_sameSlots(updated.pactMagicSlots, synced.pactMagicSlots)) {
      changes.add(
        const CharacterMigrationChange(
          code: SyncMulticlassSpellSlotsMigration.pactMagicSlotsChangeCode,
          count: 1,
        ),
      );
    }
    updated = synced;

    final armorClass = calcArmorClass(updated);
    if (updated.armorClass != armorClass) {
      changes.add(
        const CharacterMigrationChange(
          code: SyncSpellSlotsAndArmorClassMigration.armorClassChangeCode,
          count: 1,
        ),
      );
      updated = updated.copyWith(armorClass: armorClass);
    }

    return CharacterMigrationResult(character: updated, changes: changes);
  }

  List<CharacterClassEntry> _normalizeClassEntries(Character character) {
    final normalized = <CharacterClassEntry>[];
    final usedIds = <String>{};
    final entries = character.classEntries;
    final startingIndex = entries.indexWhere((entry) => entry.isStartingClass);
    final effectiveStartingIndex = startingIndex < 0 ? 0 : startingIndex;

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final className = entry.className.trim().isNotEmpty
          ? entry.className.trim()
          : character.characterClass;
      final id = _uniqueClassEntryId(
        baseId: entry.id,
        className: className,
        index: i,
        usedIds: usedIds,
      );
      normalized.add(
        CharacterClassEntry(
          id: id,
          className: className,
          subclassName: entry.subclassName,
          level: entry.level.clamp(1, 20).toInt(),
          isStartingClass: i == effectiveStartingIndex,
        ),
      );
    }

    return normalized;
  }

  String _uniqueClassEntryId({
    required String baseId,
    required String className,
    required int index,
    required Set<String> usedIds,
  }) {
    final trimmed = baseId.trim();
    final fallback = className.trim().toLowerCase().replaceAll(' ', '_');
    final seed = trimmed.isNotEmpty
        ? trimmed
        : (fallback.isNotEmpty ? fallback : 'class_${index + 1}');
    var candidate = seed;
    var suffix = 2;
    while (usedIds.contains(candidate)) {
      candidate = '${seed}_$suffix';
      suffix++;
    }
    usedIds.add(candidate);
    return candidate;
  }

  List<CharacterHitDiePool> _normalizeHitDicePools(
    Character character,
    List<CharacterClassEntry> classes,
  ) {
    final pools = character.hitDicePools;
    final usedPoolIndexes = <int>{};
    return [
      for (final entry in classes)
        _hitDiePoolForClass(character, entry, pools, usedPoolIndexes),
    ];
  }

  CharacterHitDiePool _hitDiePoolForClass(
    Character character,
    CharacterClassEntry entry,
    List<CharacterHitDiePool> pools,
    Set<int> usedPoolIndexes,
  ) {
    final index = _poolIndexForClass(entry, pools, usedPoolIndexes);
    final existing = index == null ? null : pools[index];
    if (index != null) usedPoolIndexes.add(index);
    final total = entry.level.clamp(1, 20).toInt();
    final used =
        existing?.used ?? (pools.isEmpty ? character.totalHitDiceUsed : 0);
    return CharacterHitDiePool(
      dieSize: levelUpHitDie(entry.className),
      total: total,
      used: used.clamp(0, total).toInt(),
      sourceClass: entry.className,
      sourceClassEntryId: entry.id,
    );
  }

  int? _poolIndexForClass(
    CharacterClassEntry entry,
    List<CharacterHitDiePool> pools,
    Set<int> usedPoolIndexes,
  ) {
    for (var i = 0; i < pools.length; i++) {
      if (usedPoolIndexes.contains(i)) continue;
      if (pools[i].sourceClassEntryId == entry.id) return i;
    }
    for (var i = 0; i < pools.length; i++) {
      if (usedPoolIndexes.contains(i)) continue;
      if (pools[i].sourceClass?.toLowerCase() ==
          entry.className.toLowerCase()) {
        return i;
      }
    }
    return null;
  }

  KnownSpell _normalizeSpell(
    KnownSpell spell,
    List<CharacterClassEntry> classes,
    CharacterClassEntry startingClass,
  ) {
    final hasNoOrigin =
        spell.sourceType == 'manual' &&
        spell.sourceClass == null &&
        spell.sourceClassEntryId == null;
    final entry = _entryForSource(
      classes: classes,
      sourceClassEntryId: spell.sourceClassEntryId,
      sourceClass: spell.sourceClass,
      sourceSubclass: spell.sourceSubclass,
    );
    final sourceEntry = hasNoOrigin ? startingClass : entry;
    if (sourceEntry == null) return spell;
    final shouldTreatAsClassSpell =
        hasNoOrigin ||
        (spell.sourceType == 'manual' && spell.sourceClass != null);
    return spell.copyWith(
      sourceType: shouldTreatAsClassSpell ? 'class' : spell.sourceType,
      sourceClass: spell.sourceClass ?? sourceEntry.className,
      sourceSubclass: spell.sourceSubclass ?? sourceEntry.subclassName,
      sourceClassEntryId: sourceEntry.id,
    );
  }

  CharacterExtraFeature _normalizeExtraFeature(
    CharacterExtraFeature feature,
    List<CharacterClassEntry> classes,
  ) {
    if (feature.effectiveSourceType == FeatureChoiceSourceType.feat ||
        feature.sourceClass == 'Feat') {
      return feature.copyWith(
        sourceType: FeatureChoiceSourceType.feat,
        sourceFeature: feature.sourceFeature ?? feature.name,
      );
    }

    final entry = _entryForSource(
      classes: classes,
      sourceClassEntryId: feature.sourceClassEntryId,
      sourceClass: feature.sourceClass,
      sourceSubclass: feature.sourceSubclass,
    );
    if (entry == null) {
      return feature.copyWith(
        sourceFeature: feature.sourceFeature ?? feature.name,
      );
    }

    final isSubclassFeature =
        feature.effectiveSourceType ==
            FeatureChoiceSourceType.subclassFeature ||
        (entry.subclassName != null &&
            feature.sourceClass == entry.subclassName);
    return feature.copyWith(
      sourceClass: entry.className,
      sourceType: isSubclassFeature
          ? FeatureChoiceSourceType.subclassFeature
          : FeatureChoiceSourceType.classFeature,
      sourceSubclass: isSubclassFeature
          ? entry.subclassName
          : feature.sourceSubclass,
      sourceFeature: feature.sourceFeature ?? feature.name,
      sourceClassEntryId: entry.id,
    );
  }

  CharacterFeatureChoice _normalizeFeatureChoice(
    CharacterFeatureChoice choice,
    List<CharacterClassEntry> classes,
    CharacterClassEntry startingClass,
  ) {
    if (choice.sourceType != FeatureChoiceSourceType.classFeature &&
        choice.sourceType != FeatureChoiceSourceType.subclassFeature) {
      return choice;
    }

    final entry =
        _entryForSource(
          classes: classes,
          sourceClassEntryId: choice.sourceClassEntryId,
          sourceClass: choice.sourceClass,
          sourceSubclass: choice.sourceSubclass,
        ) ??
        startingClass;
    return CharacterFeatureChoice(
      sourceType: choice.sourceType,
      sourceClass: entry.className,
      sourceClassEntryId: entry.id,
      sourceSubclass:
          choice.sourceType == FeatureChoiceSourceType.subclassFeature
          ? (choice.sourceSubclass ?? entry.subclassName)
          : choice.sourceSubclass,
      sourceName: choice.sourceName,
      featureName: choice.featureName,
      choiceId: choice.choiceId,
      values: choice.values,
    );
  }

  CharacterClassEntry? _entryForSource({
    required List<CharacterClassEntry> classes,
    String? sourceClassEntryId,
    String? sourceClass,
    String? sourceSubclass,
  }) {
    if (sourceClassEntryId != null) {
      for (final entry in classes) {
        if (entry.id == sourceClassEntryId) return entry;
      }
    }
    final className = sourceClass?.toLowerCase();
    if (className != null && className.isNotEmpty) {
      for (final entry in classes) {
        if (entry.className.toLowerCase() == className) return entry;
      }
      for (final entry in classes) {
        if (entry.subclassName?.toLowerCase() == className) return entry;
      }
    }
    final subclassName = sourceSubclass?.toLowerCase();
    if (subclassName != null && subclassName.isNotEmpty) {
      for (final entry in classes) {
        if (entry.subclassName?.toLowerCase() == subclassName) return entry;
      }
    }
    return null;
  }

  bool _sameClassEntries(
    List<CharacterClassEntry> a,
    List<CharacterClassEntry> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].className != b[i].className ||
          a[i].subclassName != b[i].subclassName ||
          a[i].level != b[i].level ||
          a[i].isStartingClass != b[i].isStartingClass) {
        return false;
      }
    }
    return true;
  }

  bool _sameHitDicePools(
    List<CharacterHitDiePool> a,
    List<CharacterHitDiePool> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].dieSize != b[i].dieSize ||
          a[i].total != b[i].total ||
          a[i].used != b[i].used ||
          a[i].sourceClass != b[i].sourceClass ||
          a[i].sourceClassEntryId != b[i].sourceClassEntryId) {
        return false;
      }
    }
    return true;
  }

  bool _sameSpells(List<KnownSpell> a, List<KnownSpell> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].name != b[i].name ||
          a[i].level != b[i].level ||
          a[i].isPrepared != b[i].isPrepared ||
          a[i].isAlwaysPrepared != b[i].isAlwaysPrepared ||
          a[i].sourceType != b[i].sourceType ||
          a[i].sourceClass != b[i].sourceClass ||
          a[i].sourceSubclass != b[i].sourceSubclass ||
          a[i].sourceFeature != b[i].sourceFeature ||
          a[i].sourceClassEntryId != b[i].sourceClassEntryId) {
        return false;
      }
    }
    return true;
  }

  bool _sameExtraFeatures(
    List<CharacterExtraFeature> a,
    List<CharacterExtraFeature> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].sourceClass != b[i].sourceClass ||
          a[i].sourceType != b[i].sourceType ||
          a[i].sourceSubclass != b[i].sourceSubclass ||
          a[i].sourceFeature != b[i].sourceFeature ||
          a[i].sourceClassEntryId != b[i].sourceClassEntryId ||
          a[i].name != b[i].name ||
          a[i].level != b[i].level ||
          a[i].type != b[i].type ||
          a[i].description != b[i].description) {
        return false;
      }
    }
    return true;
  }

  bool _sameFeatureChoices(
    List<CharacterFeatureChoice> a,
    List<CharacterFeatureChoice> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].sourceType != b[i].sourceType ||
          a[i].sourceClass != b[i].sourceClass ||
          a[i].sourceClassEntryId != b[i].sourceClassEntryId ||
          a[i].sourceSubclass != b[i].sourceSubclass ||
          a[i].sourceName != b[i].sourceName ||
          a[i].featureName != b[i].featureName ||
          a[i].choiceId != b[i].choiceId ||
          !_sameStringList(a[i].values, b[i].values)) {
        return false;
      }
    }
    return true;
  }

  bool _sameSlots(SpellSlots a, SpellSlots b) {
    return _sameIntList(a.total, b.total) && _sameIntList(a.used, b.used);
  }

  bool _sameIntList(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _sameStringList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
