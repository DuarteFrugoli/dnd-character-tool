import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

const appIndexedDbName = 'dnd_character_tool';
const appIndexedDbVersion = 1;
const appIndexedDbCharactersStore = 'characters';
const appIndexedDbImagesStore = 'images';
const appIndexedDbMetadataStore = 'metadata';

Future<web.IDBDatabase>? _dbFuture;

Future<web.IDBDatabase> openAppIndexedDb() {
  final current = _dbFuture;
  if (current != null) return current;
  return _dbFuture = _openDatabase();
}

Future<T> withIndexedDbStore<T>(
  String storeName,
  String mode,
  Future<T> Function(web.IDBObjectStore store) action,
) async {
  final db = await openAppIndexedDb();
  final tx = db.transaction(storeName.toJS, mode);
  final done = transactionDone(tx);
  final store = tx.objectStore(storeName);

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

Future<JSAny?> requestToFuture(web.IDBRequest request) {
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

Future<void> transactionDone(web.IDBTransaction transaction) {
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

Future<web.IDBDatabase> _openDatabase() async {
  final request = web.window.indexedDB.open(
    appIndexedDbName,
    appIndexedDbVersion,
  );

  request.onupgradeneeded = ((web.Event _) {
    final db = request.result as web.IDBDatabase;
    if (!db.objectStoreNames.contains(appIndexedDbCharactersStore)) {
      db.createObjectStore(appIndexedDbCharactersStore);
    }
    if (!db.objectStoreNames.contains(appIndexedDbImagesStore)) {
      db.createObjectStore(appIndexedDbImagesStore);
    }
    if (!db.objectStoreNames.contains(appIndexedDbMetadataStore)) {
      db.createObjectStore(appIndexedDbMetadataStore);
    }
  }).toJS;

  try {
    final db = await requestToFuture(request);
    return db as web.IDBDatabase;
  } catch (_) {
    _dbFuture = null;
    rethrow;
  }
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
