import 'package:dnd_character_tool/data/datasources/local/character_local_data_source.dart';
import 'package:dnd_character_tool/data/datasources/local/storage_backend_stub.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/repositories/character_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Minimal fake storage backend ──────────────────────────────────────────────

class _InMemoryBackend implements StorageBackend {
  final Map<String, Map<String, dynamic>> _chars = {};

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() async =>
      _chars.values.toList();

  @override
  Future<Map<String, dynamic>?> loadCharacter(String id) async => _chars[id];

  @override
  Future<void> saveCharacter(String id, Map<String, dynamic> json) async {
    _chars[id] = json;
  }

  @override
  Future<void> deleteCharacter(String id) async => _chars.remove(id);

  @override
  Future<bool> characterExists(String id) async => _chars.containsKey(id);

  @override
  Future<String?> saveImage(String characterId, String sourcePath) async =>
      null;

  @override
  Future<String?> resolveImagePath(String? fileName) async => null;

  @override
  Future<void> deleteImage(String? fileName) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Character _makeCharacter({String id = 'original-id', String name = 'Test Hero'}) {
  final now = DateTime(2024);
  return Character(
    id: id,
    name: name,
    race: 'Human',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    createdAt: now,
    updatedAt: now,
  );
}

Future<String> _exportCharacter(CharacterRepository repo, Character c) =>
    repo.exportToJson(c);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late CharacterRepository repo;

  setUp(() {
    final ds = CharacterLocalDataSource.fromBackend(_InMemoryBackend());
    repo = CharacterRepository(dataSource: ds);
  });

  group('importFromJson', () {
    test('always assigns a new ID, never uses the exported ID', () async {
      final original = _makeCharacter(id: 'original-id');
      final jsonStr = await _exportCharacter(repo, original);

      final imported = await repo.importFromJson(jsonStr);

      expect(imported.id, isNot(equals('original-id')));
      expect(imported.id, isNotEmpty);
    });

    test('generated ID is a non-empty hex string', () async {
      final original = _makeCharacter();
      await repo.save(original);
      final jsonStr = await _exportCharacter(repo, original);
      final imported = await repo.importFromJson(jsonStr);

      expect(imported.id, matches(RegExp(r'^[0-9a-f]+$')));
    });

    test('two imports of the same JSON produce different IDs', () async {
      final original = _makeCharacter();
      await repo.save(original);
      final jsonStr = await _exportCharacter(repo, original);

      await Future.delayed(const Duration(microseconds: 100));
      final imported1 = await repo.importFromJson(jsonStr);
      await Future.delayed(const Duration(microseconds: 100));
      final imported2 = await repo.importFromJson(jsonStr);

      expect(imported1.id, isNot(equals(imported2.id)));
    });

    test('imported character preserves name', () async {
      final original = _makeCharacter(name: 'Aragorn');
      await repo.save(original);
      final jsonStr = await _exportCharacter(repo, original);
      final imported = await repo.importFromJson(jsonStr);

      expect(imported.name, equals('Aragorn'));
    });

    test('imported character is saved and retrievable by new ID', () async {
      final original = _makeCharacter();
      await repo.save(original);
      final jsonStr = await _exportCharacter(repo, original);
      final imported = await repo.importFromJson(jsonStr);

      final retrieved = await repo.getById(imported.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(imported.id));
    });

    test('throws FormatException for invalid JSON', () async {
      expect(
        () => repo.importFromJson('not valid json{{'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
