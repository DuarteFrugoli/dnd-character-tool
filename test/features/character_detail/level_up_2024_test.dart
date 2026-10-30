import 'package:dnd_character_tool/data/character_progression/progression_2024_engine.dart';
import 'package:dnd_character_tool/data/datasources/local/character_local_data_source.dart';
import 'package:dnd_character_tool/data/datasources/local/storage_backend_stub.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/repositories/character_repository.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/features/character_detail/character_detail_provider.dart';
import 'package:dnd_character_tool/features/character_detail/level_up_2024_sheet.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/shared/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryBackend extends StorageBackend {
  final Map<String, Map<String, dynamic>> store = {};

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() async =>
      store.values.toList();

  @override
  Future<Map<String, dynamic>?> loadCharacter(String id) async => store[id];

  @override
  Future<void> saveCharacter(String id, Map<String, dynamic> json) async {
    store[id] = json;
  }

  @override
  Future<void> deleteCharacter(String id) async => store.remove(id);

  @override
  Future<bool> characterExists(String id) async => store.containsKey(id);

  @override
  Future<String?> saveImage(String characterId, String sourcePath) async => null;

  @override
  Future<String?> resolveImagePath(String? fileName) async => null;

  @override
  Future<void> deleteImage(String? fileName) async {}
}

const _id = 'fighter-2024';

Character _fighter() {
  final now = DateTime(2024);
  return Character(
    id: _id,
    rulesetId: RulesetId.dnd2024,
    contentPackId: ContentPackId.srd521,
    name: 'Fighter',
    race: 'Human',
    characterClass: 'Fighter',
    classes: const [
      CharacterClassEntry(
        id: 'primary',
        className: 'Fighter',
        level: 1,
        isStartingClass: true,
      ),
    ],
    abilityScores: const AbilityScores(strength: 16, constitution: 14),
    hitPoints: const HitPoints(maximum: 12, current: 12),
    hitDicePools: const [
      CharacterHitDiePool(
        dieSize: 10,
        total: 1,
        sourceClass: 'Fighter',
        sourceClassEntryId: 'primary',
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

Future<ProviderContainer> _container(Character character) async {
  final repo = CharacterRepository(
    dataSource: CharacterLocalDataSource.fromBackend(_MemoryBackend()),
  );
  await repo.save(character);
  final container = ProviderContainer(
    overrides: [characterRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  await container.read(characterDetailProvider(_id).future);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('level up and reset round-trip a 2024 sheet without history', () async {
    final container = await _container(_fighter());
    final notifier = container.read(characterDetailProvider(_id).notifier);

    await notifier.levelUp2024(const LevelUp2024Result(className: 'Fighter', classEntryId: 'primary'));
    var saved = container.read(characterDetailProvider(_id)).value!;
    expect(saved.totalLevel, 2);
    expect(saved.hitPoints.maximum, 20);
    expect(saved.levelHistory.map((r) => r.characterLevel), [1, 2]);
    expect(saved.levelHistory.first.hitPointsGained, 12);
    expect(Progression2024Engine.canResetToLevelOne(saved), isTrue);

    await notifier.resetLevels2024();
    saved = container.read(characterDetailProvider(_id)).value!;
    expect(saved.totalLevel, 1);
    expect(saved.hitPoints.maximum, 12);
    expect(saved.levelHistory, hasLength(1));
  });

  testWidgets('wizard levels a 2024 Fighter from 1 to 2', (tester) async {
    final container = await tester.runAsync(() async {
      final container = await _container(_fighter());
      // Assets load outside the fake clock, so warm every catalog first.
      await container.read(srd2024RulesDataProvider.future);
      await container.read(srd2024SpeciesProvider.future);
      await container.read(srdI18nForPackProvider(ContentPackId.srd521).future);
      await container.read(srdWeaponsForPackProvider(ContentPackId.srd521).future);
      return container;
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container!,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => openLevelUp2024Sheet(
                    context,
                    container.read(characterDetailProvider(_id)).value!,
                    _id,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    // Class -> Hit Points -> Summary.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Average'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('+8 HP'), findsNothing);
    expect(find.text('Max HP +8'), findsOneWidget);
    await tester.tap(find.text('Confirm Level Up'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    final saved = container.read(characterDetailProvider(_id)).value!;
    expect(saved.totalLevel, 2);
    expect(find.text('open'), findsOneWidget);
  });
}
