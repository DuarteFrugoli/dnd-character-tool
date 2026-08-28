import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'storage_backend_stub.dart'
    if (dart.library.io) 'storage_backend_native.dart'
    if (dart.library.js_interop) 'storage_backend_web.dart';
import 'local_image_payload.dart';

import '../../models/models.dart';

class CharacterStorageIssue {
  const CharacterStorageIssue({
    required this.source,
    required this.message,
    this.id,
  });

  final String source;
  final String? id;
  final String message;
}

class CharacterLoadReport {
  const CharacterLoadReport({required this.characters, required this.issues});

  final List<Character> characters;
  final List<CharacterStorageIssue> issues;

  bool get hasIssues => issues.isNotEmpty;
}

/// Fachada de persistência de personagens.
/// Delega ao backend correto para cada plataforma:
/// - nativo (Android/iOS/Windows/macOS/Linux): arquivos JSON no disco
/// - web: IndexedDB
class CharacterLocalDataSource {
  CharacterLocalDataSource._() : _backend = createStorageBackend();

  /// Constructor for testing: accepts a custom [StorageBackend].
  CharacterLocalDataSource.fromBackend(StorageBackend backend)
    : _backend = backend;

  static final CharacterLocalDataSource instance = CharacterLocalDataSource._();

  final StorageBackend _backend;

  // ---------------------------------------------------------------------------
  // Personagens
  // ---------------------------------------------------------------------------

  Future<List<Character>> loadAll() async {
    return (await loadAllWithReport()).characters;
  }

  Future<CharacterLoadReport> loadAllWithReport() async {
    final scan = await _backend.scanCharacters();
    final issues = [for (final issue in scan.issues) _fromStorageIssue(issue)];
    for (final issue in issues) {
      _logStorageIssue(issue);
    }

    final characters = <Character>[];
    for (final record in scan.records) {
      try {
        characters.add(Character.fromJson(record.json));
      } catch (_) {
        final issue = CharacterStorageIssue(
          source: record.source,
          id: record.id,
          message: 'corrupted_character',
        );
        issues.add(issue);
        _logStorageIssue(issue);
      }
    }
    characters.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return CharacterLoadReport(characters: characters, issues: issues);
  }

  Future<Character?> loadById(String id) async {
    final StoredCharacterJson? record;
    try {
      record = await _backend.loadCharacterRecord(id);
    } on StorageReadException catch (e) {
      _logStorageIssue(_fromStorageIssue(e.issue));
      return null;
    }
    if (record == null) return null;
    try {
      return Character.fromJson(record.json);
    } catch (_) {
      _logStorageIssue(
        CharacterStorageIssue(
          source: record.source,
          id: record.id,
          message: 'corrupted_character',
        ),
      );
      return null;
    }
  }

  CharacterStorageIssue _fromStorageIssue(StorageReadIssue issue) {
    return CharacterStorageIssue(
      source: issue.source,
      id: issue.id,
      message: issue.message,
    );
  }

  void _logStorageIssue(CharacterStorageIssue issue) {
    final id = issue.id == null ? '' : ' id=${issue.id}';
    debugPrint(
      'Character storage issue: ${issue.message} at ${issue.source}$id',
    );
  }

  Future<void> save(Character character) async {
    await _backend.saveCharacter(character.id, character.toJson());
  }

  Future<void> delete(String id) async {
    await _backend.deleteCharacter(id);
  }

  Future<bool> exists(String id) async {
    return _backend.characterExists(id);
  }

  // ---------------------------------------------------------------------------
  // Imagens
  // ---------------------------------------------------------------------------

  Future<String?> saveImage(String characterId, String sourcePath) async {
    return _backend.saveImage(characterId, sourcePath);
  }

  Future<String?> resolveImagePath(String? fileName) async {
    return _backend.resolveImagePath(fileName);
  }

  Future<void> deleteImage(String? fileName) async {
    await _backend.deleteImage(fileName);
  }

  Future<({Uint8List? bytes, String? mimeType})> readImagePayload(
    Character character,
  ) {
    return _readImagePayload(character.imagePath);
  }

