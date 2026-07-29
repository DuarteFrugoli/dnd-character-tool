import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/feature_choice_option_resolver.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

SrdFeatureChoiceCatalog _catalog() {
  return const SrdFeatureChoiceCatalog(
    optionSources: {
      'fighting_styles': [
        SrdFeatureChoiceOption(
          id: 'defense',
          name: 'Defense',
          description: '+1 AC while wearing armor.',
        ),
        SrdFeatureChoiceOption(
          id: 'dueling',
          name: 'Dueling',
          description: '+2 damage with a one-handed melee weapon.',
        ),
      ],
    },
    classFeatures: {
      'Fighter': {
        'Fighting Style': SrdFeatureChoiceDefinition(
          choices: [
            SrdFeatureChoiceRequirement(
              id: 'style',
              type: 'option',
              optionsSource: 'fighting_styles',
              count: 1,
            ),
          ],
        ),
      },
    },
    subclassFeatures: {
      'Fighter': {
        'Battle Master': {
          'Combat Superiority': SrdFeatureChoiceDefinition(
            choices: [
              SrdFeatureChoiceRequirement(
                id: 'maneuver',
                type: 'option',
                countByLevel: {3: 3, 7: 2},
                options: [
                  SrdFeatureChoiceOption(id: 'trip', name: 'Trip Attack'),
                  SrdFeatureChoiceOption(id: 'riposte', name: 'Riposte'),
                ],
              ),
            ],
          ),
        },
      },
    },
    raceTraits: {
      'Bonus Feat': SrdFeatureChoiceDefinition(
        choices: [SrdFeatureChoiceRequirement(id: 'feat', type: 'feat')],
      ),
    },
    feats: {},
  );
}

Character _character({
  String cls = 'Fighter',
  String? subclass,
  int level = 1,
  List<CharacterFeatureChoice> choices = const [],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    name: 'Test Hero',
    race: 'Human',
    characterClass: cls,
    subclass: subclass,
    level: level,
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    featureChoices: choices,
    createdAt: now,
    updatedAt: now,
  );
}

SrdSpell _spell({
  required String name,
  required int level,
  required String school,
  required List<String> classes,
}) {
  return SrdSpell(
    name: name,
    level: level,
    school: school,
    castingTime: '1 action',
    castingTimeType: 'action',
    ritual: false,
    range: '30 feet',
    components: const ['V'],
    materialConsumed: false,
    duration: 'Instantaneous',
    concentration: false,
    damageTypes: const [],
    description: '',
    classes: classes,
    subclassSpells: const [],
    raceSpells: const [],
  );
}

