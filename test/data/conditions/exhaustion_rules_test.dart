import 'package:dnd_character_tool/data/conditions/exhaustion_rules.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  RulesetId rulesetId = RulesetId.dnd2024,
  int exhaustionLevel = 0,
  int speed = 30,
}) {
  final now = DateTime(2024);
  return Character(
    id: 'tired-hero',
    rulesetId: rulesetId,
    contentPackId: rulesetId == RulesetId.dnd2024
        ? ContentPackId.srd521
        : ContentPackId.srd51,
    name: 'Tired Hero',
    race: 'Human',
    characterClass: 'Fighter',
    abilityScores: const AbilityScores(),
    hitPoints: const HitPoints(maximum: 10, current: 10),
    speed: speed,
    exhaustionLevel: exhaustionLevel,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('2024 Exhaustion', () {
    test('each level imposes -2 on D20 Tests and -5 feet of Speed', () {
      final character = _character(exhaustionLevel: 3);
      final rules = ExhaustionRules.forCharacter(character);

      expect(rules.tracksLevels, isTrue);
      expect(rules.d20TestModifier(character), -6);
      expect(rules.speedFor(character), 15);
    });

    test('Speed never drops below zero', () {
      final character = _character(exhaustionLevel: 5, speed: 20);

      expect(ExhaustionRules.forCharacter(character).speedFor(character), 0);
    });

    test('no levels means no penalties', () {
      final character = _character();
      final rules = ExhaustionRules.forCharacter(character);

      expect(rules.d20TestModifier(character), 0);
      expect(rules.speedFor(character), 30);
    });
  });

  test('2014 sheets ignore the level field', () {
    final character = _character(
      rulesetId: RulesetId.dnd2014,
      exhaustionLevel: 4,
    );
    final rules = ExhaustionRules.forCharacter(character);

    expect(rules.tracksLevels, isFalse);
    expect(rules.d20TestModifier(character), 0);
    expect(rules.speedFor(character), 30);
    expect(rules.levelAfterLongRest(4), 4);
  });

  test('exhaustionLevel survives JSON and old saves default to zero', () {
    final character = _character(exhaustionLevel: 2);
    final json = character.toJson();

    expect(Character.fromJson(json).exhaustionLevel, 2);
    expect(
      Character.fromJson({...json}..remove('exhaustionLevel')).exhaustionLevel,
      0,
    );
    expect(
      Character.fromJson({...json, 'exhaustionLevel': 9}).exhaustionLevel,
      6,
    );
  });
}
