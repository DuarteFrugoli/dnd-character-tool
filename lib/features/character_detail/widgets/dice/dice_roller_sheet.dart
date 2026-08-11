import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';

final diceRollHistoryProvider =
    StateProvider.family<List<DiceRollResult>, String>(
      (ref, _) => const <DiceRollResult>[],
    );

Future<void> openDiceRollerSheet(
  BuildContext context, {
  required String characterId,
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DiceRollerSheet(characterId: characterId),
      );
    },
  );
}

class DiceRollerSheet extends ConsumerStatefulWidget {
  const DiceRollerSheet({super.key, required this.characterId});

  final String characterId;

  @override
  ConsumerState<DiceRollerSheet> createState() => _DiceRollerSheetState();
}

enum _DiceMode { normal, advantage, disadvantage }

class _DiceRollerSheetState extends ConsumerState<DiceRollerSheet> {
  static const _quickDice = [4, 6, 8, 10, 12, 20, 100];

  final _quantityCtrl = TextEditingController(text: '1');
  final _modifierCtrl = TextEditingController(text: '0');
  final _expressionCtrl = TextEditingController(text: '1d20');
  final _roller = DiceRoller();

  int _selectedSides = 20;
  _DiceMode _mode = _DiceMode.normal;
  DiceRollResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    final history = ref.read(diceRollHistoryProvider(widget.characterId));
    if (history.isNotEmpty) {
      _result = history.first;
    }
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _modifierCtrl.dispose();
    _expressionCtrl.dispose();
    super.dispose();
  }

  void _selectDie(int sides) {
    setState(() {
      _selectedSides = sides;
      if (sides != 20) _mode = _DiceMode.normal;
      _syncExpressionFromControls();
    });
  }

  void _setMode(_DiceMode mode) {
    setState(() {
      _mode = mode;
      if (mode != _DiceMode.normal) {
        _quantityCtrl.text = '1';
        _selectedSides = 20;
      }
      _syncExpressionFromControls();
    });
  }

  void _syncExpressionFromControls() {
    final quantity = int.tryParse(_quantityCtrl.text.trim());
    final modifier = int.tryParse(_modifierCtrl.text.trim()) ?? 0;
    final safeQuantity = quantity == null || quantity < 1 ? 1 : quantity;

    final dice = switch (_mode) {
      _DiceMode.normal => '${safeQuantity}d$_selectedSides',
      _DiceMode.advantage => '2d20kh1',
      _DiceMode.disadvantage => '2d20kl1',
    };
    final modifierText = modifier == 0
        ? ''
        : modifier > 0
        ? '+$modifier'
        : '$modifier';
    _expressionCtrl.text = '$dice$modifierText';
    _expressionCtrl.selection = TextSelection.collapsed(
      offset: _expressionCtrl.text.length,
    );
    _error = null;
  }

  void _roll() {
    try {
      final expression = DiceParser.parse(_expressionCtrl.text);
      final result = _roller.roll(expression);
      setState(() {
        _result = result;
        _error = null;
      });
      final history = ref.read(diceRollHistoryProvider(widget.characterId));
      ref.read(diceRollHistoryProvider(widget.characterId).notifier).state = [
        result,
        ...history,
      ].take(20).toList();
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString();
      });
    }
  }

  void _showExpressionHelp() {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.diceExpressionHelpTitle),
        content: SingleChildScrollView(
          child: Text(l10n.diceExpressionHelpBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.dialogClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final history = ref.watch(diceRollHistoryProvider(widget.characterId));

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Material(
          color: scheme.surface,
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.casino_outlined, color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.characterActionRollDice,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.dialogClose,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    24 +
                        mediaQuery.viewPadding.bottom +
                        mediaQuery.viewInsets.bottom,
                  ),
                  children: [
                    _QuickDiceSelector(
                      quickDice: _quickDice,
                      selectedSides: _selectedSides,
                      onSelected: _selectDie,
                    ),
                    const SizedBox(height: 16),
                    _BasicDiceControls(
                      quantityCtrl: _quantityCtrl,
                      modifierCtrl: _modifierCtrl,
                      quantityEnabled: _mode == _DiceMode.normal,
                      onChanged: () => setState(_syncExpressionFromControls),
                    ),
                    if (_selectedSides == 20) ...[
                      const SizedBox(height: 12),
                      SegmentedButton<_DiceMode>(
                        segments: [
                          ButtonSegment(
                            value: _DiceMode.normal,
                            label: Text(l10n.diceModeNormal),
                          ),
                          ButtonSegment(
                            value: _DiceMode.advantage,
                            label: Text(l10n.diceModeAdvantage),
                          ),
                          ButtonSegment(
                            value: _DiceMode.disadvantage,
                            label: Text(l10n.diceModeDisadvantage),
                          ),
                        ],
                        selected: {_mode},
                        showSelectedIcon: false,
                        onSelectionChanged: (values) => _setMode(values.first),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _expressionCtrl,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _roll(),
                      decoration: InputDecoration(
                        labelText: l10n.diceExpressionLabel,
                        hintText: l10n.diceExpressionHint,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: l10n.diceExpressionHelpTooltip,
                          icon: const Icon(Icons.info_outline),
                          onPressed: _showExpressionHelp,
                        ),
                        errorText: _error == null
                            ? null
                            : l10n.diceInvalidExpression(_error!),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _roll,
                      icon: const Icon(Icons.casino_outlined),
                      label: Text(l10n.diceRollButton),
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 16),
                      _DiceResultCard(result: _result!, onReroll: _roll),
                    ],
                    const SizedBox(height: 20),
                    _DiceHistoryList(history: history),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickDiceSelector extends StatelessWidget {
  const _QuickDiceSelector({
    required this.quickDice,
    required this.selectedSides,
    required this.onSelected,
  });

  final List<int> quickDice;
  final int selectedSides;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final sides in quickDice)
          ChoiceChip(
            label: Text('d$sides'),
            selected: selectedSides == sides,
            onSelected: (_) => onSelected(sides),
          ),
      ],
    );
  }
}

