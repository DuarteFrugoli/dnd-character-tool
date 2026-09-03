import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/features/character_creation/character_draft_provider.dart';
import 'package:dnd_character_tool/features/character_creation/creation_feature_choice_loader.dart';
import 'package:flutter_test/flutter_test.dart';

const _baseAttributes = {
  'Strength': 10,
  'Dexterity': 10,
  'Constitution': 10,
  'Intelligence': 10,
  'Wisdom': 10,
  'Charisma': 10,
};

const _fighter = SrdClass(
  name: 'Fighter',
  hitDie: 10,
  primaryAbility: ['Strength'],
  savingThrows: ['Strength', 'Constitution'],
  armorProficiencies: [],
  weaponProficiencies: [],
  toolProficiencies: [],
  skillChoices: SrdSkillChoice(count: 0, from: []),
  subclassLevel: 3,
  subclassFeatureName: 'Martial Archetype',
  startingGoldDice: '5d4',
);

const _fighterWithEquipmentChoices = SrdClass(
  name: 'Fighter',
  hitDie: 10,
  primaryAbility: ['Strength'],
  savingThrows: ['Strength', 'Constitution'],
  armorProficiencies: [],
  weaponProficiencies: [],
  toolProficiencies: [],
  skillChoices: SrdSkillChoice(count: 0, from: []),
  subclassLevel: 3,
  subclassFeatureName: 'Martial Archetype',
  startingGoldDice: '5d4',
  startingEquipment: SrdClassStartingEquipment(
    fixed: [],
    choices: [
      SrdEquipmentChoiceGroup(
        options: [
          ['Longsword'],
          ['Shortsword'],
        ],
      ),
    ],
  ),
);

const _background = SrdBackground(
  name: 'Soldier',
  skillProficiencies: [],
  toolProficiencies: [],
  languages: 0,
  startingEquipment: [],
  feature: SrdBackgroundFeature(name: 'Military Rank', description: ''),
  variants: [],
);

const _human = SrdRace(
  name: 'Human',
  speed: 30,
  size: 'Medium',
  abilityScoreIncreases: {
    'Strength': 1,
    'Dexterity': 1,
    'Constitution': 1,
    'Intelligence': 1,
    'Wisdom': 1,
    'Charisma': 1,
  },
  traits: [],
  languages: [],
  subraces: [],
);

const _halfElf = SrdRace(
  name: 'Half-Elf',
  speed: 30,
  size: 'Medium',
  abilityScoreIncreases: {'Charisma': 2},
  freeAsiPoints: 2,
  traits: [],
  languages: [],
  subraces: [],
);

const _variantHuman = SrdRace(
  name: 'Variant Human',
  speed: 30,
  size: 'Medium',
  abilityScoreIncreases: {},
  freeAsiPoints: 2,
  traits: ['Bonus Feat'],
  languages: [],
  subraces: [],
);

CharacterDraft _draft({
  SrdClass selectedClass = _fighter,
  SrdRace race = _human,
  bool freeAsi = false,
  Map<String, int> freeAsiDistribution = const {},
  Map<String, int> freePicksDistribution = const {},
  bool featureChoicesLoaded = true,
  List<FeatureChoiceRequest> featureChoiceRequests = const [],
  List<CharacterFeatureChoice> featureChoices = const [],
  List<int?> classEquipmentChoices = const [],
  int? rolledStartingGold = 100,
}) {
  return CharacterDraft(
    id: 'draft-id',
    selectedClass: selectedClass,
    selectedRace: race,
    selectedBackground: _background,
    baseAttributes: _baseAttributes,
    freeAsi: freeAsi,
    freeAsiDistribution: freeAsiDistribution,
    freePicksDistribution: freePicksDistribution,
    featureChoicesLoaded: featureChoicesLoaded,
    featureChoiceRequests: featureChoiceRequests,
    featureChoices: featureChoices,
    classEquipmentChoices: classEquipmentChoices,
    rolledStartingGold: rolledStartingGold,
  );
}

