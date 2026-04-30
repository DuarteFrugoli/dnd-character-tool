import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../character_draft_provider.dart';

const _attributes = [
  'Strength',
  'Dexterity',
  'Constitution',
  'Intelligence',
  'Wisdom',
  'Charisma',
];

const _standardArray = [15, 14, 13, 12, 10, 8];

// Point Buy: custo por valor (8→0, 9→1, 10→2, 11→3, 12→4, 13→5, 14→7, 15→9)
const _pointBuyCost = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9};
const _pointBuyTotal = 27;

class StepAttributes extends ConsumerStatefulWidget {
  const StepAttributes({super.key});

  @override
  ConsumerState<StepAttributes> createState() => _StepAttributesState();
}

class _StepAttributesState extends ConsumerState<StepAttributes> {
  // Standard Array: índice em _standardArray por atributo
  late final Map<String, int?> _arrayAssignment;

  // Point Buy: valor por atributo
  late final Map<String, int> _pointBuyValues;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(characterDraftProvider).baseAttributes;
    // Inicializa Point Buy a partir do draft (ou 8 como padrão)
    _pointBuyValues = {
      for (final a in _attributes) a: existing[a] ?? 8,
    };
    // Reconstrói a atribuição de índices do Standard Array a partir dos valores salvos
    _arrayAssignment = {
      for (final a in _attributes)
        a: existing.containsKey(a)
            ? _standardArray.indexOf(existing[a]!)
            : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(characterDraftProvider);
    final method = draft.attributeMethod;
    final freeAsi = draft.freeAsi;

    // Combina bônus de raça base + subraça para exibição
    final raceAsi = <String, int>{
      ...?draft.selectedRace?.abilityScoreIncreases,
    };
    draft.selectedSubrace?.abilityScoreIncreases.forEach((attr, bonus) {
      raceAsi[attr] = (raceAsi[attr] ?? 0) + bonus;
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Método ────────────────────────────────────────────────────────
        Text('Choose your method:',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<AttributeMethod>(
          segments: const [
            ButtonSegment(
              value: AttributeMethod.standardArray,
              label: Text('Standard Array'),
            ),
            ButtonSegment(
              value: AttributeMethod.pointBuy,
              label: Text('Point Buy'),
            ),
          ],
          selected: {method},
          onSelectionChanged: (s) {
            ref
                .read(characterDraftProvider.notifier)
                .setAttributeMethod(s.first);
            _clearAttributes();
          },
        ),
        const SizedBox(height: 16),

        // ── ASI toggle ───────────────────────────────────────────────────
        if (raceAsi.isNotEmpty) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Distribute racial bonuses freely'),
            subtitle: const Text(
                'Tasha\'s optional rule — assign ASI points to any attribute'),
            value: freeAsi,
            onChanged: (v) {
              ref.read(characterDraftProvider.notifier).setFreeAsi(v);
              if (v) {
                ref
                    .read(characterDraftProvider.notifier)
                    .setFreeAsiDistribution({});
              }
            },
          ),
          const Divider(height: 24),
        ],

        // ── Distribuição ─────────────────────────────────────────────────
        if (method == AttributeMethod.standardArray)
          _StandardArraySection(
            assignment: _arrayAssignment,
            raceAsi: freeAsi ? {} : raceAsi,
            onChanged: _onArrayChanged,
          )
        else
          _PointBuySection(
            values: _pointBuyValues,
            raceAsi: freeAsi ? {} : raceAsi,
            onChanged: _onPointBuyChanged,
          ),

        // ── Free picks da raça (ex: Half-Elf twoOthers) ──────────────────
        if (!freeAsi && (draft.selectedRace?.freeAsiPoints ?? 0) > 0) ...[
          const Divider(height: 24),
          _FreePicksSection(
            totalPoints: draft.selectedRace!.freeAsiPoints,
            fixedAsi: raceAsi,
          ),
        ],

        // ── Free ASI distribution (Tasha's) ──────────────────────────────
        if (freeAsi && raceAsi.isNotEmpty) ...[
          const Divider(height: 24),
          _FreeAsiSection(raceAsi: raceAsi),
        ],
      ],
    );
  }

  void _clearAttributes() {
    for (final a in _attributes) {
      _arrayAssignment[a] = null;
      _pointBuyValues[a] = 8;
    }
    ref
        .read(characterDraftProvider.notifier)
        .setBaseAttributes({});
  }

  void _onArrayChanged(Map<String, int?> assignment) {
    setState(() => _arrayAssignment.addAll(assignment));
    _pushArrayState();
  }

  void _pushArrayState() {
    final complete = _arrayAssignment.values.every((v) => v != null) &&
        _arrayAssignment.values.toSet().length == _attributes.length;
    if (complete) {
      ref.read(characterDraftProvider.notifier).setBaseAttributes({
        for (final e in _arrayAssignment.entries)
          e.key: _standardArray[e.value!],
      });
    }
  }

  void _onPointBuyChanged(Map<String, int> values) {
    setState(() => _pointBuyValues.addAll(values));
    ref.read(characterDraftProvider.notifier).setBaseAttributes(
          Map<String, int>.from(_pointBuyValues),
        );
  }
}

// ── Standard Array ────────────────────────────────────────────────────────────

class _StandardArraySection extends StatelessWidget {
  const _StandardArraySection({
    required this.assignment,
    required this.raceAsi,
    required this.onChanged,
  });

  final Map<String, int?> assignment;
  final Map<String, int> raceAsi;
  final ValueChanged<Map<String, int?>> onChanged;

