import 'package:dnd_character_tool/data/models/local_backup.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/repositories/character_repository.dart';
import 'package:dnd_character_tool/features/home/local_backups_screen.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/shared/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _BackupsRepository extends CharacterRepository {
  List<LocalBackupInfo> backups = [];
  final restored = <String>[];
  bool failLoad = false;

  @override
  Future<List<LocalBackupInfo>> listLocalBackups() async {
    if (failLoad) throw StateError('Unavailable');
    return backups;
  }

  @override
  Future<String> createLocalBackup() async {
    backups = [
      LocalBackupInfo(
        id: 'new',
        createdAt: DateTime(2026, 11, 25),
        characterCount: 2,
      ),
      ...backups,
    ].take(3).toList();
    return '{}';
  }

  @override
  Future<List<Character>> restoreLocalBackup(String id) async {
    restored.add(id);
    return [];
  }
}

Future<void> _pump(WidgetTester tester, _BackupsRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [characterRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LocalBackupsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty history allows saving and then shows the local copy', (
    tester,
  ) async {
    final repository = _BackupsRepository();
    await _pump(tester, repository);
    expect(find.text('No local backups yet.'), findsOneWidget);
    await tester.tap(find.text('Save a copy now'));
    await tester.pumpAndSettle();
    expect(find.text('No local backups yet.'), findsNothing);
    expect(find.text('Characters: 2'), findsOneWidget);
    expect(find.text('Local backup saved.'), findsOneWidget);
    expect(find.text('Export backup'), findsOneWidget);
  });

  testWidgets('restore explains copy semantics and requires confirmation', (
    tester,
  ) async {
    final repository = _BackupsRepository()
      ..backups = [
        LocalBackupInfo(
          id: 'one',
          createdAt: DateTime(2026),
          characterCount: 1,
        ),
      ];
    await _pump(tester, repository);
    await tester.tap(find.text('Restore copies'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Characters will be added as new copies. Your current characters will be kept.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.restored, isEmpty);
    await tester.tap(find.text('Restore copies'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Restore copies'));
    await tester.pumpAndSettle();
    expect(repository.restored, ['one']);
    expect(find.text('0 characters imported from backup.'), findsOneWidget);
  });

  testWidgets('load failures can be retried without leaving settings', (
    tester,
  ) async {
    final repository = _BackupsRepository()..failLoad = true;
    await _pump(tester, repository);
    expect(find.text('Could not load local backups.'), findsOneWidget);
    repository.failLoad = false;
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('No local backups yet.'), findsOneWidget);
    expect(find.text('Could not load local backups.'), findsNothing);
  });
}
