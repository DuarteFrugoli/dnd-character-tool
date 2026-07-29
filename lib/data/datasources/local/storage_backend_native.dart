import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'storage_backend_stub.dart'
    show
        StorageBackend,
        StorageCharacterScan,
        StorageReadException,
        StorageReadIssue,
        StoredCharacterJson;
export 'storage_backend_stub.dart'
    show
        StorageBackend,
        StorageCharacterScan,
        StorageReadException,
        StorageReadIssue,
        StoredCharacterJson;

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

  // ---- Characters ----

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() async {
    final scan = await scanCharacters();
    return [for (final record in scan.records) record.json];
  }

  @override
  Future<StorageCharacterScan> scanCharacters() async {
    final dir = await _charactersDir;
    final files = dir.listSync().whereType<File>().where(
      (file) => file.path.endsWith('.json'),
    );

    final records = <StoredCharacterJson>[];
    final issues = <StorageReadIssue>[];
    for (final file in files) {
      final fallbackId = file.uri.pathSegments.last.replaceFirst(
        RegExp(r'\.json$'),
        '',
      );
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, dynamic>) {
          final rawId = decoded['id'];
          records.add(
            StoredCharacterJson(
              source: file.path,
              id: rawId is String && rawId.isNotEmpty ? rawId : fallbackId,
              json: decoded,
            ),
          );
        } else {
          issues.add(
            StorageReadIssue(
              source: file.path,
              id: fallbackId,
              message: 'not_object',
            ),
          );
        }
      } catch (_) {
        issues.add(
          StorageReadIssue(
            source: file.path,
            id: fallbackId,
            message: 'invalid_json',
          ),
        );
      }
    }
    return StorageCharacterScan(records: records, issues: issues);
  }

  @override
  Future<Map<String, dynamic>?> loadCharacter(String id) async {
    try {
      return (await loadCharacterRecord(id))?.json;
    } on StorageReadException {
      return null;
    }
  }

  @override
  Future<StoredCharacterJson?> loadCharacterRecord(String id) async {
    final file = await _fileForId(id);
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final rawId = decoded['id'];
        return StoredCharacterJson(
          source: file.path,
          id: rawId is String && rawId.isNotEmpty ? rawId : id,
          json: decoded,
        );
      }
      throw StorageReadException(
        StorageReadIssue(source: file.path, id: id, message: 'not_object'),
      );
    } on StorageReadException {
      rethrow;
    } catch (_) {
      throw StorageReadException(
        StorageReadIssue(source: file.path, id: id, message: 'invalid_json'),
      );
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

  // ---- Images ----

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
    return dest.path;
  }

  @override
  Future<String?> resolveImagePath(String? fileName) async {
    if (fileName == null) return null;
    final file = File(fileName);
    return await file.exists() ? file.path : null;
  }

  @override
  Future<void> deleteImage(String? fileName) async {
    if (fileName == null) return;
    final file = File(fileName);
    if (await file.exists()) await file.delete();
  }
}
