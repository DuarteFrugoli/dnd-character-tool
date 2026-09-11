import 'dice_roller.dart';

enum ContextualD20Mode { disadvantage, normal, advantage }

class ContextualRollOptions {
  const ContextualRollOptions({this.d20Mode = ContextualD20Mode.normal});

  final ContextualD20Mode d20Mode;
}

class ContextualRollRequest {
  const ContextualRollRequest({
    required this.key,
    required this.title,
    this.subtitle,
    required this.parts,
  });

  final String key;
  final String title;
  final String? subtitle;
  final List<ContextualRollPart> parts;

  bool get supportsD20Mode => parts.any((part) => part.supportsD20Mode);
}

sealed class ContextualRollPart {
  const ContextualRollPart._({required this.label});

  const factory ContextualRollPart.expression({
    required String label,
    required String expression,
  }) = ContextualExpressionRollPart;

  const factory ContextualRollPart.d20({
    required String label,
    required int d20Modifier,
  }) = ContextualD20RollPart;

  final String label;

  bool get supportsD20Mode;
}

class ContextualExpressionRollPart extends ContextualRollPart {
  const ContextualExpressionRollPart({
    required super.label,
    required this.expression,
  }) : super._();

  final String expression;

  @override
  bool get supportsD20Mode => false;
}

class ContextualD20RollPart extends ContextualRollPart {
  const ContextualD20RollPart({
    required super.label,
    required this.d20Modifier,
  }) : super._();

  final int d20Modifier;

  @override
  bool get supportsD20Mode => true;
}

class ContextualRollPartResult {
  const ContextualRollPartResult({
    required this.label,
    required this.result,
  });

  final String label;
  final DiceRollResult result;
}

class ContextualRollResult {
  const ContextualRollResult({
    required this.requestKey,
    required this.title,
    this.subtitle,
    required this.options,
    required this.parts,
  });

  final String requestKey;
  final String title;
  final String? subtitle;
  final ContextualRollOptions options;
  final List<ContextualRollPartResult> parts;
}

class ContextualRollHistory {
  const ContextualRollHistory._();

  static const maxEntries = 20;

  static List<ContextualRollResult> add(
    List<ContextualRollResult> history,
    ContextualRollResult result, {
    int limit = maxEntries,
  }) {
    return [result, ...history].take(limit).toList();
  }
}
