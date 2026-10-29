import '../models/character.dart';
import 'ruleset_ids.dart';

class SrdContentPack {
  const SrdContentPack({
    required this.id,
    required this.srdAssetRoot,
    required this.i18nAssetRoot,
    required this.i18nSubdir,
  });

  final ContentPackId id;
  final String srdAssetRoot;
  final String i18nAssetRoot;
  final String i18nSubdir;

  RulesetId get rulesetId => id.rulesetId;

  String srdAsset(String fileName) => '$srdAssetRoot/$fileName.json';

  String i18nAsset(String locale, String fileName) =>
      '$i18nAssetRoot/$locale/$i18nSubdir/$fileName.json';
}

class SrdContentPackRegistry {
  const SrdContentPackRegistry._();

  static const srd51 = SrdContentPack(
    id: ContentPackId.srd51,
    srdAssetRoot: 'assets/data/srd/5.1',
    i18nAssetRoot: 'assets/data/i18n',
    i18nSubdir: '5.1',
  );

  static const srd521 = SrdContentPack(
    id: ContentPackId.srd521,
    srdAssetRoot: 'assets/data/srd/5.2.1',
    i18nAssetRoot: 'assets/data/i18n',
    i18nSubdir: '5.2.1',
  );

  static SrdContentPack forId(ContentPackId id) => switch (id) {
    ContentPackId.srd51 => srd51,
    ContentPackId.srd521 => srd521,
  };

  static SrdContentPack forCharacter(Character character) {
    final pack = forId(character.contentPackId);
    if (pack.rulesetId != character.rulesetId) {
      throw StateError('Character ruleset and content pack do not match.');
    }
    return pack;
  }
}
