import 'dart:convert';

import 'package:flutter/widgets.dart';

ImageProvider resolveCharacterImageProvider(String path) {
  if (path.startsWith('data:')) {
    return MemoryImage(base64Decode(path.split(',').last));
  }
  return NetworkImage(path);
}

Future<void> saveCharacterImage(String path, String filename) async {
  throw UnsupportedError('Image saving is not supported on this platform.');
}