class _BasicDiceControls extends StatelessWidget {
  const _BasicDiceControls({
    required this.quantityCtrl,
    required this.modifierCtrl,
    required this.quantityEnabled,
    required this.onChanged,
  });

  final TextEditingController quantityCtrl;
  final TextEditingController modifierCtrl;
  final bool quantityEnabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: quantityCtrl,
            enabled: quantityEnabled,
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: l10n.diceQuantityLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: modifierCtrl,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: l10n.diceModifierLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _DiceResultCard extends StatelessWidget {
  const _DiceResultCard({required this.result, required this.onReroll});

  final DiceRollResult result;
  final VoidCallback onReroll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.diceResultTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onReroll,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.diceRerollButton),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.total.toString(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (result.hasNaturalTwenty || result.hasNaturalOne) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (result.hasNaturalTwenty)
                    Chip(
                      label: Text(l10n.diceNaturalTwenty),
                      avatar: const Icon(Icons.arrow_upward, size: 18),
                    ),
                  if (result.hasNaturalOne)
                    Chip(
                      label: Text(l10n.diceNaturalOne),
                      avatar: const Icon(Icons.arrow_downward, size: 18),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              result.expression.normalized,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _formatResultBreakdown(result),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiceHistoryList extends StatelessWidget {
  const _DiceHistoryList({required this.history});

  final List<DiceRollResult> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.diceHistoryTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          Text(
            l10n.diceNoRollsYet,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          for (final result in history.take(8))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(result.expression.normalized),
              subtitle: Text(_formatResultBreakdown(result)),
              trailing: Text(
                result.total.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
      ],
    );
  }
}

String _formatResultBreakdown(DiceRollResult result) {
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
