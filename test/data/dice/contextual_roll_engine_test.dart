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

    test('natural 20 applies double dice critical damage', () {
      final engine = ContextualRollEngine(roller: _rollerWith([20, 4, 5]));
      const request = ContextualRollRequest(
        key: 'weapon:longsword',
        title: 'Longsword',
        parts: [
          ContextualRollPart.d20(label: 'Attack', d20Modifier: 6),
          ContextualRollPart.expression(
            label: 'Damage',
            expression: '1d8+3',
            critical: true,
          ),
        ],
      );

      final result = engine.roll(
        request,
        options: const ContextualRollOptions(
          criticalMode: ContextualCriticalMode.doubleDice,
        ),
      );
      final attack = result.parts[0];
      final damage = result.parts[1];

      expect(attack.result.hasNaturalTwenty, isTrue);
      expect(damage.criticalApplied, isTrue);
      expect(damage.result.expression.normalized, '2d8+3');
      expect(damage.result.total, 12);
      expect(damage.total, 12);
    });

    test('natural 20 applies double total critical damage', () {
      final engine = ContextualRollEngine(roller: _rollerWith([20, 4]));
      const request = ContextualRollRequest(
        key: 'weapon:longsword',
        title: 'Longsword',
        parts: [
          ContextualRollPart.d20(label: 'Attack', d20Modifier: 6),
          ContextualRollPart.expression(
            label: 'Damage',
            expression: '1d8+3',
            critical: true,
          ),
        ],
      );

      final result = engine.roll(
        request,
        options: const ContextualRollOptions(
          criticalMode: ContextualCriticalMode.doubleTotal,
        ),
      );
      final attack = result.parts[0];
      final damage = result.parts[1];

      expect(attack.result.hasNaturalTwenty, isTrue);
      expect(damage.criticalApplied, isTrue);
      expect(damage.result.expression.normalized, '1d8+3');
      expect(damage.result.total, 7);
      expect(damage.total, 14);
    });

    test('non-critical attacks do not apply critical damage', () {
      final engine = ContextualRollEngine(roller: _rollerWith([19, 4]));
      const request = ContextualRollRequest(
        key: 'weapon:longsword',
        title: 'Longsword',
        parts: [
          ContextualRollPart.d20(label: 'Attack', d20Modifier: 6),
          ContextualRollPart.expression(
            label: 'Damage',
            expression: '1d8+3',
            critical: true,
          ),
        ],
      );

      final result = engine.roll(
        request,
        options: const ContextualRollOptions(
          criticalMode: ContextualCriticalMode.doubleDice,
        ),
      );
      final damage = result.parts[1];

      expect(damage.criticalApplied, isFalse);
      expect(damage.result.expression.normalized, '1d8+3');
      expect(damage.total, 7);
    });

    test('critical state resets when another d20 attack is rolled', () {
      final engine = ContextualRollEngine(
        roller: _rollerWith([20, 4, 5, 19, 6]),
      );
      const request = ContextualRollRequest(
        key: 'weapon:multiattack',
        title: 'Multiattack',
        parts: [
          ContextualRollPart.d20(label: 'Attack 1', d20Modifier: 6),
          ContextualRollPart.expression(
            label: 'Damage 1',
            expression: '1d8+3',
            critical: true,
          ),
          ContextualRollPart.d20(label: 'Attack 2', d20Modifier: 6),
          ContextualRollPart.expression(
            label: 'Damage 2',
            expression: '1d8+3',
            critical: true,
          ),
        ],
      );

      final result = engine.roll(
        request,
        options: const ContextualRollOptions(
          criticalMode: ContextualCriticalMode.doubleDice,
        ),
      );
      final firstDamage = result.parts[1];
      final secondDamage = result.parts[3];

      expect(firstDamage.criticalApplied, isTrue);
      expect(firstDamage.result.expression.normalized, '2d8+3');
      expect(firstDamage.total, 12);
      expect(secondDamage.criticalApplied, isFalse);
      expect(secondDamage.result.expression.normalized, '1d8+3');
      expect(secondDamage.total, 9);
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
