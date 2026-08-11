import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/sync_multiclass_spell_slots_migration.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  required List<CharacterClassEntry> classes,
  SpellSlots spellSlots = const SpellSlots(),
  SpellSlots pactMagicSlots = const SpellSlots(),
}) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    dataVersion: 7,
    name: 'Test Caster',
    race: 'Human',
    characterClass: classes.first.className,
    level: classes.fold<int>(0, (sum, entry) => sum + entry.level),
    classes: classes,
    abilityScores: const AbilityScores(intelligence: 16, charisma: 14),
    hitPoints: const HitPoints(maximum: 24, current: 24),
    spellSlots: spellSlots,
    pactMagicSlots: pactMagicSlots,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  const migration = SyncMulticlassSpellSlotsMigration();
  const context = CharacterMigrationContext(itemsByName: {});

  test('separates standard spell slots from Pact Magic slots', () {
    final character = _character(
      classes: const [
        CharacterClassEntry(
          id: 'wizard',
          className: 'Wizard',
          level: 3,
          isStartingClass: true,
        ),
        CharacterClassEntry(id: 'warlock', className: 'Warlock', level: 2),
      ],
      spellSlots: const SpellSlots(
        total: [4, 2, 0, 0, 0, 0, 0, 0, 0],
        used: [1, 0, 0, 0, 0, 0, 0, 0, 0],
      ),
    );

    final result = migration.migrate(character, context);

    expect(result.character.spellSlots.total, [4, 2, 0, 0, 0, 0, 0, 0, 0]);
    expect(result.character.spellSlots.used[0], 1);
    expect(result.character.pactMagicSlots.total, [2, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(result.character.pactMagicSlots.used, List<int>.filled(9, 0));
    expect(result.changes.map((change) => change.code), [
      SyncMulticlassSpellSlotsMigration.pactMagicSlotsChangeCode,
    ]);
  });

  test('moves legacy pure Warlock slots into Pact Magic', () {
    final character = _character(
      classes: const [
        CharacterClassEntry(
          id: 'warlock',
          className: 'Warlock',
          level: 3,
          isStartingClass: true,
        ),
      ],
      spellSlots: const SpellSlots(
        total: [0, 2, 0, 0, 0, 0, 0, 0, 0],
        used: [0, 1, 0, 0, 0, 0, 0, 0, 0],
      ),
    );

    final result = migration.migrate(character, context);

    expect(result.character.spellSlots.total, List<int>.filled(9, 0));
    expect(result.character.pactMagicSlots.total, [0, 2, 0, 0, 0, 0, 0, 0, 0]);
    expect(result.character.pactMagicSlots.used[1], 1);
    expect(result.changes.map((change) => change.code), [
      SyncMulticlassSpellSlotsMigration.standardSlotsChangeCode,
      SyncMulticlassSpellSlotsMigration.pactMagicSlotsChangeCode,
    ]);
  });
}
