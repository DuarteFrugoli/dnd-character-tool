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