  @override
  Widget build(BuildContext context) {
    final usedIndices = assignment.values.whereType<int>().toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assign each value to one attribute:',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        ..._attributes.map((attr) {
          final currentIdx = assignment[attr];
          final asi = raceAsi[attr] ?? 0;
          final baseVal =
              currentIdx != null ? _standardArray[currentIdx] : null;
          final finalVal = baseVal != null ? baseVal + asi : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(attr,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: currentIdx,
                    hint: const Text('—'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('—')),
                      ..._standardArray.asMap().entries.map((e) {
                        final taken =
                            usedIndices.contains(e.key) && e.key != currentIdx;
                        return DropdownMenuItem(
                          value: e.key,
                          enabled: !taken,
                          child: Text(
                            '${e.value}',
                            style: taken
                                ? TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.38))
                                : null,
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) => onChanged({...assignment, attr: v}),
                  ),
                ),
                if (asi != 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text('+$asi race',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.primary)),
                  ),
                if (finalVal != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 36,
                      child: Text('= $finalVal',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Point Buy ─────────────────────────────────────────────────────────────────

class _PointBuySection extends StatelessWidget {
  const _PointBuySection({
    required this.values,
    required this.raceAsi,
    required this.onChanged,
  });

  final Map<String, int> values;
  final Map<String, int> raceAsi;
  final ValueChanged<Map<String, int>> onChanged;

  int get _spent => values.values
      .map((v) => _pointBuyCost[v] ?? 0)
      .fold(0, (a, b) => a + b);

  int get _remaining => _pointBuyTotal - _spent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Points remaining: ',
                style: Theme.of(context).textTheme.bodySmall),
            Text(
              '$_remaining / $_pointBuyTotal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _remaining < 0
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._attributes.map((attr) {
          final val = values[attr]!;
          final asi = raceAsi[attr] ?? 0;
          final cost = _pointBuyCost[val] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(attr,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: val > 8
                      ? () => onChanged({...values, attr: val - 1})
                      : null,
                ),
                SizedBox(
                  width: 28,
                  child: Text('$val',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: val < 15 &&
                          _remaining >=
                              (_pointBuyCost[val + 1] ?? 99) - cost
                      ? () => onChanged({...values, attr: val + 1})
                      : null,
                ),
                if (asi != 0)
                  Text('+$asi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary)),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text('= ${val + asi}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Free ASI Distribution ─────────────────────────────────────────────────────

class _FreeAsiSection extends ConsumerWidget {
  const _FreeAsiSection({required this.raceAsi});

  final Map<String, int> raceAsi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dist = ref.watch(characterDraftProvider).freeAsiDistribution;
    final totalPool =
        raceAsi.values.fold(0, (a, b) => a + b);
    final assigned = dist.values.fold(0, (a, b) => a + b);
    final remaining = totalPool - assigned;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribute racial ASI points freely ($remaining remaining):',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ..._attributes.map((attr) {
          final current = dist[attr] ?? 0;
          return Row(
            children: [
              SizedBox(
                  width: 110,
                  child: Text(attr,
                      style: Theme.of(context).textTheme.bodyMedium)),
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: current > 0
                    ? () => ref
                        .read(characterDraftProvider.notifier)
                        .setFreeAsiDistribution({...dist, attr: current - 1})
                    : null,
              ),
              Text('$current',
                  style: Theme.of(context).textTheme.bodyMedium),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: remaining > 0
                    ? () => ref
                        .read(characterDraftProvider.notifier)
                        .setFreeAsiDistribution({...dist, attr: current + 1})
                    : null,
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ── Free Picks da Raça (twoOthers, etc.) ─────────────────────────────────────

/// Seletor para pontos ASI livres específicos da raça (ex: Half-Elf +1/+1).
/// Independente do toggle de Tasha's — é parte da regra base da raça.
class _FreePicksSection extends ConsumerWidget {
  const _FreePicksSection({
    required this.totalPoints,
    required this.fixedAsi,
  });

  /// Quantidade total de pontos +1 a distribuir (ex: Half-Elf = 2).
  final int totalPoints;

  /// Bônus fixos da raça (para exibição apenas — não afeta este seletor).
  final Map<String, int> fixedAsi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dist = ref.watch(characterDraftProvider).freePicksDistribution;
    final assigned = dist.values.fold(0, (a, b) => a + b);
    final remaining = totalPoints - assigned;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Racial free ASI: assign +1 to $totalPoints attributes ($remaining remaining):',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Cannot assign to attributes already receiving a racial bonus.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ..._attributes.map((attr) {
          final current = dist[attr] ?? 0;
          final hasFixedBonus = (fixedAsi[attr] ?? 0) > 0;
          return Row(
            children: [
              SizedBox(
                  width: 110,
                  child: Text(attr,
                      style: Theme.of(context).textTheme.bodyMedium)),
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: current > 0
                    ? () => ref
                        .read(characterDraftProvider.notifier)
                        .setFreePicksDistribution({...dist, attr: current - 1})
                    : null,
              ),
              Text('+$current',
                  style: Theme.of(context).textTheme.bodyMedium),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                // Não pode colocar em atributo com bônus fixo da raça,
                // não pode passar de 1 por atributo, e precisa ter ponto disponível.
                onPressed: remaining > 0 && current < 1 && !hasFixedBonus
                    ? () => ref
                        .read(characterDraftProvider.notifier)
                        .setFreePicksDistribution({...dist, attr: current + 1})
                    : null,
              ),
            ],
          );
        }),
      ],
    );
  }
}
