import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../shared/providers/providers.dart';
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

  // Rolled Dice: qual valor (por índice em rolledValues) está em cada atributo
  final Map<String, int?> _rollAssignment = {
    for (final a in _attributes) a: null,
  };

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
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
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
        // ── Lembrete de classe ───────────────────────────────────────────────
        if (draft.selectedClass != null) ...
          [_ClassReminder(cls: draft.selectedClass!, i18n: i18n), const SizedBox(height: 16)],

        // ── Método ────────────────────────────────────────────────────────
        Text(AppLocalizations.of(context)!.stepChooseMethod,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<AttributeMethod>(
          segments: [
            ButtonSegment(
              value: AttributeMethod.standardArray,
              label: Text(AppLocalizations.of(context)!.stepStandardArray),
            ),
            ButtonSegment(
              value: AttributeMethod.pointBuy,
              label: Text(AppLocalizations.of(context)!.stepPointBuy),
            ),
            ButtonSegment(
              value: AttributeMethod.rolledDice,
              label: Text(AppLocalizations.of(context)!.stepRoll4d6),
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
            title: Text(AppLocalizations.of(context)!.stepDistributeRacialBonuses),
            subtitle: Text(
                AppLocalizations.of(context)!.stepTashaRule),
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
        else if (method == AttributeMethod.pointBuy)
          _PointBuySection(
            values: _pointBuyValues,
            raceAsi: freeAsi ? {} : raceAsi,
            onChanged: _onPointBuyChanged,
          )
        else
          _RolledDiceSection(
            rolledValues: draft.rolledValues,
            assignment: _rollAssignment,
            raceAsi: freeAsi ? {} : raceAsi,
            onRoll: _onReroll,
            onChanged: _onRollAssignmentChanged,
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
      _rollAssignment[a] = null;
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

  void _onReroll() {
    final rng = Random();
    int roll4d6DropLowest() {
      final dice = List.generate(4, (_) => rng.nextInt(6) + 1);
      dice.sort();
      return dice.skip(1).fold(0, (a, b) => a + b);
    }

    final values = List.generate(6, (_) => roll4d6DropLowest());
    ref.read(characterDraftProvider.notifier).setRolledValues(values);
    // Clear roll assignment on reroll
    setState(() {
      for (final a in _attributes) {
        _rollAssignment[a] = null;
      }
    });
    ref.read(characterDraftProvider.notifier).setBaseAttributes({});
  }

  void _onRollAssignmentChanged(Map<String, int?> assignment) {
    setState(() => _rollAssignment.addAll(assignment));
    final rolled = ref.read(characterDraftProvider).rolledValues;
    final complete = _rollAssignment.values.every((v) => v != null) &&
        _rollAssignment.values.whereType<int>().toSet().length ==
            _attributes.length;
    if (complete) {
      ref.read(characterDraftProvider.notifier).setBaseAttributes({
        for (final e in _rollAssignment.entries) e.key: rolled[e.value!],
      });
    } else {
      ref.read(characterDraftProvider.notifier).setBaseAttributes({});
    }
  }
}

// ── Class Reminder ────────────────────────────────────────────────────────────

class _ClassReminder extends StatelessWidget {
  const _ClassReminder({required this.cls, required this.i18n});
  final SrdClass cls;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurface),
                children: [
                  TextSpan(
                    text: '${i18n.className(cls.name)} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '— '),
                  TextSpan(text: AppLocalizations.of(context)!.stepPrimaryAbilities),
                  TextSpan(
                    text: cls.primaryAbility.map((a) => abilityName(AppLocalizations.of(context)!, a)).join(', '),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: scheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rolled Dice ───────────────────────────────────────────────────────────────

class _RolledDiceSection extends StatelessWidget {
  const _RolledDiceSection({
    required this.rolledValues,
    required this.assignment,
    required this.raceAsi,
    required this.onRoll,
    required this.onChanged,
  });

  final List<int> rolledValues;
  final Map<String, int?> assignment;
  final Map<String, int> raceAsi;
  final VoidCallback onRoll;
  final ValueChanged<Map<String, int?>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final usedIndices = assignment.values.whereType<int>().toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Roll button + current rolled values
        Row(
          children: [
            FilledButton.icon(
              onPressed: onRoll,
              icon: const Icon(Icons.casino_outlined, size: 18),
              label: Text(rolledValues.isEmpty ? AppLocalizations.of(context)!.stepRollDice : AppLocalizations.of(context)!.stepReroll),
            ),
            if (rolledValues.isNotEmpty) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: rolledValues.asMap().entries.map((e) {
                    final taken = usedIndices.contains(e.key);
                    return Chip(
                      label: Text('${e.value}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: taken
                                ? scheme.onSurface.withAlpha(80)
                                : scheme.onPrimaryContainer,
                          )),
                      backgroundColor: taken
                          ? scheme.surfaceContainerHighest
                          : scheme.primaryContainer,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
        if (rolledValues.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              AppLocalizations.of(context)!.stepRollHint,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          )
        else ...[
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.stepAssignRolls,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          ..._attributes.map((attr) {
            final currentIdx = assignment[attr];
            final asi = raceAsi[attr] ?? 0;
            final baseVal =
                currentIdx != null ? rolledValues[currentIdx] : null;
            final finalVal = baseVal != null ? baseVal + asi : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(abilityName(l10n, attr),
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Expanded(
                    child: DropdownButton<int?>(
                      isExpanded: true,
                      value: currentIdx,
                      hint: const Text('—'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('—')),
                        ...rolledValues.asMap().entries.map((e) {
                          final taken =
                              usedIndices.contains(e.key) && e.key != currentIdx;
                          return DropdownMenuItem(
                            value: e.key,
                            enabled: !taken,
                            child: Text(
                              '${e.value}',
                              style: taken
                                  ? TextStyle(
                                      color: scheme.onSurface.withAlpha(97))
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
                      child: Text(AppLocalizations.of(context)!.stepRaceBonus(asi),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: scheme.primary)),
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
      ],
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
    final l10n = AppLocalizations.of(context)!;
    final usedIndices = assignment.values.whereType<int>().toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.stepAssignValues,
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
                  child: Text(abilityName(l10n, attr),
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
                    child: Text(AppLocalizations.of(context)!.stepRaceBonus(asi),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.stepPointsRemaining,
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
                  child: Text(abilityName(l10n, attr),
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
    final l10n = AppLocalizations.of(context)!;
    final dist = ref.watch(characterDraftProvider).freeAsiDistribution;
    final totalPool =
        raceAsi.values.fold(0, (a, b) => a + b);
    final assigned = dist.values.fold(0, (a, b) => a + b);
    final remaining = totalPool - assigned;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stepFreeAsiRemaining(remaining),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ..._attributes.map((attr) {
          final current = dist[attr] ?? 0;
          return Row(
            children: [
              SizedBox(
                  width: 110,
                  child: Text(abilityName(l10n, attr),
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
    final l10n = AppLocalizations.of(context)!;
    final dist = ref.watch(characterDraftProvider).freePicksDistribution;
    final assigned = dist.values.fold(0, (a, b) => a + b);
    final remaining = totalPoints - assigned;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stepFreePicksRemaining(totalPoints, remaining),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.stepFreePicksNoStack,
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
                  child: Text(abilityName(l10n, attr),
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
