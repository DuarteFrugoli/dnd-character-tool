// Platform-aware export helper.
// On mobile/desktop: writes a temp file and opens the system share sheet.
// On web: triggers a browser download via a blob URL.
export 'file_exporter_stub.dart'
    if (dart.library.io) 'file_exporter_io.dart'
    if (dart.library.html) 'file_exporter_web.dart';
