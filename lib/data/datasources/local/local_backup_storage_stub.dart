import '../../models/local_backup.dart';

abstract class LocalBackupStorage {
  Future<List<LocalBackupInfo>> list();
  Future<void> write(LocalBackupInfo info, String fileJson);
  Future<String> read(String id);
  Future<void> delete(String id);
}

LocalBackupStorage createLocalBackupStorage() =>
    throw UnsupportedError('Local backups are not supported.');
