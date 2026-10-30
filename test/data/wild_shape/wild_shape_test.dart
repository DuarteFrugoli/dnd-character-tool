import 'package:dnd_character_tool/data/character_change_summary.dart';
import 'package:dnd_character_tool/data/character_progression/progression_2024_engine.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_monster.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/feature_choice_option_resolver.dart';
import 'package:dnd_character_tool/data/feature_usage_engine.dart';
import 'package:dnd_character_tool/data/hit_point_changes.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/data/rulesets/wild_shape_rules.dart';
import 'package:dnd_character_tool/data/wild_shape/wild_shape_engine.dart';
import 'package:flutter_test/flutter_test.dart';

late List<SrdMonster> _beasts2014;
late List<SrdMonster> _beasts2024;
late FeatureUsageCatalog _usages2014;
late FeatureUsageCatalog _usages2024;
late Rules2024Data _rules2024;

SrdMonster _beast(List<SrdMonster> beasts, String id) =>
    beasts.firstWhere((beast) => beast.id == id);

CharacterFeatureChoice _knownForms(List<String> ids) => CharacterFeatureChoice(
  sourceType: FeatureChoiceSourceType.classFeature,
  sourceClass: 'Druid',
  sourceClassEntryId: 'primary',
  featureName: 'Wild Shape',
  choiceId: WildShape2024Rules.knownFormsChoice,
  values: ids,
);

