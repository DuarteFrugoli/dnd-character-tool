import 'dart:convert';
import 'dart:js_interop';

import '../../../core/platform/app_indexed_db_web.dart';
import '../../models/local_backup.dart';
import 'local_backup_storage_stub.dart';

LocalBackupStorage createLocalBackupStorage() => WebLocalBackupStorage();

class WebLocalBackupStorage implements LocalBackupStorage {
  static const _infoPrefix = 'local-backup:info:';
  static const _dataPrefix = 'local-backup:data:';

  @override
  Future<List<LocalBackupInfo>> list() =>
      withIndexedDbStore(appIndexedDbMetadataStore, 'readonly', (store) async {
        final keys = (await requestToFuture(store.getAllKeys()))?.dartify();
        final result = <LocalBackupInfo>[];
        if (keys is! List) return result;
        for (final key in keys.whereType<String>().where(
          (key) => key.startsWith(_infoPrefix),
        )) {
          final value = (await requestToFuture(store.get(key.toJS)))?.dartify();
          try {
            if (value is String) {
              final info = LocalBackupInfo.fromJson(
                jsonDecode(value) as Map<String, dynamic>,
              );
              if (key == '$_infoPrefix${info.id}') result.add(info);
            }
          } catch (_) {
            // Other backups remain available if one metadata record is damaged.
          }
        }
        return result;
      });

  @override
  Future<void> write(LocalBackupInfo info, String fileJson) {
    LocalBackupInfo.validateId(info.id);
    return withIndexedDbStore(appIndexedDbMetadataStore, 'readwrite', (
      store,
    ) async {
      // Both records commit together, without changing existing app stores.
      await requestToFuture(
        store.put(fileJson.toJS, '$_dataPrefix${info.id}'.toJS),
      );
      await requestToFuture(
        store.put(
          jsonEncode(info.toJson()).toJS,
          '$_infoPrefix${info.id}'.toJS,
        ),
      );
    });
  }

  @override
  Future<String> read(String id) {
    LocalBackupInfo.validateId(id);
    return withIndexedDbStore(appIndexedDbMetadataStore, 'readonly', (
      store,
    ) async {
      final value = (await requestToFuture(
        store.get('$_dataPrefix$id'.toJS),
      ))?.dartify();
      if (value is! String) throw StateError('Local backup is unavailable.');
      return value;
    });
  }

  @override
  Future<void> delete(String id) {
    LocalBackupInfo.validateId(id);
    return withIndexedDbStore(appIndexedDbMetadataStore, 'readwrite', (
      store,
    ) async {
      await requestToFuture(store.delete('$_infoPrefix$id'.toJS));
      await requestToFuture(store.delete('$_dataPrefix$id'.toJS));
    });
  }
}