  Future<String?> copyImageForCharacter(
    Character source, {
    required String imageOwnerId,
  }) async {
    final imagePath = source.imagePath;
    if (imagePath == null) return null;

    final resolvedPath = await _tryResolveImagePath(imagePath);
    final directCopyCandidates = <String>[
      ?resolvedPath,
      if (resolvedPath != imagePath) imagePath,
    ];
    for (final candidate in directCopyCandidates) {
      try {
        final copiedPath = await saveImage(imageOwnerId, candidate);
        if (copiedPath != null && copiedPath != imagePath) {
          return copiedPath;
        }
      } catch (_) {}
    }

    final image = await _readImagePayload(imagePath);
    final bytes = image.bytes;
    if (bytes != null) {
      try {
        return await persistImportedImagePayload(
          backend: _backend,
          imageOwnerId: imageOwnerId,
          imageData: base64Encode(bytes),
          mimeType: image.mimeType ?? 'image/jpeg',
        );
      } catch (_) {}
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Export / Import JSON
  // ---------------------------------------------------------------------------

  Future<String> exportToJson(Character character) {
    return exportToFileJson(character);
  }

  Future<String> exportToFileJson(Character character) async {
    final image = await readImagePayload(character);

    return compute(_encodeExportPayload, {
      'character': character.copyWith(clearImagePath: true).toJson(),
      'bytes': image.bytes,
      'mimeType': image.mimeType,
      'exportedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<String> exportBackupToFileJson() async {
    final characters = await loadAll();
    final exportedCharacters = <Map<String, dynamic>>[];

    for (final character in characters) {
      final image = await readImagePayload(character);
      final exportedCharacter = <String, dynamic>{
        'character': character.copyWith(clearImagePath: true).toJson(),
      };
      final imageBytes = image.bytes;
      if (imageBytes != null) {
        exportedCharacter['imageData'] = base64Encode(imageBytes);
      }
      final imageMimeType = image.mimeType;
      if (imageMimeType != null) {
        exportedCharacter['imageMimeType'] = imageMimeType;
      }
      exportedCharacters.add(exportedCharacter);
    }

    return compute(_encodeBackupPayload, {
      'characters': exportedCharacters,
      'exportedAt': DateTime.now().toIso8601String(),
    });
  }

  Character importFromJson(String jsonString) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (_) {
      throw const FormatException('invalid_json');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('not_object');
    }

    if (!decoded.containsKey('character')) {
      throw const FormatException('missing_character');
    }

    final characterJson = decoded['character'];
    if (characterJson is! Map<String, dynamic>) {
      throw const FormatException('corrupted_character');
    }

    try {
      return Character.fromJson(characterJson).copyWith(clearImagePath: true);
    } catch (_) {
      throw const FormatException('corrupted_character');
    }
  }

  List<Map<String, dynamic>> backupEntriesFromFileJson(String fileJson) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(fileJson);
    } catch (_) {
      throw const FormatException('invalid_json');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('not_object');
    }

    final entries = decoded['characters'];
    if (entries is! List) {
      throw const FormatException('missing_characters');
    }

    final result = <Map<String, dynamic>>[];
    for (final entry in entries) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('corrupted_character');
      }
      result.add(entry);
    }
    return result;
  }

  /// Imports a character from a `.dndchar` file JSON string.
  /// Returns the parsed [Character] with image saved to disk (if present).
  /// The caller is responsible for assigning a final ID before persisting.
  Future<Character> importFromDndCharFile(
    String fileJson, {
    String imageOwnerId = 'import_tmp',
  }) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(fileJson);
    } catch (_) {
      throw const FormatException('invalid_json');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('not_object');
    }

    return importFromDndCharPayload(decoded, imageOwnerId: imageOwnerId);
  }

  Future<Character> importFromDndCharPayload(
    Map<String, dynamic> decoded, {
    String imageOwnerId = 'import_tmp',
  }) async {
    if (!decoded.containsKey('character')) {
      throw const FormatException('missing_character');
    }

    final characterJson = decoded['character'];
    if (characterJson is! Map<String, dynamic>) {
      throw const FormatException('corrupted_character');
    }

    Character character;
    try {
      character = Character.fromJson(
        characterJson,
      ).copyWith(clearImagePath: true);
    } catch (_) {
      throw const FormatException('corrupted_character');
    }

    final imageData = decoded['imageData'] as String?;
    final imageMimeType = decoded['imageMimeType'] as String?;

    if (imageData != null) {
      try {
        final mimeType = imageMimeType ?? 'image/jpeg';
        final savedPath = await persistImportedImagePayload(
          backend: _backend,
          imageOwnerId: imageOwnerId,
          imageData: imageData,
          mimeType: mimeType,
        );
        if (savedPath != null) {
          character = character.copyWith(imagePath: savedPath);
        }
      } catch (_) {
        // Image import failed — proceed without image
      }
    }

    return character;
  }

  Future<({Uint8List? bytes, String? mimeType})> _readImagePayload(
    String? imagePath,
  ) async {
    if (imagePath == null) {
      return (bytes: null, mimeType: null);
    }

    if (imagePath.startsWith('data:')) {
      final commaIdx = imagePath.indexOf(',');
      if (commaIdx == -1) {
        return (bytes: null, mimeType: null);
      }

      final header = imagePath.substring(5, commaIdx);
      final mimeType = header.split(';').first;
      try {
        return (
          bytes: base64Decode(imagePath.substring(commaIdx + 1)),
          mimeType: mimeType,
        );
      } catch (_) {
        return (bytes: null, mimeType: null);
      }
    }

    final resolvedPath = await _tryResolveImagePath(imagePath);
    final candidates = <String>[
      ?resolvedPath,
      if (resolvedPath != imagePath) imagePath,
    ];
    for (final candidate in candidates) {
      try {
        final image = await readStoredImagePayload(candidate);
        if (image.bytes != null) return image;
      } catch (_) {}
    }

    return (bytes: null, mimeType: null);
  }

  Future<String?> _tryResolveImagePath(String imagePath) async {
    try {
      return await resolveImagePath(imagePath);
    } catch (_) {
      return null;
    }
  }
}

// Top-level function required by compute() — runs in a separate isolate.
String _encodeExportPayload(Map<String, dynamic> args) {
  final characterJson = args['character'] as Map<String, dynamic>;
  final bytes = args['bytes'] as Uint8List?;
  final mimeType = args['mimeType'] as String?;
  final exportedAt = args['exportedAt'] as String;

  final payload = <String, dynamic>{
    'version': '1.0',
    'exportedAt': exportedAt,
    'character': characterJson,
  };
  if (bytes != null) {
    payload['imageData'] = base64Encode(bytes);
  }
  if (mimeType != null) {
    payload['imageMimeType'] = mimeType;
  }
  return const JsonEncoder.withIndent('  ').convert(payload);
}

String _encodeBackupPayload(Map<String, dynamic> args) {
  final characters = args['characters'] as List<Map<String, dynamic>>;
  final exportedAt = args['exportedAt'] as String;

  final payload = <String, dynamic>{
    'version': '1.0',
    'type': 'dnd-character-tool-backup',
    'exportedAt': exportedAt,
    'characterCount': characters.length,
    'characters': characters,
  };
  return const JsonEncoder.withIndent('  ').convert(payload);
}
