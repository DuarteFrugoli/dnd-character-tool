import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportDndCharFile(String characterName, String fileJson) async {
  final dir = await getTemporaryDirectory();
  final safeName = characterName.replaceAll(RegExp(r'[^\w]'), '_');
  final file = File('${dir.path}/$safeName.dndchar');
  await file.writeAsString(fileJson);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/octet-stream')],
    subject: characterName,
  );
}

Future<void> exportDndBackupFile(String fileJson) async {
  final dir = await getTemporaryDirectory();
  final timestamp = DateTime.now()
      .toIso8601String()
      .replaceAll(RegExp(r'[:.]'), '-');
  final file = File('${dir.path}/dnd_character_backup_$timestamp.dndbackup');
  await file.writeAsString(fileJson);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/octet-stream')],
    subject: 'D&D Character Tool Backup',
  );
}
