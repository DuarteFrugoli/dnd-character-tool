import 'dart:io';
import 'dart:typed_data';

import 'storage_backend_stub.dart' show StorageBackend;

Future<({Uint8List? bytes, String? mimeType})> readStoredImagePayload(
  String absolutePath,
) async {
  final file = File(absolutePath);
  if (!await file.exists()) {
    return (bytes: null, mimeType: null);
  }

  final ext = absolutePath.split('.').last.toLowerCase();
  final mimeType = switch (ext) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    _ => 'image/jpeg',
  };
  return (
    bytes: await file.readAsBytes(),
    mimeType: mimeType,
  );
}

Future<String?> persistImportedImagePayload({
  required StorageBackend backend,
  required String imageOwnerId,
  required String imageData,
  required String mimeType,
}) async {
  return backend.saveImage(imageOwnerId, 'data:$mimeType;base64,$imageData');
}
