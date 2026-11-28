import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:dnd_character_tool/data/feature_choice_engine.dart';
import 'package:dnd_character_tool/data/feature_choice_option_resolver.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/fighting_style_rules.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter_test/flutter_test.dart';

CharacterFeatureChoice _style(String value, {String feature = 'Fighting Style'}) =>
    CharacterFeatureChoice(
      sourceType: FeatureChoiceSourceType.classFeature,
      sourceClass: 'Fighter',
      sourceClassEntryId: 'primary',
      featureName: feature,
      choiceId: 'fighting_style',
      values: [value],
    );

CharacterExtraFeature _feat(String name) => CharacterExtraFeature(
  sourceClass: 'Feat',
  sourceType: FeatureChoiceSourceType.feat,
  sourceFeature: 'Ability Score Improvement',
  sourceClassEntryId: 'feat:4',
  name: name,
  level: 4,
  type: 'passive',
  description: '',
);

Character _fighter({
  RulesetId ruleset = RulesetId.dnd2024,
  List<String> styles = const [],
  List<String> feats = const [],
  List<EquipmentItem> equipment = const [],
}) => Character(
  id: 'hero',
  rulesetId: ruleset,
  contentPackId: ruleset == RulesetId.dnd2024 ? ContentPackId.srd521 : ContentPackId.srd51,
  name: 'Hero',
  race: 'Human',
  characterClass: 'Fighter',
  classes: const [
    CharacterClassEntry(id: 'primary', className: 'Fighter', level: 7, isStartingClass: true),
  ],
  // Strength +3, Dexterity +2.
  abilityScores: const AbilityScores(strength: 16, dexterity: 14),
  hitPoints: const HitPoints(maximum: 10, current: 10),
  proficiencyBonus: 3,
  featureChoices: [for (final style in styles) _style(style)],
  extraFeatures: [for (final feat in feats) _feat(feat)],
  equipment: equipment,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

EquipmentItem _weapon(
  String name,
  String category,
  String dice, {
  List<String> properties = const [],
  String? versatile,
  String id = 'weapon',
  bool equipped = false,
}) => EquipmentItem(
  id: id,
  name: name,
  category: category,
  itemType: ItemType.weapon,
  isEquipped: equipped,
  properties: {
    'damageDice': dice,
    'weaponProperties': properties,
    'versatileDamage': ?versatile,
  },
);

final _longsword = _weapon('Longsword', 'martial melee', '1d8', properties: ['versatile'], versatile: '1d10');
final _greatsword = _weapon('Greatsword', 'martial melee', '2d6', properties: ['heavy', 'two-handed']);
final _longbow = _weapon('Longbow', 'martial ranged', '1d8', properties: ['heavy', 'two-handed']);
final _dagger = _weapon('Dagger', 'simple melee', '1d4', properties: ['finesse', 'light', 'thrown']);
final _spear = _weapon('Spear', 'simple melee', '1d6', properties: ['thrown', 'versatile'], versatile: '1d8');
final _dart = _weapon('Dart', 'simple ranged', '1d4', properties: ['finesse', 'thrown']);

ContextualRollRequest _roll(Character character, EquipmentItem item) =>
    ContextualWeaponRollBuilder.build(
      character: character,
      item: item,
      displayName: item.name,
      attackLabel: 'Attack',
      damageLabel: 'Damage',
      extraDamageLabel: 'Extra damage',
      versatileGripLabel: 'Grip',
      versatileOneHandedLabel: 'One-handed',
      versatileTwoHandedLabel: 'Two-handed',
      attackModeLabel: 'Attack type',
      meleeLabel: 'Melee',
      thrownLabel: 'Thrown',
      classes: character.rulesetId == RulesetId.dnd2014 ? const [] : null,
      weaponProficiencies: character.rulesetId == RulesetId.dnd2024
          ? const ['simple', 'martial']
          : null,
    )!;

int _attack(ContextualRollRequest request) =>
    (request.parts.first as ContextualD20RollPart).d20Modifier;

ContextualExpressionRollPart _damage(ContextualRollRequest request) =>
    request.parts[1] as ContextualExpressionRollPart;

Map<String, String> _choices(ContextualRollRequest request) => {
  for (final choice in _damage(request).choices) choice.key: choice.expression,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('weapon rolls', () {
    test('Archery adds 2 to attacks with Ranged weapons only', () {
      final archer = _fighter(styles: ['archery']);
      // Dexterity 2 + proficiency 3 + Archery 2.
      expect(_attack(_roll(archer, _longbow)), 7);
      expect(_attack(_roll(_fighter(), _longbow)), 5);
      expect(_attack(_roll(archer, _longsword)), 6);
      // A thrown Melee weapon is not a Ranged weapon.
      expect(_attack(_roll(archer, _dagger)), 6);
    });

    test('Dueling adds 2 to one-handed Melee damage', () {
      final duelist = _fighter(styles: ['dueling']);
      expect(_choices(_roll(duelist, _longsword)), {
        'one_handed': '1d8+5',
        'two_handed': '1d10+3',
      });
      expect(_damage(_roll(duelist, _greatsword)).expression, '2d6+3');
      expect(_damage(_roll(duelist, _longbow)).expression, '1d8+2');
    });

    test('Dueling is left out while another Melee weapon is equipped', () {
      final offhand = _weapon('Shortsword', 'martial melee', '1d6',
          properties: ['finesse', 'light'], id: 'offhand', equipped: true);
      final bow = _weapon('Shortbow', 'simple ranged', '1d6',
          properties: ['two-handed'], id: 'bow', equipped: true);
      expect(
        _damage(_roll(_fighter(styles: ['dueling'], equipment: [offhand]), _longsword)).expression,
        '1d8+3',
      );
      expect(
        _damage(_roll(_fighter(styles: ['dueling'], equipment: [bow]), _longsword)).expression,
        '1d8+5',
      );
    });

    test('Thrown Weapon Fighting offers a thrown attack with +2 damage', () {
      final thrower = _fighter(styles: ['thrown_weapon_fighting']);
      final dagger = _roll(thrower, _dagger);
      expect(_damage(dagger).choiceLabel, 'Attack type');
      expect(_choices(dagger), {'melee': '1d4+3', 'thrown': '1d4+5'});

      expect(_choices(_roll(thrower, _spear)), {
        'one_handed': '1d6+3',
        'two_handed': '1d8+3',
        'thrown': '1d6+5',
      });
      // A Dart is a Ranged weapon: always thrown, and Archery applies too.
      final dart = _roll(_fighter(feats: ['Thrown Weapon Fighting', 'Archery']), _dart);
      expect(_damage(dart).expression, '1d4+5');
      expect(_damage(dart).choices, isEmpty);
      expect(_attack(dart), 8);

      // Without the style there is no thrown option.
      expect(_damage(_roll(_fighter(), _dagger)).choices, isEmpty);
    });

    test('Dueling also applies to a thrown one-handed weapon', () {
      final both = _fighter(styles: ['dueling'], feats: ['Thrown Weapon Fighting']);
      expect(_choices(_roll(both, _dagger)), {'melee': '1d4+5', 'thrown': '1d4+7'});
    });

    test('2014 Archery and Dueling use the same rules', () {
      final archer = _fighter(ruleset: RulesetId.dnd2014, styles: ['archery']);
      final duelist = _fighter(ruleset: RulesetId.dnd2014, styles: ['dueling']);
      // Without a class catalog the 2014 sheet is not proficient.
      expect(_attack(_roll(archer, _longbow)), 4);
      expect(_choices(_roll(duelist, _longsword))['one_handed'], '1d8+5');
    });
  });

  group('choosing a Fighting Style', () {
    FeatureChoiceOptionResolver resolver(
      SrdFeatureChoiceCatalog catalog,
      FeatureChoiceRequest request,
      Character character,
    ) => FeatureChoiceOptionResolver(
      request: request,
      catalog: catalog,
      i18n: SrdI18nService.english,
      skills: const [],
      tools: const [],
      spells: const [],
      languages: const [],
      weapons: const [],
      feats: const [],
      character: character,
    );

    test('the 2024 Champion is not offered styles the sheet already has', () async {
      final catalog = await SrdDataSource.forPack(SrdContentPackRegistry.srd521)
          .getFeatureChoiceCatalog();
      final request = FeatureChoiceEngine.requestsForSubclassFeature(
        catalog: catalog,
        className: 'Fighter',
        sourceClassEntryId: 'primary',
        subclassName: 'Champion',
        featureName: 'Additional Fighting Style',
        level: 7,
      ).single;
      final ids = resolver(
        catalog,
        request,
        _fighter(styles: ['dueling'], feats: ['Protection']),
      ).options.map((option) => option.id);
      expect(ids, isNot(contains('dueling')));
      expect(ids, isNot(contains('protection')));
      expect(ids, contains('archery'));
    });

    test('the 2014 Champion is not offered the level 1 style', () async {
      final catalog = await SrdDataSource.forPack(SrdContentPackRegistry.srd51)
          .getFeatureChoiceCatalog();
      final request = FeatureChoiceEngine.requestsForSubclassFeature(
        catalog: catalog,
        className: 'Fighter',
        sourceClassEntryId: 'primary',
        subclassName: 'Champion',
        featureName: 'Additional Fighting Style',
        level: 10,
      ).single;
      final character = _fighter(ruleset: RulesetId.dnd2014, styles: ['archery']);
      final ids = resolver(catalog, request, character).options.map((option) => option.id);
      expect(ids, isNot(contains('archery')));
      expect(ids, contains('dueling'));

      // A style already saved in this choice stays available to keep it.
      final saved = character.copyWith(featureChoices: [
        ...character.featureChoices,
        request.toChoice(['dueling']),
      ]);
      final kept = FeatureChoiceOptionResolver(
        request: request,
        catalog: catalog,
        i18n: SrdI18nService.english,
        skills: const [],
        tools: const [],
        spells: const [],
        languages: const [],
        weapons: const [],
        feats: const [],
        character: saved,
        choices: saved.featureChoices,
      ).options.map((option) => option.id);
      expect(kept, contains('dueling'));
      expect(kept, isNot(contains('archery')));
    });

    test('styles come from both features and feats', () {
      final character = _fighter(styles: ['defense'], feats: ['Dueling', 'Alert']);
      expect(
        FightingStyleRules.stylesOf(character),
        containsAll(['defense', 'dueling']),
      );
    });
  });
}
