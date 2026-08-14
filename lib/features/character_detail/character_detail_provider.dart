import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/character_progression/character_progression.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/feature_usage_engine.dart';
import '../../data/json_helpers.dart';
import '../../data/constants/armor_class.dart';
import '../../data/constants/level_up_rules.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/inventory/inventory_operations.dart' as inventory_ops;
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';
import '../character_list/character_list_provider.dart';

final characterDetailProvider =
    AsyncNotifierProvider.family<CharacterDetailNotifier, Character, String>(
      CharacterDetailNotifier.new,
    );

class CharacterDetailNotifier extends FamilyAsyncNotifier<Character, String> {
  @override
  Future<Character> build(String id) async {
    // Stay in sync with updates that come from the character list
    // (e.g. image changes made from the list screen).
    ref.listen<AsyncValue<List<Character>>>(characterListProvider, (_, next) {
      final fromList = next.valueOrNull?.firstWhereOrNull((c) => c.id == id);
      if (fromList != null) state = AsyncData(fromList);
    });

    final repo = ref.read(characterRepositoryProvider);
    final c = await repo.getById(id);
    if (c == null) throw Exception('Character not found');
    return c;
  }

  Future<void> _save(Character updated) async {
    // Optimistic update: ensures concurrent calls read the latest state
    // instead of the stale snapshot that was current when they were dispatched.
    state = AsyncData(updated);
    final saved = await ref.read(characterRepositoryProvider).save(updated);
    state = AsyncData(saved);
    if (ref.exists(characterListProvider)) {
      await ref.read(characterListProvider.notifier).updateSingle(saved);
    }
  }

  /// Restore a previously snapshotted character, discarding all edit changes.
  Future<void> revertTo(Character snapshot) => _save(snapshot);

