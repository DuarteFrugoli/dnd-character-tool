enum DiceSelectionMode { keepHighest, keepLowest, dropHighest, dropLowest }

class DiceSelection {
  const DiceSelection({required this.mode, required this.count});

  final DiceSelectionMode mode;
  final int count;

  String get notation {
    final prefix = switch (mode) {
      DiceSelectionMode.keepHighest => 'kh',
      DiceSelectionMode.keepLowest => 'kl',
      DiceSelectionMode.dropHighest => 'dh',
      DiceSelectionMode.dropLowest => 'dl',
    };
    return '$prefix$count';
  }
}

sealed class DiceTerm {
  const DiceTerm({required this.sign});

  final int sign;

  String get notation;
}

class DiceRollTerm extends DiceTerm {
  const DiceRollTerm({
    required super.sign,
    required this.quantity,
    required this.sides,
    this.selection,
  });

  final int quantity;
  final int sides;
  final DiceSelection? selection;

  @override
  String get notation => '${quantity}d$sides${selection?.notation ?? ''}';
}

class DiceModifierTerm extends DiceTerm {
  const DiceModifierTerm({required super.sign, required this.value});

  final int value;

  @override
  String get notation => value.toString();
}

class DiceExpression {
  const DiceExpression({required this.source, required this.terms});

  final String source;
  final List<DiceTerm> terms;

  String get normalized {
    final buffer = StringBuffer();
    for (var i = 0; i < terms.length; i++) {
      final term = terms[i];
      if (term.sign < 0) {
        buffer.write('-');
      } else if (i > 0) {
        buffer.write('+');
      }
      buffer.write(term.notation);
    }
    return buffer.toString();
  }
}
