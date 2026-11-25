import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/local_backup.dart';
import 'local_backup_storage_stub.dart';

LocalBackupStorage createLocalBackupStorage() => NativeLocalBackupStorage();

class NativeLocalBackupStorage implements LocalBackupStorage {
  NativeLocalBackupStorage({Directory? directory})
    : _directoryOverride = directory;

  final Directory? _directoryOverride;

  Future<Directory> get _directory async {
    final overridden = _directoryOverride;
    if (overridden != null) return overridden.create(recursive: true);
    final base = await getApplicationSupportDirectory();
    return Directory(
      '${base.path}/dnd_character_tool/backups',
    ).create(recursive: true);
  }

  @override
  Future<List<LocalBackupInfo>> list() async {
    final directory = await _directory;
    final result = <LocalBackupInfo>[];
    await for (final entry in directory.list()) {
      if (entry is! File || !entry.path.endsWith('.meta.json')) continue;
      try {
        final info = LocalBackupInfo.fromJson(
          jsonDecode(await entry.readAsString()) as Map<String, dynamic>,
        );
        if (entry.uri.pathSegments.last != '${info.id}.meta.json') continue;
        if (await File('${directory.path}/${info.id}.dndbackup').exists()) {
          result.add(info);
        }
      } catch (_) {
        // An incomplete/corrupt record does not hide other recoverable backups.
      }
    }
    return result;
  }

  @override
  Future<void> write(LocalBackupInfo info, String fileJson) async {
    LocalBackupInfo.validateId(info.id);
    final directory = await _directory;
    await compute(_writeBackup, {
      'directory': directory.path,
      'info': info.toJson(),
      'payload': fileJson,
    });
  }

  @override
  Future<String> read(String id) async {
    LocalBackupInfo.validateId(id);
    final directory = await _directory;
    return File('${directory.path}/$id.dndbackup').readAsString();
  }

  @override
  Future<void> delete(String id) async {
    LocalBackupInfo.validateId(id);
    final directory = await _directory;
    for (final suffix in ['.meta.json', '.dndbackup']) {
      final file = File('${directory.path}/$id$suffix');
      if (await file.exists()) await file.delete();
    }
  }
}

Future<void> _writeBackup(Map<String, dynamic> args) async {
  final info = args['info'] as Map<String, dynamic>;
  final base = '${args['directory']}/${info['id']}';
  final payloadTemp = File('$base.dndbackup.tmp');
  final metadataTemp = File('$base.meta.json.tmp');
  var published = false;
  try {
    await payloadTemp.writeAsString(args['payload'] as String, flush: true);
    await payloadTemp.rename('$base.dndbackup');
    await metadataTemp.writeAsString(jsonEncode(info), flush: true);
    // Publishing the metadata last makes only complete backups discoverable.
    await metadataTemp.rename('$base.meta.json');
    published = true;
  } finally {
    for (final file in [payloadTemp, metadataTemp]) {
      if (await file.exists()) await file.delete();
    }
    if (!published && !await File('$base.meta.json').exists()) {
      final incomplete = File('$base.dndbackup');
      if (await incomplete.exists()) await incomplete.delete();
    }
  }
}
