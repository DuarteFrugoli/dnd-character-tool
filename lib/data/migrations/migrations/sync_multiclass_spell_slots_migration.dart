import '../../character_progression/character_progression.dart';
import '../../models/models.dart';
import '../character_migration.dart';

class SyncMulticlassSpellSlotsMigration extends CharacterMigration {
  const SyncMulticlassSpellSlotsMigration();

  static const standardSlotsChangeCode = 'standard_spell_slots_synced';
  static const pactMagicSlotsChangeCode = 'pact_magic_slots_synced';

  @override
  int get targetVersion => 8;

  @override
  String get id => 'sync_multiclass_spell_slots';

  @override
  String get title => 'Sync multiclass spell slots';

  @override
  String get description =>
      'Separates standard spell slots from Pact Magic slots.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext _,
  ) {
    final synced = CharacterProgressionEngine.syncSpellcastingSlotsFor(
      character,
    );
    final changes = <CharacterMigrationChange>[
      if (!_sameSlots(character.spellSlots, synced.spellSlots))
        const CharacterMigrationChange(code: standardSlotsChangeCode, count: 1),
      if (!_sameSlots(character.pactMagicSlots, synced.pactMagicSlots))
        const CharacterMigrationChange(
          code: pactMagicSlotsChangeCode,
          count: 1,
        ),
    ];
    return CharacterMigrationResult(character: synced, changes: changes);
  }

  bool _sameSlots(SpellSlots a, SpellSlots b) {
    return _sameList(a.total, b.total) && _sameList(a.used, b.used);
  }

  bool _sameList(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
