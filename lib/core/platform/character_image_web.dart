import 'dart:js_interop';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'web_image_store.dart';

ImageProvider resolveCharacterImageProvider(String path) {
  if (path.startsWith('data:')) {
    final payload = parseImageDataUrl(path);
    if (payload != null) return MemoryImage(payload.bytes);
  }
  if (isIndexedDbImageReference(path)) {
    return _IndexedDbImageProvider(path);
  }
  return NetworkImage(path);
}

Future<void> saveCharacterImage(String path, String filename) async {
  final payload = await readWebImagePayload(path);
  if (payload == null) {
    throw UnsupportedError('Image is not available on web.');
  }

  final blob = web.Blob(
    [payload.bytes.toJS].toJS,
    web.BlobPropertyBag(type: payload.mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}

class _IndexedDbImageProvider extends ImageProvider<_IndexedDbImageProvider> {
  const _IndexedDbImageProvider(this.path);

  final String path;

  @override
  Future<_IndexedDbImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_IndexedDbImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _IndexedDbImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: key.path,
    );
  }

  Future<ui.Codec> _loadAsync(
    _IndexedDbImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    final payload = await readWebImagePayload(key.path);
    if (payload == null) {
      throw StateError('IndexedDB image not found: ${key.path}');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(payload.bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    return other is _IndexedDbImageProvider && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
