import 'package:dnd_character_tool/core/whats_new/whats_new_service.dart';
import 'package:dnd_character_tool/core/services/incoming_file_service.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/features/character_list/character_list_provider.dart';
import 'package:dnd_character_tool/features/character_list/character_list_screen.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _convert = 'Convert to D&D 2024';

class _Characters extends CharacterListNotifier {
  _Characters(this.character);

  final Character character;

  @override
  Future<List<Character>> build() async => [character];
}

class _NoWhatsNew extends WhatsNewService {
  @override
  Future<WhatsNewInfo?> pendingInfo() async => null;
}

Character _character(RulesetId ruleset) {
  final now = DateTime(2024);
  return Character(
    id: 'hero',
    rulesetId: ruleset,
    contentPackId: ruleset == RulesetId.dnd2024
        ? ContentPackId.srd521
        : ContentPackId.srd51,
    name: 'Hero',
    race: 'Human',
    characterClass: 'Fighter',
    level: 3,
    classes: const [
      CharacterClassEntry(
        id: 'primary',
        className: 'Fighter',
        level: 3,
        isStartingClass: true,
      ),
    ],
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 20, current: 20),
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _openMenu(WidgetTester tester, Character character) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const CharacterListScreen()),
      GoRoute(
        path: '/convert/2024/:id',
        builder: (_, state) => Text('converting ${state.pathParameters['id']}'),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        characterListProvider.overrideWith(() => _Characters(character)),
        whatsNewServiceProvider.overrideWithValue(_NoWhatsNew()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('incoming character and backup prompts are shown one at a time', (
    tester,
  ) async {
    IncomingFileService.instance.initialize();
    await _openMenu(tester, _character(RulesetId.dnd2014));
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(CharacterListScreen)),
    )!;
    const codec = StandardMethodCodec();
    for (final json in ['{"character":{}}', '{"characters":[]}']) {
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'dnd.character/file_import',
        codec.encodeMethodCall(MethodCall('onFileReceived', json)),
        (_) {},
      );
    }
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(l10n.importFileIncoming), findsOneWidget);
    await tester.tap(find.text(l10n.dialogCancel));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(l10n.incomingBackupPrompt), findsOneWidget);
    await tester.tap(find.text(l10n.dialogCancel));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a 2014 character opens the conversion from the list menu', (
    tester,
  ) async {
    await _openMenu(tester, _character(RulesetId.dnd2014));
    await tester.tap(find.text(_convert));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hero'), findsWidgets);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('converting hero'), findsOneWidget);
  });

  testWidgets('cancelling keeps the player in the list', (tester) async {
    await _openMenu(tester, _character(RulesetId.dnd2014));
    await tester.tap(find.text(_convert));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();
    expect(find.text('converting hero'), findsNothing);
  });

  testWidgets('a 2024 character has no conversion in the list menu', (
    tester,
  ) async {
    await _openMenu(tester, _character(RulesetId.dnd2024));
    expect(find.text(_convert), findsNothing);
  });
}
