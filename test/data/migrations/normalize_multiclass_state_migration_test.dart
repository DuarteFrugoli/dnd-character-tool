import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/normalize_multiclass_state_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/prepare_multiclass_structure_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/sync_multiclass_spell_slots_migration.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _staleCharacter() {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    dataVersion: 8,
    name: 'Test Hero',
    race: 'Human',
    characterClass: 'Rogue',
    subclass: 'Thief',
    level: 99,
    classes: const [
      CharacterClassEntry(
        id: 'fighter',
        className: 'Fighter',
        level: 1,
        isStartingClass: true,
      ),
      CharacterClassEntry(id: 'wizard', className: 'Wizard', level: 2),
    ],
    proficiencyBonus: 6,
    abilityScores: const AbilityScores(intelligence: 16),
    hitPoints: const HitPoints(maximum: 20, current: 20),
    hitDicePools: const [
      CharacterHitDiePool(
        dieSize: 8,
        total: 99,
        used: 99,
        sourceClass: 'Wizard',
      ),
    ],
    spells: const [
      KnownSpell(name: 'Shield', level: 1, sourceClass: 'Wizard'),
    ],
    extraFeatures: const [
      CharacterExtraFeature(
        sourceClass: 'Wizard',
        name: 'Arcane Recovery',
        level: 1,
        type: 'active',
        description: 'Recover spell slots.',
      ),
    ],
    featureChoices: const [
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Wizard',
        featureName: 'Arcane Recovery',
        choiceId: 'arcane_recovery',
        values: ['example'],
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  const migration = NormalizeMulticlassStateMigration();
  const context = CharacterMigrationContext(itemsByName: {});

  test('normalizes class mirrors, hit dice, and source metadata', () {
    final result = migration.migrate(_staleCharacter(), context);
    final character = result.character;

    expect(character.characterClass, 'Fighter');
    expect(character.subclass, isNull);
    expect(character.level, 3);
    expect(character.proficiencyBonus, 2);

    expect(character.hitDicePools, hasLength(2));
    expect(character.hitDicePools[0].sourceClassEntryId, 'fighter');
    expect(character.hitDicePools[0].dieSize, 10);
    expect(character.hitDicePools[0].total, 1);
    expect(character.hitDicePools[1].sourceClassEntryId, 'wizard');
    expect(character.hitDicePools[1].dieSize, 6);
    expect(character.hitDicePools[1].total, 2);
    expect(character.hitDicePools[1].used, 2);

    expect(character.spells.single.sourceType, 'class');
    expect(character.spells.single.sourceClassEntryId, 'wizard');
    expect(character.extraFeatures.single.sourceClass, 'Wizard');
    expect(character.extraFeatures.single.sourceClassEntryId, 'wizard');
    expect(character.featureChoices.single.sourceClassEntryId, 'wizard');

    expect(
      result.changes.map((change) => change.code),
      contains(PrepareMulticlassStructureMigration.changeCode),
    );
    expect(
      result.changes.map((change) => change.code),
      contains(SyncMulticlassSpellSlotsMigration.standardSlotsChangeCode),
    );
  });
}
