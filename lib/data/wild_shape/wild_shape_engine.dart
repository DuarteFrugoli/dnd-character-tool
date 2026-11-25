import '../datasources/srd/srd_monster.dart';
import '../feature_choice_engine.dart';
import '../feature_usage_engine.dart';
import '../models/models.dart';
import '../rulesets/wild_shape_rules.dart';

/// Assumes and leaves Wild Shape forms.
class WildShapeEngine {
  const WildShapeEngine._();

  static const elementalForms = {
    'air_elemental', 'earth_elemental', 'fire_elemental', 'water_elemental',
  };

  static bool _elementalMoon(Character character) =>
      WildShapeRules.forCharacter(character) is WildShape2014Rules &&
      character.subclassFor('Druid') == 'Circle of the Moon' &&
      character.classLevel('Druid') >= 10;

  static int formCost(Character character, SrdMonster form) =>
      _elementalMoon(character) && elementalForms.contains(form.id) ? 2 : 1;

  static int armorClassFor(Character character, SrdMonster form) {
    final isMoon = WildShapeRules.forCharacter(character) is WildShape2024Rules &&
        character.classLevel('Druid') >= 3 &&
        character.subclassFor('Druid') == 'Circle of the Moon';
    final moonAc = 13 + character.abilityScores.wisdomModifier;
    return isMoon && moonAc > form.armorClass ? moonAc : form.armorClass;
  }

  /// 2024 known forms saved as the Wild Shape feature choice.
  static List<String> knownFormIds(Character character) => [
    for (final choice in character.featureChoices)
      if (choice.sourceType == FeatureChoiceSourceType.classFeature &&
          choice.sourceClass == WildShapeRules.druid &&
          choice.featureName == WildShapeRules.featureName &&
          choice.choiceId == WildShape2024Rules.knownFormsChoice)
        ...choice.values,
  ];

  /// Forms [character] can assume now: 2024 known forms, or every Beast the
  /// 2014 table allows (the Druid must have seen it, which the GM tracks).
  static List<SrdMonster> availableForms(
    Character character,
    List<SrdMonster> monsters,
  ) {
    final rules = WildShapeRules.forCharacter(character);
    final limits = rules.limitsFor(character);
    if (limits == null) return const [];
    final allowed = [
      for (final monster in monsters)
        if ((limits.allows(monster) &&
                (rules is! WildShape2014Rules || !monster.isSwarm)) ||
            (_elementalMoon(character) && elementalForms.contains(monster.id)))
          monster,
    ];
    if (rules is! WildShape2024Rules) return allowed;
    final known = knownFormIds(character).toSet();
    return [for (final monster in allowed) if (known.contains(monster.id)) monster];
  }

  /// Uses of Wild Shape; null when the sheet has no Wild Shape resource.
  static FeatureUsageView? usage(Character character, FeatureUsageCatalog catalog) =>
      FeatureUsageEngine.viewForRef(
        catalog: catalog,
        character: character,
        ref: catalog.classFeature(WildShapeRules.druid, WildShapeRules.featureName),
        usageContext: FeatureUsageContext.forCharacter(
          character,
          sourceClass: WildShapeRules.druid,
        ),
      );

  /// Spends one use and takes [form]. A new form replaces the current one.
  static Character assume(
    Character character,
    SrdMonster form,
    List<SrdMonster> monsters,
    FeatureUsageCatalog catalog,
  ) {
    final rules = WildShapeRules.forCharacter(character);
    if (!availableForms(character, monsters).any((m) => m.id == form.id)) {
      throw ArgumentError('${form.name} is not an available Wild Shape form.');
    }
    final uses = usage(character, catalog);
    final cost = formCost(character, form);
    if (uses == null) throw StateError('This character has no Wild Shape uses.');
    if (!uses.isUnlimited && (uses.current ?? 0) < cost) {
      throw StateError('No Wild Shape uses left.');
    }
    final druidLevel = character.classLevel(WildShapeRules.druid);
    final temporary = rules.temporaryHitPointsOnAssume(
      druidLevel,
      subclass: character.subclassFor('Druid'),
    );
    final hp = character.hitPoints;
    return character.copyWith(
      featureResources: uses.isUnlimited
          ? null
          : {...character.featureResources, uses.resource.id: uses.current! - cost},
      hitPoints: temporary > hp.temporary ? hp.copyWith(temporary: temporary) : null,
      wildShape: ActiveWildShape(
        monsterId: form.id,
        hitPoints: rules.usesBeastHitPoints ? form.hitPoints : null,
        maxHitPoints: rules.usesBeastHitPoints ? form.hitPoints : null,
      ),
    );
  }

  static Character leave(Character character) =>
      character.copyWith(wildShape: null);
}
