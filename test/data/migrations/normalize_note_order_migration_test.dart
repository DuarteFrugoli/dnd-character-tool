import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/normalize_note_order_migration.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character(List<CharacterNote> notes) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    dataVersion: 3,
    name: 'Test Hero',
    race: 'Human',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    notes: notes,
    createdAt: now,
    updatedAt: now,
  );
}

CharacterNote _note({
  required String id,
  required String title,
  bool pinned = false,
  int sortOrder = 0,
}) {
  return CharacterNote(
    id: id,
    title: title,
    content: '',
    isPinned: pinned,
    sortOrder: sortOrder,
    createdAt: DateTime(2024),
  );
}

void main() {
  group('NormalizeNoteOrderMigration', () {
    test('places pinned notes first and normalizes order per group', () {
      final result = const NormalizeNoteOrderMigration().migrate(
        _character([
          _note(id: 'a', title: 'A', sortOrder: 99),
          _note(id: 'b', title: 'B', pinned: true, sortOrder: 7),
          _note(id: 'c', title: 'C', pinned: true, sortOrder: 8),
        ]),
        const CharacterMigrationContext(itemsByName: {}),
      );

      expect(result.character.notes.map((note) => note.id), ['b', 'c', 'a']);
      expect(result.character.notes.map((note) => note.sortOrder), [0, 1, 0]);
      expect(result.changes.single.code, 'notes_order_normalized');
    });

    test('does not report a change when notes are already normalized', () {
      final notes = [
        _note(id: 'pinned', title: 'Pinned', pinned: true, sortOrder: 0),
        _note(id: 'regular', title: 'Regular', sortOrder: 0),
      ];

      final result = const NormalizeNoteOrderMigration().migrate(
        _character(notes),
        const CharacterMigrationContext(itemsByName: {}),
      );

      expect(result.character.notes.map((note) => note.id), [
        'pinned',
        'regular',
      ]);
      expect(result.changes, isEmpty);
    });
  });
}