Character _druid({
  required RulesetId ruleset,
  int level = 2,
  int hp = 17,
  int temporaryHp = 0,
  List<CharacterFeatureChoice> choices = const [],
  Map<String, int> resources = const {},
  ActiveWildShape? wildShape,
}) {
  final now = DateTime(2024);
  return Character(
    id: 'druid',
    rulesetId: ruleset,
    contentPackId: ruleset == RulesetId.dnd2024 ? ContentPackId.srd521 : ContentPackId.srd51,
    name: 'Druid',
    race: 'Human',
    characterClass: 'Druid',
    level: level,
    classes: [
      CharacterClassEntry(id: 'primary', className: 'Druid', level: level, isStartingClass: true),
    ],
    abilityScores: const AbilityScores(
      strength: 10,
      dexterity: 12,
      constitution: 14,
      intelligence: 11,
      wisdom: 16,
      charisma: 8,
    ),
    hitPoints: HitPoints(maximum: hp, current: hp, temporary: temporaryHp),
    featureChoices: choices,
    featureResources: resources,
    wildShape: wildShape,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final srd51 = SrdDataSource.forPack(SrdContentPackRegistry.srd51);
    final srd521 = SrdDataSource.forPack(SrdContentPackRegistry.srd521);
    _beasts2014 = await srd51.getMonsters();
    _beasts2024 = await srd521.getMonsters();
    _usages2014 = await srd51.getFeatureUsageCatalog();
    _usages2024 = await srd521.getFeatureUsageCatalog();
    _rules2024 = await Rules2024Data.load(source: srd521);
  });

  group('monster catalogs', () {
    test('both packs hold the Beasts Wild Shape can use', () {
      for (final beasts in [_beasts2014, _beasts2024]) {
        expect(beasts, isNotEmpty);
        expect(beasts.every((beast) => beast.isBeast && beast.challengeValue <= 1), isTrue);
        expect({for (final beast in beasts) beast.id}, hasLength(beasts.length));
      }
    });

    test('stat blocks keep structured attacks and edition differences', () {
      final wolf2014 = _beast(_beasts2014, 'wolf');
      final wolf2024 = _beast(_beasts2024, 'wolf');
      expect(wolf2014.armorClass, 13);
      expect(wolf2024.armorClass, 12);
      expect(wolf2014.initiativeModifier, isNull);
      expect(wolf2024.initiativeModifier, 2);
      final bite = wolf2024.attacks.single;
      expect(bite.attack!.bonus, 4);
      expect(bite.attack!.reach, 5);
      expect(bite.damage.single.formula, '1d6+2');
      expect(bite.damage.single.type, 'piercing');
      expect(wolf2014.attacks.single.damage.single.formula, '2d4+2');

      final spider = _beast(_beasts2014, 'giant_spider');
      final web = spider.actions.firstWhere((action) => action.id == 'web');
      expect(web.usage?.type, 'recharge');
      expect(web.usage?.rechargeMin, 5);
      final venom = spider.actions.firstWhere((action) => action.id == 'bite').save!;
      expect(venom.dc, 11);
      expect(venom.damage.single.formula, '2d8');
      expect(venom.halfOnSuccess, isTrue);
    });
  });

  group('Beast Shapes limits', () {
    test('2014 limits challenge, swim and fly by Druid level', () {
      const rules = WildShape2014Rules();
      final octopus = _beast(_beasts2014, 'octopus');
      final eagle = _beast(_beasts2014, 'eagle');
      final wolf = _beast(_beasts2014, 'wolf');
      final crocodile = _beast(_beasts2014, 'crocodile');
      final brownBear = _beast(_beasts2014, 'brown_bear');
      expect(rules.limitsAt(1), isNull);
      final level2 = rules.limitsAt(2)!;
      expect(level2.allows(wolf), isTrue);
      expect(level2.allows(octopus), isFalse, reason: 'no Swim Speed at level 2');
      expect(level2.allows(crocodile), isFalse);
      final level4 = rules.limitsAt(4)!;
      expect(level4.allows(octopus), isTrue);
      expect(level4.allows(crocodile), isTrue);
      expect(level4.allows(eagle), isFalse);
      final level8 = rules.limitsAt(8)!;
      expect(level8.allows(eagle), isTrue);
      expect(level8.allows(brownBear), isTrue);
    });

    test('2024 known forms grow and Fly Speed opens at level 8', () {
      const rules = WildShape2024Rules();
      final insects = _beast(_beasts2024, 'swarm_of_insects');
      expect(rules.limitsAt(2)!.knownForms, 4);
      expect(rules.limitsAt(4)!.knownForms, 6);
      expect(rules.limitsAt(8)!.knownForms, 8);
      expect(rules.limitsAt(2)!.allows(_beast(_beasts2024, 'octopus')), isTrue);
      expect(rules.limitsAt(4)!.allows(insects), isFalse, reason: 'Climb or Fly counts as Fly');
      expect(rules.limitsAt(8)!.allows(insects), isTrue);
      expect(rules.durationHours(5), 2);
    });
  });

  group('2024 known forms choice', () {
    test('level 2 asks for four forms and level 4 for six', () {
      final druid = _druid(ruleset: RulesetId.dnd2024, level: 1)
          .copyWith(levelHistory: const [
        CharacterLevelRecord(
          characterLevel: 1,
          classEntryId: 'primary',
          className: 'Druid',
          classLevel: 1,
          hitPointsGained: 10,
        ),
      ]);
      final plan = Progression2024Engine.plan(druid, _rules2024, className: 'Druid', classEntryId: 'primary');
      final request = Progression2024Engine.requestsFor(druid, _rules2024, plan)
          .firstWhere((r) => r.choiceId == WildShape2024Rules.knownFormsChoice);
      expect(request.requiredCount, 4);

      final resolver = FeatureChoiceOptionResolver(
        request: request,
        catalog: _rules2024.choices,
        i18n: SrdI18nService.englishForPack(SrdContentPackRegistry.srd521),
        skills: const [],
        tools: const [],
        spells: const [],
        languages: const [],
        weapons: const [],
        feats: const [],
        monsters: _beasts2024,
        character: druid,
      );
      final ids = {for (final option in resolver.options) option.id};
      expect(ids, containsAll(['rat', 'riding_horse', 'spider', 'wolf']));
      expect(ids, isNot(contains('eagle')));
      expect(ids, isNot(contains('crocodile')));

      final level3 = _druid(
        ruleset: RulesetId.dnd2024,
        level: 3,
        choices: [_knownForms(['rat', 'riding_horse', 'spider', 'wolf'])],
      ).copyWith(levelHistory: [
        for (var level = 1; level <= 3; level++)
          CharacterLevelRecord(
            characterLevel: level,
            classEntryId: 'primary',
            className: 'Druid',
            classLevel: level,
            hitPointsGained: 6,
          ),
      ]);
      final level4Plan = Progression2024Engine.plan(
        level3,
        _rules2024,
        className: 'Druid',
        classEntryId: 'primary',
      );
      final level4 = Progression2024Engine.requestsFor(level3, _rules2024, level4Plan)
          .firstWhere((r) => r.choiceId == WildShape2024Rules.knownFormsChoice);
      expect(level4.requiredCount, 6);
    });

    test('level up rejects forms the table does not allow', () {
      final druid = _druid(ruleset: RulesetId.dnd2024, level: 1).copyWith(
        levelHistory: const [
          CharacterLevelRecord(
            characterLevel: 1,
            classEntryId: 'primary',
            className: 'Druid',
            classLevel: 1,
            hitPointsGained: 10,
          ),
        ],
      );
      final plan = Progression2024Engine.plan(druid, _rules2024, className: 'Druid', classEntryId: 'primary');
      final requests = Progression2024Engine.requestsFor(druid, _rules2024, plan);
      List<CharacterFeatureChoice> choicesWith(List<String> forms) => [
        for (final request in requests)
          request.toChoice(
            request.choiceId == WildShape2024Rules.knownFormsChoice
                ? forms
                : [for (var i = 0; i < request.requiredCount; i++) '${request.choiceId}_$i'],
          ),
      ];
      LevelUp2024Result result(List<String> forms) => LevelUp2024Result(
        className: 'Druid',
        classEntryId: 'primary',
        featureChoices: choicesWith(forms),
      );
      expect(
        () => Progression2024Engine.applyLevelUp(
          druid,
          _rules2024,
          result(['rat', 'riding_horse', 'spider', 'eagle']),
        ),
        throwsA(
          isA<ArgumentError>().having((e) => '${e.message}', 'message', contains('Wild Shape')),
        ),
      );
      final leveled = Progression2024Engine.applyLevelUp(
        druid,
        _rules2024,
        result(['rat', 'riding_horse', 'spider', 'wolf']),
      );
      expect(WildShapeEngine.knownFormIds(leveled), ['rat', 'riding_horse', 'spider', 'wolf']);
    });
  });

  group('assuming a form', () {
    test('2024 spends a use, grants Temporary Hit Points and keeps HP', () {
      final druid = _druid(
        ruleset: RulesetId.dnd2024,
        level: 3,
        choices: [_knownForms(['wolf', 'rat'])],
      );
      expect(
        WildShapeEngine.availableForms(druid, _beasts2024).map((b) => b.id),
        unorderedEquals(['wolf', 'rat']),
      );
      final shaped = WildShapeEngine.assume(druid, _beast(_beasts2024, 'wolf'), _beasts2024, _usages2024);
      expect(shaped.wildShape?.monsterId, 'wolf');
      expect(shaped.wildShape?.hitPoints, isNull);
      expect(shaped.hitPoints.temporary, 3);
      expect(shaped.hitPoints.current, druid.hitPoints.current);
      expect(shaped.featureResources['2024_wild_shape'], 1);

      expect(
        () => WildShapeEngine.assume(druid, _beast(_beasts2024, 'riding_horse'), _beasts2024, _usages2024),
        throwsArgumentError,
        reason: 'not a known form',
      );
      final keptTemp = WildShapeEngine.assume(
        druid.copyWith(hitPoints: druid.hitPoints.copyWith(temporary: 8)),
        _beast(_beasts2024, 'rat'),
        _beasts2024,
        _usages2024,
      );
      expect(keptTemp.hitPoints.temporary, 8);
    });

    test('no uses left blocks a new form', () {
      final druid = _druid(
        ruleset: RulesetId.dnd2024,
        choices: [_knownForms(['wolf'])],
        resources: const {'2024_wild_shape': 0},
      );
      expect(
        () => WildShapeEngine.assume(druid, _beast(_beasts2024, 'wolf'), _beasts2024, _usages2024),
        throwsStateError,
      );
    });

    test('2014 forms use their own hit points and excess damage carries over', () {
      final druid = _druid(ruleset: RulesetId.dnd2014, hp: 17, temporaryHp: 2);
      final wolf = _beast(_beasts2014, 'wolf');
      final shaped = WildShapeEngine.assume(druid, wolf, _beasts2014, _usages2014);
      expect(shaped.wildShape?.hitPoints, 11);
      expect(shaped.featureResources['wild_shape'], 1);

      final hurt = HitPointChanges.apply(shaped, -5);
      expect(hurt.hitPoints.temporary, 0);
      expect(hurt.wildShape?.hitPoints, 8);
      expect(HitPointChanges.apply(hurt, 10).wildShape?.hitPoints, 11);

      final reverted = HitPointChanges.apply(hurt, -12);
      expect(reverted.wildShape, isNull);
      expect(reverted.hitPoints.current, 13);
    });

    test('2014 Archdruid has unlimited uses', () {
      final druid = _druid(ruleset: RulesetId.dnd2014, level: 20);
      final shaped = WildShapeEngine.assume(druid, _beast(_beasts2014, 'brown_bear'), _beasts2014, _usages2014);
      expect(shaped.featureResources.containsKey('wild_shape'), isFalse);
    });

    test('leaving the form and the reset review say the form ends', () {
      final druid = _druid(
        ruleset: RulesetId.dnd2024,
        choices: [_knownForms(['wolf'])],
      );
      final shaped = WildShapeEngine.assume(druid, _beast(_beasts2024, 'wolf'), _beasts2024, _usages2024);
      final left = WildShapeEngine.leave(shaped);
      expect(left.wildShape, isNull);
      final kinds = CharacterChangeSummary.compare(
        shaped,
        left.copyWith(featureChoices: const []),
      ).map((change) => change.kind);
      expect(kinds, containsAll([CharacterChangeKind.wildShapeEnds, CharacterChangeKind.wildShapeKnownForms]));
    });

    test('the active form survives a save round trip', () {
      final druid = _druid(
        ruleset: RulesetId.dnd2014,
        wildShape: const ActiveWildShape(monsterId: 'wolf', hitPoints: 7, maxHitPoints: 11),
      );
      final restored = Character.fromJson(druid.toJson());
      expect(restored.wildShape?.monsterId, 'wolf');
      expect(restored.wildShape?.hitPoints, 7);
      expect(restored.wildShape?.maxHitPoints, 11);
    });
  });
}
