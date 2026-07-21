import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'storage_backend_stub.dart' show StorageBackend;
export 'storage_backend_stub.dart' show StorageBackend;

StorageBackend createStorageBackend() => WebStorageBackend();

/// Backend de storage para a web usando IndexedDB.
///
/// Personagens ficam no object store `characters` como JSON string indexado
/// pelo ID. Os stores `images` e `metadata` ja sao criados para as proximas
/// etapas, mas a separacao de imagens do JSON do personagem fica para o item 4
/// do plano web.
class WebStorageBackend implements StorageBackend {
  static const _dbName = 'dnd_character_tool';
  static const _dbVersion = 1;
  static const _charactersStore = 'characters';
  static const _imagesStore = 'images';
  static const _metadataStore = 'metadata';

  Future<web.IDBDatabase>? _dbFuture;

  Future<web.IDBDatabase> get _db {
    final current = _dbFuture;
    if (current != null) return current;
    return _dbFuture = _openDatabase();
  }

  // ---- Personagens ----

  @override
  Future<List<Map<String, dynamic>>> loadAllCharacters() {
    return _withCharacterStore('readonly', (store) async {
      final values = await _requestToFuture(store.getAll());
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
    return _withCharacterStore('readonly', (store) async {
      final value = await _requestToFuture(store.get(id.toJS));
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
    return _withCharacterStore('readwrite', (store) async {
      await _requestToFuture(store.put(jsonEncode(json).toJS, id.toJS));
    });
  }

  @override
  Future<void> deleteCharacter(String id) {
    return _withCharacterStore('readwrite', (store) async {
      await _requestToFuture(store.delete(id.toJS));
    });
  }

  @override
  Future<bool> characterExists(String id) {
    return _withCharacterStore('readonly', (store) async {
      final value = await _requestToFuture(store.get(id.toJS));
      return value != null;
    });
  }

  // ---- Imagens ----

  @override
  Future<String?> saveImage(String characterId, String sourcePath) async =>
      null;

  @override
  Future<String?> resolveImagePath(String? fileName) async => null;

  @override
  Future<void> deleteImage(String? fileName) async {}

  // ---- Helpers ----

  Future<web.IDBDatabase> _openDatabase() async {
    final request = web.window.indexedDB.open(_dbName, _dbVersion);

    request.onupgradeneeded = ((web.Event _) {
      final db = request.result as web.IDBDatabase;
      if (!db.objectStoreNames.contains(_charactersStore)) {
        db.createObjectStore(_charactersStore);
      }
      if (!db.objectStoreNames.contains(_imagesStore)) {
        db.createObjectStore(_imagesStore);
      }
      if (!db.objectStoreNames.contains(_metadataStore)) {
        db.createObjectStore(_metadataStore);
      }
    }).toJS;

    try {
      final db = await _requestToFuture(request);
      return db as web.IDBDatabase;
    } catch (_) {
      _dbFuture = null;
      rethrow;
    }
  }

  Future<T> _withCharacterStore<T>(
    String mode,
    Future<T> Function(web.IDBObjectStore store) action,
  ) async {
    final db = await _db;
    final tx = db.transaction(_charactersStore.toJS, mode);
    final done = _transactionDone(tx);
    final store = tx.objectStore(_charactersStore);

    try {
      final result = await action(store);
      await done;
      return result;
    } catch (_) {
      try {
        tx.abort();
      } catch (_) {}
      rethrow;
    }
  }

  Future<JSAny?> _requestToFuture(web.IDBRequest request) {
    final completer = Completer<JSAny?>();

    request.onsuccess = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.complete(request.result);
      }
    }).toJS;

    request.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(StateError(_requestErrorMessage(request)));
      }
    }).toJS;

    return completer.future;
  }

  Future<void> _transactionDone(web.IDBTransaction transaction) {
    final completer = Completer<void>();

    transaction.oncomplete = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }).toJS;

    void completeWithError() {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError(_transactionErrorMessage(transaction)),
        );
      }
    }

    transaction.onerror = ((web.Event _) {
      completeWithError();
    }).toJS;
    transaction.onabort = ((web.Event _) {
      completeWithError();
    }).toJS;

    return completer.future;
  }

  String _requestErrorMessage(web.IDBRequest request) {
    final message = request.error?.message;
    return message == null || message.isEmpty
        ? 'IndexedDB request failed.'
        : message;
  }

  String _transactionErrorMessage(web.IDBTransaction transaction) {
    final message = transaction.error?.message;
    return message == null || message.isEmpty
        ? 'IndexedDB transaction failed.'
        : message;
  }
}
