import 'contextual_roll.dart';
import 'dice_parser.dart';
import 'dice_roller.dart';

class ContextualRollEngine {
  ContextualRollEngine({DiceRoller? roller}) : _roller = roller ?? DiceRoller();

  final DiceRoller _roller;

  ContextualRollResult roll(
    ContextualRollRequest request, {
    ContextualRollOptions options = const ContextualRollOptions(),
  }) {
    final parts = [
      for (final part in request.parts)
        ContextualRollPartResult(
          label: part.label,
          result: _roller.roll(DiceParser.parse(_expressionFor(part, options))),
        ),
    ];

    return ContextualRollResult(
      requestKey: request.key,
      title: request.title,
      subtitle: request.subtitle,
      options: options,
      parts: parts,
    );
  }

  String _expressionFor(
    ContextualRollPart part,
    ContextualRollOptions options,
  ) {
    return switch (part) {
      ContextualExpressionRollPart(:final expression) => expression,
      ContextualD20RollPart(:final d20Modifier) => _withModifier(
        switch (options.d20Mode) {
          ContextualD20Mode.disadvantage => '2d20kl1',
          ContextualD20Mode.normal => '1d20',
          ContextualD20Mode.advantage => '2d20kh1',
        },
        d20Modifier,
      ),
    };
  }

  String _withModifier(String dice, int modifier) {
    if (modifier == 0) return dice;
    if (modifier > 0) return '$dice+$modifier';
    return '$dice$modifier';
  }
}
