import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'app_indexed_db_web.dart';

const indexedDbImagePrefix = 'indexeddb:image:';

bool isIndexedDbImageReference(String path) =>
    path.startsWith(indexedDbImagePrefix);

String indexedDbImageReference(String imageId) => '$indexedDbImagePrefix$imageId';

Future<String?> saveWebImageDataUrl({
  required String ownerId,
  required String dataUrl,
}) async {
  final payload = parseImageDataUrl(dataUrl);
  if (payload == null) return null;

  final imageId = '${_safeId(ownerId)}_${DateTime.now().microsecondsSinceEpoch}';
  final record = <String, dynamic>{
    'id': imageId,
    'ownerId': ownerId,
    'dataUrl': dataUrl,
    'mimeType': payload.mimeType,
    'updatedAt': DateTime.now().toIso8601String(),
  };

  await withIndexedDbStore(appIndexedDbImagesStore, 'readwrite', (store) async {
    await requestToFuture(store.put(jsonEncode(record).toJS, imageId.toJS));
  });

  return indexedDbImageReference(imageId);
}

Future<({Uint8List bytes, String mimeType})?> readWebImagePayload(
  String path,
) async {
  if (path.startsWith('data:')) {
    return parseImageDataUrl(path);
  }

  final imageId = _imageIdFromReference(path);
  if (imageId == null) return null;

  final value = await withIndexedDbStore(appIndexedDbImagesStore, 'readonly', (
    store,
  ) async {
    return requestToFuture(store.get(imageId.toJS));
  });

  final raw = value?.dartify();
  if (raw is! String) return null;

  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final dataUrl = decoded['dataUrl'] as String?;
    if (dataUrl == null) return null;
    return parseImageDataUrl(dataUrl);
  } catch (_) {
    return null;
  }
}

Future<void> deleteWebImage(String? path) async {
  if (path == null) return;
  final imageId = _imageIdFromReference(path);
  if (imageId == null) return;

  await withIndexedDbStore(appIndexedDbImagesStore, 'readwrite', (store) async {
    await requestToFuture(store.delete(imageId.toJS));
  });
}

({Uint8List bytes, String mimeType})? parseImageDataUrl(String dataUrl) {
  final commaIdx = dataUrl.indexOf(',');
  if (commaIdx == -1 || !dataUrl.startsWith('data:')) return null;

  final header = dataUrl.substring(5, commaIdx);
  final mimeType = header.split(';').first;
  if (mimeType.isEmpty) return null;

  try {
    return (
      bytes: base64Decode(dataUrl.substring(commaIdx + 1)),
      mimeType: mimeType,
    );
  } catch (_) {
    return null;
  }
}

String? _imageIdFromReference(String path) {
  if (!isIndexedDbImageReference(path)) return null;
  final imageId = path.substring(indexedDbImagePrefix.length);
  return imageId.isEmpty ? null : imageId;
}

String _safeId(String value) {
  final sanitized = value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  return sanitized.isEmpty ? 'image' : sanitized;
}
