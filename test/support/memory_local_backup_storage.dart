import 'package:dnd_character_tool/data/datasources/local/local_backup_storage_stub.dart';
import 'package:dnd_character_tool/data/models/local_backup.dart';

class MemoryLocalBackupStorage implements LocalBackupStorage {
  final infos = <String, LocalBackupInfo>{};
  final payloads = <String, String>{};
  bool failWrites = false;

  @override
  Future<List<LocalBackupInfo>> list() async => infos.values.toList();

  @override
  Future<void> write(LocalBackupInfo info, String fileJson) async {
    if (failWrites) throw StateError('Storage full');
    payloads[info.id] = fileJson;
    infos[info.id] = info;
  }

  @override
  Future<String> read(String id) async {
    final payload = payloads[id];
    if (payload == null) throw StateError('Missing backup');
    return payload;
  }

  @override
  Future<void> delete(String id) async {
    infos.remove(id);
    payloads.remove(id);
  }
}
