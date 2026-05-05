import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';

final characterListProvider =
    AsyncNotifierProvider<CharacterListNotifier, List<Character>>(
  CharacterListNotifier.new,
);

class CharacterListNotifier extends AsyncNotifier<List<Character>> {
  @override
  Future<List<Character>> build() async {
    final chars = await ref.read(characterRepositoryProvider).getAll();
    return _sorted(chars);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final chars = await ref.read(characterRepositoryProvider).getAll();
      return _sorted(chars);
    });
  }

  List<Character> _sorted(List<Character> chars) {
    final list = [...chars];
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      if (a.sortOrder != b.sortOrder) return a.sortOrder.compareTo(b.sortOrder);
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  Future<void> togglePin(String id) async {
    final character = await ref.read(characterRepositoryProvider).getById(id);
    if (character == null) return;
    await ref
        .read(characterRepositoryProvider)
        .save(character.copyWith(isPinned: !character.isPinned));
    await refresh();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (newIndex > oldIndex) newIndex--;

    final pinned = current.where((c) => c.isPinned).toList();
    final unpinned = current.where((c) => !c.isPinned).toList();
    final pinnedCount = pinned.length;

    if (oldIndex < pinnedCount && newIndex < pinnedCount) {
      final item = pinned.removeAt(oldIndex);
      pinned.insert(newIndex, item);
    } else if (oldIndex >= pinnedCount && newIndex >= pinnedCount) {
      final ao = oldIndex - pinnedCount;
      final an = newIndex - pinnedCount;
      final item = unpinned.removeAt(ao);
      unpinned.insert(an, item);
    } else {
      return; // cross-section drag — ignore
    }

    final repo = ref.read(characterRepositoryProvider);
    final allUpdated = <Character>[];
    for (var i = 0; i < pinned.length; i++) {
      final updated = pinned[i].copyWith(sortOrder: i);
      allUpdated.add(updated);
      await repo.save(updated);
    }
    for (var i = 0; i < unpinned.length; i++) {
      final updated = unpinned[i].copyWith(sortOrder: i);
      allUpdated.add(updated);
      await repo.save(updated);
    }
    state = AsyncData(allUpdated);
  }

  Future<void> delete(String id) async {
    await ref.read(characterRepositoryProvider).delete(id);
    await refresh();
  }

  Future<String> exportCharacter(Character character) {
    return ref.read(characterRepositoryProvider).exportToJson(character);
  }

  Future<Character> importCharacter(String jsonString) async {
    final character =
        await ref.read(characterRepositoryProvider).importFromJson(jsonString);
    await refresh();
    return character;
  }

  Future<void> rename(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final character = await ref.read(characterRepositoryProvider).getById(id);
    if (character == null) return;
    await ref.read(characterRepositoryProvider).save(character.copyWith(name: trimmed));
    await refresh();
  }
}
