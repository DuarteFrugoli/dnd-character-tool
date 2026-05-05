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
    return ref.read(characterRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(characterRepositoryProvider).getAll(),
    );
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
