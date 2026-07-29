import '../../models/models.dart';
import '../character_migration.dart';

class NormalizeNoteOrderMigration extends CharacterMigration {
  const NormalizeNoteOrderMigration();

  static const changeCode = 'notes_order_normalized';

  @override
  int get targetVersion => 4;

  @override
  String get id => 'normalize_note_order';

  @override
  String get title => 'Normalize note order';

  @override
  String get description => 'Assigns explicit order values to character notes.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext _,
  ) {
    if (character.notes.isEmpty) {
      return CharacterMigrationResult(character: character);
    }

    final updatedNotes = <CharacterNote>[];
    var changedCount = 0;

    void appendGroup(bool pinned) {
      var sortOrder = 0;
      for (final note in character.notes.where((n) => n.isPinned == pinned)) {
        final updated = note.sortOrder == sortOrder
            ? note
            : note.copyWith(sortOrder: sortOrder);
        if (updated.sortOrder != note.sortOrder) {
          changedCount += 1;
        }
        updatedNotes.add(updated);
        sortOrder += 1;
      }
    }

    appendGroup(true);
    appendGroup(false);

    final orderChanged = !_sameNoteOrder(character.notes, updatedNotes);
    if (changedCount == 0 && !orderChanged) {
      return CharacterMigrationResult(character: character);
    }

    return CharacterMigrationResult(
      character: character.copyWith(notes: updatedNotes),
      changes: [
        CharacterMigrationChange(
          code: changeCode,
          count: changedCount == 0 ? updatedNotes.length : changedCount,
        ),
      ],
    );
  }

  bool _sameNoteOrder(List<CharacterNote> a, List<CharacterNote> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}
