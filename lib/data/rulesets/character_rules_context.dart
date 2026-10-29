import '../models/character.dart';
import 'ruleset_ids.dart';
import 'srd_content_pack.dart';

class CharacterRulesContext {
  const CharacterRulesContext._({
    required this.rulesetId,
    required this.pack,
  });

  factory CharacterRulesContext.fromCharacter(Character character) {
    return CharacterRulesContext.forIds(character.rulesetId, character.contentPackId);
  }

  factory CharacterRulesContext.forIds(RulesetId rulesetId, ContentPackId packId) {
    final pack = SrdContentPackRegistry.forId(packId);
    if (pack.rulesetId != rulesetId) {
      throw StateError('Character ruleset and content pack do not match.');
    }
    return CharacterRulesContext._(
      rulesetId: rulesetId,
      pack: pack,
    );
  }

  final RulesetId rulesetId;
  final SrdContentPack pack;

  ContentPackId get contentPackId => pack.id;
  bool get supportsLegacySheet => rulesetId == RulesetId.dnd2014;

  void requireLegacyOperation(String operation) {
    if (!supportsLegacySheet) {
      throw UnsupportedError(
        '$operation is not implemented for ${rulesetId.value}.',
      );
    }
  }
}
