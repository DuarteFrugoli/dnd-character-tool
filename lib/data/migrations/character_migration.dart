import '../character_progression/progression_2024_engine.dart';
import '../datasources/srd/srd_models.dart';
import '../models/models.dart';

class CharacterMigrationContext {
  const CharacterMigrationContext({required this.itemsByName, this.rules2024});

  final Map<String, SrdItemData> itemsByName;

  /// SRD 5.2.1 data for migrations of 2024 characters.
  final Rules2024Data? rules2024;
}

abstract class CharacterMigration {
  const CharacterMigration();

  int get targetVersion;
  String get id;
  String get title;
  String get description;

  CharacterMigrationResult migrate(
    Character character,
    CharacterMigrationContext context,
  );
}

class CharacterMigrationResult {
  const CharacterMigrationResult({
    required this.character,
    this.changes = const [],
  });

  final Character character;
  final List<CharacterMigrationChange> changes;
}

class CharacterMigrationChange {
  const CharacterMigrationChange({required this.code, required this.count});

  final String code;
  final int count;
}