  Future<void> adjustHp(int delta) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final hp = c.hitPoints;
    int newTemp = hp.temporary;
    int newCurrent = hp.current;
    if (delta < 0) {
      // Damage: drain temp HP first
      final damage = -delta;
      if (newTemp >= damage) {
        newTemp -= damage;
      } else {
        newCurrent = (newCurrent - (damage - newTemp)).clamp(0, hp.maximum);
        newTemp = 0;
      }
    } else {
      // Heal: only affects real HP
      newCurrent = (newCurrent + delta).clamp(0, hp.maximum);
    }
    // When recovering from 0 HP, reset death saves
    final resetDeathSaves = hp.isDead && (newCurrent > 0 || newTemp > 0);
    await _save(
      c.copyWith(
        hitPoints: hp.copyWith(
          current: newCurrent,
          temporary: newTemp,
          deathSaveSuccesses: resetDeathSaves ? 0 : null,
          deathSaveFailures: resetDeathSaves ? 0 : null,
        ),
      ),
    );
  }

  Future<void> updateDeathSaves({
    required int successes,
    required int failures,
  }) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(
        hitPoints: c.hitPoints.copyWith(
          deathSaveSuccesses: successes.clamp(0, 3),
          deathSaveFailures: failures.clamp(0, 3),
        ),
      ),
    );
  }

  Future<void> setTemporaryHp(int temp) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(
        hitPoints: c.hitPoints.copyWith(temporary: temp.clamp(0, 9999)),
      ),
    );
  }

  Future<void> useSpellSlot(int level) async {
    if (level < 1 || level > 9) return;
    final c = state.valueOrNull;
    if (c == null) return;
    final slots = c.spellSlots;
    final idx = level - 1;
    if (slots.used[idx] >= slots.total[idx]) return;
    final newUsed = List<int>.from(slots.used);
    newUsed[idx]++;
    await _save(c.copyWith(spellSlots: slots.copyWith(used: newUsed)));
  }

  Future<void> restoreSpellSlot(int level) async {
    if (level < 1 || level > 9) return;
    final c = state.valueOrNull;
    if (c == null) return;
    final slots = c.spellSlots;
    final idx = level - 1;
    if (slots.used[idx] <= 0) return;
    final newUsed = List<int>.from(slots.used);
    newUsed[idx]--;
    await _save(c.copyWith(spellSlots: slots.copyWith(used: newUsed)));
  }

  Future<void> usePactMagicSlot(int level) async {
    if (level < 1 || level > 9) return;
    final c = state.valueOrNull;
    if (c == null) return;
    final slots = c.pactMagicSlots;
    final idx = level - 1;
    if (slots.used[idx] >= slots.total[idx]) return;
    final newUsed = List<int>.from(slots.used);
    newUsed[idx]++;
    await _save(c.copyWith(pactMagicSlots: slots.copyWith(used: newUsed)));
  }

  Future<void> restorePactMagicSlot(int level) async {
    if (level < 1 || level > 9) return;
    final c = state.valueOrNull;
    if (c == null) return;
    final slots = c.pactMagicSlots;
    final idx = level - 1;
    if (slots.used[idx] <= 0) return;
    final newUsed = List<int>.from(slots.used);
    newUsed[idx]--;
    await _save(c.copyWith(pactMagicSlots: slots.copyWith(used: newUsed)));
  }

  Future<void> addSpell(KnownSpell spell) async {
    final c = state.valueOrNull;
    if (c == null) return;
    if (c.spells.any((s) => s.name == spell.name)) return;
    await _save(c.copyWith(spells: [...c.spells, spell]));
  }

  Future<void> removeSpell(String name) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(spells: c.spells.where((s) => s.name != name).toList()),
    );
  }

  Future<void> togglePrepared(String name) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.spells.map((s) {
      if (s.name == name && !s.isAlwaysPrepared) {
        return s.copyWith(isPrepared: !s.isPrepared);
      }
      return s;
    }).toList();
    await _save(c.copyWith(spells: updated));
  }

  Future<void> longRest() async {
    final c = state.valueOrNull;
    if (c == null) return;
    // Recover ceil(level / 2) hit dice on a long rest (PHB rules)
    final hdRecovered = (c.totalLevel / 2).ceil();
    final newHdUsed = (c.totalHitDiceUsed - hdRecovered)
        .clamp(0, c.totalHitDice)
        .toInt();
    final newHitDicePools = _recoverHitDicePools(c.hitDicePools, hdRecovered);
    final featureResources = await _featureResourcesAfterRest(
      c,
      FeatureUsageRest.longRest,
    );
    await _save(
      c.copyWith(
        hitPoints: c.hitPoints.copyWith(
          current: c.hitPoints.maximum,
          temporary: 0,
          hitDiceUsed: newHdUsed,
        ),
        hitDicePools: newHitDicePools,
        spellSlots: c.spellSlots.copyWith(used: List.filled(9, 0)),
        pactMagicSlots: c.pactMagicSlots.copyWith(used: List.filled(9, 0)),
        innateSpells: c.innateSpells
            .map((s) => s.copyWith(usedToday: 0))
            .toList(),
        featureResources: featureResources,
        concentrationSpell: null,
      ),
    );
  }

  Future<void> setConcentration(String? spellName) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(concentrationSpell: spellName));
  }

  Future<void> shortRest({
    required List<int> hitDiceSpentByPool,
    required int hpGained,
  }) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final clampedHp = hpGained
        .clamp(0, c.hitPoints.maximum - c.hitPoints.current)
        .toInt();
    final newHitDicePools = _spendHitDicePoolsByIndex(
      c.hitDicePools,
      hitDiceSpentByPool,
    );
    final hdSpent = _hitDiceSpent(c.hitDicePools, hitDiceSpentByPool);
    final newHdUsed = newHitDicePools.isEmpty
        ? (c.totalHitDiceUsed + hdSpent).clamp(0, c.totalHitDice).toInt()
        : newHitDicePools.fold<int>(0, (sum, pool) => sum + pool.used);
    var rested = c.copyWith(
      hitPoints: c.hitPoints.copyWith(
        current: c.hitPoints.current + clampedHp,
        hitDiceUsed: newHdUsed,
      ),
      hitDicePools: newHitDicePools,
    );
    rested = CharacterProgressionEngine.syncSpellcastingSlotsFor(rested)
        .copyWith(
          pactMagicSlots:
              CharacterProgressionEngine.pactMagicSlotsAfterShortRest(rested),
        );
    final featureResources = await _featureResourcesAfterRest(
      rested,
      FeatureUsageRest.shortRest,
    );
    await _save(rested.copyWith(featureResources: featureResources));
  }

  Future<void> adjustFeatureResource(String resourceId, int delta) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final binding = await _activeFeatureUsageBinding(c, resourceId);
    if (binding == null) return;
    final resource = binding.resource;
    final max = FeatureUsageEngine.maxFor(
      resource,
      c,
      usageContext: binding.usageContext,
    );
    if (max == null) return;
    final current = FeatureUsageEngine.currentFor(c, resource, max) ?? max;
    final next = (current + delta).clamp(0, max).toInt();
    if (next == current) return;
    await _save(
      c.copyWith(featureResources: {...c.featureResources, resourceId: next}),
    );
  }

  Future<Map<String, int>> _featureResourcesAfterRest(
    Character c,
    FeatureUsageRest rest,
  ) async {
    final result = Map<String, int>.from(c.featureResources);
    final bindings = await _activeFeatureUsageBindings(c);
    final activeResourceIds = bindings
        .map((binding) => binding.resource.id)
        .toSet();
    result.removeWhere((id, _) => !activeResourceIds.contains(id));
    for (final binding in bindings) {
      final resource = binding.resource;
      final max = FeatureUsageEngine.maxFor(
        resource,
        c,
        usageContext: binding.usageContext,
      );
      if (max == null) {
        result.remove(resource.id);
        continue;
      }
      final recharge = FeatureUsageEngine.rechargeFor(
        resource,
        c,
        usageContext: binding.usageContext,
      );
      if (FeatureUsageEngine.restoresOn(recharge, rest)) {
        result[resource.id] = max;
        continue;
      }
      if (rest == FeatureUsageRest.shortRest &&
          resource.id == 'sorcery_points' &&
          binding.usageContext.sourceClass?.toLowerCase() == 'sorcerer' &&
          binding.usageContext.effectiveClassLevel >= 20) {
        final current = FeatureUsageEngine.currentFor(c, resource, max) ?? max;
        result[resource.id] = (current + 4).clamp(0, max).toInt();
        continue;
      }
      final current = result[resource.id];
      if (current != null) {
        result[resource.id] = current.clamp(0, max).toInt();
      }
    }
    return result;
  }

  Future<FeatureUsageBinding?> _activeFeatureUsageBinding(
    Character c,
    String resourceId,
  ) async {
    final bindings = await _activeFeatureUsageBindings(c);
    return bindings.firstWhereOrNull(
      (binding) => binding.resource.id == resourceId,
    );
  }

  Future<List<FeatureUsageBinding>> _activeFeatureUsageBindings(
    Character c,
  ) async {
    final srd = ref.read(srdDataSourceProvider);
    final catalog = await srd.getFeatureUsageCatalog();
    final classFeatureSets = <FeatureUsageFeatureSet>[];
    for (final classEntry in c.classEntries) {
      final classFeatures = (await srd.getClassFeatures(
        classEntry.className,
      )).where((f) => f.level <= classEntry.level).toList();
      final subclassName = classEntry.subclassName ?? '';
      final subclassFeatures = subclassName.isEmpty
          ? <SrdClassFeature>[]
          : (await srd.getSubclassFeatures(
              classEntry.className,
              subclassName,
            )).where((f) => f.level <= classEntry.level).toList();
      classFeatureSets.add(
        FeatureUsageFeatureSet(
          classEntry: classEntry,
          classFeatures: classFeatures,
          subclassFeatures: subclassFeatures,
        ),
      );
    }
    final races = await srd.getRaces();
    final race = races.where((r) => r.name == c.race).firstOrNull;
    final subrace = race?.subraces
        .where((s) => s.name == c.subrace)
        .firstOrNull;
    final traits = <String>[...?race?.traits, ...?subrace?.traits];
    return FeatureUsageEngine.activeResourceBindings(
      character: c,
      catalog: catalog,
      classFeatureSets: classFeatureSets,
      raceTraits: traits,
    ).toList();
  }

  /// Auto-populates [innateSpells] from the SRD race data if the character has
  /// racial innate spells but none are stored yet.
  Future<void> syncInnateSpells() async {
    final c = state.valueOrNull;
    if (c == null) return;
    if (c.innateSpells.isNotEmpty) return;
    final races = await ref.read(srdDataSourceProvider).getRaces();
    // Check main race
    final srdRace = races.where((r) => r.name == c.race).firstOrNull;
    final raceDefs = srdRace?.innateSpells ?? [];
    // Check subrace
    final srdSubrace = srdRace?.subraces
        .where((s) => s.name == c.subrace)
        .firstOrNull;
    final subraceDefs = srdSubrace?.innateSpells ?? [];
    final allDefs = [...raceDefs, ...subraceDefs];
    if (allDefs.isEmpty) return;
    await _save(
      c.copyWith(
        innateSpells: allDefs
            .map((d) => InnateSpell(name: d.name, usesPerDay: d.usesPerDay))
            .toList(),
      ),
    );
  }

  /// Uses one charge of an innate spell (no-op if at-will or already exhausted).
  Future<void> useInnateSpell(String name) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.innateSpells.map((s) {
      if (s.name == name && s.canUse && !s.isAtWill) {
        return s.copyWith(usedToday: s.usedToday + 1);
      }
      return s;
    }).toList();
    await _save(c.copyWith(innateSpells: updated));
  }

  Future<void> updateName(
    String name, {
    String fallback = 'Unnamed Hero',
  }) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final trimmed = name.trim();
    await _save(c.copyWith(name: trimmed.isEmpty ? fallback : trimmed));
  }

  /// Applies all decisions from the Level Up Wizard atomically.
  Future<void> levelUp(LevelUpResult result) async {
    final c = state.valueOrNull;
    if (c == null) return;

    var updated = CharacterProgressionEngine.applyLevelUp(c, result);

    if (c.xpTrackingEnabled) {
      updated = updated.copyWith(
        experiencePoints: levelToMinXp(updated.totalLevel),
      );
    }

    await _save(updated);

    if (result.subclassChosen != null) {
      await syncInnateSpells();
    }
  }

  /// Resets class progression to a new level 1 starting class.
  Future<void> resetLevels(CharacterLevelResetResult result) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(CharacterLevelResetEngine.resetToLevelOne(c, result));
  }

  /// Saves a character rebuilt by the level reset flow after all choices are done.
  Future<void> saveRebuiltLevels(
    Character character, {
    bool syncInnateSpellsAfterSave = false,
  }) async {
    await _save(character);
    if (syncInnateSpellsAfterSave) {
      await syncInnateSpells();
    }
  }

  Future<void> updateSubclass(String subclassName) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updatedClasses = [
      for (final entry in c.classEntries)
        entry.id == c.primaryClass.id
            ? entry.copyWith(subclassName: subclassName)
            : entry,
    ];
    final updated = c.copyWith(subclass: subclassName, classes: updatedClasses);
    await _save(updated.copyWith(armorClass: calcArmorClass(updated)));
  }

  Future<void> updateBackground(String v) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(background: v.trim()));
  }

  Future<void> updateAlignment(String v) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(alignment: v.trim()));
  }

  Future<void> updatePlayerName(String v) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(playerName: v.trim()));
  }

  Future<void> updateLanguages(List<String> languages) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(languages: languages));
  }

  Future<void> updateHpMax(int max) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final clamped = max.clamp(1, 9999);
    await _save(
      c.copyWith(
        hitPoints: c.hitPoints.copyWith(
          maximum: clamped,
          current: c.hitPoints.current.clamp(0, clamped),
        ),
      ),
    );
  }

  Future<void> updateSpeed(int speed) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(speed: speed.clamp(0, 999)));
  }

  /// Atomic save for all stats-tab edit-mode fields.
  /// Replaces three separate saves that previously ran concurrently and could
  /// corrupt the character file when writes interleaved.
  Future<void> saveStatsEdit({
    required int? hpMax,
    required int? speed,
    required int? xp,
  }) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final clampedHpMax = (hpMax ?? c.hitPoints.maximum).clamp(1, 9999);
    await _save(
      c.copyWith(
        hitPoints: hpMax != null
            ? c.hitPoints.copyWith(
                maximum: clampedHpMax,
                current: c.hitPoints.current.clamp(0, clampedHpMax),
              )
            : null,
        speed: speed?.clamp(0, 999),
        experiencePoints: xp?.clamp(0, 999999),
      ),
    );
  }

  Future<void> updateSavingThrows(List<String> proficiencies) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(savingThrowProficiencies: proficiencies));
  }

  Future<void> updateSkillProficiencies(
    List<String> profs,
    List<String> expertises,
  ) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(skillProficiencies: profs, skillExpertises: expertises),
    );
  }

  Future<void> updateDisabledFeatures(List<String> disabled) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.copyWith(disabledFeatures: disabled);
    await _save(updated.copyWith(armorClass: calcArmorClass(updated)));
  }

  Future<void> toggleDisabledSpell(String name) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final current = List<String>.from(c.disabledSpells);
    if (current.contains(name)) {
      current.remove(name);
    } else {
      current.add(name);
    }
    await _save(c.copyWith(disabledSpells: current));
  }

  Future<void> updateAbilityScore(String key, int value) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final clamped = value.clamp(1, 30);
    final updated = switch (key) {
      'strength' => c.abilityScores.copyWith(strength: clamped),
      'dexterity' => c.abilityScores.copyWith(dexterity: clamped),
      'constitution' => c.abilityScores.copyWith(constitution: clamped),
      'intelligence' => c.abilityScores.copyWith(intelligence: clamped),
      'wisdom' => c.abilityScores.copyWith(wisdom: clamped),
      'charisma' => c.abilityScores.copyWith(charisma: clamped),
      _ => c.abilityScores,
    };
    final newC = c.copyWith(abilityScores: updated);
    await _save(newC.copyWith(armorClass: calcArmorClass(newC)));
  }

  int _hitDiceSpent(List<CharacterHitDiePool> pools, List<int> spendByPool) {
    if (spendByPool.isEmpty) return 0;
    if (pools.isEmpty) {
      return spendByPool.fold<int>(
        0,
        (sum, count) => sum + count.clamp(0, 20).toInt(),
      );
    }
    var spent = 0;
    for (var i = 0; i < pools.length; i++) {
      final requested = i < spendByPool.length ? spendByPool[i] : 0;
      spent += requested.clamp(0, pools[i].remaining).toInt();
    }
    return spent;
  }

  List<CharacterHitDiePool> _spendHitDicePoolsByIndex(
    List<CharacterHitDiePool> pools,
    List<int> spendByPool,
  ) {
    if (pools.isEmpty || spendByPool.isEmpty) return pools;
    final updated = <CharacterHitDiePool>[];
    for (var i = 0; i < pools.length; i++) {
      final pool = pools[i];
      final requested = i < spendByPool.length ? spendByPool[i] : 0;
      final spend = requested.clamp(0, pool.remaining).toInt();
      updated.add(pool.copyWith(used: pool.used + spend));
    }
    return updated;
  }

  List<CharacterHitDiePool> _recoverHitDicePools(
    List<CharacterHitDiePool> pools,
    int count,
  ) {
    if (pools.isEmpty || count <= 0) return pools;
    var remaining = count;
    final updated = <CharacterHitDiePool>[];
    for (final pool in pools) {
      final recovered = remaining < pool.used ? remaining : pool.used;
      updated.add(pool.copyWith(used: pool.used - recovered));
      remaining -= recovered;
    }
    return updated;
  }

  // ── Extra Features (multiclasse / manual) ──────────────────────────────────

  Future<void> addExtraFeature(
    SrdClassFeature feature,
    String sourceClass,
  ) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final classEntry = c.classEntries.firstWhereOrNull(
      (entry) => entry.className == sourceClass,
    );
    final subclassEntry = c.classEntries.firstWhereOrNull(
      (entry) => entry.subclassName == sourceClass,
    );
    final resolvedSourceClass =
        classEntry?.className ?? subclassEntry?.className ?? sourceClass;
    final sourceSubclass = subclassEntry?.subclassName;
    final sourceClassEntryId = classEntry?.id ?? subclassEntry?.id;
    final sourceType = classEntry != null
        ? FeatureChoiceSourceType.classFeature
        : subclassEntry != null
        ? FeatureChoiceSourceType.subclassFeature
        : 'manual';

    final already = c.extraFeatures.any(
      (f) =>
          f.name == feature.name &&
          f.sourceClass == resolvedSourceClass &&
          f.sourceSubclass == sourceSubclass,
    );
    if (already) return;
    final extra = CharacterExtraFeature(
      sourceClass: resolvedSourceClass,
      sourceType: sourceType,
      sourceSubclass: sourceSubclass,
      sourceFeature: feature.name,
      sourceClassEntryId: sourceClassEntryId,
      name: feature.name,
      level: feature.level,
      type: feature.type,
      description: feature.description,
    );
    final updated = c.copyWith(extraFeatures: [...c.extraFeatures, extra]);
    await _save(updated.copyWith(armorClass: calcArmorClass(updated)));
  }

  Future<void> addFeat(SrdFeat feat) async {
    final c = state.valueOrNull;
    if (c == null) return;
    const sourceClass = 'Feat';
    if (c.extraFeatures.any(
      (f) => f.name == feat.name && f.sourceClass == sourceClass,
    )) {
      return;
    }
    final extra = CharacterExtraFeature(
      sourceClass: sourceClass,
      sourceType: FeatureChoiceSourceType.feat,
      sourceFeature: feat.name,
      name: feat.name,
      level: c.totalLevel,
      type: 'passive',
      description: feat.description,
    );
    final updated = c.copyWith(extraFeatures: [...c.extraFeatures, extra]);
    await _save(updated.copyWith(armorClass: calcArmorClass(updated)));
  }

  Future<void> updateFeatureChoices(
    List<CharacterFeatureChoice> choices,
  ) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(featureChoices: choices));
  }

  Future<void> upsertFeatureChoices(
    List<CharacterFeatureChoice> choices,
  ) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(
        featureChoices: FeatureChoiceEngine.upsertChoices(
          c.featureChoices,
          choices,
        ),
      ),
    );
  }

  Future<void> removeExtraFeature(String name, String sourceClass) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.extraFeatures
        .where((f) => !(f.name == name && f.sourceClass == sourceClass))
        .toList();
    final updatedChoices = c.featureChoices.where((choice) {
      if (sourceClass == 'Feat') {
        return !(choice.sourceType == FeatureChoiceSourceType.feat &&
            choice.sourceName == name);
      }
      return !(choice.sourceClass == sourceClass && choice.featureName == name);
    }).toList();
    final newC = c.copyWith(
      extraFeatures: updated,
      featureChoices: updatedChoices,
    );
    await _save(newC.copyWith(armorClass: calcArmorClass(newC)));
  }

  Future<void> addToolProficiency(String toolName) async {
    final c = state.valueOrNull;
    if (c == null) return;
    if (c.features.contains(toolName)) return;
    await _save(c.copyWith(features: [...c.features, toolName]));
  }

  Future<void> removeToolProficiency(String toolName) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(features: c.features.where((f) => f != toolName).toList()),
    );
  }

  // ── Inventário ─────────────────────────────────────────────────────────────

  Future<void> addEquipmentItem(EquipmentItem item) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(equipment: inventory_ops.addEquipmentItem(c.equipment, item)),
    );
  }

  Future<void> removeEquipmentItem(String id) async {
    await removeEquipmentQuantity(id, 1);
  }

  Future<void> removeEquipmentQuantity(
    String id,
    int amount, {
    inventory_ops.ContainerRemovalMode containerRemovalMode =
        inventory_ops.ContainerRemovalMode.moveContentsToInventory,
  }) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final idx = c.equipment.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    final removed = c.equipment[idx];
    final updated = inventory_ops.removeEquipmentQuantity(
      c.equipment,
      id,
      amount,
      containerRemovalMode: containerRemovalMode,
    );
    final newC = c.copyWith(equipment: updated);

    if (removed.itemType == ItemType.armor && removed.isEquipped) {
      await _save(newC.copyWith(armorClass: calcArmorClass(newC)));
    } else {
      await _save(newC);
    }
  }

  Future<void> toggleEquipped(String id, {bool forceArmorSwap = false}) async {
    final c = state.valueOrNull;
    if (c == null) return;

    final idx = c.equipment.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    final target = c.equipment[idx];
    final isBodyArmor = _isBodyArmor(target);
    final updated = inventory_ops.toggleEquipped(
      c.equipment,
      id,
      isBodyArmor: _isBodyArmor,
      forceArmorSwap: forceArmorSwap,
    );

    final newC = c.copyWith(equipment: updated);

    if (target.itemType == ItemType.armor || isBodyArmor) {
      await _save(newC.copyWith(armorClass: calcArmorClass(newC)));
    } else {
      await _save(newC);
    }
  }

  bool _isBodyArmor(EquipmentItem item) {
    if (item.itemType != ItemType.armor) return false;
    final props = item.properties;
    if (props == null) return false;
    if (readBool(props['isShield'])) return false;
    return props.containsKey('baseAC');
  }

  Future<void> moveItemToContainer(String itemId, String? containerId) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(
        equipment: inventory_ops.moveItemToContainer(
          c.equipment,
          itemId,
          containerId,
        ),
      ),
    );
  }

  Future<void> reorderEquipmentItems({
    required List<String> itemIds,
    required int oldIndex,
    required int newIndex,
  }) async {
    final c = state.valueOrNull;
    if (c == null || itemIds.length < 2) return;

    final reordered = inventory_ops.reorderEquipmentItems(
      equipment: c.equipment,
      itemIds: itemIds,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );

    await _save(c.copyWith(equipment: reordered));
  }

  Future<void> adjustItemQuantity(String id, int delta) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
      c.copyWith(
        equipment: inventory_ops.adjustItemQuantity(c.equipment, id, delta),
      ),
    );
  }

  Future<void> updateCurrency(Map<String, int> currency) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(currency: currency));
  }

  // ── Notes ───────────────────────────────────────────────────────────────────

  Future<void> addNote(CharacterNote note) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final ordered = _notesInDisplayOrder(c.notes);
    final sameGroup = [
      note.copyWith(sortOrder: 0),
      ...ordered.where((n) => n.isPinned == note.isPinned),
    ];
    final otherGroup = ordered.where((n) => n.isPinned != note.isPinned);
    final notes = note.isPinned
        ? [...sameGroup, ...otherGroup]
        : [...otherGroup, ...sameGroup];
    await _save(c.copyWith(notes: _normalizeNoteSortOrders(notes)));
  }

  Future<void> updateNote(CharacterNote updated) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final notes = c.notes.map((n) => n.id == updated.id ? updated : n).toList();
    await _save(
      c.copyWith(notes: _normalizeNoteSortOrders(_notesInDisplayOrder(notes))),
    );
  }

  Future<void> toggleNotePinned(String id) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final ordered = _notesInDisplayOrder(c.notes);
    final note = ordered.firstWhereOrNull((n) => n.id == id);
    if (note == null) return;

    final targetPinned = !note.isPinned;
    final targetSortOrder = ordered
        .where((n) => n.id != id && n.isPinned == targetPinned)
        .length;
    final notes = ordered
        .map(
          (n) => n.id == id
              ? n.copyWith(isPinned: targetPinned, sortOrder: targetSortOrder)
              : n,
        )
        .toList();
    await _save(
      c.copyWith(notes: _normalizeNoteSortOrders(_notesInDisplayOrder(notes))),
    );
  }

  Future<void> reorderNotes({
    required bool pinned,
    required int oldIndex,
    required int newIndex,
  }) async {
    final c = state.valueOrNull;
    if (c == null) return;

    final ordered = _notesInDisplayOrder(c.notes);
    final group = ordered.where((n) => n.isPinned == pinned).toList();
    if (oldIndex < 0 || oldIndex >= group.length) return;

    var insertIndex = newIndex;
    if (insertIndex > oldIndex) insertIndex--;
    insertIndex = insertIndex.clamp(0, group.length - 1).toInt();
    if (oldIndex == insertIndex) return;

    final moved = group.removeAt(oldIndex);
    group.insert(insertIndex, moved);

    final pinnedNotes = pinned
        ? group
        : ordered.where((n) => n.isPinned).toList();
    final unpinnedNotes = pinned
        ? ordered.where((n) => !n.isPinned).toList()
        : group;

    await _save(
      c.copyWith(
        notes: _normalizeNoteSortOrders([...pinnedNotes, ...unpinnedNotes]),
      ),
    );
  }

  Future<void> deleteNote(String id) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(notes: c.notes.where((n) => n.id != id).toList()));
  }

  List<CharacterNote> _notesInDisplayOrder(List<CharacterNote> notes) {
    final indexed =
        notes.mapIndexed((index, note) => MapEntry(index, note)).toList()
          ..sort((a, b) {
            final noteA = a.value;
            final noteB = b.value;
            if (noteA.isPinned != noteB.isPinned) {
              return noteA.isPinned ? -1 : 1;
            }
            final byOrder = noteA.sortOrder.compareTo(noteB.sortOrder);
            if (byOrder != 0) return byOrder;
            return a.key.compareTo(b.key);
          });
    return indexed.map((entry) => entry.value).toList();
  }

  List<CharacterNote> _normalizeNoteSortOrders(List<CharacterNote> notes) {
    final pinned = notes.where((note) => note.isPinned).toList();
    final unpinned = notes.where((note) => !note.isPinned).toList();
    return [
      for (var i = 0; i < pinned.length; i++)
        pinned[i].sortOrder == i ? pinned[i] : pinned[i].copyWith(sortOrder: i),
      for (var i = 0; i < unpinned.length; i++)
        unpinned[i].sortOrder == i
            ? unpinned[i]
            : unpinned[i].copyWith(sortOrder: i),
    ];
  }

  // ── Appearance ───────────────────────────────────────────────────────────────

  Future<void> updateAppearance(CharacterAppearance appearance) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(appearance: appearance));
  }

  // ── Image ────────────────────────────────────────────────────────────────────

  Future<void> updateImage(String? newPath) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final repo = ref.read(characterRepositoryProvider);
    final Character updated;
    if (newPath == null) {
      updated = await repo.removeImage(c);
    } else {
      updated = await repo.saveImage(c, newPath);
    }
    state = AsyncData(updated);
    if (ref.exists(characterListProvider)) {
      await ref.read(characterListProvider.notifier).updateSingle(updated);
    }
  }

  // ── Identity (atomic save) ────────────────────────────────────────────────

  Future<void> updateIdentity({
    required String name,
    required String alignment,
    required String playerName,
    required CharacterAppearance appearance,
    required CharacterPersonality personality,
    required String backstory,
    String nameFallback = 'Unnamed Hero',
  }) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final trimmed = name.trim();
    await _save(
      c.copyWith(
        name: trimmed.isEmpty ? nameFallback : trimmed,
        alignment: alignment.trim(),
        playerName: playerName.trim(),
        appearance: appearance,
        personality: personality,
        backstory: backstory.trim(),
      ),
    );
  }

  // ── Personality & Backstory ───────────────────────────────────────────────

  Future<void> updatePersonality(CharacterPersonality personality) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(personality: personality));
  }

  Future<void> updateBackstory(String backstory) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(backstory: backstory.trim()));
  }

  // ── Inspiration & XP ─────────────────────────────────────────────────────

  Future<void> toggleInspiration() async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(inspiration: !c.inspiration));
  }

  Future<void> toggleCondition(String name) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final current = List<String>.from(c.activeConditions);
    if (current.contains(name)) {
      current.remove(name);
    } else {
      current.add(name);
    }
    await _save(c.copyWith(activeConditions: current));
  }

  Future<void> updateExperiencePoints(int xp) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(experiencePoints: xp.clamp(0, 999999)));
  }

  /// Enables or disables XP tracking.
  /// When enabling: adjusts XP to the minimum for the current level if needed.
  Future<void> updateXpTracking(bool enabled) async {
    final c = state.valueOrNull;
    if (c == null) return;
    int xp = c.experiencePoints;
    if (enabled) {
      final minXp = levelToMinXp(c.totalLevel);
      if (xp < minXp) xp = minXp;
    }
    await _save(c.copyWith(xpTrackingEnabled: enabled, experiencePoints: xp));
  }

  Future<void> toggleWeightTracking() async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(weightTrackingEnabled: !c.weightTrackingEnabled));
  }
}
