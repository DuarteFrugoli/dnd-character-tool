import 'dart:collection';

import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:flutter_test/flutter_test.dart';

DiceRoller _rollerWith(List<int> rolls) {
  final queue = Queue<int>.from(rolls);
  return DiceRoller(rollDie: (_) => queue.removeFirst());
}

ContextualRollRequest _skillRequest({int modifier = 5}) {
  return ContextualRollRequest(
    key: 'skill:stealth',
    title: 'Stealth',
    parts: [ContextualRollPart.d20(label: 'Stealth', d20Modifier: modifier)],
  );
}

void main() {
  group('ContextualRollEngine', () {
    test('rolls a normal d20 contextual check', () {
      final engine = ContextualRollEngine(roller: _rollerWith([12]));

      final result = engine.roll(_skillRequest());
      final part = result.parts.single;

      expect(result.requestKey, 'skill:stealth');
      expect(part.label, 'Stealth');
      expect(part.result.expression.normalized, '1d20+5');
      expect(part.result.total, 17);
    });

    test('rolls advantage by keeping the highest d20', () {
      final engine = ContextualRollEngine(roller: _rollerWith([8, 19]));

      final result = engine.roll(
        _skillRequest(modifier: 3),
        options: const ContextualRollOptions(
          d20Mode: ContextualD20Mode.advantage,
        ),
      );
      final part = result.parts.single;
      final dice = part.result.terms.first as DiceRollTermResult;

      expect(part.result.expression.normalized, '2d20kh1+3');
      expect(part.result.total, 22);
      expect(dice.rolls.map((roll) => roll.kept), [false, true]);
    });

    test('rolls disadvantage by keeping the lowest d20', () {
      final engine = ContextualRollEngine(roller: _rollerWith([4, 17]));

      final result = engine.roll(
        _skillRequest(modifier: -1),
        options: const ContextualRollOptions(
          d20Mode: ContextualD20Mode.disadvantage,
        ),
      );
      final part = result.parts.single;
      final dice = part.result.terms.first as DiceRollTermResult;

      expect(part.result.expression.normalized, '2d20kl1-1');
      expect(part.result.total, 3);
      expect(dice.rolls.map((roll) => roll.kept), [true, false]);
    });

    test('rolls composite contextual requests', () {
      final engine = ContextualRollEngine(roller: _rollerWith([15, 6]));
      const request = ContextualRollRequest(
        key: 'weapon:longsword',
        title: 'Longsword',
        parts: [
          ContextualRollPart.d20(label: 'Attack', d20Modifier: 6),
          ContextualRollPart.expression(label: 'Damage', expression: '1d8+4'),
        ],
      );

      final result = engine.roll(request);

      expect(result.parts.map((part) => part.label), ['Attack', 'Damage']);
      expect(result.parts.map((part) => part.result.total), [21, 10]);
    });

    test('contextual history keeps the latest entries first and clamps size', () {
      const request = ContextualRollRequest(
        key: 'skill:stealth',
        title: 'Stealth',
        parts: [ContextualRollPart.expression(label: 'Stealth', expression: '1')],
      );
      final engine = ContextualRollEngine(roller: _rollerWith([]));

      var history = const <ContextualRollResult>[];
      for (var i = 0; i < 25; i++) {
        history = ContextualRollHistory.add(history, engine.roll(request));
      }

      expect(history, hasLength(ContextualRollHistory.maxEntries));
      expect(history.first.title, 'Stealth');
    });
  });
}
