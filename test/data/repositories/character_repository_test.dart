import 'dart:convert';

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

Character _makeCharacter({
  String id = 'original-id',
  String name = 'Test Hero',
}) {
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
  TestWidgetsFlutterBinding.ensureInitialized();

  late CharacterRepository repo;
  late _InMemoryBackend backend;

  setUp(() {
    backend = _InMemoryBackend();
    final ds = CharacterLocalDataSource.fromBackend(backend);
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

  group('backup import/export', () {
    test(
      'exportBackupToFileJson writes a backup payload with characters list',
      () async {
        await repo.save(_makeCharacter(id: 'one', name: 'One'));
        await repo.save(_makeCharacter(id: 'two', name: 'Two'));

        final backupJson = await repo.exportBackupToFileJson();
        final decoded = jsonDecode(backupJson) as Map<String, dynamic>;

        expect(decoded['type'], 'dnd-character-tool-backup');
        expect(decoded['characterCount'], 2);
        expect(decoded['characters'], isA<List<dynamic>>());
        expect(
          (decoded['characters'] as List<dynamic>).first,
          containsPair('character', isA<Map<String, dynamic>>()),
        );
      },
    );

    test('importBackupFromFileJson imports every entry with new IDs', () async {
      final exportedA = _makeCharacter(id: 'exported-a', name: 'A');
      final exportedB = _makeCharacter(id: 'exported-b', name: 'B');
      final payload = jsonEncode({
        'type': 'dnd-character-tool-backup',
        'characters': [
          {'character': exportedA.toJson()},
          {'character': exportedB.toJson()},
        ],
      });

      final imported = await repo.importBackupFromFileJson(payload);

      expect(imported.map((character) => character.name), ['A', 'B']);
      expect(
        imported.map((character) => character.id),
        isNot(contains('exported-a')),
      );
      expect(
        imported.map((character) => character.id),
        isNot(contains('exported-b')),
      );
      expect(await repo.getById(imported.first.id), isNotNull);
      expect(backend._chars, hasLength(2));
    });

    test(
      'importBackupFromFileJson rejects a single-character payload',
      () async {
        final payload = await repo.exportToJson(_makeCharacter());

        expect(
          () => repo.importBackupFromFileJson(payload),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });

  group('dndchar file import', () {
    test(
      'importFromDndCharFile assigns a new ID and ignores broken image data',
      () async {
        final exported = _makeCharacter(id: 'exported-id', name: 'With Image');
        final payload = jsonEncode({
          'version': '1.0',
          'character': exported.toJson(),
          'imageData': 'not-base64',
          'imageMimeType': 'image/jpeg',
        });

        final imported = await repo.importFromDndCharFile(payload);

        expect(imported.name, 'With Image');
        expect(imported.id, isNot('exported-id'));
        expect(imported.imagePath, isNull);
        expect(await repo.getById(imported.id), isNotNull);
      },
    );

    test('importFromDndCharFile rejects payloads without character', () async {
      expect(
        () => repo.importFromDndCharFile(jsonEncode({'characters': []})),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
