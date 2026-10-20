import 'ruleset_ids.dart';

enum SrdContentKind {
  background('background'),
  classEntry('class'),
  classFeature('class_feature'),
  condition('condition'),
  equipment('equipment'),
  feat('feat'),
  featureChoice('feature_choice'),
  featureUsage('feature_usage'),
  language('language'),
  magicItem('magic_item'),
  race('race'),
  raceTrait('race_trait'),
  skill('skill'),
  spell('spell'),
  subclass('subclass'),
  subclassFeature('subclass_feature'),
  tool('tool');

  const SrdContentKind(this.value);

  final String value;

  static SrdContentKind parse(String value) {
    for (final kind in values) {
      if (kind.value == value) return kind;
    }
    throw FormatException('Unknown SRD content kind: $value');
  }
}

class SrdContentRef {
  SrdContentRef({required this.packId, required this.kind, required this.id}) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
  }

  final ContentPackId packId;
  final SrdContentKind kind;
  final String id;

  String get value => '${packId.value}/${kind.value}/${Uri.encodeComponent(id)}';

  static SrdContentRef parse(String value) {
    final parts = value.split('/');
    if (parts.length != 3) throw FormatException('Invalid SRD reference: $value');
    return SrdContentRef(
      packId: ContentPackId.parse(parts[0]),
      kind: SrdContentKind.parse(parts[1]),
      id: Uri.decodeComponent(parts[2]),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SrdContentRef &&
      other.packId == packId &&
      other.kind == kind &&
      other.id == id;

  @override
  int get hashCode => Object.hash(packId, kind, id);
}
