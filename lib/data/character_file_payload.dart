import 'dart:convert';

/// Returns true when [fileJson] looks like a full app backup payload.
///
/// A single `.dndchar` file stores one `character`; a `.dndbackup` stores a
/// `characters` list. The home import flow uses this to choose the correct
/// repository import method before validating the payload in detail.
bool looksLikeDndBackupFileJson(String fileJson) {
  try {
    final decoded = jsonDecode(fileJson);
    return decoded is Map<String, dynamic> && decoded['characters'] is List;
  } catch (_) {
    return false;
  }
}
