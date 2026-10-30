import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/shared/widgets/character_changes_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  int level = 5,
  int strength = 16,
  List<String> skills = const ['Athletics', 'Perception'],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'hero',
    name: 'Hero',
    race: 'Human',
    characterClass: 'Fighter',
    level: level,
    abilityScores: AbilityScores(strength: strength),
    hitPoints: HitPoints(maximum: level * 10, current: level * 10),
    skillProficiencies: skills,
    createdAt: now,
    updatedAt: now,
  );
}

Future<bool?> _open(WidgetTester tester, {List<String> notes = const []}) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => FilledButton(
          onPressed: () async {
            result = await showCharacterChangesDialog(
              context,
              before: _character(),
              after: _character(level: 1, strength: 14, skills: const ['Perception']),
              i18n: SrdI18nService.english,
              notes: notes,
            );
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('lists the changes and saves only when confirmed', (tester) async {
    await _open(tester, notes: const ['Ability increases stay.']);

    expect(find.text('Review changes'), findsOneWidget);
    expect(find.text('5 → 1'), findsOneWidget);
    expect(find.text('16 → 14'), findsOneWidget);
    expect(find.text('Removed: Athletics'), findsOneWidget);
    expect(find.text('Kept as they are'), findsOneWidget);
    expect(find.text('Ability increases stay.'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Review changes'), findsNothing);
  });

  testWidgets('returns true on save', (tester) async {
    bool? saved;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              saved = await showCharacterChangesDialog(
                context,
                before: _character(),
                after: _character(level: 1),
                i18n: SrdI18nService.english,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(saved, isTrue);
  });
}
