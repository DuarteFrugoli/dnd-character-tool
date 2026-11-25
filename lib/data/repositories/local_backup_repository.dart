import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../datasources/local/local_backup_storage_stub.dart'
    if (dart.library.io) '../datasources/local/local_backup_storage_native.dart'
    if (dart.library.js_interop) '../datasources/local/local_backup_storage_web.dart'
    as platform;
import '../datasources/local/local_backup_storage_stub.dart';
import '../models/local_backup.dart';

class LocalBackupRepository {
  LocalBackupRepository({LocalBackupStorage? storage, DateTime Function()? now})
    : _storage = storage ?? platform.createLocalBackupStorage(),
      _now = now ?? DateTime.now;

  static const retainedCount = 3;
  static final instance = LocalBackupRepository();
  final LocalBackupStorage _storage;
  final DateTime Function() _now;
  Future<void> _writes = Future.value();

  Future<List<LocalBackupInfo>> list() async {
    final backups = await _storage.list();
    backups.sort((a, b) {
      final sequence = b.sequence.compareTo(a.sequence);
      if (sequence != 0) return sequence;
      final date = b.createdAt.compareTo(a.createdAt);
      return date != 0 ? date : b.id.compareTo(a.id);
    });
    return backups;
  }

  Future<LocalBackupInfo> save(String fileJson) {
    final operation = _writes.then((_) async {
      final count = await compute(_backupCharacterCount, fileJson);
      final previous = await list();
      final info = LocalBackupInfo(
        id: const Uuid().v4(),
        createdAt: _now().toUtc(),
        characterCount: count,
        sequence:
            previous.fold<int>(
              0,
              (value, backup) =>
                  value > backup.sequence ? value : backup.sequence,
            ) +
            1,
      );
      await _storage.write(info, fileJson);
      // Never remove an older recovery point until the new copy is durable.
      // Sequence numbers preserve save order if the device clock moves backwards.
      for (final old in previous.skip(retainedCount - 1)) {
        await _storage.delete(old.id);
      }
      return info;
    });
    _writes = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<String> read(String id) {
    LocalBackupInfo.validateId(id);
    return _storage.read(id);
  }
}

int _backupCharacterCount(String fileJson) {
  final payload = jsonDecode(fileJson);
  if (payload is! Map ||
      payload['type'] != 'dnd-character-tool-backup' ||
      payload['characters'] is! List) {
    throw const FormatException('invalid_local_backup');
  }
  final entries = payload['characters'] as List;
  if (entries.any((entry) => entry is! Map || entry['character'] is! Map)) {
    throw const FormatException('invalid_local_backup');
  }
  return entries.length;
}
