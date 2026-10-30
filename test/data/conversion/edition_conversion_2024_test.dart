import 'package:dnd_character_tool/data/character_progression/progression_2024_engine.dart';
import 'package:dnd_character_tool/data/conversion/edition_conversion_2024.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_2024_creation_catalog.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/features/character_creation/creation_2024_draft.dart';
import 'package:flutter_test/flutter_test.dart';

late Creation2024Catalog _catalog;
late List<SrdRace> _races;

Character _monk({
  String race = 'Halfling',
  String? subrace = 'Lightfoot',
  int level = 1,
  List<CharacterLevelRecord> history = const [],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'old',
    name: 'Old Monk',
    playerName: 'Pedro',
    race: race,
    subrace: subrace,
    characterClass: 'Monk',
    level: level,
    classes: [
      CharacterClassEntry(id: 'primary', className: 'Monk', level: level, isStartingClass: true),
    ],
    background: 'Criminal',
    abilityScores: const AbilityScores(
      strength: 10,
      dexterity: 17,
      constitution: 14,
      intelligence: 10,
      wisdom: 15,
      charisma: 9,
    ),
    hitPoints: const HitPoints(maximum: 10, current: 3),
    skillProficiencies: const ['acrobatics', 'stealth', 'insight'],
    languages: const ['Common', 'Halfling'],
    equipment: [
      EquipmentItem(id: 'sword', name: 'Longsword', category: 'Martial Melee', itemType: ItemType.weapon, quantity: 1),
      EquipmentItem(id: 'rope', name: 'Lucky Rope', category: 'gear', itemType: ItemType.gear),
    ],
    currency: const {'cp': 3, 'sp': 0, 'ep': 0, 'gp': 42, 'pp': 1},
    experiencePoints: 120,
    notes: [CharacterNote(id: 'n', title: 'Quest', content: 'Find the bell', createdAt: now)],
    backstory: 'Raised in a monastery.',
    levelHistory: history,
    activeConditions: const ['Poisoned'],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    _catalog = await Creation2024Catalog.load();
    _races = await SrdDataSource.forPack(SrdContentPackRegistry.srd51).getRaces();
  });

  test('prefill removes 2014 racial bonuses and maps class, species and background', () {
    final prefill = EditionConversion2024.prefill(_monk(), races2014: _races, catalog: _catalog);
    expect(prefill.className, 'Monk');
    expect(prefill.speciesName, 'Halfling');
    expect(prefill.backgroundName, 'Criminal');
    expect(prefill.baseAbilities['dexterity'], 15, reason: 'Halfling +2');
    expect(prefill.baseAbilities['charisma'], 8, reason: 'Lightfoot +1');
    expect(prefill.abilityIncreasesUnknown, isFalse);
    expect(prefill.skills, ['acrobatics', 'insight'], reason: 'Criminal grants Stealth in 2024');
    expect(prefill.languages, ['Halfling']);
  });

  test('prefill flags increases it cannot identify', () {
    final halfElf = EditionConversion2024.prefill(
      _monk(race: 'Half-Elf', subrace: null),
      races2014: _races,
      catalog: _catalog,
    );
    expect(halfElf.speciesName, isNull);
    expect(halfElf.abilityIncreasesUnknown, isTrue, reason: 'Half-Elf picks two +1');

    expect(
      EditionConversion2024.prefill(_monk(level: 5), races2014: _races, catalog: _catalog)
          .abilityIncreasesUnknown,
      isTrue,
      reason: 'no level history',
    );

    final recorded = EditionConversion2024.prefill(
      _monk(
        level: 4,
        history: [
          for (var level = 1; level <= 4; level++)
            CharacterLevelRecord(
              characterLevel: level,
              classEntryId: 'primary',
              className: 'Monk',
              classLevel: level,
              hitPointsGained: 5,
              abilityIncreases: level == 4 ? const {'wisdom': 2} : const {},
            ),
        ],
      ),
      races2014: _races,
      catalog: _catalog,
    );
    expect(recorded.abilityIncreasesUnknown, isFalse);
    expect(recorded.baseAbilities['wisdom'], 13);
  });

  test('a converted sheet keeps the inventory and story and starts fresh', () {
    final old = _monk();
    final prefill = EditionConversion2024.prefill(old, races2014: _races, catalog: _catalog);
    final draft = Creation2024Draft.forConversion(prefill, _catalog)
      ..name = old.name
      ..playerName = old.playerName;
    expect(draft.abilityMethod, Creation2024AbilityMethod.fromSheet);
    expect(draft.equipmentComplete, isTrue);
    draft.backgroundBonuses.addAll({'dexterity': 2, 'constitution': 1});
    draft.classTools.add("Brewer's Supplies");
    draft.languages.add('Elvish');
    draft.reconcileChoices(_catalog);

    final built = draft.build(_catalog, fallbackName: 'Unnamed');
    expect(built.equipment, isEmpty);
    expect(built.featureChoices.where((choice) => choice.featureName == 'Starting Equipment'), isEmpty);
    expect(built.abilityScores.dexterity, 17);

    final converted = EditionConversion2024.carryOver(old, built, items: _catalog.items);
    expect(converted.rulesetId, RulesetId.dnd2024);
    expect(converted.id, isNot(old.id));
    expect(converted.name, 'Old Monk');
    expect(converted.playerName, 'Pedro');
    expect(converted.backstory, old.backstory);
    expect(converted.notes.single.title, 'Quest');
    expect(converted.currency, old.currency);
    expect(converted.experiencePoints, 120);
    expect(converted.hitPoints.current, converted.hitPoints.maximum);
    expect(converted.activeConditions, isEmpty);
    final sword = converted.equipment.firstWhere((item) => item.name == 'Longsword');
    expect(sword.properties?['mastery'], 'sap', reason: '2024 catalog data');
    expect(converted.equipment.map((item) => item.name), contains('Lucky Rope'));
    expect(converted.featureChoices.any((choice) =>
        choice.sourceType == FeatureChoiceSourceType.classFeature &&
        choice.choiceId == 'skills' &&
        choice.values.contains('insight')), isTrue);
  });

  test('the converted level 1 sheet can be rebuilt with 2024 level ups', () async {
    final old = _monk(level: 2);
    final prefill = EditionConversion2024.prefill(old, races2014: _races, catalog: _catalog);
    final draft = Creation2024Draft.forConversion(prefill, _catalog);
    draft.backgroundBonuses.addAll({'dexterity': 2, 'constitution': 1});
    draft.classTools.add("Brewer's Supplies");
    draft.languages.add('Elvish');
    draft.reconcileChoices(_catalog);
    final levelOne = EditionConversion2024.carryOver(
      old,
      draft.build(_catalog, fallbackName: 'Unnamed'),
      items: _catalog.items,
    );
    final data = await Rules2024Data.load();
    final plan = Progression2024Engine.plan(levelOne, data, className: 'Monk', classEntryId: 'primary');
    final requests = Progression2024Engine.requestsFor(levelOne, data, plan);
    final levelTwo = Progression2024Engine.applyLevelUp(
      levelOne,
      data,
      LevelUp2024Result(
        className: 'Monk',
        classEntryId: 'primary',
        featureChoices: [
          for (final request in requests)
            request.toChoice([for (var i = 0; i < request.requiredCount; i++) '${request.choiceId}_$i']),
        ],
      ),
    );
    expect(levelTwo.totalLevel, 2);
    expect(levelTwo.levelHistory, hasLength(2));
    expect(levelTwo.experiencePoints, old.experiencePoints);
  });

  test('only 2014 sheets can be converted', () {
    final sheet = _monk().copyWith(rulesetId: RulesetId.dnd2024, contentPackId: ContentPackId.srd521);
    expect(
      () => EditionConversion2024.prefill(sheet, races2014: _races, catalog: _catalog),
      throwsArgumentError,
    );
  });
}
