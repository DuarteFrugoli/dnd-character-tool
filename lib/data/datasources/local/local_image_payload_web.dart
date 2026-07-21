import 'dart:typed_data';

import 'storage_backend_stub.dart' show StorageBackend;

Future<({Uint8List? bytes, String? mimeType})> readStoredImagePayload(
  String absolutePath,
) async {
  return (bytes: null, mimeType: null);
}

Future<String?> persistImportedImagePayload({
  required StorageBackend backend,
  required String imageOwnerId,
  required String imageData,
  required String mimeType,
}) async {
  return 'data:$mimeType;base64,$imageData';
}
