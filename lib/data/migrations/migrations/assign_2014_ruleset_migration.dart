import '../../models/models.dart';
import '../../rulesets/ruleset_ids.dart';
import '../character_migration.dart';

class Assign2014RulesetMigration extends CharacterMigration {
  const Assign2014RulesetMigration();

  static const changeCode = 'ruleset_2014_assigned';

  @override
  int get targetVersion => 10;

  @override
  String get id => 'assign_2014_ruleset';

  @override
  String get title => 'Assign 2014 ruleset';

  @override
  String get description =>
      'Marks existing characters as using 2014 rules and SRD 5.1 content.';

  @override
  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext _,
  ) => CharacterMigrationResult(
    character: character.copyWith(
      rulesetId: RulesetId.dnd2014,
      contentPackId: ContentPackId.srd51,
    ),
    changes: const [CharacterMigrationChange(code: changeCode, count: 1)],
  );
}
