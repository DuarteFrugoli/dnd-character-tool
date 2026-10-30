import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/features/home/credits_screen.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/shared/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('both packs carry the CC-BY-4.0 notice of their SRD version', () async {
    for (final (pack, version) in [
      (SrdContentPackRegistry.srd51, '5.1'),
      (SrdContentPackRegistry.srd521, '5.2.1'),
    ]) {
      final manifest = await SrdDataSource.forPack(pack).getManifest();
      expect(manifest.version, version);
      expect(manifest.license, 'CC-BY-4.0');
      expect(manifest.attribution, contains('System Reference Document $version'));
      expect(manifest.attribution, contains('Wizards of the Coast LLC'));
    }
  });

  testWidgets('credits show both SRD notices', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final srd51 = await tester.runAsync(
      () => SrdDataSource.forPack(SrdContentPackRegistry.srd51).getManifest(),
    );
    final srd521 = await tester.runAsync(
      () => SrdDataSource.forPack(SrdContentPackRegistry.srd521).getManifest(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          srdManifestForPackProvider.overrideWith(
            (ref, packId) async => packId == ContentPackId.srd51 ? srd51! : srd521!,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CreditsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(srd51!.attribution), findsOneWidget);
    expect(find.text(srd521!.attribution), findsOneWidget);
    expect(find.textContaining('not affiliated'), findsOneWidget);
  });
}
