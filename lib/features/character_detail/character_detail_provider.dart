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
    // Sempre adiciona em item não equipado; nunca empilha item novo em equipado.
    final idx = c.equipment.indexWhere(
      (e) =>
          !e.isEquipped &&
          e.name == item.name &&
          e.itemType == item.itemType,
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
      updated[idx] = removed.copyWith(quantity: removed.quantity - removeAmount);
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
      _mergeIntoCarried(
        updated,
        target.copyWith(isEquipped: false),
      );
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

  void _unequipOtherBodyArmors(List<EquipmentItem> items,
      {required String exceptId}) {
    final toUnequip = items
        .where((e) => e.id != exceptId && e.isEquipped && _isBodyArmor(e))
        .toList();
    items.removeWhere((e) => e.id != exceptId && e.isEquipped && _isBodyArmor(e));
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
    await _save(c.copyWith(
      equipment: updated.where((e) => e.quantity > 0).toList(),
    ));
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
    final notes = c.notes
        .map((n) => n.id == updated.id ? updated : n)
        .toList();
    await _save(c.copyWith(notes: notes));
  }

  Future<void> deleteNote(String id) async {
    final c = state.valueOrNull;
    if (c == null) return;
    await _save(c.copyWith(
      notes: c.notes.where((n) => n.id != id).toList(),
    ));
  }
}
