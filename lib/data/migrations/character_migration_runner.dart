import '../models/models.dart';
import 'character_migration.dart';
import 'migrations/backfill_equipment_weights_migration.dart';
import 'migrations/expand_equipment_packs_migration.dart';
import 'migrations/normalize_equipment_order_migration.dart';
import 'migrations/normalize_note_order_migration.dart';
import 'migrations/normalize_equipment_items_migration.dart';
import 'migrations/prepare_multiclass_structure_migration.dart';
import 'migrations/sync_multiclass_spell_slots_migration.dart';
import 'migrations/sync_spell_slots_and_armor_class_migration.dart';

class CharacterMigrationRunner {
  CharacterMigrationRunner({List<CharacterMigration>? migrations})
    : migrations = _sorted(
        migrations ??
            const [
              BackfillEquipmentWeightsMigration(),
              NormalizeEquipmentItemsMigration(),
              ExpandEquipmentPacksMigration(),
              NormalizeNoteOrderMigration(),
              NormalizeEquipmentOrderMigration(),
              SyncSpellSlotsAndArmorClassMigration(),
              PrepareMulticlassStructureMigration(),
              SyncMulticlassSpellSlotsMigration(),
            ],
      );

  final List<CharacterMigration> migrations;

  static List<CharacterMigration> _sorted(List<CharacterMigration> source) {
    final sorted = [...source]
      ..sort((a, b) => a.targetVersion.compareTo(b.targetVersion));
    return List.unmodifiable(sorted);
  }

  int get latestVersion =>
      migrations.isEmpty ? 0 : migrations.last.targetVersion;

  CharacterMigrationBatchReport preview(
    List<Character> characters,
    CharacterMigrationContext context,
  ) {
    return CharacterMigrationBatchReport(
      latestVersion: latestVersion,
      characters: [
        for (final character in characters) migrate(character, context),
      ],
    );
  }

  CharacterMigrationCharacterReport migrate(
    Character character,
    CharacterMigrationContext context,
  ) {
    final fromVersion = character.dataVersion;
    var current = character;
    final changes = <CharacterMigrationChange>[];
    final appliedMigrationIds = <String>[];

    for (final migration in migrations) {
      if (migration.targetVersion <= current.dataVersion) continue;

      final result = migration.migrate(current, context);
      current = result.character.copyWith(dataVersion: migration.targetVersion);
      changes.addAll(result.changes);
      appliedMigrationIds.add(migration.id);
    }

    return CharacterMigrationCharacterReport(
      original: character,
      character: current,
      fromVersion: fromVersion,
      toVersion: current.dataVersion,
      appliedMigrationIds: appliedMigrationIds,
      changes: changes,
    );
  }
}

class CharacterMigrationBatchReport {
  const CharacterMigrationBatchReport({
    required this.latestVersion,
    required this.characters,
    this.readIssues = const [],
  });

  final int latestVersion;
  final List<CharacterMigrationCharacterReport> characters;
  final List<CharacterMigrationReadIssue> readIssues;

  int get checkedCount => characters.length;

  int get outdatedCount =>
      characters.where((entry) => entry.needsMigration).length;

  int get dataChangedCount =>
      characters.where((entry) => entry.hasDataChanges).length;

  bool get hasUpdates => outdatedCount > 0;

  int get readIssueCount => readIssues.length;

  bool get hasReadIssues => readIssues.isNotEmpty;

  CharacterMigrationBatchReport withReadIssues(
    List<CharacterMigrationReadIssue> issues,
  ) {
    return CharacterMigrationBatchReport(
      latestVersion: latestVersion,
      characters: characters,
      readIssues: issues,
    );
  }
}

class CharacterMigrationReadIssue {
  const CharacterMigrationReadIssue({
    required this.source,
    required this.message,
    this.id,
  });

  final String source;
  final String? id;
  final String message;
}

class CharacterMigrationCharacterReport {
  const CharacterMigrationCharacterReport({
    required this.original,
    required this.character,
    required this.fromVersion,
    required this.toVersion,
    required this.appliedMigrationIds,
    required this.changes,
  });

  final Character original;
  final Character character;
  final int fromVersion;
  final int toVersion;
  final List<String> appliedMigrationIds;
  final List<CharacterMigrationChange> changes;

  bool get needsMigration => fromVersion < toVersion;

  bool get hasDataChanges => changes.isNotEmpty;
}
