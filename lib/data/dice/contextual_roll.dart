import 'dice_roller.dart';

enum ContextualD20Mode { disadvantage, normal, advantage }

enum ContextualCriticalMode { none, doubleDice, doubleTotal }

class ContextualRollOptions {
  const ContextualRollOptions({
    this.d20Mode = ContextualD20Mode.normal,
    this.criticalMode = ContextualCriticalMode.none,
  });

  final ContextualD20Mode d20Mode;
  final ContextualCriticalMode criticalMode;
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
  const ContextualRollPart._({required this.label});

  const factory ContextualRollPart.expression({
    required String label,
    required String expression,
    bool? critical,
  }) = ContextualExpressionRollPart;

  const factory ContextualRollPart.d20({
    required String label,
    required int d20Modifier,
  }) = ContextualD20RollPart;

  final String label;

  bool get supportsD20Mode;

  bool get supportsCritical;
}

class ContextualExpressionRollPart extends ContextualRollPart {
  const ContextualExpressionRollPart({
    required super.label,
    required this.expression,
    bool? critical,
  }) : critical = critical ?? false,
       super._();

  final String expression;
  final bool critical;

  @override
  bool get supportsD20Mode => false;

  @override
  bool get supportsCritical => critical;
}

class ContextualD20RollPart extends ContextualRollPart {
  const ContextualD20RollPart({
    required super.label,
    required this.d20Modifier,
  }) : super._();

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
