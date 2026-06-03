import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> exportDndCharFile(String characterName, String fileJson) async {
  final safeName = characterName.replaceAll(RegExp(r'[^\w]'), '_');
  final blob = web.Blob(
    [fileJson.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = '$safeName.dndchar';
  anchor.click();
  web.URL.revokeObjectURL(url);
}
