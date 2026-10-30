/// `manifest.json` of an SRD pack: where its content comes from and the
/// license notice the app must show.
class SrdPackManifest {
  const SrdPackManifest({
    required this.id,
    required this.title,
    required this.version,
    required this.source,
    required this.license,
    required this.licenseUrl,
    required this.attribution,
  });

  final String id;
  final String title;
  final String version;
  final String source;
  final String license;
  final String licenseUrl;

  /// Notice required by the license, kept in its original English.
  final String attribution;

  factory SrdPackManifest.fromJson(Map<String, dynamic> json) => SrdPackManifest(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    version: json['version'] as String? ?? '',
    source: json['source'] as String? ?? '',
    license: json['license'] as String? ?? '',
    licenseUrl: json['licenseUrl'] as String? ?? '',
    attribution: json['attribution'] as String? ?? '',
  );
}
