import 'dart:io';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'file_export_cancelled.dart';

Future<void> exportDndCharFile(
  String characterName,
  String fileJson, {
  required Rect sharePositionOrigin,
}) async {
  var safeName = characterName.replaceAll(RegExp(r'[^\w]'), '_');
  if (safeName.isEmpty) safeName = 'character';
  if (safeName.length > 80) safeName = safeName.substring(0, 80);
  await _shareFile(
    '$safeName.dndchar',
    fileJson,
    characterName,
    sharePositionOrigin,
  );
}

Future<void> exportDndBackupFile(
  String fileJson, {
  required Rect sharePositionOrigin,
}) async {
  final timestamp = DateTime.now().toIso8601String().replaceAll(
    RegExp(r'[:.]'),
    '-',
  );
  await _shareFile(
    'dnd_character_backup_$timestamp.dndbackup',
    fileJson,
    'D&D Character Tool Backup',
    sharePositionOrigin,
  );
}

Future<void> _shareFile(
  String name,
  String fileJson,
  String subject,
  Rect origin,
) async {
  final temporary = await getTemporaryDirectory();
  // Keep simultaneous exports separate while other apps read their files.
  final directory = await temporary.createTemp('dnd_export_');
  final file = File('${directory.path}/$name');
  await file.writeAsString(fileJson);
  final result = await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/octet-stream')],
    subject: subject,
    sharePositionOrigin: origin,
  );
  if (result.status == ShareResultStatus.dismissed) {
    throw const FileExportCancelled();
  }
}
