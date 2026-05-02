import 'dart:convert';

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
      'character': character.copyWith(imagePath: null).toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Character importFromJson(String jsonString) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (_) {
      throw const FormatException('O texto colado não é um JSON válido.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Formato inválido: esperado um objeto JSON.');
    }

    if (!decoded.containsKey('character')) {
      throw const FormatException(
          'JSON inválido: campo "character" não encontrado. Certifique-se de usar um JSON exportado por este app.');
    }

    final characterJson = decoded['character'];
    if (characterJson is! Map<String, dynamic>) {
      throw const FormatException('JSON inválido: campo "character" corrompido.');
    }

    try {
      return Character.fromJson(characterJson);
    } catch (_) {
      throw const FormatException(
          'Não foi possível ler o personagem. O JSON pode estar incompleto ou ser de uma versão incompatível.');
    }
  }
}

