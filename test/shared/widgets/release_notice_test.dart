import 'package:dnd_character_tool/features/character_creation/ruleset_selection_screen.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/shared/widgets/whats_new_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edition picker discloses incomplete 2024 before selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RulesetSelectionScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(tiles, hasLength(2));
    expect((tiles[0].title! as Text).data, isNot(contains('Beta')));
    expect((tiles[1].title! as Text).data, contains('Beta'));
    expect((tiles[1].subtitle! as Text).data, contains('incompletos'));
    expect(tiles[1].onTap, isNotNull);
  });

  testWidgets('current announcement explains 2014 additions and 2024 limits', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showWhatsNewDialog(context, version: '3.0.2'),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('More 2014 content'), findsOneWidget);
    expect(find.text('D&D 2024: beta'), findsOneWidget);
    expect(find.textContaining('manual application'), findsOneWidget);
    expect(find.textContaining('three cantrip choices'), findsOneWidget);
    expect(find.text('Version 3.0.2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
