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
    final dataUrl = _decodeImageDataUrl(sourcePath);
    final ext = dataUrl == null
        ? _extensionForPath(sourcePath)
        : _extensionForMimeType(dataUrl.mimeType);
    // Use a timestamp so the path always changes on update, preventing
    // Flutter's FileImage cache from serving the stale image.
    final ts = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${characterId}_$ts.$ext';
    final dest = File('${dir.path}/$fileName');
    if (dataUrl != null) {
      await dest.writeAsBytes(dataUrl.bytes);
    } else {
      await File(_normalizeFilePath(sourcePath)).copy(dest.path);
    }
    return dest.path;
  }

  @override
  Future<String?> resolveImagePath(String? fileName) async {
    if (fileName == null) return null;
    final file = File(_normalizeFilePath(fileName));
    return await file.exists() ? file.path : null;
  }

  @override
  Future<void> deleteImage(String? fileName) async {
    if (fileName == null) return;
    final file = File(_normalizeFilePath(fileName));
    if (await file.exists()) await file.delete();
  }

  String _normalizeFilePath(String path) {
    if (path.startsWith('file://')) {
      try {
        return Uri.parse(path).toFilePath();
      } catch (_) {}
    }
    return path;
  }

  String _extensionForPath(String path) {
    final cleanPath = _normalizeFilePath(path);
    final lastSegment = cleanPath.split(RegExp(r'[\\/]')).last;
    if (!lastSegment.contains('.')) return 'jpg';
    final ext = lastSegment.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'png',
      'webp' => 'webp',
      'gif' => 'gif',
      'jpeg' => 'jpg',
      'jpg' => 'jpg',
      _ => 'jpg',
    };
  }

  String _extensionForMimeType(String mimeType) {
    return switch (mimeType.toLowerCase()) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/gif' => 'gif',
      _ => 'jpg',
    };
  }

  ({List<int> bytes, String mimeType})? _decodeImageDataUrl(String dataUrl) {
    if (!dataUrl.startsWith('data:')) return null;
    final commaIdx = dataUrl.indexOf(',');
    if (commaIdx == -1) return null;
    final header = dataUrl.substring(5, commaIdx);
    final mimeType = header.split(';').first;
    if (!mimeType.startsWith('image/')) return null;
    try {
      return (
        bytes: base64Decode(dataUrl.substring(commaIdx + 1)),
        mimeType: mimeType,
      );
    } catch (_) {
      return null;
    }
  }
}
