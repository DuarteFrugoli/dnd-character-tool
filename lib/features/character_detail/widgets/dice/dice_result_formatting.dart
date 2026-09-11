import '../../../../data/dice/dice.dart';

String formatDiceResultBreakdown(DiceRollResult result) {
  final parts = <String>[];
  for (var i = 0; i < result.terms.length; i++) {
    final term = result.terms[i];
    final prefix = term.term.sign < 0
        ? '-'
        : i == 0
        ? ''
        : '+';
    switch (term) {
      case DiceRollTermResult():
        final rolls = term.rolls
            .map((roll) => roll.kept ? '${roll.value}' : '(${roll.value})')
            .join(', ');
        parts.add('$prefix${term.term.notation} [$rolls]');
      case DiceModifierTermResult():
        parts.add('$prefix${term.subtotal}');
    }
  }
  return parts.join(' ');
}
