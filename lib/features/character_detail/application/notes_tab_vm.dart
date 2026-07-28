import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../character_detail_provider.dart';
import 'vm_reference_utils.dart';

final notesTabVmProvider =
    Provider.family<AsyncValue<NotesTabVm>, String>((ref, characterId) {
  return ref.watch(
    characterDetailProvider(characterId).select(
      (state) => state.whenData(NotesTabVm.fromCharacter),
    ),
  );
});

class NotesTabVm {
  const NotesTabVm({required this.notes});

  factory NotesTabVm.fromCharacter(Character character) {
    return NotesTabVm(notes: character.notes);
  }

  final List<CharacterNote> notes;

  @override
  bool operator ==(Object other) {
    return other is NotesTabVm && sameReference(notes, other.notes);
  }

  @override
  int get hashCode => referenceHash(notes);
}
