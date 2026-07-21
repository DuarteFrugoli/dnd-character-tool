import 'dart:typed_data';

import '../../../core/platform/web_image_store.dart';
import 'storage_backend_stub.dart' show StorageBackend;

Future<({Uint8List? bytes, String? mimeType})> readStoredImagePayload(
  String imagePath,
) async {
  final payload = await readWebImagePayload(imagePath);
  return (bytes: payload?.bytes, mimeType: payload?.mimeType);
}

Future<String?> persistImportedImagePayload({
  required StorageBackend backend,
  required String imageOwnerId,
  required String imageData,
  required String mimeType,
}) async {
  return backend.saveImage(imageOwnerId, 'data:$mimeType;base64,$imageData');
}