void main() {
  group('CharacterDraft racial ASI', () {
    test('applies default human +1 to all abilities', () {
      final draft = _draft();

      expect(draft.racialAsiComplete, isTrue);
      expect(draft.finalAttributes, {
        'Strength': 11,
        'Dexterity': 11,
        'Constitution': 11,
        'Intelligence': 11,
        'Wisdom': 11,
        'Charisma': 11,
      });
    });

    test(
      'Tasha mode keeps the same increment shape instead of one free pool',
      () {
        final draft = _draft(
          freeAsi: true,
          freeAsiDistribution: const {
            'Strength': 2,
            'Dexterity': 1,
            'Constitution': 1,
            'Intelligence': 1,
            'Wisdom': 1,
          },
        );

        expect(draft.racialAsiIncrements, [1, 1, 1, 1, 1, 1]);
        expect(draft.racialAsiComplete, isFalse);
      },
    );

    test('fixed race free picks cannot reuse fixed ASI attributes', () {
      final draft = _draft(
        race: _halfElf,
        freePicksDistribution: const {'Charisma': 1, 'Dexterity': 1},
      );

      expect(draft.racialAsiComplete, isFalse);
    });

    test(
      'fixed race free picks complete when all free attributes are valid',
      () {
        final draft = _draft(
          race: _halfElf,
          freePicksDistribution: const {'Strength': 1, 'Dexterity': 1},
        );

        expect(draft.racialAsiComplete, isTrue);
        expect(draft.finalAttributes['Charisma'], 12);
        expect(draft.finalAttributes['Strength'], 11);
        expect(draft.finalAttributes['Dexterity'], 11);
      },
    );

    test('feat ability choice adds +1 and respects the 20 cap', () {
      final draft = _draft(
        featureChoices: const [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.feat,
            sourceName: 'Resilient',
            featureName: 'Resilient',
            choiceId: 'ability',
            values: ['strength'],
          ),
        ],
      );

      expect(draft.finalAttributes['Strength'], 12);

      final capped = CharacterDraft(
        id: 'draft-id',
        selectedClass: _fighter,
        selectedRace: _human,
        selectedBackground: _background,
        baseAttributes: const {
          'Strength': 20,
          'Dexterity': 10,
          'Constitution': 10,
          'Intelligence': 10,
          'Wisdom': 10,
          'Charisma': 10,
        },
        featureChoicesLoaded: true,
        rolledStartingGold: 100,
        featureChoices: const [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.feat,
            sourceName: 'Resilient',
            featureName: 'Resilient',
            choiceId: 'ability',
            values: ['strength'],
          ),
        ],
      );

      expect(capped.finalAttributes['Strength'], 20);
    });
  });

  group('CharacterDraft required feature choices', () {
    const featRequest = FeatureChoiceRequest(
      sourceType: FeatureChoiceSourceType.raceTrait,
      sourceName: 'Bonus Feat',
      featureName: 'Bonus Feat',
      level: 1,
      requirement: SrdFeatureChoiceRequirement(
        id: 'feat',
        type: 'feat',
        count: 1,
      ),
      requiredCount: 1,
    );

    test('is incomplete while a variant human required feat is empty', () {
      final draft = _draft(
        race: _variantHuman,
        freePicksDistribution: const {'Strength': 1, 'Dexterity': 1},
        featureChoiceRequests: const [featRequest],
        featureChoices: const [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.raceTrait,
            sourceName: 'Bonus Feat',
            featureName: 'Bonus Feat',
            choiceId: 'feat',
          ),
        ],
      );

      expect(draft.isComplete, isFalse);
    });

    test('is complete when racial ASI and required feat are chosen', () {
      final draft = _draft(
        race: _variantHuman,
        freePicksDistribution: const {'Strength': 1, 'Dexterity': 1},
        featureChoiceRequests: const [featRequest],
        featureChoices: const [
          CharacterFeatureChoice(
            sourceType: FeatureChoiceSourceType.raceTrait,
            sourceName: 'Bonus Feat',
            featureName: 'Bonus Feat',
            choiceId: 'feat',
            values: ['Lucky'],
          ),
        ],
      );

      expect(draft.isComplete, isTrue);
    });

    test('hides the creation step when loaded requests are empty', () {
      final draft = _draft(
        featureChoicesLoaded: true,
        featureChoiceRequests: const [],
      );

      expect(shouldShowCreationFeatureChoiceStep(draft), isFalse);
    });

    test('shows the creation step when loaded requests are pending', () {
      final draft = _draft(
        featureChoicesLoaded: true,
        featureChoiceRequests: const [featRequest],
      );

      expect(shouldShowCreationFeatureChoiceStep(draft), isTrue);
    });

    test('keeps the creation step visible after a matching load error', () {
      final draft = _draft(featureChoicesLoaded: false);

      expect(
        shouldShowCreationFeatureChoiceStep(
          draft,
          featureChoiceLoadErrorKey: creationFeatureChoiceDraftKey(draft),
        ),
        isTrue,
      );
      expect(
        shouldShowCreationFeatureChoiceStep(
          draft,
          featureChoiceLoadErrorKey: 'other-draft',
        ),
        isFalse,
      );
    });
  });

  group('CharacterDraft review requirements', () {
    test('requires starting gold to be rolled before completion', () {
      final draft = _draft(rolledStartingGold: null);

      expect(draft.isComplete, isFalse);
      expect(firstCreationReviewIssue(draft), CreationReviewIssue.startingGold);
    });

    test('is complete when review requirements are filled', () {
      final draft = _draft(rolledStartingGold: 80);

      expect(firstCreationReviewIssue(draft), isNull);
      expect(draft.isComplete, isTrue);
    });

    test('reports class equipment choices as a review requirement', () {
      final draft = _draft(selectedClass: _fighterWithEquipmentChoices);

      expect(creationReviewFieldsComplete(draft), isFalse);
      expect(
        firstCreationReviewIssue(draft),
        CreationReviewIssue.classEquipment,
      );

      final complete = _draft(
        selectedClass: _fighterWithEquipmentChoices,
        classEquipmentChoices: const [0],
      );

      expect(firstCreationReviewIssue(complete), isNull);
      expect(creationReviewFieldsComplete(complete), isTrue);
    });
  });
}
