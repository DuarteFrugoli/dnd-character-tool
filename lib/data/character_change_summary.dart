import 'feature_choice_engine.dart';
import 'models/models.dart';

enum CharacterChangeKind {
  level,
  classes,
  maxHp,
  ability,
  savingThrows,
  skills,
  expertise,
  proficiencies,
  languages,
  feats,
  spells,
  experience,
}

/// One difference between two states of a character: a value that changed
/// ([before] → [after]) or a list with [added] and [removed] entries.
class CharacterChange {
  const CharacterChange({
    required this.kind,
    this.ability,
    this.before,
    this.after,
    this.added = const [],
    this.removed = const [],
  });

  final CharacterChangeKind kind;

  /// Ability name for [CharacterChangeKind.ability].
  final String? ability;
  final String? before;
  final String? after;
  final List<String> added;
  final List<String> removed;
}

/// What an operation such as a level reset changes on a sheet, shown to the
/// player before it is saved.
class CharacterChangeSummary {
  const CharacterChangeSummary._();

  static const _abilities = [
    'strength',
    'dexterity',
    'constitution',
    'intelligence',
    'wisdom',
    'charisma',
  ];

  static List<CharacterChange> compare(Character before, Character after) {
    final changes = <CharacterChange>[];
    void value(CharacterChangeKind kind, Object from, Object to, {String? ability}) {
      if (from == to) return;
      changes.add(
        CharacterChange(kind: kind, ability: ability, before: '$from', after: '$to'),
      );
    }

    // Counts repeats (two Ability Score Improvements) and ignores case, since
    // older sheets mix `perception` and `Perception`.
    void list(CharacterChangeKind kind, Iterable<String> from, Iterable<String> to) {
      Map<String, List<String>> group(Iterable<String> values) {
        final result = <String, List<String>>{};
        for (final v in values) {
          (result[v.toLowerCase()] ??= []).add(v);
        }
        return result;
      }

      final fromGroups = group(from);
      final toGroups = group(to);
      final added = <String>[];
      final removed = <String>[];
      for (final key in {...fromGroups.keys, ...toGroups.keys}) {
        final had = fromGroups[key] ?? const [];
        final has = toGroups[key] ?? const [];
        if (has.length > had.length) added.addAll(has.skip(had.length));
        if (had.length > has.length) removed.addAll(had.skip(has.length));
      }
      if (added.isEmpty && removed.isEmpty) return;
      changes.add(CharacterChange(kind: kind, added: added, removed: removed));
    }

    value(CharacterChangeKind.level, before.totalLevel, after.totalLevel);
    value(CharacterChangeKind.classes, _classes(before), _classes(after));
    value(CharacterChangeKind.maxHp, before.hitPoints.maximum, after.hitPoints.maximum);
    for (final ability in _abilities) {
      value(
        CharacterChangeKind.ability,
        before.abilityScores[ability],
        after.abilityScores[ability],
        ability: ability,
      );
    }
    list(
      CharacterChangeKind.savingThrows,
      before.savingThrowProficiencies,
      after.savingThrowProficiencies,
    );
    list(CharacterChangeKind.skills, before.skillProficiencies, after.skillProficiencies);
    list(CharacterChangeKind.expertise, before.skillExpertises, after.skillExpertises);
    list(CharacterChangeKind.proficiencies, before.features, after.features);
    list(CharacterChangeKind.languages, before.languages, after.languages);
    list(CharacterChangeKind.feats, _feats(before), _feats(after));
    list(
      CharacterChangeKind.spells,
      before.spells.map((s) => s.name),
      after.spells.map((s) => s.name),
    );
    value(CharacterChangeKind.experience, before.experiencePoints, after.experiencePoints);
    return changes;
  }

  static String _classes(Character character) => [
    for (final entry in character.classEntries)
      [
        entry.className,
        if (entry.subclassName != null) '(${entry.subclassName})',
        '${entry.level}',
      ].join(' '),
  ].join(' / ');

  static Iterable<String> _feats(Character character) => [
    for (final feature in character.extraFeatures)
      if (feature.effectiveSourceType == FeatureChoiceSourceType.feat)
        feature.name,
  ];
}
