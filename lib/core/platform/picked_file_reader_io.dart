import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';

const shouldLoadPickedFileData = false;

Future<String?> readPickedFileAsString(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes != null) return utf8.decode(bytes);
  final path = file.path;
  if (path == null || path.isEmpty) return null;
  return File(path).readAsString();
}
