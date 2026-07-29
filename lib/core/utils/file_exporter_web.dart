import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> exportDndCharFile(String characterName, String fileJson) async {
  final safeName = characterName.replaceAll(RegExp(r'[^\w]'), '_');
  final blob = web.Blob(
    [fileJson.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = '$safeName.dndchar';
  anchor.click();
  web.URL.revokeObjectURL(url);
}

Future<void> exportDndBackupFile(String fileJson) async {
  final timestamp = DateTime.now().toIso8601String().replaceAll(
    RegExp(r'[:.]'),
    '-',
  );
  final blob = web.Blob(
    [fileJson.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = 'dnd_character_backup_$timestamp.dndbackup';
  anchor.click();
  web.URL.revokeObjectURL(url);
}
