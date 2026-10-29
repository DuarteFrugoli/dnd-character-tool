import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/character_spellcasting_summary.dart';
import 'package:dnd_character_tool/data/character_progression/character_progression_engine.dart';
import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/character_migration_runner.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/character_rules_context.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_ref.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({int version = currentCharacterDataVersion}) {
  final now = DateTime(2024);
  return Character(
    id: 'hero',
    dataVersion: version,
    name: 'Hero',
    race: 'Human',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  const migrationContext = CharacterMigrationContext(
    itemsByName: <String, SrdItemData>{},
  );

  test('new characters persist ruleset and pack in the character JSON', () {
    final original = _character();
    final json = original.toJson();
    final restored = Character.fromJson(json);

    expect(json['rulesetId'], 'dnd_2014');
    expect(json['contentPackId'], 'srd_5_1');
    expect(restored.rulesetId, RulesetId.dnd2014);
    expect(restored.contentPackId, ContentPackId.srd51);
    expect(restored.schemaVersion, currentCharacterDataVersion);
  });

  test('old JSON is readable for explicit maintenance but remains outdated', () {
    final json = _character(version: 9).toJson()
      ..remove('rulesetId')
      ..remove('contentPackId');
    final oldCharacter = Character.fromJson(json);
    final report = CharacterMigrationRunner().migrate(
      oldCharacter,
      migrationContext,
    );

    expect(oldCharacter.needsDataUpdate, isTrue);
    expect(oldCharacter.dataVersion, 9);
    expect(report.appliedMigrationIds, ['assign_2014_ruleset']);
    expect(report.changes.single.code, 'ruleset_2014_assigned');
    expect(report.character.dataVersion, currentCharacterDataVersion);
    expect(report.character.needsDataUpdate, isFalse);
    expect(report.character.toJson()['rulesetId'], 'dnd_2014');
    expect(report.character.toJson()['contentPackId'], 'srd_5_1');
  });

  test('current JSON cannot omit or mismatch its ruleset identifiers', () {
    final json = _character().toJson();
    expect(
      () => Character.fromJson({...json}..remove('rulesetId')),
      throwsFormatException,
    );
    expect(
      () => Character.fromJson({...json, 'contentPackId': 'srd_5_2_1'}),
      throwsFormatException,
    );
    expect(
      () => Character.fromJson({...json, 'rulesetId': 'unknown'}),
      throwsFormatException,
    );
  });

  test('pack registry resolves both bundled rulesets', () {
    expect(
      SrdContentPackRegistry.forCharacter(_character()).srdAsset('spells'),
      'assets/data/srd/5.1/spells.json',
    );
    expect(
      SrdContentPackRegistry.srd51.i18nAsset('pt', 'spells'),
      'assets/data/i18n/pt/5.1/spells.json',
    );
    expect(
      SrdContentPackRegistry.forId(ContentPackId.srd521).srdAsset('spells'),
      'assets/data/srd/5.2.1/spells.json',
    );
  });

  test('character rules context rejects a cross-edition content pack', () {
    expect(
      () => CharacterRulesContext.forIds(RulesetId.dnd2024, ContentPackId.srd51),
      throwsStateError,
    );
    expect(
      () => CharacterRulesContext.forIds(RulesetId.dnd2014, ContentPackId.srd521),
      throwsStateError,
    );
    final legacy = CharacterRulesContext.fromCharacter(_character());
    final current = CharacterRulesContext.forIds(RulesetId.dnd2024, ContentPackId.srd521);
    expect(legacy.supportsLegacySheet, isTrue);
    expect(current.supportsLegacySheet, isFalse);
    expect(() => current.requireLegacyOperation('Level up'), throwsUnsupportedError);
  });

  test('2014 spellcasting calculations reject a 2024 character', () {
    final current = _character().copyWith(
      rulesetId: RulesetId.dnd2024,
      contentPackId: ContentPackId.srd521,
    );
    expect(
      () => CharacterSpellcastingSummary.fromCharacter(current),
      throwsUnsupportedError,
    );
    expect(
      () => CharacterProgressionEngine.syncSpellcastingSlotsFor(current),
      throwsUnsupportedError,
    );
  });

  test('typed content references preserve pack, kind, and English ID', () {
    final reference = SrdContentRef(
      packId: ContentPackId.srd51,
      kind: SrdContentKind.spell,
      id: 'Melf\'s Acid Arrow',
    );
    expect(SrdContentRef.parse(reference.value), reference);
    expect(reference.value, startsWith('srd_5_1/spell/'));
    expect(reference.value, contains('%20'));
  });
}
