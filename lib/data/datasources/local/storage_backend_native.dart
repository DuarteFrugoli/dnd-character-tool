import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'storage_backend_stub.dart' show StorageBackend;
export 'storage_backend_stub.dart' show StorageBackend;

StorageBackend createStorageBackend() => NativeStorageBackend();

class NativeStorageBackend implements StorageBackend {
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

  // ---- Personagens ----

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() async {
    final dir = await _charactersDir;
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'));

    final result = <Map<String, dynamic>>[];
    for (final file in files) {
      try {
        result.add(jsonDecode(await file.readAsString()) as Map<String, dynamic>);
      } catch (_) {
        // arquivo corrompido — ignora
      }
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>?> loadCharacter(String id) async {
    final file = await _fileForId(id);
    if (!await file.exists()) return null;
    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCharacter(String id, Map<String, dynamic> json) async {
    final file = await _fileForId(id);
    await file.writeAsString(jsonEncode(json));
  }

  @override
  Future<void> deleteCharacter(String id) async {
    final file = await _fileForId(id);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<bool> characterExists(String id) async {
    return (await _fileForId(id)).exists();
  }

  Future<File> _fileForId(String id) async {
    // Allow only safe alphanumeric + hyphen/underscore characters to prevent
    // path traversal (e.g. an id like "../../etc/passwd" from a crafted import).
    if (!RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(id)) {
      throw ArgumentError('Invalid character id: "$id"');
    }
    final dir = await _charactersDir;
    return File('${dir.path}/$id.json');
  }

  // ---- Imagens ----

  /// Returns true if [path] is an absolute filesystem path.
  bool _isAbsolute(String path) =>
      path.startsWith('/') || (path.length >= 2 && path[1] == ':');

  @override
  Future<String?> saveImage(String characterId, String sourcePath) async {
    final dir = await _imagesDir;
    final ext = sourcePath.contains('.')
        ? sourcePath.split('.').last.toLowerCase()
        : 'jpg';
    // Use a timestamp so the path always changes on update, preventing
    // Flutter's FileImage cache from serving the stale image.
    final ts = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${characterId}_$ts.$ext';
    final dest = File('${dir.path}/$fileName');
    await File(sourcePath).copy(dest.path);
    return dest.path; // full absolute path
  }

  @override
  Future<String?> resolveImagePath(String? fileName) async {
    if (fileName == null) return null;
    // Support both absolute paths (new) and bare filenames (legacy).
    final file = _isAbsolute(fileName)
        ? File(fileName)
        : File('${(await _imagesDir).path}/$fileName');
    return await file.exists() ? file.path : null;
  }

  @override
  Future<void> deleteImage(String? fileName) async {
    if (fileName == null) return;
    // Support both absolute paths (new) and bare filenames (legacy).
    final file = _isAbsolute(fileName)
        ? File(fileName)
        : File('${(await _imagesDir).path}/$fileName');
    if (await file.exists()) await file.delete();
  }
}
