import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/review/app_review_service.dart';
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
    unawaited(
      ref
          .read(appReviewServiceProvider)
          .maybeRequestReview(characterCount: chars.length),
    );
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
    final repo = ref.read(characterRepositoryProvider);
    final current = state.valueOrNull ?? _sorted(await repo.getAll());
    final character = current.firstWhereOrNull((c) => c.id == id);
    if (character == null) return;

    final isPinned = !character.isPinned;
    final groupSortOrders = current
        .where((c) => c.id != id && c.isPinned == isPinned)
        .map((c) => c.sortOrder);
    final sortOrder = groupSortOrders.isEmpty
        ? 0
        : groupSortOrders.reduce(math.max) + 1;
    final updated = await repo.save(
      character.copyWith(isPinned: isPinned, sortOrder: sortOrder),
    );
    state = AsyncData(_sorted([...current.where((c) => c.id != id), updated]));
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

    final allUpdated = [
      for (var i = 0; i < pinned.length; i++) pinned[i].copyWith(sortOrder: i),
      for (var i = 0; i < unpinned.length; i++)
        unpinned[i].copyWith(sortOrder: i),
    ];
    final previousById = {for (final c in current) c.id: c};
    final changed = allUpdated.where((character) {
      return previousById[character.id]?.sortOrder != character.sortOrder;
    }).toList();

    // Update UI immediately — no flash
    state = AsyncData(allUpdated);

    // Persist in the background
    final repo = ref.read(characterRepositoryProvider);
    for (final c in changed) {
      await repo.save(c);
    }
  }

  Future<void> delete(String id) async {
    await ref.read(characterRepositoryProvider).delete(id);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.where((c) => c.id != id).toList());
    }
  }

  Future<Character?> duplicate(String id, {required String name}) async {
    final repo = ref.read(characterRepositoryProvider);
    final current = state.valueOrNull ?? _sorted(await repo.getAll());
    final source = current.firstWhereOrNull((c) => c.id == id);
    if (source == null) return null;

    final group = current
        .where((character) => character.isPinned == source.isPinned)
        .toList();
    final otherGroup = current
        .where((character) => character.isPinned != source.isPinned)
        .toList();
    final sourceIndex = group.indexWhere((character) => character.id == id);
    final insertIndex = sourceIndex < 0 ? group.length : sourceIndex + 1;

    final duplicate = await repo.duplicate(
      source,
      name: name,
      isPinned: source.isPinned,
      sortOrder: insertIndex,
    );

    group.insert(insertIndex, duplicate);
    final normalizedGroup = [
      for (var i = 0; i < group.length; i++) group[i].copyWith(sortOrder: i),
    ];
    final normalizedDuplicate = normalizedGroup.firstWhere(
      (character) => character.id == duplicate.id,
    );

    state = AsyncData(_sorted([...normalizedGroup, ...otherGroup]));

    final previousById = {
      for (final character in current) character.id: character,
    };
    for (final character in normalizedGroup) {
      final previous = previousById[character.id];
      if (previous == null) {
        if (character.sortOrder != duplicate.sortOrder) {
          await repo.save(character);
        }
        continue;
      }
      if (previous.sortOrder != character.sortOrder) {
        await repo.save(character);
      }
    }

    return normalizedDuplicate;
  }

  Future<String> exportCharacter(Character character) {
    return ref.read(characterRepositoryProvider).exportToJson(character);
  }

  Future<String> exportCharacterToFile(Character character) {
    return ref.read(characterRepositoryProvider).exportToFileJson(character);
  }

  Future<void> updateSingle(Character character) async {
    var current = state.valueOrNull;
    if (current == null) {
      try {
        current = await future;
      } catch (e, st) {
        debugPrint('updateSingle: failed to resolve current state: $e\n$st');
        return;
      }
    }
    final withoutOld = current.where((c) => c.id != character.id).toList();
    state = AsyncData(_sorted([character, ...withoutOld]));
  }

  Future<Character> importCharacter(String jsonString) async {
    final character = await ref
        .read(characterRepositoryProvider)
        .importFromJson(jsonString);
    await updateSingle(character);
    return character;
  }

  Future<Character> importCharacterFromFile(String fileJson) async {
    final character = await ref
        .read(characterRepositoryProvider)
        .importFromDndCharFile(fileJson);
    await updateSingle(character);
    return character;
  }

  Future<void> rename(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final current = state.valueOrNull;
    if (current == null) return;
    final character = current.firstWhereOrNull((c) => c.id == id);
    if (character == null) return;
    final updated = character.copyWith(
      name: trimmed,
      updatedAt: DateTime.now(),
    );
    await ref.read(characterRepositoryProvider).save(updated);
    state = AsyncData(current.map((c) => c.id == id ? updated : c).toList());
  }

  Future<void> updateImage(String id, String? imagePath) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final character = current.firstWhereOrNull((c) => c.id == id);
    if (character == null) return;
    final repo = ref.read(characterRepositoryProvider);
    final Character updated;
    if (imagePath == null) {
      // Deleta a imagem persistida e limpa o campo.
      updated = await repo.removeImage(character);
    } else {
      // Nativo copia arquivo; Web salva data URL no IndexedDB.
      updated = await repo.saveImage(character, imagePath);
    }
    state = AsyncData(current.map((c) => c.id == id ? updated : c).toList());
  }
}
