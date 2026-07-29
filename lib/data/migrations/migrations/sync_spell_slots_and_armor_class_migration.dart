import '../../constants/armor_class.dart';
import '../../models/models.dart';
import '../../spellcasting_engine.dart';
import '../character_migration.dart';

class SyncSpellSlotsAndArmorClassMigration extends CharacterMigration {
  const SyncSpellSlotsAndArmorClassMigration();

  static const spellSlotsChangeCode = 'spell_slots_synced';
  static const armorClassChangeCode = 'armor_class_recalculated';

  @override
  int get targetVersion => 6;

  @override
  String get id => 'sync_spell_slots_and_armor_class';

  @override
  String get title => 'Sync spell slots and armor class';

  @override
  String get description =>
      'Updates spell slot totals and recalculates armor class.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext _,
  ) {
    var updated = character;
    final changes = <CharacterMigrationChange>[];

    final syncedSlots = SpellcastingEngine.syncedSlotsFor(
      current: updated.spellSlots,
      className: updated.primaryClass.className,
      classLevel: updated.primaryClass.level,
      abilityScores: updated.abilityScores,
      proficiencyBonus: updated.proficiencyBonus,
      subclass: updated.primaryClass.subclassName,
    );
    if (!_sameList(updated.spellSlots.total, syncedSlots.total) ||
        !_sameList(updated.spellSlots.used, syncedSlots.used)) {
      updated = updated.copyWith(spellSlots: syncedSlots);
      changes.add(
        const CharacterMigrationChange(code: spellSlotsChangeCode, count: 1),
      );
    }

    final recalculatedArmorClass = calcArmorClass(updated);
    if (updated.armorClass != recalculatedArmorClass) {
      updated = updated.copyWith(armorClass: recalculatedArmorClass);
      changes.add(
        const CharacterMigrationChange(code: armorClassChangeCode, count: 1),
      );
    }

    return CharacterMigrationResult(character: updated, changes: changes);
  }

  bool _sameList(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
