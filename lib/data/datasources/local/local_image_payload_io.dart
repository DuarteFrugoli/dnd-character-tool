import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'storage_backend_stub.dart' show StorageBackend;

Future<({Uint8List? bytes, String? mimeType})> readStoredImagePayload(
  String absolutePath,
) async {
  final file = File(absolutePath);
  if (!await file.exists()) {
    return (bytes: null, mimeType: null);
  }

  final ext = absolutePath.split('.').last.toLowerCase();
  return (
    bytes: await file.readAsBytes(),
    mimeType: ext == 'png' ? 'image/png' : 'image/jpeg',
  );
}

Future<String?> persistImportedImagePayload({
  required StorageBackend backend,
  required String imageOwnerId,
  required String imageData,
  required String mimeType,
}) async {
  final bytes = base64Decode(imageData);
  final ext = mimeType == 'image/png' ? 'png' : 'jpg';
  final tempDir = await getTemporaryDirectory();
  final ts = DateTime.now().microsecondsSinceEpoch;
  final tempFile = File('${tempDir.path}/dndchar_import_$ts.$ext');

  try {
    await tempFile.writeAsBytes(bytes);
    return backend.saveImage(imageOwnerId, tempFile.path);
  } finally {
    try {
      if (await tempFile.exists()) await tempFile.delete();
    } catch (_) {}
  }
}
