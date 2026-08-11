import '../../data/constants/level_up_rules.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/models/models.dart';

String localizedClassLevelSummary(
  Character character,
  SrdI18nService i18n, {
  bool includeSubclasses = false,
}) {
  return localizedClassEntriesSummary(
    character.classEntries,
    i18n,
    includeSubclasses: includeSubclasses,
  );
}

String localizedClassEntriesSummary(
  Iterable<CharacterClassEntry> entries,
  SrdI18nService i18n, {
  bool includeSubclasses = false,
}) {
  return entries
      .map(
        (entry) => localizedClassEntryLabel(
          entry,
          i18n,
          includeSubclass: includeSubclasses,
        ),
      )
      .join(' / ');
}

String localizedClassEntryLabel(
  CharacterClassEntry entry,
  SrdI18nService i18n, {
  bool includeSubclass = false,
}) {
  final className = i18n.className(entry.className);
  final subclassName = entry.subclassName;
  final label =
      includeSubclass && subclassName != null && subclassName.isNotEmpty
      ? '$className (${i18n.subclassName(entry.className, subclassName)})'
      : className;
  return '$label ${entry.level}';
}

String localizedRaceSummary(Character character, SrdI18nService i18n) {
  return localizedRaceSummaryFromParts(
    race: character.race,
    subrace: character.subrace,
    i18n: i18n,
  );
}

String localizedRaceSummaryFromParts({
  required String race,
  required String? subrace,
  required SrdI18nService i18n,
}) {
  final raceName = i18n.raceName(race);
  final subraceName = subrace;
  if (subraceName == null || subraceName.isEmpty) return raceName;
  return '$raceName (${i18n.subraceName(subraceName)})';
}

String hitDicePoolSummary(Character character) {
  final pools = character.hitDicePools.isNotEmpty
      ? character.hitDicePools
      : [
          CharacterHitDiePool(
            dieSize: levelUpHitDie(character.primaryClassName),
            total: character.totalLevel,
            used: character.hitPoints.hitDiceUsed,
            sourceClass: character.primaryClassName,
            sourceClassEntryId: character.primaryClass.id,
          ),
        ];
  return pools.map((pool) => 'd${pool.dieSize} x ${pool.total}').join(', ');
}
