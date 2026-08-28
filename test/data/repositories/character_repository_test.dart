import 'dart:convert';
import 'dart:io';

import 'package:dnd_character_tool/data/datasources/local/character_local_data_source.dart';
import 'package:dnd_character_tool/data/datasources/local/storage_backend_stub.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/repositories/character_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Minimal fake storage backend ──────────────────────────────────────────────

class _InMemoryBackend extends StorageBackend {
  final Map<String, Map<String, dynamic>> _chars = {};
  final Directory _imageDir = Directory.systemTemp.createTempSync(
    'dnd_character_repository_test_images_',
  );
  int _imageCounter = 0;

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
  Future<String?> saveImage(String characterId, String sourcePath) async {
    if (sourcePath.startsWith('data:')) {
      final commaIdx = sourcePath.indexOf(',');
      if (commaIdx == -1) return null;
      final header = sourcePath.substring(5, commaIdx);
      final mimeType = header.split(';').first;
      final ext = mimeType == 'image/png' ? 'png' : 'jpg';
      final path = '${_imageDir.path}/${characterId}_${_imageCounter++}.$ext';
      await File(
        path,
      ).writeAsBytes(base64Decode(sourcePath.substring(commaIdx + 1)));
      return path;
    }
    final source = File(sourcePath);
    if (!await source.exists()) return null;
    final ext = sourcePath.contains('.')
        ? sourcePath.split('.').last.toLowerCase()
        : 'jpg';
    final path = '${_imageDir.path}/${characterId}_${_imageCounter++}.$ext';
    await source.copy(path);
    return path;
  }

  @override
  Future<String?> resolveImagePath(String? fileName) async {
    if (fileName == null) return null;
    return await File(fileName).exists() ? fileName : null;
  }

  @override
  Future<void> deleteImage(String? fileName) async {
    if (fileName == null) return;
    final file = File(fileName);
    if (await file.exists()) await file.delete();
  }

  Future<String> writeImage(
    List<int> bytes, {
    String name = 'source.jpg',
  }) async {
    final file = File('${_imageDir.path}/$name');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  void dispose() {
    if (_imageDir.existsSync()) {
      _imageDir.deleteSync(recursive: true);
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Character _makeCharacter({
  String id = 'original-id',
  String name = 'Test Hero',
  String? imagePath,
}) {
  final now = DateTime(2024);
  return Character(
    id: id,
    name: name,
    race: 'Human',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    imagePath: imagePath,
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

  tearDown(() {
    backend.dispose();
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

    test('exportToJson includes readable character images', () async {
      final sourceImagePath = await backend.writeImage(
        [2, 4, 6, 8],
        name: 'json-source.jpg',
      );
      final original = _makeCharacter(
        id: 'with-image',
        imagePath: sourceImagePath,
      );

      final jsonStr = await _exportCharacter(repo, original);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['imageData'], base64Encode([2, 4, 6, 8]));
      expect(decoded['imageMimeType'], 'image/jpeg');
    });

    test(
      'preserves embedded image data when the payload includes it',
      () async {
        final exported = _makeCharacter(id: 'exported-id', name: 'With Image');
        final payload = jsonEncode({
          'version': '1.0',
          'character': exported.toJson(),
          'imageData': base64Encode([1, 2, 3, 4]),
          'imageMimeType': 'image/png',
        });

        final imported = await repo.importFromJson(payload);

        expect(imported.imagePath, isNotNull);
        expect(await File(imported.imagePath!).readAsBytes(), [1, 2, 3, 4]);
      },
    );

    test('duplicate copies the image into a new local image path', () async {
      final sourceImagePath = await backend.writeImage([5, 6, 7, 8]);
      final original = _makeCharacter(
        id: 'original-id',
        imagePath: sourceImagePath,
      );
      await repo.save(original);

      final duplicate = await repo.duplicate(
        original,
        name: 'Test Hero Copy',
        isPinned: false,
        sortOrder: 1,
      );

      expect(duplicate.imagePath, isNotNull);
      expect(duplicate.imagePath, isNot(sourceImagePath));
      expect(await File(duplicate.imagePath!).readAsBytes(), [5, 6, 7, 8]);
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
      'importBackupFromFileJson preserves embedded character images',
      () async {
        final exported = _makeCharacter(id: 'exported-a', name: 'A');
        final payload = jsonEncode({
          'type': 'dnd-character-tool-backup',
          'characters': [
            {
              'character': exported.toJson(),
              'imageData': base64Encode([9, 8, 7, 6]),
              'imageMimeType': 'image/jpeg',
            },
          ],
        });

        final imported = await repo.importBackupFromFileJson(payload);

        expect(imported.single.imagePath, isNotNull);
        expect(await File(imported.single.imagePath!).readAsBytes(), [
          9,
          8,
          7,
          6,
        ]);
      },
    );

    test('exportBackupToFileJson embeds readable character images', () async {
      final sourceImagePath = await backend.writeImage([
        4,
        3,
        2,
        1,
      ], name: 'backup-source.png');
      await repo.save(
        _makeCharacter(
          id: 'with-image',
          name: 'With Image',
          imagePath: sourceImagePath,
        ),
      );

      final backupJson = await repo.exportBackupToFileJson();
      final decoded = jsonDecode(backupJson) as Map<String, dynamic>;
      final entries = decoded['characters'] as List<dynamic>;
      final exported = entries.single as Map<String, dynamic>;

      expect(exported['imageData'], base64Encode([4, 3, 2, 1]));
      expect(exported['imageMimeType'], 'image/png');
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
    test('export and import preserves the embedded character image', () async {
      final sourceImagePath = await backend.writeImage([
        3,
        1,
        4,
        1,
      ], name: 'dndchar-source.jpg');
      final exported = _makeCharacter(
        id: 'exported-id',
        name: 'With Image',
        imagePath: sourceImagePath,
      );

      final fileJson = await repo.exportToFileJson(exported);
      final decoded = jsonDecode(fileJson) as Map<String, dynamic>;
      final imported = await repo.importFromDndCharFile(fileJson);

      expect(decoded['imageData'], base64Encode([3, 1, 4, 1]));
      expect(imported.imagePath, isNotNull);
      expect(imported.imagePath, isNot(sourceImagePath));
      expect(await File(imported.imagePath!).readAsBytes(), [3, 1, 4, 1]);
    });

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
