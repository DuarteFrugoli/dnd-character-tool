import 'package:dnd_character_tool/data/character_progression/choice_effects.dart';
import 'package:dnd_character_tool/data/character_progression/progression_2024_engine.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/record_2024_level_one_migration.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:flutter_test/flutter_test.dart';

late CharacterMigrationContext _context;

/// A level 1 Sage Fighter saved by 2024 creation before history existed.
Character _legacy2024({
  RulesetId rulesetId = RulesetId.dnd2024,
  List<CharacterFeatureChoice> extraChoices = const [],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'legacy',
    dataVersion: 10,
    rulesetId: rulesetId,
    contentPackId: rulesetId == RulesetId.dnd2024
        ? ContentPackId.srd521
        : ContentPackId.srd51,
    name: 'Legacy',
    race: 'Human',
    background: 'Sage',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(strength: 17, constitution: 15, intelligence: 14),
    hitPoints: const HitPoints(maximum: 12, current: 12),
    skillProficiencies: const ['arcana', 'history', 'athletics', 'perception', 'insight'],
    featureChoices: [
      const CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.background,
        sourceName: 'Sage',
        featureName: 'Ability Score Increase',
        choiceId: 'ability_scores',
        values: ['constitution:1', 'intelligence:2'],
      ),
      ...extraChoices,
    ],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    _context = CharacterMigrationContext(
      itemsByName: const {},
      rules2024: await Rules2024Data.load(),
    );
  });

  test('records the level 1 history from the background increases', () {
    final result = const Record2024LevelOneMigration().migrate(_legacy2024(), _context);
    final record = result.character.levelHistory.single;

    expect(record.characterLevel, 1);
    expect(record.className, 'Fighter');
    expect(record.hitPointsGained, 12);
    expect(record.baseAbilityScores['constitution'], 14);
    expect(record.baseAbilityScores['intelligence'], 12);
    expect(record.baseAbilityScores['strength'], 17);
    expect(
      result.changes.map((c) => c.code),
      contains(Record2024LevelOneMigration.historyChangeCode),
    );
  });

  test('records class skills that no background or choice grants', () {
    final result = const Record2024LevelOneMigration().migrate(
      _legacy2024(
        extraChoices: const [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.raceTrait,
            sourceName: 'Skillful',
            featureName: 'Skillful',
            choiceId: 'skill',
            values: ['insight'],
          ),
        ],
      ),
      _context,
    );
    final skills = result.character.featureChoices.singleWhere(
      (c) => c.featureName == ChoiceEffects.classSkillsFeature,
    );

    // Arcana and History come from Sage; Insight from Skillful.
    expect(skills.values, unorderedEquals(['athletics', 'perception']));
    expect(skills.sourceClass, 'Fighter');
    expect(
      result.changes.map((c) => c.code),
      contains(Record2024LevelOneMigration.classSkillsChangeCode),
    );
  });

  test('leaves recorded 2024 sheets and 2014 sheets unchanged', () {
    final migrated = const Record2024LevelOneMigration()
        .migrate(_legacy2024(), _context)
        .character;
    final again = const Record2024LevelOneMigration().migrate(migrated, _context);
    expect(again.changes, isEmpty);

    final legacy2014 = _legacy2024(rulesetId: RulesetId.dnd2014);
    final result2014 = const Record2024LevelOneMigration().migrate(legacy2014, _context);
    expect(result2014.changes, isEmpty);
    expect(result2014.character.levelHistory, isEmpty);
  });
}
