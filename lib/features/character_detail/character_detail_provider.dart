import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';
import '../character_list/character_list_provider.dart';

final characterDetailProvider = AsyncNotifierProvider.family<
    CharacterDetailNotifier, Character, String>(
  CharacterDetailNotifier.new,
);

class CharacterDetailNotifier
    extends FamilyAsyncNotifier<Character, String> {
  @override
  Future<Character> build(String id) async {
    final c = await ref.read(characterRepositoryProvider).getById(id);
    if (c == null) throw Exception('Character not found');
    return c;
  }

  Future<void> _save(Character updated) async {
    final saved = await ref.read(characterRepositoryProvider).save(updated);
    state = AsyncData(saved);
    ref.invalidate(characterListProvider);
  }

  Future<void> adjustHp(int delta) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final hp = c.hitPoints;
    final newCurrent = (hp.current + delta).clamp(0, hp.maximum);
    await _save(c.copyWith(hitPoints: hp.copyWith(current: newCurrent)));
  }

  Future<void> setTemporaryHp(int temp) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(
        c.copyWith(hitPoints: c.hitPoints.copyWith(temporary: temp.clamp(0, 9999))));
  }

  Future<void> useSpellSlot(int level) async {
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
    final c = state.valueOrNull;
    if (c == null) return;
    final slots = c.spellSlots;
    final idx = level - 1;
    if (slots.used[idx] <= 0) return;
    final newUsed = List<int>.from(slots.used);
    newUsed[idx]--;
    await _save(c.copyWith(spellSlots: slots.copyWith(used: newUsed)));
  }

  Future<void> longRest() async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(
      hitPoints: c.hitPoints.copyWith(current: c.hitPoints.maximum, temporary: 0),
      spellSlots: c.spellSlots.copyWith(used: List.filled(9, 0)),
    ));
  }

  Future<void> updateName(String name) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final trimmed = name.trim();
    await _save(c.copyWith(name: trimmed.isEmpty ? 'Unnamed Hero' : trimmed));
  }

  Future<void> updateLevel(int level) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final clamped = level.clamp(1, 20);
    await _save(c.copyWith(level: clamped, proficiencyBonus: _profBonus(clamped)));
  }

  static int _profBonus(int level) {
    if (level <= 4) return 2;
    if (level <= 8) return 3;
    if (level <= 12) return 4;
    if (level <= 16) return 5;
    return 6;
  }

  // ── Inventário ─────────────────────────────────────────────────────────────

  Future<void> addEquipmentItem(EquipmentItem item) async {
    final c = state.valueOrNull;
    if (c == null) return;
    // Stack se já existe item com mesmo nome e tipo
    final idx = c.equipment.indexWhere(
      (e) => e.name == item.name && e.itemType == item.itemType,
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
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.equipment.where((e) => e.id != id).toList();
    await _save(c.copyWith(equipment: updated));
  }

  Future<void> toggleEquipped(String id) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.equipment.map((e) {
      if (e.id != id) return e;
      return e.copyWith(isEquipped: !e.isEquipped);
    }).toList();
    final newC = c.copyWith(equipment: updated);
    // Recalcula CA se o item afetado for armadura
    final affected = updated.firstWhere((e) => e.id == id);
    if (affected.itemType == ItemType.armor) {
      await _save(newC.copyWith(armorClass: _calcArmorClass(newC)));
    } else {
      await _save(newC);
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
    await _save(c.copyWith(
      equipment: updated.where((e) => e.quantity > 0).toList(),
    ));
  }

  Future<void> updateCurrency(Map<String, int> currency) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(currency: currency));
  }
}
