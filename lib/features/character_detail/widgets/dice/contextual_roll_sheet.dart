import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dice/dice.dart';
import '../../../../l10n/app_localizations.dart';
import 'dice_result_formatting.dart';

class ContextualRollHistoryKey {
  const ContextualRollHistoryKey({
    required this.characterId,
    required this.rollKey,
  });

  final String characterId;
  final String rollKey;

  @override
  bool operator ==(Object other) {
    return other is ContextualRollHistoryKey &&
        other.characterId == characterId &&
        other.rollKey == rollKey;
  }

  @override
  int get hashCode => Object.hash(characterId, rollKey);
}

final contextualRollHistoryProvider =
    StateProvider.family<List<ContextualRollResult>, ContextualRollHistoryKey>(
      (ref, _) => const <ContextualRollResult>[],
    );

Future<void> openContextualRollSheet(
  BuildContext context, {
  required String characterId,
  required ContextualRollRequest request,
  bool rollImmediately = false,
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => ContextualRollSheet(
      characterId: characterId,
      request: request,
      rollImmediately: rollImmediately,
    ),
  );
}

class ContextualRollSheet extends ConsumerStatefulWidget {
  const ContextualRollSheet({
    super.key,
    required this.characterId,
    required this.request,
    this.rollImmediately = false,
  });

  final String characterId;
  final ContextualRollRequest request;
  final bool rollImmediately;

  @override
  ConsumerState<ContextualRollSheet> createState() =>
      _ContextualRollSheetState();
}

class _ContextualRollSheetState extends ConsumerState<ContextualRollSheet> {
  final _engine = ContextualRollEngine();
  ContextualD20Mode _d20Mode = ContextualD20Mode.normal;

  ContextualRollHistoryKey get _historyKey => ContextualRollHistoryKey(
    characterId: widget.characterId,
    rollKey: widget.request.key,
  );

  @override
  void initState() {
    super.initState();
    if (widget.rollImmediately) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _roll();
      });
    }
  }

  void _roll() {
    final result = _engine.roll(
      widget.request,
      options: ContextualRollOptions(d20Mode: _d20Mode),
    );
    final history = ref.read(contextualRollHistoryProvider(_historyKey));
    ref.read(contextualRollHistoryProvider(_historyKey).notifier).state =
        ContextualRollHistory.add(history, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final history = ref.watch(contextualRollHistoryProvider(_historyKey));
    final latest = history.isEmpty ? null : history.first;
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: latest == null ? 0.42 : 0.66,
      minChildSize: 0.32,
      maxChildSize: 0.9,
      builder: (context, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (widget.request.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.request.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.dialogClose,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (widget.request.supportsD20Mode) ...[
            const SizedBox(height: 16),
            SegmentedButton<ContextualD20Mode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ContextualD20Mode.disadvantage,
                  label: Text(l10n.diceModeDisadvantage),
                ),
                ButtonSegment(
                  value: ContextualD20Mode.normal,
                  label: Text(l10n.diceModeNormal),
                ),
                ButtonSegment(
                  value: ContextualD20Mode.advantage,
                  label: Text(l10n.diceModeAdvantage),
                ),
              ],
              selected: {_d20Mode},
              onSelectionChanged: (selection) {
                setState(() => _d20Mode = selection.single);
              },
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _roll,
            icon: const Icon(Icons.casino_outlined),
            label: Text(
              latest == null ? l10n.diceRollButton : l10n.diceRerollButton,
            ),
          ),
          if (latest != null) ...[
            const SizedBox(height: 16),
            _ContextualRollResultCard(result: latest),
          ],
          const SizedBox(height: 16),
          _ContextualRollHistoryList(history: history),
        ],
      ),
    );
  }
}

class _ContextualRollResultCard extends StatelessWidget {
  const _ContextualRollResultCard({required this.result});

  final ContextualRollResult result;

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
            Text(
              l10n.diceResultTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            for (final part in result.parts) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      part.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Text(
                    part.result.total.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                part.result.expression.normalized,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                formatDiceResultBreakdown(part.result),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (part.result.hasNaturalTwenty || part.result.hasNaturalOne)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (part.result.hasNaturalTwenty)
                        Chip(
                          label: Text(l10n.diceNaturalTwenty),
                          avatar: const Icon(Icons.arrow_upward, size: 18),
                        ),
                      if (part.result.hasNaturalOne)
                        Chip(
                          label: Text(l10n.diceNaturalOne),
                          avatar: const Icon(Icons.arrow_downward, size: 18),
                        ),
                    ],
                  ),
                ),
              if (part != result.parts.last) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContextualRollHistoryList extends StatelessWidget {
  const _ContextualRollHistoryList({required this.history});

  final List<ContextualRollResult> history;

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
              title: Text(result.title),
              subtitle: Text(
                result.parts
                    .map(
                      (part) =>
                          '${part.label}: ${part.result.expression.normalized}',
                    )
                    .join(' | '),
              ),
              trailing: Text(
                result.parts.map((part) => part.result.total).join(' / '),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
      ],
    );
  }
}
