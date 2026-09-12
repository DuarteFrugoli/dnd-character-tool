import 'contextual_roll.dart';
import 'dice_expression.dart';
import 'dice_parser.dart';
import 'dice_roller.dart';

class ContextualRollEngine {
  ContextualRollEngine({DiceRoller? roller}) : _roller = roller ?? DiceRoller();

  final DiceRoller _roller;

  ContextualRollResult roll(
    ContextualRollRequest request, {
    ContextualRollOptions options = const ContextualRollOptions(),
  }) {
    final parts = <ContextualRollPartResult>[];
    var criticalTriggered = false;

    for (final part in request.parts) {
      final result = _rollPart(part, options, criticalTriggered);
      parts.add(result);
      if (part.supportsD20Mode) {
        criticalTriggered = result.result.hasNaturalTwenty;
      }
    }

    return ContextualRollResult(
      requestKey: request.key,
      title: request.title,
      subtitle: request.subtitle,
      options: options,
      parts: parts,
    );
  }

  ContextualRollPartResult _rollPart(
    ContextualRollPart part,
    ContextualRollOptions options,
    bool criticalTriggered,
  ) {
    final criticalApplied =
        criticalTriggered &&
        part.supportsCritical &&
        options.criticalMode != ContextualCriticalMode.none;
    final doublesTotal =
        criticalApplied &&
        options.criticalMode == ContextualCriticalMode.doubleTotal;
    final expression = _expressionFor(part, options, criticalApplied);
    return ContextualRollPartResult(
      label: part.label,
      result: _roller.roll(DiceParser.parse(expression)),
      criticalApplied: criticalApplied,
      totalMultiplier: doublesTotal ? 2 : 1,
    );
  }

  String _expressionFor(
    ContextualRollPart part,
    ContextualRollOptions options,
    bool criticalApplied,
  ) {
    return switch (part) {
      ContextualExpressionRollPart(:final critical) =>
        critical &&
            criticalApplied &&
            options.criticalMode == ContextualCriticalMode.doubleDice
            ? _doubleDiceExpression(_expressionChoiceFor(part, options))
            : _expressionChoiceFor(part, options),
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

  String _expressionChoiceFor(
    ContextualExpressionRollPart part,
    ContextualRollOptions options,
  ) {
    final selectedKey = options.expressionChoices[part.id];
    if (selectedKey == null) return part.expression;
    for (final choice in part.choices) {
      if (choice.key == selectedKey) return choice.expression;
    }
    return part.expression;
  }

  String _doubleDiceExpression(String expression) {
    final parsed = DiceParser.parse(expression);
    final terms = [
      for (final term in parsed.terms)
        switch (term) {
          DiceRollTerm() => DiceRollTerm(
            sign: term.sign,
            quantity: term.quantity * 2,
            sides: term.sides,
            selection: term.selection,
          ),
          DiceModifierTerm() => term,
        },
    ];
    return DiceExpression(source: expression, terms: terms).normalized;
  }

  String _withModifier(String dice, int modifier) {
    if (modifier == 0) return dice;
    if (modifier > 0) return '$dice+$modifier';
    return '$dice$modifier';
  }
}