void main() {
  group('FeatureChoiceEngine', () {
    test('creates a request for a class feature choice', () {
      final requests = FeatureChoiceEngine.requestsForClassFeature(
        catalog: _catalog(),
        className: 'Fighter',
        featureName: 'Fighting Style',
        level: 1,
      );

      expect(requests, hasLength(1));
      expect(requests.single.choiceId, 'style');
      expect(requests.single.requiredCount, 1);
      expect(requests.single.sourceType, FeatureChoiceSourceType.classFeature);
    });

    test('uses cumulative countByLevel for later subclass choices', () {
      final requests = FeatureChoiceEngine.requestsForSubclassFeature(
        catalog: _catalog(),
        className: 'Fighter',
        subclassName: 'Battle Master',
        featureName: 'Combat Superiority',
        level: 7,
      );

      expect(requests.single.requiredCount, 5);
    });

    test(
      'level-triggered requests do not duplicate feature-triggered ones',
      () {
        final requests = FeatureChoiceEngine.requestsForLevelUp(
          catalog: _catalog(),
          character: _character(subclass: 'Battle Master'),
          newLevel: 7,
          newClassFeatures: const [],
          newSubclassFeatures: const [
            SrdClassFeature(
              name: 'Combat Superiority',
              level: 7,
              type: 'active',
              description: '',
            ),
          ],
        );

        expect(requests, hasLength(1));
        expect(requests.single.choiceId, 'maneuver');
      },
    );

    test('toChoice removes duplicates and caps values at required count', () {
      final request = FeatureChoiceEngine.requestsForClassFeature(
        catalog: _catalog(),
        className: 'Fighter',
        featureName: 'Fighting Style',
        level: 1,
      ).single;

      final choice = request.toChoice(['defense', 'defense', 'dueling']);

      expect(choice.values, ['defense']);
      expect(request.isComplete([choice]), isTrue);
    });

    test('upsertChoices replaces an existing matching choice', () {
      const oldChoice = CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Fighter',
        featureName: 'Fighting Style',
        choiceId: 'style',
        values: ['defense'],
      );
      const newChoice = CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Fighter',
        featureName: 'Fighting Style',
        choiceId: 'style',
        values: ['dueling'],
      );

      final result = FeatureChoiceEngine.upsertChoices(
        const [oldChoice],
        const [newChoice],
      );

      expect(result, hasLength(1));
      expect(result.single.values, ['dueling']);
    });

    test(
      'upsertChoices keeps choices from different class entries separate',
      () {
        const fighterChoice = CharacterFeatureChoice(
          sourceType: FeatureChoiceSourceType.classFeature,
          sourceClass: 'Fighter',
          sourceClassEntryId: 'fighter-entry',
          featureName: 'Fighting Style',
          choiceId: 'style',
          values: ['defense'],
        );
        const paladinChoice = CharacterFeatureChoice(
          sourceType: FeatureChoiceSourceType.classFeature,
          sourceClass: 'Fighter',
          sourceClassEntryId: 'paladin-entry',
          featureName: 'Fighting Style',
          choiceId: 'style',
          values: ['dueling'],
        );

        final result = FeatureChoiceEngine.upsertChoices(
          const [fighterChoice],
          const [paladinChoice],
        );

        expect(result, hasLength(2));
        expect(result.map((choice) => choice.sourceClassEntryId), [
          'fighter-entry',
          'paladin-entry',
        ]);
      },
    );
  });

  group('FeatureChoiceOptionResolver', () {
    test('resolves option sources with descriptions', () {
      final request = FeatureChoiceEngine.requestsForClassFeature(
        catalog: _catalog(),
        className: 'Fighter',
        featureName: 'Fighting Style',
        level: 1,
      ).single;

      final resolver = FeatureChoiceOptionResolver(
        request: request,
        catalog: _catalog(),
        i18n: SrdI18nService.english,
        skills: const [],
        tools: const [],
        spells: const [],
        languages: const [],
        weapons: const [],
        feats: const [],
      );

      expect(resolver.optionFor('defense')!.name, 'Defense');
      expect(
        resolver.optionFor('defense')!.description,
        '+1 AC while wearing armor.',
      );
    });

    test('skill expertise choices only include proficient skills', () {
      const request = FeatureChoiceRequest(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: 'Rogue',
        featureName: 'Expertise',
        level: 1,
        requirement: SrdFeatureChoiceRequirement(
          id: 'expertise',
          type: 'skill_expertise',
          count: 2,
        ),
        requiredCount: 2,
      );

      final resolver = FeatureChoiceOptionResolver(
        request: request,
        catalog: _catalog(),
        i18n: SrdI18nService.english,
        skills: const [
          SrdSkill(name: 'Stealth', ability: 'dex'),
          SrdSkill(name: 'Arcana', ability: 'int'),
        ],
        tools: const [],
        spells: const [],
        languages: const [],
        weapons: const [],
        feats: const [],
        character: _character(
          choices: const [],
        ).copyWith(skillProficiencies: const ['stealth']),
      );

      expect(resolver.options.map((option) => option.id), ['stealth']);
    });

    test('spell choices can depend on another feature choice value', () {
      const classRequest = FeatureChoiceRequest(
        sourceType: FeatureChoiceSourceType.raceTrait,
        sourceName: 'Magic Initiate',
        featureName: 'Magic Initiate',
        level: 1,
        requirement: SrdFeatureChoiceRequirement(
          id: 'spell_class',
          type: 'option',
          options: [SrdFeatureChoiceOption(id: 'wizard', name: 'Wizard')],
        ),
        requiredCount: 1,
      );
      const spellRequest = FeatureChoiceRequest(
        sourceType: FeatureChoiceSourceType.raceTrait,
        sourceName: 'Magic Initiate',
        featureName: 'Magic Initiate',
        level: 1,
        requirement: SrdFeatureChoiceRequirement(
          id: 'cantrip',
          type: 'cantrip',
          count: 2,
          spellClassFromChoice: 'spell_class',
        ),
        requiredCount: 2,
      );

      final resolver = FeatureChoiceOptionResolver(
        request: spellRequest,
        catalog: _catalog(),
        i18n: SrdI18nService.english,
        skills: const [],
        tools: const [],
        spells: [
          _spell(
            name: 'Fire Bolt',
            level: 0,
            school: 'evocation',
            classes: const ['wizard'],
          ),
          _spell(
            name: 'Guidance',
            level: 0,
            school: 'divination',
            classes: const ['cleric'],
          ),
        ],
        languages: const [],
        weapons: const [],
        feats: const [],
        relatedRequests: const [classRequest],
        choices: const [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.raceTrait,
            sourceName: 'Magic Initiate',
            featureName: 'Magic Initiate',
            choiceId: 'spell_class',
            values: ['wizard'],
          ),
        ],
      );

      expect(resolver.options.map((option) => option.id), ['Fire Bolt']);
    });
  });
}
