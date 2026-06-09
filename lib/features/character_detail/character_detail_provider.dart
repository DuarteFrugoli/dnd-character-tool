import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/spellcasting_engine.dart';
import '../../data/constants/level_up_rules.dart';
import '../../data/datasources/srd/srd_models.dart';
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
    ref.listen<AsyncValue<List<Character>>>(
      characterListProvider,
      (_, next) {
        final fromList =
            next.valueOrNull?.firstWhereOrNull((c) => c.id == id);
        if (fromList != null) state = AsyncData(fromList);
      },
    );

    final c = await ref.read(characterRepositoryProvider).getById(id);
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
    final hdRecovered = (c.level / 2).ceil();
    final newHdUsed = (c.hitPoints.hitDiceUsed - hdRecovered).clamp(0, c.level);
    await _save(
      c.copyWith(
        hitPoints: c.hitPoints.copyWith(
          current: c.hitPoints.maximum,
          temporary: 0,
          hitDiceUsed: newHdUsed,
        ),
        spellSlots: c.spellSlots.copyWith(used: List.filled(9, 0)),
        innateSpells: c.innateSpells
            .map((s) => s.copyWith(usedToday: 0))
            .toList(),
        concentrationSpell: null,
      ),
    );
  }

  Future<void> setConcentration(String? spellName) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(concentrationSpell: spellName));
  }

  Future<void> shortRest({required int hdSpent, required int hpGained}) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final clampedHp = hpGained.clamp(0, c.hitPoints.maximum - c.hitPoints.current);
    final newHdUsed = (c.hitPoints.hitDiceUsed + hdSpent).clamp(0, c.level);
    await _save(
      c.copyWith(
        hitPoints: c.hitPoints.copyWith(
          current: c.hitPoints.current + clampedHp,
          hitDiceUsed: newHdUsed,
        ),
      ),
    );
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

  Future<void> updateLevel(int level) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final clamped = level.clamp(1, 20);
    final newXp = c.xpTrackingEnabled
        ? levelToMinXp(clamped)
        : c.experiencePoints;
    final updated = c.copyWith(
      level: clamped,
      proficiencyBonus: _profBonus(clamped),
      experiencePoints: newXp,
    );
    await _save(_applySlotSync(updated));
  }

  /// Applies all decisions from the Level Up Wizard atomically.
  Future<void> levelUp(LevelUpResult result) async {
    final c = state.valueOrNull;
    if (c == null) return;

    final newLevel = (c.level + 1).clamp(1, 20);
    final newProfBonus = _profBonus(newLevel);

    // 1. Apply HP
    final newMaxHp = c.hitPoints.maximum + result.hpGained;
    final newCurrentHp = c.hitPoints.current + result.hpGained;

    // 2. Apply ASI
    var newScores = c.abilityScores;
    for (final entry in result.asiChanges.entries) {
      newScores = newScores.increment(entry.key, entry.value);
    }

    // 3. Apply subclass
    final newSubclass =
        result.subclassChosen != null ? result.subclassChosen! : c.subclass;

    // 4. Apply feat
    var newExtraFeatures = c.extraFeatures;
    if (result.featChosen != null) {
      final feat = result.featChosen!;
      final alreadyHas = newExtraFeatures.any(
        (f) => f.name == feat.name && f.sourceClass == 'Feat',
      );
      if (!alreadyHas) {
        newExtraFeatures = [
          ...newExtraFeatures,
          CharacterExtraFeature(
            sourceClass: 'Feat',
            name: feat.name,
            level: newLevel,
            type: 'passive',
            description: feat.description,
          ),
        ];
      }
    }

    // 5. Apply spell changes
    var newSpells = c.spells;
    if (result.spellSwapped != null) {
      newSpells =
          newSpells.where((s) => s.name != result.spellSwapped).toList();
    }
    newSpells = [...newSpells, ...result.cantripsLearned, ...result.spellsLearned];

    var updated = c.copyWith(
      level: newLevel,
      proficiencyBonus: newProfBonus,
      hitPoints: c.hitPoints.copyWith(
        maximum: newMaxHp,
        current: newCurrentHp.clamp(0, newMaxHp),
      ),
      abilityScores: newScores,
      subclass: newSubclass,
      extraFeatures: newExtraFeatures,
      spells: newSpells,
    );

    // 6. Sync XP to minimum for new level when tracking is enabled
    if (c.xpTrackingEnabled) {
      updated = updated.copyWith(experiencePoints: levelToMinXp(newLevel));
    }

    // 7. Sync spell slots to new level
    await _save(_applySlotSync(updated));

    // 8. Sync innate spells if subclass changed
    if (result.subclassChosen != null) {
      await syncInnateSpells();
    }
  }

  /// Syncs `spellSlots.total` to match the class progression for the given
  /// character's class and level. Preserves `used` counts (clamped to new totals).
  Character _applySlotSync(Character c) {
    final engine = SpellcastingEngine.forClass(
      className: c.characterClass,
      classLevel: c.level,
      abilityScores: c.abilityScores,
      proficiencyBonus: c.proficiencyBonus,
      subclass: c.subclass,
    );
    if (engine == null) return c;
    final newTotal = engine.slotsPerLevel;
    final newUsed = List<int>.generate(
      9,
      (i) => c.spellSlots.used[i].clamp(0, newTotal[i]),
    );
    return c.copyWith(
      spellSlots: c.spellSlots.copyWith(total: newTotal, used: newUsed),
    );
  }

  /// Manually sync spell slots to current class/level. Exposed so the UI
  /// can call it once for characters created before auto-sync existed.
  Future<void> syncSpellSlots() async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(_applySlotSync(c));
  }

  Future<void> updateSubclass(String subclassName) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(subclass: subclassName));
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
    await _save(c.copyWith(disabledFeatures: disabled));
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
    await _save(newC.copyWith(armorClass: _calcArmorClass(newC)));
  }

  static int _profBonus(int level) {
    if (level <= 4) return 2;
    if (level <= 8) return 3;
    if (level <= 12) return 4;
    if (level <= 16) return 5;
    return 6;
  }

  // ── Extra Features (multiclasse / manual) ──────────────────────────────────

  Future<void> addExtraFeature(
    SrdClassFeature feature,
    String sourceClass,
  ) async {
    final c = state.valueOrNull;
    if (c == null) return;
    // Evita duplicatas
    final already = c.extraFeatures.any(
      (f) => f.name == feature.name && f.sourceClass == sourceClass,
    );
    if (already) return;
    final extra = CharacterExtraFeature(
      sourceClass: sourceClass,
      name: feature.name,
      level: feature.level,
      type: feature.type,
      description: feature.description,
    );
    await _save(c.copyWith(extraFeatures: [...c.extraFeatures, extra]));
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
      name: feat.name,
      level: c.level,
      type: 'passive',
      description: feat.description,
    );
    await _save(c.copyWith(extraFeatures: [...c.extraFeatures, extra]));
  }

  Future<void> removeExtraFeature(String name, String sourceClass) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.extraFeatures
        .where((f) => !(f.name == name && f.sourceClass == sourceClass))
        .toList();
    await _save(c.copyWith(extraFeatures: updated));
  }

  // ── Inventário ─────────────────────────────────────────────────────────────

  Future<void> addEquipmentItem(EquipmentItem item) async {
    final c = state.valueOrNull;
    if (c == null) return;
    // Sempre adiciona em item não equipado; nunca empilha item novo em equipado.
    final idx = c.equipment.indexWhere(
      (e) =>
          !e.isEquipped && e.name == item.name && e.itemType == item.itemType,
    );
    if (idx >= 0) {
      final updated = List<EquipmentItem>.from(c.equipment);
      updated[idx] = updated[idx].copyWith(
        quantity: updated[idx].quantity + item.quantity,
      );
      await _save(c.copyWith(equipment: updated));
    } else {
      await _save(c.copyWith(equipment: [...c.equipment, item]));
    }
  }

  Future<void> removeEquipmentItem(String id) async {
    await removeEquipmentQuantity(id, 1);
  }

  Future<void> removeEquipmentQuantity(String id, int amount) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = List<EquipmentItem>.from(c.equipment);
    final idx = updated.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    final removed = updated[idx];
    final removeAmount = amount.clamp(1, removed.quantity);

    // Em stacks, remove apenas a quantidade selecionada.
    if (removeAmount < removed.quantity) {
      updated[idx] = removed.copyWith(
        quantity: removed.quantity - removeAmount,
      );
      await _save(c.copyWith(equipment: updated));
      return;
    }

    updated.removeAt(idx);
    final newC = c.copyWith(equipment: updated);

    // Recalcula CA se a armadura removida estava equipada.
    if (removed.itemType == ItemType.armor && removed.isEquipped) {
      await _save(newC.copyWith(armorClass: _calcArmorClass(newC)));
    } else {
      await _save(newC);
    }
  }

  Future<void> toggleEquipped(String id, {bool forceArmorSwap = false}) async {
    final c = state.valueOrNull;
    if (c == null) return;

    final updated = List<EquipmentItem>.from(c.equipment);
    int idx = updated.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    EquipmentItem target = updated[idx];
    final isBodyArmor = _isBodyArmor(target);

    if (!target.isEquipped) {
      // Se for armadura corporal, só pode haver uma equipada por vez.
      if (isBodyArmor && forceArmorSwap) {
        _unequipOtherBodyArmors(updated, exceptId: target.id);

        // O merge da armadura antiga pode alterar quantidade/posição do item alvo.
        idx = updated.indexWhere((e) => e.id == id);
        if (idx < 0) return;
        target = updated[idx];
      }

      // Equipar 1 unidade de um stack: separa em entrada equipada + entrada carregada.
      if (target.quantity > 1) {
        updated[idx] = target.copyWith(quantity: target.quantity - 1);
        updated.add(
          EquipmentItem(
            name: target.name,
            category: target.category,
            itemType: target.itemType,
            quantity: 1,
            description: target.description,
            isEquipped: true,
            properties: target.properties,
          ),
        );
      } else {
        updated[idx] = target.copyWith(isEquipped: true);
      }
    } else {
      // Desequipar: remove a entrada equipada e devolve ao stack carregado.
      updated.removeAt(idx);
      _mergeIntoCarried(updated, target.copyWith(isEquipped: false));
    }

    final newC = c.copyWith(equipment: updated);

    // Recalcula CA quando há mudança relacionada a armadura.
    if (target.itemType == ItemType.armor || isBodyArmor) {
      await _save(newC.copyWith(armorClass: _calcArmorClass(newC)));
    } else {
      await _save(newC);
    }
  }

  bool _isBodyArmor(EquipmentItem item) {
    if (item.itemType != ItemType.armor) return false;
    final props = item.properties;
    if (props == null) return false;
    if (props['isShield'] == true) return false;
    return props.containsKey('baseAC');
  }

  void _unequipOtherBodyArmors(
    List<EquipmentItem> items, {
    required String exceptId,
  }) {
    final toUnequip = items
        .where((e) => e.id != exceptId && e.isEquipped && _isBodyArmor(e))
        .toList();
    items.removeWhere(
      (e) => e.id != exceptId && e.isEquipped && _isBodyArmor(e),
    );
    for (final armor in toUnequip) {
      _mergeIntoCarried(items, armor.copyWith(isEquipped: false));
    }
  }

  void _mergeIntoCarried(List<EquipmentItem> items, EquipmentItem item) {
    final carryIdx = items.indexWhere(
      (e) =>
          !e.isEquipped && e.name == item.name && e.itemType == item.itemType,
    );
    if (carryIdx >= 0) {
      items[carryIdx] = items[carryIdx].copyWith(
        quantity: items[carryIdx].quantity + item.quantity,
      );
    } else {
      items.add(
        EquipmentItem(
          name: item.name,
          category: item.category,
          itemType: item.itemType,
          quantity: item.quantity,
          description: item.description,
          isEquipped: false,
          properties: item.properties,
        ),
      );
    }
  }

  /// Calcula CA com base nos itens de armadura equipados.
  /// Regra: a CA base vem de UMA armadura (não-shield). Shields somam bônus.
  /// Sem armadura equipada: 10 + mod DEX.
  int _calcArmorClass(Character c) {
    final dexMod = c.abilityScores.dexterityModifier;
    int base = 10 + dexMod; // sem armadura
    int shieldBonus = 0;

    for (final item in c.equipment) {
      if (!item.isEquipped || item.itemType != ItemType.armor) continue;
      final props = item.properties;
      if (props == null) continue;

      if (props['isShield'] == true) {
        shieldBonus = (props['acBonus'] as num?)?.toInt() ?? 2;
      } else {
        final baseAC = (props['baseAC'] as num?)?.toInt() ?? 10;
        final addDex = props['addDexModifier'] as bool? ?? true;
        final maxDex = (props['maxDexBonus'] as num?)?.toInt();
        int armorAC = baseAC;
        if (addDex) {
          armorAC += maxDex != null ? dexMod.clamp(-99, maxDex) : dexMod;
        }
        base = armorAC;
      }
    }

    return base + shieldBonus;
  }

  Future<void> adjustItemQuantity(String id, int delta) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.equipment.map((e) {
      if (e.id != id) return e;
      final newQty = (e.quantity + delta).clamp(0, 9999);
      return e.copyWith(quantity: newQty);
    }).toList();
    // Remove se chegou a zero
    await _save(
      c.copyWith(equipment: updated.where((e) => e.quantity > 0).toList()),
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
    await _save(c.copyWith(notes: [note, ...c.notes]));
  }

  Future<void> updateNote(CharacterNote updated) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final notes = c.notes.map((n) => n.id == updated.id ? updated : n).toList();
    await _save(c.copyWith(notes: notes));
  }

  Future<void> deleteNote(String id) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(notes: c.notes.where((n) => n.id != id).toList()));
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
    } else if (newPath.startsWith('data:')) {
      updated = await repo.save(
        c.copyWith(imagePath: newPath, updatedAt: DateTime.now()),
      );
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
    await _save(c.copyWith(
      name: trimmed.isEmpty ? nameFallback : trimmed,
      alignment: alignment.trim(),
      playerName: playerName.trim(),
      appearance: appearance,
      personality: personality,
      backstory: backstory.trim(),
    ));
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
      final minXp = levelToMinXp(c.level);
      if (xp < minXp) xp = minXp;
    }
    await _save(c.copyWith(xpTrackingEnabled: enabled, experiencePoints: xp));
  }
}
