import 'dart:io';

import 'package:file_picker/file_picker.dart';

const shouldLoadPickedFileData = false;

Future<String?> readPickedFileAsString(PlatformFile file) async {
  final path = file.path;
  if (path == null) return null;
  return File(path).readAsString();
}
