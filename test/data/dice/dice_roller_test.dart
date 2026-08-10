import 'dart:collection';

import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:flutter_test/flutter_test.dart';

DiceRoller _rollerWith(List<int> rolls) {
  final queue = Queue<int>.from(rolls);
  return DiceRoller(rollDie: (_) => queue.removeFirst());
}

void main() {
  group('DiceRoller', () {
    test('rolls dice terms and applies modifiers', () {
      final roller = _rollerWith([4, 2, 3]);
      final result = roller.roll(DiceParser.parse('2d6+3-1d4'));

      expect(result.total, 6);

      final diceTerms = result.terms.whereType<DiceRollTermResult>().toList();
      expect(diceTerms, hasLength(2));
      expect(diceTerms.first.rolls.map((roll) => roll.value), [4, 2]);
      expect(diceTerms.last.rolls.single.value, 3);
    });

    test('keeps highest d20 for advantage', () {
      final roller = _rollerWith([8, 20]);
      final result = roller.roll(DiceParser.parse('2d20kh1+5'));

      expect(result.total, 25);
      expect(result.hasNaturalTwenty, isTrue);
      expect(result.hasNaturalOne, isFalse);

      final dice = result.terms.first as DiceRollTermResult;
      expect(dice.rolls.map((roll) => roll.kept), [false, true]);
    });

    test('keeps lowest d20 for disadvantage', () {
      final roller = _rollerWith([1, 18]);
      final result = roller.roll(DiceParser.parse('2d20kl1+2'));

      expect(result.total, 3);
      expect(result.hasNaturalOne, isTrue);
      expect(result.hasNaturalTwenty, isFalse);

      final dice = result.terms.first as DiceRollTermResult;
      expect(dice.rolls.map((roll) => roll.kept), [true, false]);
    });

    test('drops the lowest die', () {
      final roller = _rollerWith([1, 6, 3, 4]);
      final result = roller.roll(DiceParser.parse('4d6dl1'));

      expect(result.total, 13);

      final dice = result.terms.single as DiceRollTermResult;
      expect(dice.rolls.map((roll) => roll.kept), [false, true, true, true]);
    });
  });
}
