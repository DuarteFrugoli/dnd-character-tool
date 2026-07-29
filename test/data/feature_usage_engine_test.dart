import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/feature_usage_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  String cls = 'Fighter',
  String? subclass,
  int level = 1,
  AbilityScores scores = const AbilityScores(),
  Map<String, int> featureResources = const {},
  List<CharacterExtraFeature> extraFeatures = const [],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    name: 'Test Hero',
    race: 'Human',
    characterClass: cls,
    subclass: subclass,
    level: level,
    abilityScores: scores,
    hitPoints: const HitPoints(maximum: 10, current: 10),
    featureResources: featureResources,
    extraFeatures: extraFeatures,
    createdAt: now,
    updatedAt: now,
  );
}

FeatureUsageResource _resource(
  String id,
  String maxFormula, {
  String recharge = 'long_rest',
}) {
  return FeatureUsageResource(
    id: id,
    name: id,
    maxFormula: maxFormula,
    recharge: recharge,
  );
}

void main() {
  group('FeatureUsageCatalog.fromJson', () {
    test('parses resources and feature references', () {
      final catalog = FeatureUsageCatalog.fromJson({
        'resources': {
          'ki': {'name': 'Ki', 'max': 'monk_level', 'recharge': 'short_rest'},
        },
        'classFeatures': {
          'Monk': {
            'Ki': {'resourceId': 'ki', 'spend': 2},
          },
        },
        'subclassFeatures': {
          'Fighter': {
            'Battle Master': {
              'Combat Superiority': {'resourceId': 'superiority_dice'},
            },
          },
        },
        'raceTraits': {
          'Lucky': {'resourceId': 'luck'},
        },
        'feats': {
          'Lucky': {'resourceId': 'luck'},
        },
      });

      expect(catalog.resource('ki')!.maxFormula, 'monk_level');
      expect(catalog.classFeature('Monk', 'Ki')!.spend, 2);
      expect(
        catalog
            .subclassFeature('Fighter', 'Battle Master', 'Combat Superiority')!
            .resourceId,
        'superiority_dice',
      );
      expect(catalog.raceTrait('Lucky')!.resourceId, 'luck');
      expect(catalog.feat('Lucky')!.resourceId, 'luck');
    });
  });

  group('FeatureUsageEngine.maxFor', () {
    test('monk ki equals character level', () {
      final character = _character(cls: 'Monk', level: 7);

      expect(
        FeatureUsageEngine.maxFor(_resource('ki', 'monk_level'), character),
        7,
      );
    });

    test('class formulas can use source class level', () {
      final character = _character(cls: 'Fighter', level: 10);

      expect(
        FeatureUsageEngine.maxFor(
          _resource('ki', 'monk_level'),
          character,
          usageContext: const FeatureUsageContext(
            totalCharacterLevel: 10,
            sourceClass: 'Monk',
            sourceClassLevel: 2,
          ),
        ),
        2,
      );
      expect(
        FeatureUsageEngine.maxFor(
          _resource('lay_on_hands', 'paladin_level_x5'),
          character,
          usageContext: const FeatureUsageContext(
            totalCharacterLevel: 10,
            sourceClass: 'Paladin',
            sourceClassLevel: 3,
          ),
        ),
        15,
      );
    });

    test('rage scales by barbarian level and becomes unlimited at 20', () {
      expect(
        FeatureUsageEngine.maxFor(
          _resource('rage', 'barbarian_rage_uses'),
          _character(cls: 'Barbarian', level: 2),
        ),
        2,
      );
      expect(
        FeatureUsageEngine.maxFor(
          _resource('rage', 'barbarian_rage_uses'),
          _character(cls: 'Barbarian', level: 12),
        ),
        5,
      );
      expect(
        FeatureUsageEngine.maxFor(
          _resource('rage', 'barbarian_rage_uses'),
          _character(cls: 'Barbarian', level: 20),
        ),
        isNull,
      );
    });

    test('ability formulas respect minimum one', () {
      final character = _character(
        scores: const AbilityScores(charisma: 8, wisdom: 16),
      );

      expect(
        FeatureUsageEngine.maxFor(
          _resource('bardic', 'charisma_modifier_min_1'),
          character,
        ),
        1,
      );
      expect(
        FeatureUsageEngine.maxFor(
          _resource('wisdom', 'wisdom_modifier_min_1'),
          character,
        ),
        3,
      );
    });
  });

  group('FeatureUsageEngine.currentFor', () {
    test('defaults to max when no value is saved', () {
      final resource = _resource('ki', 'monk_level');
      final character = _character(cls: 'Monk', level: 4);

      expect(FeatureUsageEngine.currentFor(character, resource, 4), 4);
    });

    test('clamps saved values to the resource bounds', () {
      final resource = _resource('ki', 'monk_level');

      expect(
        FeatureUsageEngine.currentFor(
          _character(featureResources: const {'ki': 99}),
          resource,
          4,
        ),
        4,
      );
      expect(
        FeatureUsageEngine.currentFor(
          _character(featureResources: const {'ki': -1}),
          resource,
          4,
        ),
        0,
      );
    });
  });

  group('FeatureUsageEngine recharge', () {
    test('bardic inspiration moves to short rest at level 5', () {
      final resource = _resource(
        'bardic',
        'charisma_modifier_min_1',
        recharge: 'bardic_inspiration_recharge',
      );

      expect(
        FeatureUsageEngine.rechargeFor(
          resource,
          _character(cls: 'Bard', level: 4),
        ),
        'long_rest',
      );
      expect(
        FeatureUsageEngine.rechargeFor(
          resource,
          _character(cls: 'Bard', level: 5),
        ),
        'short_rest',
      );
    });

    test('bardic inspiration recharge uses source class level', () {
      final resource = _resource(
        'bardic',
        'charisma_modifier_min_1',
        recharge: 'bardic_inspiration_recharge',
      );
      final character = _character(cls: 'Fighter', level: 10);

      expect(
        FeatureUsageEngine.rechargeFor(
          resource,
          character,
          usageContext: const FeatureUsageContext(
            totalCharacterLevel: 10,
            sourceClass: 'Bard',
            sourceClassLevel: 4,
          ),
        ),
        'long_rest',
      );
      expect(
        FeatureUsageEngine.rechargeFor(
          resource,
          character,
          usageContext: const FeatureUsageContext(
            totalCharacterLevel: 10,
            sourceClass: 'Bard',
            sourceClassLevel: 5,
          ),
        ),
        'short_rest',
      );
    });

    test('restoresOn respects short and long rest rules', () {
      expect(
        FeatureUsageEngine.restoresOn('short_rest', FeatureUsageRest.shortRest),
        isTrue,
      );
      expect(
        FeatureUsageEngine.restoresOn('long_rest', FeatureUsageRest.shortRest),
        isFalse,
      );
      expect(
        FeatureUsageEngine.restoresOn('long_rest', FeatureUsageRest.longRest),
        isTrue,
      );
    });
  });

  group('FeatureUsageEngine.activeResources', () {
    test(
      'finds class, subclass, race and feat resources without duplicates',
      () {
        final catalog = FeatureUsageCatalog(
          resources: {
            'rage': _resource('rage', 'barbarian_rage_uses'),
            'maneuvers': _resource(
              'maneuvers',
              'battle_master_superiority_dice',
            ),
            'luck': _resource('luck', '3'),
          },
          classFeatures: const {
            'Fighter': {'Second Wind': FeatureUsageRef(resourceId: 'rage')},
          },
          subclassFeatures: const {
            'Fighter': {
              'Battle Master': {
                'Combat Superiority': FeatureUsageRef(resourceId: 'maneuvers'),
              },
            },
          },
          raceTraits: const {'Lucky': FeatureUsageRef(resourceId: 'luck')},
          feats: const {'Lucky': FeatureUsageRef(resourceId: 'luck')},
        );
        final character = _character(
          cls: 'Fighter',
          subclass: 'Battle Master',
          extraFeatures: const [
            CharacterExtraFeature(
              sourceClass: 'Feat',
              name: 'Lucky',
              level: 1,
              type: 'active',
              description: '',
            ),
          ],
        );

        final resources = FeatureUsageEngine.activeResources(
          character: character,
          catalog: catalog,
          classFeatures: const [
            SrdClassFeature(
              name: 'Second Wind',
              level: 1,
              type: 'active',
              description: '',
            ),
          ],
          subclassFeatures: const [
            SrdClassFeature(
              name: 'Combat Superiority',
              level: 3,
              type: 'active',
              description: '',
            ),
          ],
          raceTraits: const ['Lucky'],
        ).toList();

        expect(resources.map((resource) => resource.id), [
          'rage',
          'maneuvers',
          'luck',
        ]);
      },
    );

    test(
      'activeResourceBindings keeps source level for extra class features',
      () {
        final catalog = FeatureUsageCatalog(
          resources: {'ki': _resource('ki', 'monk_level')},
          classFeatures: const {
            'Monk': {'Ki': FeatureUsageRef(resourceId: 'ki')},
          },
          subclassFeatures: const {},
          raceTraits: const {},
          feats: const {},
        );
        final character = _character(
          cls: 'Fighter',
          level: 10,
          extraFeatures: const [
            CharacterExtraFeature(
              sourceClass: 'Monk',
              name: 'Ki',
              level: 2,
              type: 'active',
              description: '',
            ),
          ],
        );

        final binding = FeatureUsageEngine.activeResourceBindings(
          character: character,
          catalog: catalog,
          classFeatures: const [],
          subclassFeatures: const [],
          raceTraits: const [],
        ).single;

        expect(binding.usageContext.sourceClass, 'Monk');
        expect(binding.usageContext.sourceClassLevel, 2);
        expect(
          FeatureUsageEngine.maxFor(
            binding.resource,
            character,
            usageContext: binding.usageContext,
          ),
          2,
        );
      },
    );
  });
}
