import 'dice_expression.dart';

class DiceParseException implements Exception {
  const DiceParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DiceParser {
  DiceParser._();

  static const maxQuantity = 100;
  static const maxSides = 10000;
  static final _termPattern = RegExp(
    r'(?:(\d*)d(\d+|%)(?:(kh|kl|dh|dl)(\d+))?|(\d+))',
    caseSensitive: false,
  );

  static DiceExpression parse(String input) {
    final source = input.trim();
    if (source.isEmpty) {
      throw const DiceParseException('empty expression');
    }
    final terms = <DiceTerm>[];
    var index = 0;
    while (index < source.length) {
      index = _skipWhitespace(source, index);
      if (index >= source.length) break;

      var sign = 1;
      var hasExplicitSign = false;
      final signChar = source[index];
      if (signChar == '+' || signChar == '-') {
        hasExplicitSign = true;
        sign = signChar == '-' ? -1 : 1;
        index = _skipWhitespace(source, index + 1);
      }

      if (terms.isNotEmpty && !hasExplicitSign) {
        throw DiceParseException('expected + or - at position ${index + 1}');
      }

      final match = _termPattern.matchAsPrefix(source, index);
      if (match == null) {
        throw DiceParseException('unexpected token at position ${index + 1}');
      }

      final diceSides = match.group(2);
      if (diceSides != null) {
        terms.add(_parseDiceTerm(match, sign));
      } else {
        terms.add(_parseModifierTerm(match, sign));
      }

      index = match.end;
    }

    if (terms.isEmpty) {
      throw const DiceParseException('empty expression');
    }
    return DiceExpression(source: source, terms: terms);
  }

  static int _skipWhitespace(String source, int index) {
    var current = index;
    while (current < source.length && source[current].trim().isEmpty) {
      current++;
    }
    return current;
  }

  static DiceRollTerm _parseDiceTerm(Match match, int sign) {
    final rawQuantity = match.group(1);
    final quantity = rawQuantity == null || rawQuantity.isEmpty
        ? 1
        : int.parse(rawQuantity);
    final sidesText = match.group(2)!;
    final sides = sidesText == '%' ? 100 : int.parse(sidesText);

    if (quantity < 1) {
      throw const DiceParseException('dice quantity must be at least 1');
    }
    if (quantity > maxQuantity) {
      throw DiceParseException(
        'dice quantity cannot be greater than $maxQuantity',
      );
    }
    if (sides < 2) {
      throw const DiceParseException('dice must have at least 2 sides');
    }
    if (sides > maxSides) {
      throw DiceParseException('dice sides cannot be greater than $maxSides');
    }

    final selector = match.group(3);
    final selectorCountText = match.group(4);
    DiceSelection? selection;
    if (selector != null && selectorCountText != null) {
      final count = int.parse(selectorCountText);
      selection = _parseSelection(selector.toLowerCase(), count, quantity);
    }

    return DiceRollTerm(
      sign: sign,
      quantity: quantity,
      sides: sides,
      selection: selection,
    );
  }

  static DiceModifierTerm _parseModifierTerm(Match match, int sign) {
    final value = int.parse(match.group(5)!);
    return DiceModifierTerm(sign: sign, value: value);
  }

  static DiceSelection _parseSelection(
    String selector,
    int count,
    int quantity,
  ) {
    if (count < 1) {
      throw const DiceParseException('selection count must be at least 1');
    }

    final mode = switch (selector) {
      'kh' => DiceSelectionMode.keepHighest,
      'kl' => DiceSelectionMode.keepLowest,
      'dh' => DiceSelectionMode.dropHighest,
      'dl' => DiceSelectionMode.dropLowest,
      _ => throw DiceParseException('unknown dice selector $selector'),
    };

    if ((mode == DiceSelectionMode.keepHighest ||
            mode == DiceSelectionMode.keepLowest) &&
        count > quantity) {
      throw const DiceParseException('cannot keep more dice than rolled');
    }
    if ((mode == DiceSelectionMode.dropHighest ||
            mode == DiceSelectionMode.dropLowest) &&
        count >= quantity) {
      throw const DiceParseException('must keep at least one die');
    }

    return DiceSelection(mode: mode, count: count);
  }
}
