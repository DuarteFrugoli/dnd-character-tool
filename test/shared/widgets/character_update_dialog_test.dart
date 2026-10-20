import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/character_migration_runner.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/repositories/character_repository.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/shared/providers/providers.dart';
import 'package:dnd_character_tool/shared/widgets/character_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MaintenanceRepository extends CharacterRepository {
  _MaintenanceRepository({this.hasReadIssues = false});

  final bool hasReadIssues;
  int backupCalls = 0;
  int updateCalls = 0;
  List<String>? events;

  late final CharacterMigrationBatchReport report = () {
    final now = DateTime(2024);
    final oldCharacter = Character(
      id: 'hero',
      dataVersion: 9,
      name: 'Hero',
      race: 'Human',
      characterClass: 'Fighter',
      abilityScores: const AbilityScores(),
      hitPoints: const HitPoints(maximum: 10, current: 10),
      createdAt: now,
      updatedAt: now,
    );
    return CharacterMigrationBatchReport(
      latestVersion: currentCharacterDataVersion,
      readIssues: hasReadIssues
          ? const [
              CharacterMigrationReadIssue(
                source: 'broken',
                message: 'corrupted_character',
              ),
            ]
          : const [],
      characters: [
        CharacterMigrationCharacterReport(
          original: oldCharacter,
          character: oldCharacter.copyWith(
            dataVersion: currentCharacterDataVersion,
          ),
          fromVersion: 9,
          toVersion: currentCharacterDataVersion,
          appliedMigrationIds: const ['assign_2014_ruleset'],
          changes: const [
            CharacterMigrationChange(
              code: 'ruleset_2014_assigned',
              count: 1,
            ),
          ],
        ),
      ],
    );
  }();

  @override
  Future<CharacterMigrationBatchReport> previewMigrations() async => report;

  @override
  Future<String> exportBackupToFileJson() async {
    backupCalls++;
    return 'backup';
  }

  @override
  Future<CharacterMigrationBatchReport> applyMigrations() async {
    updateCalls++;
    events?.add('apply');
    return report;
  }
}

Future<void> _showHarness(
  WidgetTester tester,
  _MaintenanceRepository repository, {
  required Future<void> Function(String) exportBackup,
  required void Function(bool) onClosed,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [characterRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                onClosed(
                  await showCharacterUpdateDialog(
                    context,
                    exportBackup: exportBackup,
                  ),
                );
              },
              child: const Text('Open character'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open character'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cancel leaves every character untouched', (tester) async {
    final repository = _MaintenanceRepository();
    bool? result;
    await _showHarness(
      tester,
      repository,
      exportBackup: (_) async {},
      onClosed: (value) => result = value,
    );

    expect(find.text('Update all characters'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(repository.backupCalls, 0);
    expect(repository.updateCalls, 0);
  });

  testWidgets('backup alone does not update; update backs up before applying', (
    tester,
  ) async {
    final repository = _MaintenanceRepository();
    final events = <String>[];
    repository.events = events;
    bool? result;
    await _showHarness(
      tester,
      repository,
      exportBackup: (json) async {
        expect(json, 'backup');
        events.add('export');
      },
      onClosed: (value) => result = value,
    );

    await tester.tap(find.text('Back up characters'));
    await tester.pumpAndSettle();
    expect(repository.backupCalls, 1);
    expect(repository.updateCalls, 0);
    expect(find.text('Update all characters'), findsOneWidget);

    await tester.tap(find.text('Update all characters'));
    await tester.pumpAndSettle();
    expect(repository.backupCalls, 2);
    expect(repository.updateCalls, 1);
    expect(events, ['export', 'export', 'apply']);
    expect(find.text('Update complete'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('failed backup keeps characters unchanged', (tester) async {
    final repository = _MaintenanceRepository();
    bool? result;
    await _showHarness(
      tester,
      repository,
      exportBackup: (_) async => throw StateError('share failed'),
      onClosed: (value) => result = value,
    );

    await tester.tap(find.text('Update all characters'));
    await tester.pumpAndSettle();

    expect(repository.backupCalls, 1);
    expect(repository.updateCalls, 0);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('read issues disable backup and update', (tester) async {
    final repository = _MaintenanceRepository(hasReadIssues: true);
    await _showHarness(
      tester,
      repository,
      exportBackup: (_) async {},
      onClosed: (_) {},
    );

    expect(find.text('Update all characters'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(repository.backupCalls, 0);
    expect(repository.updateCalls, 0);
  });
}
