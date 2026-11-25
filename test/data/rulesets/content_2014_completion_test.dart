import 'dart:convert';

import 'package:dnd_character_tool/data/character_progression/choice_effects.dart';
import 'package:dnd_character_tool/data/character_progression/choice_effects_2014.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_monster.dart';
import 'package:dnd_character_tool/data/datasources/srd/supplemental_2014_catalog.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/feature_choice_option_resolver.dart';
import 'package:dnd_character_tool/data/feature_usage_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/data/rulesets/spell_roll_rules.dart';
import 'package:dnd_character_tool/data/wild_shape/wild_shape_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Character hero(
  String cls,
  int level, {
  String? subclass,
  List<CharacterFeatureChoice> choices = const [],
  List<KnownSpell> spells = const [],
  Map<String, int> resources = const {},
}) => Character(
  id: 'test',
  name: 'Test',
  race: 'Human',
  characterClass: cls,
  level: level,
  subclass: subclass,
  classes: [
    CharacterClassEntry(
      id: 'primary',
      className: cls,
      level: level,
      subclassName: subclass,
      isStartingClass: true,
    ),
  ],
  abilityScores: const AbilityScores(wisdom: 16, charisma: 16),
  hitPoints: const HitPoints(maximum: 50, current: 50),
  featureChoices: choices,
  spells: spells,
  featureResources: resources,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final source = SrdDataSource.forPack(SrdContentPackRegistry.srd51);
  late ChoiceEffects2014Data data;
  late List<SrdMonster> monsters;
  late FeatureUsageCatalog usages;
  setUpAll(() async {
    data = await ChoiceEffects2014Data.load(source);
    monsters = await source.getMonsters();
    usages = await source.getFeatureUsageCatalog();
  });

  FeatureChoiceRequest invocations(int level) =>
      FeatureChoiceEngine.requestsForClassFeature(
        catalog: data.choices,
        className: 'Warlock',
        sourceClassEntryId: 'primary',
        featureName: 'Eldritch Invocations',
        level: level,
      ).single;

  List<SrdFeatureChoiceOption> resolve(
    FeatureChoiceRequest request,
    Character character, {
    List<CharacterFeatureChoice> choices = const [],
  }) => FeatureChoiceOptionResolver(
    request: request,
    character: character,
    catalog: data.choices,
    i18n: SrdI18nService.english,
    spells: data.spells,
    choices: choices,
    skills: const [],
    tools: const [],
    languages: const [],
    weapons: const [],
    feats: const [],
  ).options;

  test(
    '32 PHB invocations respect warlock level, cantrip and saved pact prerequisites',
    () {
      expect(
        data.choices.optionSources['eldritch_invocations_2014'],
        hasLength(32),
      );
      final empty = resolve(
        invocations(2),
        hero('Warlock', 2),
      ).map((x) => x.id);
      expect(empty, isNot(contains('agonizing_blast')));
      expect(empty, isNot(contains('thirsting_blade')));
      expect(empty, contains('armor_of_shadows'));
      final pact = CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Warlock',
        sourceClassEntryId: 'primary',
        featureName: 'Pact Boon',
        choiceId: 'pact_boon',
        values: const ['pact_of_the_blade'],
      );
      final options = resolve(
        invocations(5),
        hero(
          'Warlock',
          5,
          choices: [pact],
          spells: [
            const KnownSpell(
              name: 'Eldritch Blast',
              level: 0,
              sourceClass: 'Warlock',
            ),
          ],
        ),
      ).map((x) => x.id);
      expect(options, containsAll(['agonizing_blast', 'thirsting_blade']));
      expect(options, isNot(contains('chains_of_carceri')));
      expect(options, isNot(contains('book_of_ancient_secrets')));
    },
  );

  test(
    'invocations allow a single replacement even on a level with no additional invocation',
    () {
      final requests = FeatureChoiceEngine.requestsForLevelUp(
        catalog: data.choices,
        character: hero('Warlock', 3),
        newLevel: 4,
        targetClassEntryId: 'primary',
        newClassFeatures: const [],
        newSubclassFeatures: const [],
      );
      final req = requests.single;
      expect(req.requiredCount, 2);
      final previous = [
        req.toChoice(['armor_of_shadows', 'beast_speech']),
      ];
      expect(
        FeatureChoiceEngine.replacementsWithinLimit(requests, previous, [
          req.toChoice(['armor_of_shadows', 'eldritch_sight']),
        ]),
        isTrue,
      );
      expect(
        FeatureChoiceEngine.replacementsWithinLimit(requests, previous, [
          req.toChoice(['eldritch_sight', 'misty_visions']),
        ]),
        isFalse,
      );
      expect(invocations(18).requiredCount, 8);
    },
  );

  test('2014 Agonizing Blast applies only to Eldritch Blast', () {
    final choice = invocations(
      5,
    ).toChoice(['agonizing_blast', 'armor_of_shadows']);
    final warlock = hero('Warlock', 5, choices: [choice]);
    expect(SpellRollRules.damageBonus(warlock, 'Eldritch Blast'), 3);
    expect(SpellRollRules.damageBonus(warlock, 'Fire Bolt'), 0);
  });

  test(
    '2014 Tome requires three cantrips from any class, only for that pact',
    () {
      final requests = FeatureChoiceEngine.requestsForLevelUp(
        catalog: data.choices,
        character: hero('Warlock', 2),
        newLevel: 3,
        targetClassEntryId: 'primary',
        newClassFeatures: const [
          SrdClassFeature(
            name: 'Pact Boon',
            level: 3,
            type: 'passive',
            description: '',
          ),
        ],
        newSubclassFeatures: const [],
      ).where((r) => r.featureName == 'Pact Boon').toList();
      final pact = requests.singleWhere((r) => r.choiceId == 'pact_boon');
      final tome = requests.singleWhere((r) => r.choiceId == 'tome_cantrips');
      final selected = [
        pact.toChoice(['pact_of_the_tome']),
      ];
      expect(tome.isApplicable([]), isFalse);
      expect(
        tome.isApplicable([
          pact.toChoice(['pact_of_the_chain']),
        ]),
        isFalse,
      );
      expect(tome.isApplicable(selected), isTrue);
      expect(tome.requiredCount, 3);
      expect(tome.isComplete(selected), isFalse);
      expect(
        tome.isComplete([
          ...selected,
          tome.toChoice(['Guidance', 'Fire Bolt']),
        ]),
        isFalse,
      );
      expect(
        tome.isComplete([
          ...selected,
          tome.toChoice(['Guidance', 'Fire Bolt', 'Shillelagh']),
        ]),
        isTrue,
      );
      final names = resolve(
        tome,
        hero('Warlock', 3),
        choices: selected,
      ).map((o) => o.id);
      expect(names, containsAll(['Guidance', 'Fire Bolt', 'Shillelagh']));
      expect(names, isNot(contains('Find Familiar')));
      // 2014 Tome does not inherit the two rituals or rest swaps of 2024 Tome.
      expect(
        requests.map((r) => r.choiceId),
        unorderedEquals(['pact_boon', 'tome_cantrips']),
      );
    },
  );

  test(
    'Tome grants use Warlock provenance and undo on pact edits and resets',
    () {
      final requests = FeatureChoiceEngine.requestsForClassFeature(
        catalog: data.choices,
        className: 'Warlock',
        sourceClassEntryId: 'primary',
        featureName: 'Pact Boon',
        level: 3,
      );
      final pact = requests.singleWhere((r) => r.choiceId == 'pact_boon');
      final tome = requests.singleWhere((r) => r.choiceId == 'tome_cantrips');
      final original = hero(
        'Warlock',
        3,
        spells: const [
          KnownSpell(
            name: 'Eldritch Blast',
            level: 0,
            sourceClass: 'Warlock',
            sourceFeature: 'Pact Magic',
            sourceClassEntryId: 'primary',
          ),
        ],
      );
      final selected = [
        pact.toChoice(['pact_of_the_tome']),
        tome.toChoice(['Guidance', 'Fire Bolt', 'Shillelagh']),
      ];
      final granted = ChoiceEffects.apply(
        original,
        original.copyWith(featureChoices: selected),
        data,
      );
      final cantrips = granted.spells.where(
        (s) => s.sourceFeature == 'Pact Boon',
      );
      expect(cantrips, hasLength(3));
      expect(
        cantrips.every(
          (s) =>
              s.level == 0 &&
              s.sourceClass == 'Warlock' &&
              s.sourceClassEntryId == 'primary',
        ),
        isTrue,
      );
      final edited = ChoiceEffects.apply(
        granted,
        granted.copyWith(
          featureChoices: [
            pact.toChoice(['pact_of_the_chain']),
            selected.last,
          ],
        ),
        data,
      );
      expect(edited.spells.map((s) => s.name), ['Eldritch Blast']);
      expect(edited.featureChoices.map((c) => c.choiceId), ['pact_boon']);
      final reset = ChoiceEffects.apply(
        granted,
        granted.copyWith(featureChoices: []),
        data,
      );
      expect(reset.spells.map((s) => s.name), ['Eldritch Blast']);
    },
  );

  test('four Chain familiars keep 2014 stats and stay out of Wild Shape', () {
    const ids = {'imp', 'pseudodragon', 'quasit', 'sprite'};
    final familiars = monsters.where((m) => ids.contains(m.id)).toList();
    expect(familiars, hasLength(4));
    expect(familiars.every((m) => !m.isBeast && m.attacks.isNotEmpty), isTrue);
    final imp = familiars.singleWhere((m) => m.id == 'imp');
    expect(imp.hitPoints, 10);
    expect(imp.damageResistances, ['cold']);
    expect(imp.nonmagicalDamageResistances, isEmpty);
    expect(
      imp.traits
          .singleWhere((t) => t.id == 'conditional_damage_resistance')
          .description,
      contains("aren't silvered"),
    );
    expect(imp.actions.first.save!.dc, 11);
    expect(imp.actions.first.save!.damage.single.formula, '3d6');
    final quasit = familiars.singleWhere((m) => m.id == 'quasit');
    expect(
      quasit.nonmagicalDamageResistances,
      unorderedEquals(['bludgeoning', 'piercing', 'slashing']),
    );
    expect(quasit.actions.first.save!.damage.single.formula, '2d4');
    final sprite = familiars.singleWhere((m) => m.id == 'sprite');
    expect(sprite.armorClass, 15);
    expect(sprite.attacks.last.attack!.rangeNormal, 40);
    final forms = WildShapeEngine.availableForms(
      hero('Druid', 20, subclass: 'Circle of the Moon'),
      monsters,
    );
    expect(forms.where((m) => ids.contains(m.id)), isEmpty);
  });

  test(
    'land terrain spells follow druid levels and changing terrain removes only its grants',
    () {
      final req = FeatureChoiceEngine.requestsForSubclassFeature(
        catalog: data.choices,
        className: 'Druid',
        subclassName: 'Circle of the Land',
        sourceClassEntryId: 'primary',
        featureName: 'Circle Spells',
        level: 3,
      ).single;
      var druid = hero('Druid', 3, subclass: 'Circle of the Land');
      druid = ChoiceEffects.apply(
        druid,
        druid.copyWith(
          featureChoices: [
            req.toChoice(['coast']),
          ],
        ),
        data,
      );
      expect(
        druid.spells.map((s) => s.name),
        unorderedEquals(['Mirror Image', 'Misty Step']),
      );
      expect(
        druid.spells.every((s) => s.isAlwaysPrepared && s.isPrepared),
        isTrue,
      );
      final advanced = druid.copyWith(
        level: 5,
        classes: [druid.classEntries.single.copyWith(level: 5)],
      );
      final level5 = ChoiceEffects.apply(druid, advanced, data);
      expect(
        level5.spells.map((s) => s.name),
        containsAll(['Water Breathing', 'Water Walk']),
      );
      final changed = ChoiceEffects.apply(
        level5,
        level5.copyWith(
          featureChoices: [
            req.toChoice(['swamp']),
          ],
        ),
        data,
      );
      expect(
        changed.spells.map((s) => s.name),
        unorderedEquals([
          'Darkness',
          'Acid Arrow',
          'Water Walk',
          'Stinking Cloud',
        ]),
      );
      final reset = changed.copyWith(
        level: 2,
        classes: [changed.classEntries.single.copyWith(level: 2)],
      );
      expect(ChoiceEffects.apply(changed, reset, data).spells, isEmpty);
    },
  );

  test(
    'all terrain spell references resolve and the extra druid cantrip is selectable',
    () {
      final names = data.spells.map((s) => s.name).toSet();
      final lands = data.choices.optionSources['circle_lands_2014']!;
      expect(lands, hasLength(8));
      for (final land in lands) {
        expect(
          land.alwaysPreparedSpellsByLevel.keys,
          unorderedEquals([3, 5, 7, 9]),
        );
        for (final group in land.alwaysPreparedSpellsByLevel.values) {
          expect(group, hasLength(2));
          expect(names, containsAll(group));
        }
      }
      final req = FeatureChoiceEngine.requestsForSubclassFeature(
        catalog: data.choices,
        className: 'Druid',
        subclassName: 'Circle of the Land',
        featureName: 'Bonus Cantrip',
        level: 2,
      ).single;
      expect(
        resolve(req, hero('Druid', 2)).map((o) => o.id),
        contains('Thorn Whip'),
      );
    },
  );

  test(
    'elemental disciplines enforce monk levels and preserve errata ki costs',
    () {
      final req = FeatureChoiceEngine.requestsForSubclassFeature(
        catalog: data.choices,
        className: 'Monk',
        subclassName: 'Way of the Four Elements',
        featureName: 'Disciple of the Elements',
        level: 6,
      ).single;
      expect(req.requiredCount, 2);
      final available = resolve(req, hero('Monk', 6)).map((o) => o.id);
      expect(
        available,
        containsAll([
          'water_whip',
          'gong_of_the_summit',
          'clench_of_the_north_wind',
        ]),
      );
      expect(available, isNot(contains('flames_of_the_phoenix')));
      final disciplines =
          data.choices.optionSources['elemental_disciplines_2014']!;
      expect(disciplines, hasLength(16));
      final eternal = disciplines.singleWhere(
        (o) => o.id == 'eternal_mountain_defense',
      );
      expect(eternal.minClassLevel, 17);
      expect(eternal.kiCost, 5);
    },
  );

  test(
    'all 100 percentile results have exactly one surge and the table appears in the feature',
    () async {
      final options = await Supplemental2014Catalog.options();
      final rows = (options['wildMagicSurge'] as Map)['outcomes'] as List;
      expect(rows, hasLength(50));
      for (var roll = 1; roll <= 100; roll++) {
        expect(
          rows.where((r) => r['min'] <= roll && r['max'] >= roll),
          hasLength(1),
        );
      }
      final feature = (await source.getSubclassFeatures(
        'Sorcerer',
        'Wild Magic',
      )).singleWhere((f) => f.name == 'Wild Magic Surge');
      expect(feature.description, contains('99-00:'));
      expect(feature.description, contains('Fireball'));
      final monk = await source.getSubclassFeatures(
        'Monk',
        'Way of the Four Elements',
      );
      expect(
        monk.map((f) => f.description).join(),
        isNot(contains('Avatar of the Elements')),
      );
    },
  );

  test('totem animals are independent choices at levels 3, 6 and 14', () {
    for (final (feature, level) in [
      ('Totem Spirit', 3),
      ('Aspect of the Beast', 6),
      ('Totemic Attunement', 14),
    ]) {
      final req = FeatureChoiceEngine.requestsForSubclassFeature(
        catalog: data.choices,
        className: 'Barbarian',
        subclassName: 'Path of the Totem Warrior',
        featureName: feature,
        level: level,
      ).single;
      expect(req.requiredCount, 1);
      expect(
        resolve(req, hero('Barbarian', level)).map((o) => o.id),
        unorderedEquals(['bear', 'eagle', 'wolf']),
      );
    }
  });

  test('2014 moon forms advance while ordinary druids retain their limits', () {
    final bear = monsters.singleWhere((m) => m.id == 'brown_bear');
    expect(
      WildShapeEngine.availableForms(
        hero('Druid', 2, subclass: 'Circle of the Moon'),
        monsters,
      ),
      contains(bear),
    );
    expect(
      WildShapeEngine.availableForms(hero('Druid', 2), monsters),
      isNot(contains(bear)),
    );
    final level6 = WildShapeEngine.availableForms(
      hero('Druid', 6, subclass: 'Circle of the Moon'),
      monsters,
    );
    expect(level6.any((m) => m.id == 'polar_bear'), isTrue);
    expect(level6.every((m) => m.challengeValue <= 2 && !m.isSwarm), isTrue);
    expect(
      WildShapeEngine.availableForms(
        hero('Druid', 18, subclass: 'Circle of the Moon'),
        monsters,
      ).any((m) => m.id == 'mammoth'),
      isTrue,
    );
  });

  test(
    '2014 elemental forms require level 10 and consume two Wild Shape uses',
    () {
      final air = monsters.singleWhere((m) => m.id == 'air_elemental');
      final moon = hero('Druid', 10, subclass: 'Circle of the Moon');
      expect(
        WildShapeEngine.availableForms(
          moon,
          monsters,
        ).where((m) => m.type == 'elemental'),
        hasLength(4),
      );
      expect(
        WildShapeEngine.availableForms(
          hero('Druid', 9, subclass: 'Circle of the Moon'),
          monsters,
        ),
        isNot(contains(air)),
      );
      final transformed = WildShapeEngine.assume(moon, air, monsters, usages);
      expect(transformed.wildShape!.hitPoints, 90);
      expect(WildShapeEngine.usage(transformed, usages)!.current, 0);
      final resource = WildShapeEngine.usage(moon, usages)!.resource.id;
      expect(
        () => WildShapeEngine.assume(
          moon.copyWith(featureResources: {resource: 1}),
          air,
          monsters,
          usages,
        ),
        throwsStateError,
      );
      expect(air.nonmagicalDamageResistances, [
        'bludgeoning',
        'piercing',
        'slashing',
      ]);
      expect(air.damageResistances, ['lightning', 'thunder']);
    },
  );

  test(
    'background variants and English roleplaying suggestions load into creation',
    () async {
      final backgrounds = await source.getBackgrounds();
      expect(
        backgrounds.map((b) => b.name),
        containsAll(['Spy', 'Gladiator', 'Guild Merchant', 'Knight', 'Pirate']),
      );
      expect(
        backgrounds.singleWhere((b) => b.name == 'Knight').feature.name,
        'Retainers',
      );
      expect(
        backgrounds.singleWhere((b) => b.name == 'Pirate').feature.name,
        'Bad Reputation',
      );
      for (final bg in backgrounds) {
        expect(bg.personalitySuggestions['traits'], hasLength(8));
        expect(bg.personalitySuggestions['ideals'], hasLength(6));
        expect(bg.personalitySuggestions['bonds'], hasLength(6));
        expect(bg.personalitySuggestions['flaws'], hasLength(6));
      }
    },
  );

  test('focus and transport entries reach the inventory index', () async {
    final items = await source.getItems();
    for (final name in [
      'crystal',
      'orb',
      'rod',
      'staff',
      'wand',
      'mule',
      'cart',
      'rowboat',
      'military saddle',
    ]) {
      expect(items[name], isNotNull, reason: name);
    }
    expect(items['rowboat']!.weight, 100);
    final extra =
        jsonDecode(
              await rootBundle.loadString(
                'assets/data/2014/phb_backgrounds.json',
              ),
            )
            as Map;
    expect(extra['contentType'], contains('original suggestions'));
  });
}
