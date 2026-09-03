import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/character_migration_runner.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({int dataVersion = 0, String name = 'Hero'}) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    dataVersion: dataVersion,
    name: name,
    race: 'Human',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    createdAt: now,
    updatedAt: now,
  );
}

class _RenameMigration extends CharacterMigration {
  const _RenameMigration({required this.version, required this.suffix});

  final int version;
  final String suffix;

  @override
  int get targetVersion => version;

  @override
  String get id => 'rename_$version';

  @override
  String get title => 'Rename $version';

  @override
  String get description => 'Adds a suffix.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext context,
  ) {
    return CharacterMigrationResult(
      character: character.copyWith(name: '${character.name}$suffix'),
      changes: [CharacterMigrationChange(code: id, count: 1)],
    );
  }
}

void main() {
  const context = CharacterMigrationContext(
    itemsByName: <String, SrdItemData>{},
  );

  group('CharacterMigrationRunner', () {
    test(
      'default latestVersion matches the current character data version',
      () {
        expect(
          CharacterMigrationRunner().latestVersion,
          currentCharacterDataVersion,
        );
      },
    );

    test('sorts and applies migrations by target version', () {
      final runner = CharacterMigrationRunner(
        migrations: const [
          _RenameMigration(version: 2, suffix: ' second'),
          _RenameMigration(version: 1, suffix: ' first'),
        ],
      );

      final report = runner.migrate(_character(), context);

      expect(report.character.name, 'Hero first second');
      expect(report.fromVersion, 0);
      expect(report.toVersion, 2);
      expect(report.appliedMigrationIds, ['rename_1', 'rename_2']);
      expect(report.changes.map((change) => change.code), [
        'rename_1',
        'rename_2',
      ]);
    });

    test('skips migrations at or below the character data version', () {
      final runner = CharacterMigrationRunner(
        migrations: const [
          _RenameMigration(version: 1, suffix: ' old'),
          _RenameMigration(version: 2, suffix: ' new'),
        ],
      );

      final report = runner.migrate(_character(dataVersion: 1), context);

      expect(report.character.name, 'Hero new');
      expect(report.fromVersion, 1);
      expect(report.toVersion, 2);
      expect(report.appliedMigrationIds, ['rename_2']);
    });

    test(
      'preview reports outdated and changed characters without saving them',
      () {
        final runner = CharacterMigrationRunner(
          migrations: const [_RenameMigration(version: 1, suffix: ' updated')],
        );
        final current = _character(dataVersion: 1, name: 'Current');
        final old = _character(dataVersion: 0, name: 'Old');

        final report = runner.preview([current, old], context);

        expect(report.latestVersion, 1);
        expect(report.checkedCount, 2);
        expect(report.outdatedCount, 1);
        expect(report.dataChangedCount, 1);
        expect(current.name, 'Current');
        expect(old.name, 'Old');
      },
    );
  });
}
