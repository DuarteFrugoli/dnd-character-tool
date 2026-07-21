import 'dart:convert';

import 'package:file_picker/file_picker.dart';

const shouldLoadPickedFileData = true;

Future<String?> readPickedFileAsString(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes == null) return null;
  return utf8.decode(bytes);
}
