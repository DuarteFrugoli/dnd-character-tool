import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';

ImageProvider resolveCharacterImageProvider(String path) {
  if (path.startsWith('data:')) {
    return MemoryImage(_dataUrlBytes(path));
  }
  return FileImage(File(path));
}

Future<void> saveCharacterImage(String path, String filename) async {
  if (path.startsWith('data:')) {
    await Gal.putImageBytes(_dataUrlBytes(path));
    return;
  }
  await Gal.putImage(path);
}

Uint8List _dataUrlBytes(String path) => base64Decode(path.split(',').last);
