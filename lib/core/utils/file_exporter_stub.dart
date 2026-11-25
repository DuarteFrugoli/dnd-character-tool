import 'dart:ui';

Future<void> exportDndCharFile(
  String characterName,
  String fileJson, {
  required Rect sharePositionOrigin,
}) async {
  throw UnsupportedError('File export is not supported on this platform.');
}

Future<void> exportDndBackupFile(
  String fileJson, {
  required Rect sharePositionOrigin,
}) async {
  throw UnsupportedError('File export is not supported on this platform.');
}
