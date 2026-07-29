import '../datasources/srd/srd_models.dart';
import '../models/models.dart';

class CharacterMigrationContext {
  const CharacterMigrationContext({required this.itemsByName});

  final Map<String, SrdItemData> itemsByName;
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
