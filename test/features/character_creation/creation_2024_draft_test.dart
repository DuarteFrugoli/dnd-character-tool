import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/data/feature_choice_option_resolver.dart';
import 'package:dnd_character_tool/data/models/character.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_2024_creation_catalog.dart';
import 'package:dnd_character_tool/features/character_creation/creation_2024_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Creation2024Catalog catalog;

  setUpAll(() async {
    catalog = await Creation2024Catalog.load();
  });

  test('2024 creation rejects a 2014 data source', () async {
    await expectLater(
      Creation2024Catalog.load(
        source: SrdDataSource.forPack(SrdContentPackRegistry.srd51),
      ),
      throwsStateError,
    );
  });

  test('loads all level-one classes, species and backgrounds', () {
    expect(catalog.classes, hasLength(12));
    expect(catalog.species, hasLength(9));
    expect(catalog.backgrounds, hasLength(4));
    expect(catalog.classes.every((entry) => entry.levelOne['level'] == 1), isTrue);
  });

  test('background grants only its three eligible ability increases', () {
    final draft = Creation2024Draft()
      ..selectBackground(catalog.backgrounds.firstWhere((entry) => entry.name == 'Criminal'));
    draft.baseAbilities.addAll({
      'strength': 15,
      'dexterity': 14,
      'constitution': 13,
      'intelligence': 12,
      'wisdom': 10,
      'charisma': 8,
    });
    draft.backgroundBonuses.addAll({'dexterity': 2, 'constitution': 1});
    expect(draft.abilitiesComplete, isTrue);
    expect(draft.finalAbilities['dexterity'], 16);
    draft.backgroundBonuses['wisdom'] = 1;
    expect(draft.abilitiesComplete, isFalse);
  });

  test('point buy and rolled scores use the same background bonuses', () {
    final draft = Creation2024Draft()
      ..selectBackground(catalog.backgrounds.firstWhere((entry) => entry.name == 'Soldier'));
    draft.abilityMethod = Creation2024AbilityMethod.pointBuy;
    draft.baseAbilities.addAll({
      'strength': 15, 'dexterity': 14, 'constitution': 13,
      'intelligence': 12, 'wisdom': 10, 'charisma': 8,
    });
    draft.backgroundBonuses.addAll({'strength': 2, 'constitution': 1});
    expect(draft.abilitiesComplete, isTrue);
    expect(draft.finalAbilities['strength'], 17);
    draft.abilityMethod = Creation2024AbilityMethod.rolledDice;
    draft.rolledScores.addAll([15, 15, 13, 12, 10, 8]);
    draft.assignedRolls.addAll({
      'strength': 0, 'dexterity': 1, 'constitution': 2,
      'intelligence': 3, 'wisdom': 4, 'charisma': 5,
    });
    draft.baseAbilities['dexterity'] = 15;
    expect(draft.abilitiesComplete, isTrue);
  });

  test('creates a level-one 2024 character without 2014 progression', () {
    final draft = Creation2024Draft()
      ..selectClass(catalog.classes.firstWhere((entry) => entry.name == 'Monk'))
      ..selectSpecies(catalog.species.firstWhere((entry) => entry.name == 'Halfling'))
      ..selectBackground(catalog.backgrounds.firstWhere((entry) => entry.name == 'Criminal'));
    draft.name = '2024 Monk';
    draft.baseAbilities.addAll({
      'strength': 8,
      'dexterity': 15,
      'constitution': 14,
      'intelligence': 10,
      'wisdom': 13,
      'charisma': 12,
    });
    draft.backgroundBonuses.addAll({'dexterity': 2, 'constitution': 1});
    draft.skills.addAll(['acrobatics', 'athletics']);
    draft.classTools.add("Brewer's Supplies");
    draft.languages.addAll(['Elvish', 'Dwarvish']);
    draft.classEquipmentId = 'b';
    draft.backgroundEquipmentId = 'b';
    draft.reconcileChoices(catalog);

    final character = draft.build(catalog, fallbackName: 'Unnamed Hero');
    expect(character.rulesetId, RulesetId.dnd2024);
    expect(character.contentPackId, ContentPackId.srd521);
    expect(character.level, 1);
    expect(character.abilityScores.dexterity, 17);
    expect(character.hitPoints.maximum, 10);
    expect(character.currency['gp'], 100);
    expect(character.languages, containsAll(['Common', 'Elvish', 'Dwarvish']));
    expect(character.extraFeatures.map((feature) => feature.name), contains('Alert'));
    final abilityOrigin = character.featureChoices.singleWhere(
      (choice) => choice.sourceType == 'background' && choice.choiceId == 'ability_scores',
    );
    expect(abilityOrigin.sourceName, 'Criminal');
    expect(abilityOrigin.values, containsAll(['dexterity:2', 'constitution:1']));
    final restored = Character.fromJson(character.toJson());
    expect(restored.rulesetId, RulesetId.dnd2024);
    expect(restored.contentPackId, ContentPackId.srd521);
    expect(restored.featureChoices.singleWhere((choice) => choice.choiceId == 'ability_scores').values,
        abilityOrigin.values);
  });

  test('Acolyte Magic Initiate keeps the Cleric spell list fixed', () {
    final draft = Creation2024Draft()
      ..selectClass(catalog.classes.firstWhere((entry) => entry.name == 'Bard'))
      ..selectSpecies(catalog.species.firstWhere((entry) => entry.name == 'Dwarf'))
      ..selectBackground(catalog.backgrounds.firstWhere((entry) => entry.name == 'Acolyte'));
    draft.reconcileChoices(catalog);
    final request = draft.requests(catalog).firstWhere((entry) =>
        entry.sourceClassEntryId == 'background' && entry.choiceId == 'spell_class');
    expect(request.requirement.options.map((entry) => entry.id), ['cleric']);
    expect(request.findIn(draft.featureChoices)?.values, ['cleric']);
  });

  test('Bard and Soldier require their tool proficiency choices', () {
    final draft = Creation2024Draft()
      ..selectClass(catalog.classes.firstWhere((entry) => entry.name == 'Bard'))
      ..selectBackground(catalog.backgrounds.firstWhere((entry) => entry.name == 'Soldier'));
    draft.skills.addAll(['arcana', 'insight', 'perception']);
    draft.languages.addAll(['Elvish', 'Dwarvish']);
    expect(draft.proficienciesComplete, isFalse);
    draft.classTools.addAll(['Flute', 'Horn', 'Lute']);
    draft.backgroundTools.add('Dice');
    expect(draft.proficienciesComplete, isTrue);
  });

  test('level-one spell choices come from the 2024 progression tables', () {
    final draft = Creation2024Draft()
      ..selectSpecies(catalog.species.firstWhere((entry) => entry.name == 'Dwarf'))
      ..selectBackground(catalog.backgrounds.firstWhere((entry) => entry.name == 'Criminal'));
    draft.selectClass(catalog.classes.firstWhere((entry) => entry.name == 'Bard'));
    expect(draft.requests(catalog).firstWhere((entry) =>
        entry.choiceId == 'cantrips').requiredCount, 2);
    expect(draft.requests(catalog).firstWhere((entry) =>
        entry.choiceId == 'prepared_spells').requiredCount, 4);
    draft.selectClass(catalog.classes.firstWhere((entry) => entry.name == 'Wizard'));
    expect(draft.requests(catalog).firstWhere((entry) =>
        entry.choiceId == 'prepared_spells').requiredCount, 6);
  });

  test('Wizard starts with six book spells and four prepared spells', () {
    final draft = Creation2024Draft()
      ..selectClass(catalog.classes.firstWhere((entry) => entry.name == 'Wizard'))
      ..selectSpecies(catalog.species.firstWhere((entry) => entry.name == 'Dwarf'))
      ..selectBackground(catalog.backgrounds.firstWhere((entry) => entry.name == 'Soldier'));
    draft.baseAbilities.addAll({
      'strength': 8, 'dexterity': 13, 'constitution': 14,
      'intelligence': 15, 'wisdom': 12, 'charisma': 10,
    });
    draft.backgroundBonuses.addAll({'strength': 1, 'constitution': 2});
    draft.skills.addAll(['arcana', 'history']);
    draft.languages.addAll(['Elvish', 'Dwarvish']);
    draft.backgroundTools.add('Dice');
    draft.classEquipmentId = 'b';
    draft.backgroundEquipmentId = 'b';
    draft.reconcileChoices(catalog);

    final cantripNames = catalog.spells.where((spell) =>
        spell.level == 0 && spell.classes.contains('wizard'))
        .take(3).map((spell) => spell.name).toList();
    final bookNames = catalog.spells.where((spell) =>
        spell.level == 1 && spell.classes.contains('wizard'))
        .take(6).map((spell) => spell.name).toList();
    final requests = draft.requests(catalog);
    draft.featureChoices = [
      for (final request in requests)
        request.choiceId == 'cantrips'
            ? request.toChoice(cantripNames)
            : request.choiceId == 'prepared_spells'
                ? request.toChoice(bookNames)
                : request.findIn(draft.featureChoices) ?? request.emptyChoice(),
    ];
    draft.preparedWizardSpells.addAll(bookNames.take(4));

    final character = draft.build(catalog, fallbackName: 'Unnamed Hero');
    expect(character.spells.where((spell) => spell.level == 1), hasLength(6));
    expect(character.spells.where((spell) => spell.level == 1 && spell.isPrepared), hasLength(4));
    expect(character.spells.where((spell) => spell.level == 0), hasLength(3));
    expect(character.spellSlots.total.first, 2);
  });

  test('a Human can take a separate repeatable origin feat instance', () {
    final draft = Creation2024Draft()
      ..selectClass(catalog.classes.firstWhere((entry) => entry.name == 'Fighter'))
      ..selectSpecies(catalog.species.firstWhere((entry) => entry.name == 'Human'))
      ..selectBackground(catalog.backgrounds.firstWhere((entry) => entry.name == 'Acolyte'));
    draft.reconcileChoices(catalog);
    final versatile = draft.requests(catalog).firstWhere((entry) =>
        entry.featureName == 'Versatile');
    draft.featureChoices = [
      for (final choice in draft.featureChoices)
        if (choice.choiceId != versatile.choiceId || choice.featureName != versatile.featureName)
          choice,
      versatile.toChoice(['Magic Initiate']),
    ];
    draft.reconcileChoices(catalog);
    final spellClasses = draft.requests(catalog).where((entry) =>
        entry.sourceClassEntryId == 'species' && entry.choiceId == 'spell_class').single;
    expect(spellClasses.requirement.options.map((option) => option.id),
        isNot(contains('cleric')));
    expect(draft.requests(catalog).where((entry) =>
        entry.choiceId == 'cantrips' && entry.sourceType == 'feat'), hasLength(2));

    final humanClass = spellClasses.toChoice(['wizard']);
    draft.featureChoices = [
      for (final choice in draft.featureChoices)
        if (!choice.matches(
          sourceType: spellClasses.sourceType,
          sourceClassEntryId: spellClasses.sourceClassEntryId,
          sourceName: spellClasses.sourceName,
          featureName: spellClasses.featureName,
          choiceId: spellClasses.choiceId,
        )) choice,
      humanClass,
    ];
    draft.reconcileChoices(catalog);
    final humanCantrips = draft.requests(catalog).firstWhere((entry) =>
        entry.sourceClassEntryId == 'species' && entry.choiceId == 'cantrips');
    final options = FeatureChoiceOptionResolver(
      request: humanCantrips,
      catalog: catalog.choices,
      i18n: SrdI18nService.english,
      skills: catalog.skills,
      tools: catalog.tools,
      spells: catalog.spells,
      languages: catalog.languages,
      weapons: catalog.weapons,
      feats: catalog.feats,
      relatedRequests: draft.requests(catalog),
      choices: draft.featureChoices,
    ).options;
    expect(options.map((option) => option.id), contains('Acid Splash'));

    draft.featureChoices = [
      for (final choice in draft.featureChoices)
        if (humanCantrips.findIn([choice]) != null)
          humanCantrips.toChoice(['Acid Splash'])
        else
          choice,
    ];
    draft.setChoices(catalog, [
      for (final choice in draft.featureChoices)
        if (spellClasses.findIn([choice]) != null)
          spellClasses.toChoice(['druid'])
        else
          choice,
    ]);
    expect(humanCantrips.findIn(draft.featureChoices)?.values, isEmpty);
  });
}
