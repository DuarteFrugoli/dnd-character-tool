import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/models.dart';

/// Persiste personagens como arquivos JSON individuais no disco.
///
/// Estrutura de diretórios:
/// ```
/// documents/dnd_character_tool/
/// ├── characters/
/// │   └── {uuid}.json
/// └── images/
///     └── {uuid}.jpg   (arquivo de imagem separado)
/// ```
class CharacterLocalDataSource {
  CharacterLocalDataSource._();

  static final CharacterLocalDataSource instance =
      CharacterLocalDataSource._();

  static const _appFolder = 'dnd_character_tool';
  static const _charactersFolder = 'characters';
  static const _imagesFolder = 'images';

  Future<Directory> get _charactersDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_appFolder/$_charactersFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> get _imagesDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_appFolder/$_imagesFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ---------------------------------------------------------------------------
  // Personagens
  // ---------------------------------------------------------------------------

  Future<List<Character>> loadAll() async {
    final dir = await _charactersDir;
    final files = dir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.json'),
        );

    final characters = <Character>[];
    for (final file in files) {
      try {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        characters.add(Character.fromJson(json));
      } catch (_) {
        // arquivo corrompido — ignora e continua
      }
    }

    characters.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return characters;
  }

  Future<Character?> loadById(String id) async {
    final file = await _fileForId(id);
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return Character.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Character character) async {
    final file = await _fileForId(character.id);
    await file.writeAsString(jsonEncode(character.toJson()));
  }

  Future<void> delete(String id) async {
    final file = await _fileForId(id);
    if (await file.exists()) await file.delete();
  }

  Future<bool> exists(String id) async {
    final file = await _fileForId(id);
    return file.exists();
  }

  Future<File> _fileForId(String id) async {
    final dir = await _charactersDir;
    return File('${dir.path}/$id.json');
  }

  // ---------------------------------------------------------------------------
  // Imagens
  // ---------------------------------------------------------------------------

  /// Copia a imagem de [sourcePath] para o diretório de imagens do app.
  /// Retorna o nome do arquivo salvo (não o caminho completo).
  Future<String> saveImage(String characterId, String sourcePath) async {
    final dir = await _imagesDir;
    final ext = sourcePath.contains('.')
        ? sourcePath.split('.').last.toLowerCase()
        : 'jpg';
    final fileName = '$characterId.$ext';
    final dest = File('${dir.path}/$fileName');
    await File(sourcePath).copy(dest.path);
    return fileName;
  }

  /// Retorna o caminho absoluto da imagem a partir do nome do arquivo.
  Future<String?> resolveImagePath(String? fileName) async {
    if (fileName == null) return null;
    final dir = await _imagesDir;
    final file = File('${dir.path}/$fileName');
    return await file.exists() ? file.path : null;
  }

  Future<void> deleteImage(String? fileName) async {
    if (fileName == null) return;
    final dir = await _imagesDir;
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) await file.delete();
  }

  // ---------------------------------------------------------------------------
  // Export / Import JSON
  // ---------------------------------------------------------------------------

  /// Exporta o personagem como string JSON (sem imagem).
  Future<String> exportToJson(Character character) async {
    final payload = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'character': character.copyWith(imagePath: null).toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Parseia um JSON exportado e retorna o Character.
  Character importFromJson(String jsonString) {
    final payload = jsonDecode(jsonString) as Map<String, dynamic>;
    final characterJson = payload['character'] as Map<String, dynamic>;
    return Character.fromJson(characterJson);
  }
}
