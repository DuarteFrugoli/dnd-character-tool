import '../../character_progression/choice_effects.dart';
import '../../feature_choice_engine.dart';
import '../../feature_choice_option_resolver.dart';
import '../../models/models.dart';
import '../../rulesets/ruleset_ids.dart';
import '../character_migration.dart';

/// Records level 1 data that 2024 sheets created before progression support
/// did not save: the level 1 history record and the class skill picks.
/// 2014 sheets are unchanged.
class Record2024LevelOneMigration extends CharacterMigration {
  const Record2024LevelOneMigration();

  static const historyChangeCode = 'level_history_recorded';
  static const classSkillsChangeCode = 'class_skills_recorded';

  @override
  int get targetVersion => 11;

  @override
  String get id => 'record_2024_level_one';

  @override
  String get title => 'Record 2024 level 1 choices';

  @override
  String get description =>
      'Saves the level 1 history and class skill picks of 2024 characters.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext context,
  ) {
    final data = context.rules2024;
    if (character.rulesetId != RulesetId.dnd2024 || data == null) {
      return CharacterMigrationResult(character: character);
    }
    var updated = character;
    final changes = <CharacterMigrationChange>[];

    if (updated.levelHistory.isEmpty && updated.totalLevel == 1) {
      final entry = updated.primaryClass;
      final bonuses = <String, int>{};
      for (final choice in updated.featureChoices) {
        if (choice.sourceType != FeatureChoiceSourceType.background ||
            choice.choiceId != 'ability_scores') {
          continue;
        }
        for (final value in choice.values) {
          final parts = value.split(':');
          final bonus = parts.length == 2 ? int.tryParse(parts[1]) : null;
          if (bonus != null) bonuses[parts[0]] = bonus;
        }
      }
      updated = updated.copyWith(
        levelHistory: [
          CharacterLevelRecord(
            characterLevel: 1,
            classEntryId: entry.id,
            className: entry.className,
            classLevel: 1,
            hitPointsGained: updated.hitPoints.maximum,
            hitPointMethod: HitPointGainMethod.maximum,
            baseAbilityScores: {
              for (final ability in const [
                'strength',
                'dexterity',
                'constitution',
                'intelligence',
                'wisdom',
                'charisma',
              ])
                ability: updated.abilityScores[ability] - (bonuses[ability] ?? 0),
            },
          ),
        ],
      );
      changes.add(const CharacterMigrationChange(code: historyChangeCode, count: 1));
    }

    final recorded = updated.featureChoices.any(
      (choice) => choice.featureName == ChoiceEffects.classSkillsFeature,
    );
    if (!recorded) {
      final entry = updated.primaryClass;
      final cls = data.classNamed(entry.className);
      final classSkills = cls.skillChoices.isAny
          ? {for (final skill in data.skills) skill.name.toLowerCase()}
          : cls.skillChoices.from.toSet();
      // Skills no background or recorded choice grants came from the class.
      final granted = {
        ...?data.backgroundNamed(updated.background)?.skills,
        for (final choice in updated.featureChoices)
          if (ChoiceEffects.effectType(data, choice) case 'skill' || 'skill_or_tool')
            for (final value in choice.values)
              value.replaceFirst('skill:', '').replaceAll('_', ' '),
      };
      final picks = [
        for (final skill in updated.skillProficiencies)
          if (classSkills.contains(skill) && !granted.contains(skill))
            FeatureChoiceOptionResolver.idFromName(skill),
      ];
      updated = updated.copyWith(
        featureChoices: [
          ...updated.featureChoices,
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.classFeature,
            sourceClass: entry.className,
            sourceClassEntryId: entry.id,
            featureName: ChoiceEffects.classSkillsFeature,
            choiceId: 'skills',
            values: picks.take(cls.skillChoices.count).toList(),
          ),
        ],
      );
      changes.add(const CharacterMigrationChange(code: classSkillsChangeCode, count: 1));
    }
    return CharacterMigrationResult(character: updated, changes: changes);
  }
}
