import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'storage_backend_stub.dart'
    if (dart.library.io) 'storage_backend_native.dart'
    if (dart.library.js_interop) 'storage_backend_web.dart';

import '../../models/models.dart';

/// Fachada de persistência de personagens.
/// Delega ao backend correto para cada plataforma:
/// - nativo (Android/iOS/Windows/macOS/Linux): arquivos JSON no disco
/// - web: shared_preferences (localStorage)
class CharacterLocalDataSource {
  CharacterLocalDataSource._() : _backend = createStorageBackend();

  /// Constructor for testing: accepts a custom [StorageBackend].
  CharacterLocalDataSource.fromBackend(StorageBackend backend)
      : _backend = backend;

  static final CharacterLocalDataSource instance =
      CharacterLocalDataSource._();

  final StorageBackend _backend;

  // ---------------------------------------------------------------------------
  // Personagens
  // ---------------------------------------------------------------------------

  Future<List<Character>> loadAll() async {
    final jsons = await _backend.loadAllCharacters();
    final characters = jsons
        .map((j) {
          try {
            return Character.fromJson(j);
          } catch (_) {
            return null;
          }
        })
        .whereType<Character>()
        .toList();
    characters.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return characters;
  }

  Future<Character?> loadById(String id) async {
    final json = await _backend.loadCharacter(id);
    if (json == null) return null;
    try {
      return Character.fromJson(json);
    } catch (_) {
      return null;
    }
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

  // ---------------------------------------------------------------------------
  // Export / Import JSON
  // ---------------------------------------------------------------------------

  Future<String> exportToJson(Character character) async {
    final payload = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'character': character.copyWith(clearImagePath: true).toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<String> exportToFileJson(Character character) async {
    Uint8List? bytes;
    String? mimeType;

    if (character.imagePath != null) {
      final absolutePath = await resolveImagePath(character.imagePath);
      if (absolutePath != null) {
        final file = File(absolutePath);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
          final ext = absolutePath.split('.').last.toLowerCase();
          mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
        }
      }
    }

    return compute(_encodeExportPayload, {
      'character': character.copyWith(clearImagePath: true).toJson(),
      'bytes': bytes,
      'mimeType': mimeType,
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

  /// Imports a character from a `.dndchar` file JSON string.
  /// Returns the parsed [Character] with image saved to disk (if present).
  /// The caller is responsible for assigning a final ID before persisting.
  Future<Character> importFromDndCharFile(String fileJson) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(fileJson);
    } catch (_) {
      throw const FormatException('invalid_json');
    }

    if (decoded is! Map<String, dynamic>) throw const FormatException('not_object');
    if (!decoded.containsKey('character')) throw const FormatException('missing_character');

    final characterJson = decoded['character'];
    if (characterJson is! Map<String, dynamic>) throw const FormatException('corrupted_character');

    Character character;
    try {
      character = Character.fromJson(characterJson).copyWith(clearImagePath: true);
    } catch (_) {
      throw const FormatException('corrupted_character');
    }

    final imageData = decoded['imageData'] as String?;
    final imageMimeType = decoded['imageMimeType'] as String?;

    if (imageData != null) {
      try {
        final bytes = base64Decode(imageData);
        final ext = imageMimeType == 'image/png' ? 'png' : 'jpg';
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/dndchar_import.$ext');
        await tempFile.writeAsBytes(bytes);
        final savedPath = await _backend.saveImage('import_tmp', tempFile.path);
        await tempFile.delete().catchError((_) => File(''));
        if (savedPath != null) {
          character = character.copyWith(imagePath: savedPath);
        }
      } catch (_) {
        // Image import failed — proceed without image
      }
    }

    return character;
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
    if (bytes != null) 'imageData': base64Encode(bytes),
    'imageMimeType': ?mimeType,
    'character': characterJson,
  };
  return const JsonEncoder.withIndent('  ').convert(payload);
}

