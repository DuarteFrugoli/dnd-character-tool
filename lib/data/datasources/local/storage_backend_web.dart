import 'dart:convert';
import 'dart:js_interop';

import '../../../core/platform/app_indexed_db_web.dart';
import '../../../core/platform/web_image_store.dart';
import 'storage_backend_stub.dart' show StorageBackend;
export 'storage_backend_stub.dart' show StorageBackend;

StorageBackend createStorageBackend() => WebStorageBackend();

/// Backend de storage para a web usando IndexedDB.
///
/// Personagens ficam no object store `characters` como JSON string indexado
/// pelo ID. Fotos ficam no object store `images`, e o personagem guarda apenas
/// uma referencia `indexeddb:image:<id>`.
class WebStorageBackend implements StorageBackend {
  // ---- Personagens ----

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() {
    return withIndexedDbStore(appIndexedDbCharactersStore, 'readonly', (
      store,
    ) async {
      final values = await requestToFuture(store.getAll());
      final decodedValues = values?.dartify();
      if (decodedValues is! List) return <Map<String, dynamic>>[];

      final characters = <Map<String, dynamic>>[];
      for (final value in decodedValues) {
        if (value is! String) continue;
        try {
          characters.add(jsonDecode(value) as Map<String, dynamic>);
        } catch (_) {
          // Entrada corrompida: ignora para nao quebrar a lista inteira.
        }
      }
      return characters;
    });
  }

  @override
  Future<Map<String, dynamic>?> loadCharacter(String id) {
    return withIndexedDbStore(appIndexedDbCharactersStore, 'readonly', (
      store,
    ) async {
      final value = await requestToFuture(store.get(id.toJS));
      final jsonString = value?.dartify();
      if (jsonString is! String) return null;
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (_) {
        return null;
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

  // ---- Imagens ----

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
