import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

ImageProvider resolveCharacterImageProvider(String path) {
  if (path.startsWith('data:')) {
    return MemoryImage(_dataUrlBytes(path));
  }
  return NetworkImage(path);
}

Future<void> saveCharacterImage(String path, String filename) async {
  if (!path.startsWith('data:')) {
    throw UnsupportedError('Only data URL images can be saved on web.');
  }

  final mimeType = _dataUrlMimeType(path) ?? 'image/jpeg';
  final bytes = _dataUrlBytes(path);
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}

Uint8List _dataUrlBytes(String path) => base64Decode(path.split(',').last);

String? _dataUrlMimeType(String path) {
  final commaIdx = path.indexOf(',');
  if (commaIdx == -1 || !path.startsWith('data:')) return null;
  final header = path.substring(5, commaIdx);
  return header.split(';').first;
}
