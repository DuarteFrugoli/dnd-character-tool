import 'dart:convert';
import 'dart:js_interop';

import '../../../core/platform/app_indexed_db_web.dart';
import '../../../core/platform/web_image_store.dart';
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

StorageBackend createStorageBackend() => WebStorageBackend();

/// Web storage backend backed by IndexedDB.
///
/// Characters live in the `characters` object store as JSON strings keyed by
/// ID. Photos live in the `images` object store, and characters keep only an
/// `indexeddb:image:<id>` reference.
class WebStorageBackend implements StorageBackend {
  // ---- Characters ----

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() async {
    final scan = await scanCharacters();
    return [for (final record in scan.records) record.json];
  }

  @override
  Future<StorageCharacterScan> scanCharacters() {
    return withIndexedDbStore(appIndexedDbCharactersStore, 'readonly', (
      store,
    ) async {
      final values = await requestToFuture(store.getAll());
      final keys = await requestToFuture(store.getAllKeys());
      final decodedValues = values?.dartify();
      final decodedKeys = keys?.dartify();
      if (decodedValues is! List) return const StorageCharacterScan();

      final keyList = decodedKeys is List ? decodedKeys : const [];
      final records = <StoredCharacterJson>[];
      final issues = <StorageReadIssue>[];
      for (var i = 0; i < decodedValues.length; i++) {
        final key = i < keyList.length ? keyList[i] : null;
        final id = key is String && key.isNotEmpty ? key : null;
        final source = id ?? 'indexeddb:characters[$i]';
        final value = decodedValues[i];
        if (value is! String) {
          issues.add(
            StorageReadIssue(source: source, id: id, message: 'invalid_record'),
          );
          continue;
        }
        try {
          final decoded = jsonDecode(value);
          if (decoded is Map<String, dynamic>) {
            final rawId = decoded['id'];
            records.add(
              StoredCharacterJson(
                source: source,
                id: rawId is String && rawId.isNotEmpty ? rawId : id,
                json: decoded,
              ),
            );
          } else {
            issues.add(
              StorageReadIssue(source: source, id: id, message: 'not_object'),
            );
          }
        } catch (_) {
          issues.add(
            StorageReadIssue(source: source, id: id, message: 'invalid_json'),
          );
        }
      }
      return StorageCharacterScan(records: records, issues: issues);
    });
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
  Future<StoredCharacterJson?> loadCharacterRecord(String id) {
    return withIndexedDbStore(appIndexedDbCharactersStore, 'readonly', (
      store,
    ) async {
      final value = await requestToFuture(store.get(id.toJS));
      final jsonString = value?.dartify();
      if (jsonString is! String) return null;
      try {
        final decoded = jsonDecode(jsonString);
        if (decoded is Map<String, dynamic>) {
          final rawId = decoded['id'];
          return StoredCharacterJson(
            source: id,
            id: rawId is String && rawId.isNotEmpty ? rawId : id,
            json: decoded,
          );
        }
        throw StorageReadException(
          StorageReadIssue(source: id, id: id, message: 'not_object'),
        );
      } on StorageReadException {
        rethrow;
      } catch (_) {
        throw StorageReadException(
          StorageReadIssue(source: id, id: id, message: 'invalid_json'),
        );
      }
    });
  }

  @override
  Future<void> saveCharacter(String id, Map<String, dynamic> json) {
    return withIndexedDbStore(appIndexedDbCharactersStore, 'readwrite', (
      store,
    ) async {
      await requestToFuture(store.put(jsonEncode(json).toJS, id.toJS));
    });
  }

  @override
  Future<void> deleteCharacter(String id) {
    return withIndexedDbStore(appIndexedDbCharactersStore, 'readwrite', (
      store,
    ) async {
      await requestToFuture(store.delete(id.toJS));
    });
  }

  @override
  Future<bool> characterExists(String id) {
    return withIndexedDbStore(appIndexedDbCharactersStore, 'readonly', (
      store,
    ) async {
      final value = await requestToFuture(store.get(id.toJS));
      return value != null;
    });
  }

  // ---- Images ----

  @override
  Future<String?> saveImage(String characterId, String sourcePath) {
    if (isIndexedDbImageReference(sourcePath)) {
      return Future.value(sourcePath);
    }
    return saveWebImageDataUrl(ownerId: characterId, dataUrl: sourcePath);
  }

  @override
  Future<String?> resolveImagePath(String? fileName) async {
    if (fileName == null) return null;
    if (fileName.startsWith('data:') || isIndexedDbImageReference(fileName)) {
      return fileName;
    }
    return null;
  }

  @override
  Future<void> deleteImage(String? fileName) => deleteWebImage(fileName);
}
