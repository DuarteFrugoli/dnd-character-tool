import 'dart:math' as math;

import 'dice_expression.dart';

class DiceRoller {
  DiceRoller({math.Random? random, int Function(int sides)? rollDie})
    : _random = random ?? math.Random(),
      _rollDieOverride = rollDie;

  final math.Random _random;
  final int Function(int sides)? _rollDieOverride;

  DiceRollResult roll(DiceExpression expression) {
    final termResults = <DiceTermResult>[];
    for (final term in expression.terms) {
      switch (term) {
        case DiceRollTerm():
          termResults.add(_rollDiceTerm(term));
        case DiceModifierTerm():
          termResults.add(DiceModifierTermResult(term: term));
      }
    }
    return DiceRollResult(expression: expression, terms: termResults);
  }

  DiceRollTermResult _rollDiceTerm(DiceRollTerm term) {
    final values = [
      for (var i = 0; i < term.quantity; i++) _rollDie(term.sides),
    ];
    final keptIndexes = _keptIndexes(values, term.selection);
    return DiceRollTermResult(
      term: term,
      rolls: [
        for (var i = 0; i < values.length; i++)
          DiceRoll(value: values[i], kept: keptIndexes.contains(i)),
      ],
    );
  }

  int _rollDie(int sides) {
    final override = _rollDieOverride;
    if (override != null) return override(sides);
    return _random.nextInt(sides) + 1;
  }

  Set<int> _keptIndexes(List<int> values, DiceSelection? selection) {
    if (selection == null) {
      return {for (var i = 0; i < values.length; i++) i};
    }

    final indexed = [
      for (var i = 0; i < values.length; i++) MapEntry(i, values[i]),
    ];
    final ascending = List<MapEntry<int, int>>.of(indexed)
      ..sort((a, b) {
        final byValue = a.value.compareTo(b.value);
        if (byValue != 0) return byValue;
        return a.key.compareTo(b.key);
      });
    final descending = ascending.reversed.toList();

    final dropped = <int>{};
    final kept = <int>{};
    switch (selection.mode) {
      case DiceSelectionMode.keepHighest:
        kept.addAll(descending.take(selection.count).map((e) => e.key));
      case DiceSelectionMode.keepLowest:
        kept.addAll(ascending.take(selection.count).map((e) => e.key));
      case DiceSelectionMode.dropHighest:
        dropped.addAll(descending.take(selection.count).map((e) => e.key));
        kept.addAll(
          indexed.map((e) => e.key).where((i) => !dropped.contains(i)),
        );
      case DiceSelectionMode.dropLowest:
        dropped.addAll(ascending.take(selection.count).map((e) => e.key));
        kept.addAll(
          indexed.map((e) => e.key).where((i) => !dropped.contains(i)),
        );
    }
    return kept;
  }
}

class DiceRoll {
  const DiceRoll({required this.value, required this.kept});

  final int value;
  final bool kept;
}

sealed class DiceTermResult {
  const DiceTermResult();

  DiceTerm get term;

  int get subtotal;

  int get signedSubtotal => term.sign * subtotal;
}

class DiceRollTermResult extends DiceTermResult {
  const DiceRollTermResult({required this.term, required this.rolls});

  @override
  final DiceRollTerm term;
  final List<DiceRoll> rolls;

  @override
  int get subtotal =>
      rolls.where((roll) => roll.kept).fold(0, (sum, roll) => sum + roll.value);
}

class DiceModifierTermResult extends DiceTermResult {
  const DiceModifierTermResult({required this.term});

  @override
  final DiceModifierTerm term;

  @override
  int get subtotal => term.value;
}

class DiceRollResult {
  const DiceRollResult({required this.expression, required this.terms});

  final DiceExpression expression;
  final List<DiceTermResult> terms;

  int get total => terms.fold(0, (sum, term) => sum + term.signedSubtotal);

  bool get hasNaturalTwenty => _hasKeptD20(20);

  bool get hasNaturalOne => _hasKeptD20(1);

  bool _hasKeptD20(int value) {
    return terms.whereType<DiceRollTermResult>().any((termResult) {
      if (termResult.term.sides != 20) return false;
      return termResult.rolls.any((roll) => roll.kept && roll.value == value);
    });
  }
}
