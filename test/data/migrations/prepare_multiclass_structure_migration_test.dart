import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/prepare_multiclass_structure_migration.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _legacyCharacter() {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    dataVersion: 6,
    name: 'Test Wizard',
    race: 'Human',
    characterClass: 'Wizard',
    subclass: 'Evocation',
    level: 3,
    abilityScores: const AbilityScores(intelligence: 16),
    hitPoints: const HitPoints(maximum: 20, current: 20, hitDiceUsed: 1),
    spells: const [KnownSpell(name: 'Magic Missile', level: 1)],
    extraFeatures: const [
      CharacterExtraFeature(
        sourceClass: 'Feat',
        name: 'Alert',
        level: 1,
        type: 'passive',
        description: 'Always on the lookout for danger.',
      ),
    ],
    featureChoices: const [
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Wizard',
        featureName: 'Arcane Recovery',
        choiceId: 'example',
        values: ['value'],
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  const migration = PrepareMulticlassStructureMigration();
  const context = CharacterMigrationContext(itemsByName: {});

  test('creates primary class entry and hit die pool from legacy fields', () {
    final result = migration.migrate(_legacyCharacter(), context);
    final character = result.character;

    expect(character.classes, hasLength(1));
    expect(character.classes.single.id, 'primary');
    expect(character.classes.single.className, 'Wizard');
    expect(character.classes.single.subclassName, 'Evocation');
    expect(character.classes.single.level, 3);
    expect(character.classes.single.isStartingClass, isTrue);

    expect(character.hitDicePools, hasLength(1));
    expect(character.hitDicePools.single.dieSize, 6);
    expect(character.hitDicePools.single.total, 3);
    expect(character.hitDicePools.single.used, 1);
    expect(character.hitDicePools.single.sourceClassEntryId, 'primary');
  });

  test('adds source metadata to spells, feats, and class choices', () {
    final character = migration.migrate(_legacyCharacter(), context).character;

    expect(character.spells.single.sourceType, 'class');
    expect(character.spells.single.sourceClass, 'Wizard');
    expect(character.spells.single.sourceSubclass, 'Evocation');
    expect(character.spells.single.sourceClassEntryId, 'primary');

    expect(character.extraFeatures.single.effectiveSourceType, 'feat');
    expect(character.extraFeatures.single.sourceFeature, 'Alert');

    expect(character.featureChoices.single.sourceClassEntryId, 'primary');
  });
}
