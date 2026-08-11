import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiceParser', () {
    test('parses dice, modifiers, and signs', () {
      final expression = DiceParser.parse('2d6 + 3 - d4');

      expect(expression.normalized, '2d6+3-1d4');
      expect(expression.terms, hasLength(3));
      expect(expression.terms[0], isA<DiceRollTerm>());
      expect(expression.terms[1], isA<DiceModifierTerm>());
      expect(expression.terms[2], isA<DiceRollTerm>());

      final first = expression.terms[0] as DiceRollTerm;
      expect(first.quantity, 2);
      expect(first.sides, 6);

      final modifier = expression.terms[1] as DiceModifierTerm;
      expect(modifier.value, 3);
    });

    test('allows spaces around operators', () {
      final expression = DiceParser.parse('2d6 + 1d8 - 3');

      expect(expression.normalized, '2d6+1d8-3');
      expect(expression.terms, hasLength(3));
    });

    test('parses keep and drop selectors', () {
      final advantage = DiceParser.parse('2d20kh1+5');
      final abilityScores = DiceParser.parse('4d6dl1');

      final advantageDice = advantage.terms.first as DiceRollTerm;
      expect(advantageDice.selection?.mode, DiceSelectionMode.keepHighest);
      expect(advantageDice.selection?.count, 1);

      final abilityDice = abilityScores.terms.first as DiceRollTerm;
      expect(abilityDice.selection?.mode, DiceSelectionMode.dropLowest);
      expect(abilityDice.selection?.count, 1);
    });

    test('supports d100 shorthand', () {
      final expression = DiceParser.parse('d%');
      final dice = expression.terms.single as DiceRollTerm;

      expect(dice.quantity, 1);
      expect(dice.sides, 100);
      expect(expression.normalized, '1d100');
    });

    test('rejects invalid expressions', () {
      expect(() => DiceParser.parse(''), throwsA(isA<DiceParseException>()));
      expect(
        () => DiceParser.parse('1d20 5'),
        throwsA(isA<DiceParseException>()),
      );
      expect(() => DiceParser.parse('1d1'), throwsA(isA<DiceParseException>()));
      expect(
        () => DiceParser.parse('1d20dl1'),
        throwsA(isA<DiceParseException>()),
      );
    });
  });
}
