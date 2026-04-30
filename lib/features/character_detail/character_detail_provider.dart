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
    await _save(c.copyWith(equipment: [...c.equipment, item]));
  }

  Future<void> removeEquipmentItem(String itemName) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.equipment.where((e) => e.name != itemName).toList();
    await _save(c.copyWith(equipment: updated));
  }

  Future<void> toggleEquipped(String itemName) async {
    final c = state.valueOrNull;
    if (c == null) return;
    final updated = c.equipment.map((e) {
      if (e.name != itemName) return e;
      return e.copyWith(isEquipped: !e.isEquipped);
    }).toList();
    await _save(c.copyWith(equipment: updated));
  }

  Future<void> updateCurrency(Map<String, int> currency) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(currency: currency));
  }
}
