import 'dice_roller.dart';

enum ContextualD20Mode { disadvantage, normal, advantage }

enum ContextualCriticalMode { none, doubleDice, doubleTotal }

class ContextualRollOptions {
  const ContextualRollOptions({
    this.d20Mode = ContextualD20Mode.normal,
    this.criticalMode = ContextualCriticalMode.none,
    this.expressionChoices = const {},
  });

  final ContextualD20Mode d20Mode;
  final ContextualCriticalMode criticalMode;
  final Map<String, String> expressionChoices;
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

  bool get supportsCritical => parts.any((part) => part.supportsCritical);
}

sealed class ContextualRollPart {
  const ContextualRollPart._({required this.id, required this.label});

  const factory ContextualRollPart.expression({
    String? id,
    required String label,
    required String expression,
    bool? critical,
    String? choiceLabel,
    List<ContextualRollExpressionChoice>? choices,
  }) = ContextualExpressionRollPart;

  const factory ContextualRollPart.d20({
    String? id,
    required String label,
    required int d20Modifier,
  }) = ContextualD20RollPart;

  final String id;
  final String label;

  bool get supportsD20Mode;

  bool get supportsCritical;
}

class ContextualRollExpressionChoice {
  const ContextualRollExpressionChoice({
    required this.key,
    required this.label,
    required this.expression,
  });

  final String key;
  final String label;
  final String expression;
}

class ContextualExpressionRollPart extends ContextualRollPart {
  const ContextualExpressionRollPart({
    String? id,
    required super.label,
    required this.expression,
    bool? critical,
    this.choiceLabel,
    List<ContextualRollExpressionChoice>? choices,
  }) : critical = critical ?? false,
       choices = choices ?? const [],
       super._(id: id ?? label);

  final String expression;
  final bool critical;
  final String? choiceLabel;
  final List<ContextualRollExpressionChoice> choices;

  @override
  bool get supportsD20Mode => false;

  @override
  bool get supportsCritical => critical;
}

class ContextualD20RollPart extends ContextualRollPart {
  const ContextualD20RollPart({
    String? id,
    required super.label,
    required this.d20Modifier,
  }) : super._(id: id ?? label);

  final int d20Modifier;

  @override
  bool get supportsD20Mode => true;

  @override
  bool get supportsCritical => false;
}

class ContextualRollPartResult {
  const ContextualRollPartResult({
    required this.label,
    required this.result,
    this.criticalApplied = false,
    this.totalMultiplier = 1,
  });

  final String label;
  final DiceRollResult result;
  final bool criticalApplied;
  final int totalMultiplier;

  int get total => result.total * totalMultiplier;
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
