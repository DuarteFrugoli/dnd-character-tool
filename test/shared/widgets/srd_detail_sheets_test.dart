import 'package:dnd_character_tool/data/datasources/srd/srd_2024_creation_catalog.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/shared/widgets/srd_detail_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _open(WidgetTester tester, void Function(BuildContext context) show) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(onPressed: () => show(context), child: const Text('open')),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  // Features and traits load from the bundled assets.
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  final i18n = SrdI18nService.englishForPack(SrdContentPackRegistry.srd521);

  testWidgets('the class sheet shows 2024 class data, features and subclasses', (tester) async {
    final classes = (await tester.runAsync(Creation2024Catalog.loadClasses))!;
    final subclasses = (await tester.runAsync(Creation2024Catalog.loadSubclasses))!;
    final barbarian = classes.firstWhere((cls) => cls.name == 'Barbarian');
    await _open(
      tester,
      (context) => showClassDetailSheet(
        context,
        ClassDetail.from2024(barbarian, subclasses['Barbarian']!, subclassFeatureName: 'Subclass'),
        i18n,
      ),
    );
    expect(find.text('Barbarian'), findsOneWidget);
    expect(find.textContaining('d12'), findsOneWidget);
    expect(find.textContaining('Primary ability: Strength'), findsOneWidget);
    expect(find.text('Rage'), findsOneWidget);
    // Subclasses follow the features of all twenty levels.
    await tester.scrollUntilVisible(
      find.text('Path of the Berserker'),
      600,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Path of the Berserker'), findsOneWidget);
  });

  testWidgets('the species sheet shows 2024 sizes, traits and lineages', (tester) async {
    final species = (await tester.runAsync(Creation2024Catalog.loadSpecies))!;
    final elf = species.firstWhere((entry) => entry.name == 'Elf');
    await _open(tester, (context) => showRaceDetailSheet(context, SpeciesDetail.from2024(elf), i18n));
    expect(find.textContaining('Size: Medium'), findsOneWidget);
    expect(find.text('Darkvision'), findsOneWidget);
    expect(find.text('High Elf'), findsOneWidget);
  });
}
