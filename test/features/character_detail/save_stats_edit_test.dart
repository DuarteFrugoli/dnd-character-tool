import 'package:dnd_character_tool/data/datasources/local/character_local_data_source.dart';
import 'package:dnd_character_tool/data/datasources/local/storage_backend_stub.dart';
import 'package:dnd_character_tool/data/models/ability_scores.dart';
import 'package:dnd_character_tool/data/models/character.dart';
import 'package:dnd_character_tool/data/models/hit_points.dart';
import 'package:dnd_character_tool/data/repositories/character_repository.dart';
import 'package:dnd_character_tool/features/character_detail/character_detail_provider.dart';
import 'package:dnd_character_tool/shared/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── In-memory backend (counts writes) ────────────────────────────────────────

class _CountingBackend implements StorageBackend {
  final Map<String, Map<String, dynamic>> _store = {};
  int writeCount = 0;

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() async =>
      _store.values.toList();

  @override
  Future<Map<String, dynamic>?> loadCharacter(String id) async => _store[id];

  @override
  Future<void> saveCharacter(String id, Map<String, dynamic> json) async {
    writeCount++;
    _store[id] = json;
  }

  @override
  Future<void> deleteCharacter(String id) async => _store.remove(id);

  @override
  Future<bool> characterExists(String id) async => _store.containsKey(id);

  @override
  Future<String?> saveImage(String characterId, String sourcePath) async =>
      null;

  @override
  Future<String?> resolveImagePath(String? fileName) async => null;

  @override
  Future<void> deleteImage(String? fileName) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _id = 'test-hero';
final _now = DateTime(2024);

Character _baseCharacter({
  int hpMax = 20,
  int hpCurrent = 15,
  int speed = 30,
  int xp = 1000,
}) => Character(
  id: _id,
  name: 'Test Hero',
  race: 'Human',
  characterClass: 'Fighter',
  abilityScores: const AbilityScores(),
  hitPoints: HitPoints(maximum: hpMax, current: hpCurrent),
  speed: speed,
  experiencePoints: xp,
  createdAt: _now,
  updatedAt: _now,
);

Future<({ProviderContainer container, _CountingBackend backend})> _setup(
  Character initialCharacter,
) async {
  final backend = _CountingBackend();
  final ds = CharacterLocalDataSource.fromBackend(backend);
  final repo = CharacterRepository(dataSource: ds);

  // Pre-save so the provider can load it.
  await repo.save(initialCharacter);
  final writesBeforeTest = backend.writeCount;

  final container = ProviderContainer(
    overrides: [characterRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);

  // Initialise the provider.
  await container.read(characterDetailProvider(_id).future);

  // Reset write counter so only test-driven writes are counted.
  backend.writeCount = writesBeforeTest - writesBeforeTest; // = 0

  return (container: container, backend: backend);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── saveStatsEdit: HP clamping ────────────────────────────────────────────
  group('saveStatsEdit – HP clamping', () {
    test('reducing hpMax below currentHp clamps currentHp', () async {
      final (:container, :backend) = await _setup(
        _baseCharacter(hpMax: 20, hpCurrent: 15),
      );

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: 10, speed: null, xp: null);

      final updated = container.read(characterDetailProvider(_id)).valueOrNull!;
      expect(updated.hitPoints.maximum, 10);
      expect(updated.hitPoints.current, 10); // clamped from 15
    });

    test('currentHp stays unchanged when new maxHp is larger', () async {
      final (:container, :backend) = await _setup(
        _baseCharacter(hpMax: 20, hpCurrent: 15),
      );

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: 30, speed: null, xp: null);

      final updated = container.read(characterDetailProvider(_id)).valueOrNull!;
      expect(updated.hitPoints.maximum, 30);
      expect(updated.hitPoints.current, 15); // unchanged
    });

    test('hpMax is clamped to minimum 1', () async {
      final (:container, :backend) = await _setup(
        _baseCharacter(hpMax: 20, hpCurrent: 1),
      );

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: 0, speed: null, xp: null);

      final updated = container.read(characterDetailProvider(_id)).valueOrNull!;
      expect(updated.hitPoints.maximum, 1); // clamped from 0
    });

    test('null hpMax leaves HP unchanged', () async {
      final (:container, :backend) = await _setup(
        _baseCharacter(hpMax: 20, hpCurrent: 15),
      );

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: null, speed: 25, xp: null);

      final updated = container.read(characterDetailProvider(_id)).valueOrNull!;
      expect(updated.hitPoints.maximum, 20);
      expect(updated.hitPoints.current, 15);
    });
  });

  // ── saveStatsEdit: atomicity ──────────────────────────────────────────────
  group('saveStatsEdit – atomicity', () {
    test('saves all three fields in a single write', () async {
      final backend = _CountingBackend();
      final ds = CharacterLocalDataSource.fromBackend(backend);
      final repo = CharacterRepository(dataSource: ds);
      await repo.save(
        _baseCharacter(hpMax: 20, hpCurrent: 15, speed: 30, xp: 1000),
      );

      final container = ProviderContainer(
        overrides: [characterRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      await container.read(characterDetailProvider(_id).future);
      final writesBefore = backend.writeCount;

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: 18, speed: 25, xp: 2000);

      // Exactly ONE additional write (atomic), not three.
      expect(backend.writeCount - writesBefore, 1);
    });

    test('all three values are applied in the single write', () async {
      final (:container, :backend) = await _setup(
        _baseCharacter(hpMax: 20, hpCurrent: 15, speed: 30, xp: 1000),
      );

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: 18, speed: 25, xp: 2000);

      final updated = container.read(characterDetailProvider(_id)).valueOrNull!;
      expect(updated.hitPoints.maximum, 18);
      expect(updated.speed, 25);
      expect(updated.experiencePoints, 2000);
    });
  });

  // ── saveStatsEdit: speed and XP clamping ─────────────────────────────────
  group('saveStatsEdit – range clamping', () {
    test('speed is clamped to 0..999', () async {
      final (:container, :backend) = await _setup(_baseCharacter());

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: null, speed: 9999, xp: null);

      final updated = container.read(characterDetailProvider(_id)).valueOrNull!;
      expect(updated.speed, 999);
    });

    test('xp is clamped to 0..999999', () async {
      final (:container, :backend) = await _setup(_baseCharacter());

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: null, speed: null, xp: 9999999);

      final updated = container.read(characterDetailProvider(_id)).valueOrNull!;
      expect(updated.experiencePoints, 999999);
    });

    test('negative speed is clamped to 0', () async {
      final (:container, :backend) = await _setup(_baseCharacter());

      await container
          .read(characterDetailProvider(_id).notifier)
          .saveStatsEdit(hpMax: null, speed: -10, xp: null);

      final updated = container.read(characterDetailProvider(_id)).valueOrNull!;
      expect(updated.speed, 0);
    });
  });
}
