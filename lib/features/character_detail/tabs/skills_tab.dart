import 'dart:async';

import '../character_detail_dependencies.dart';

// ── Skills Tab ────────────────────────────────────────────────────────────────

class SkillsTab extends ConsumerStatefulWidget {
  const SkillsTab({
    super.key,
    required this.skillRows,
    required this.characterId,
  });
  final List<SkillRowVm> skillRows;
  final String characterId;

  @override
  ConsumerState<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends ConsumerState<SkillsTab>
    with AutomaticKeepAliveClientMixin {
  static const _abilityOrder = [
    'Strength',
    'Dexterity',
    'Constitution',
    'Intelligence',
    'Wisdom',
    'Charisma',
  ];

  Timer? _hintTimer;
  bool _showEditHint = true;

  @override
  void initState() {
    super.initState();
    _hintTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() => _showEditHint = false);
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _dismissHint() {
    _hintTimer?.cancel();
    if (_showEditHint) {
      setState(() => _showEditHint = false);
    }
  }

  void _cycleSkill(String skillName) {
    final c = ref.read(characterDetailProvider(widget.characterId)).valueOrNull;
    if (c == null) return;
    final lower = skillName.toLowerCase();
    // Normalize to lowercase so contains/remove always match regardless of
    // how the values were originally stored (e.g. "Perception" vs "perception")
    final profs = c.skillProficiencies.map((s) => s.toLowerCase()).toList();
    final experts = c.skillExpertises.map((s) => s.toLowerCase()).toList();

    final isExpert = experts.contains(lower);
    final isProf = profs.contains(lower);

    if (isExpert) {
      // expert → none
      experts.remove(lower);
      profs.remove(lower);
    } else if (isProf) {
      // proficient → expert
      experts.add(lower);
    } else {
      // none → proficient
      profs.add(lower);
    }
    ref
        .read(characterDetailProvider(widget.characterId).notifier)
        .updateSkillProficiencies(profs, experts);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;
    final rows = widget.skillRows;
    final abilityLabels = {
      'Strength': l10n.abilityStr,
      'Dexterity': l10n.abilityDex,
      'Constitution': l10n.abilityCon,
      'Intelligence': l10n.abilityInt,
      'Wisdom': l10n.abilityWis,
      'Charisma': l10n.abilityCha,
    };
    final scheme = Theme.of(context).colorScheme;
    final grouped = <String, List<SkillRowVm>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.ability, () => []).add(row);
    }
    final orderedAbilities = [
      for (final ability in _abilityOrder)
        if (grouped.containsKey(ability)) ability,
      for (final ability in grouped.keys)
        if (!_abilityOrder.contains(ability)) ability,
    ];

    return Stack(
      children: [
        CustomScrollView(
          key: PageStorageKey('skills-${widget.characterId}'),
          slivers: [
            for (final ability in orderedAbilities) ...[
              SliverToBoxAdapter(
                child: DetailSectionHeader(
                  title: abilityLabels[ability] ?? ability,
                  icon: _abilityIcon(ability),
                  accentColor: _abilityColor(scheme, ability),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                sliver: SliverList.separated(
                  itemCount: grouped[ability]!.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final row = grouped[ability]![index];
                    return _SkillCard(
                      row: row,
                      label: i18n.skillName(row.skillName),
                      accentColor: _abilityColor(scheme, ability),
                      onLongPress: () => _cycleSkill(row.skillName),
                    );
                  },
                ),
              ),
            ],
            const SliverPadding(padding: EdgeInsets.only(bottom: 192)),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.paddingOf(context).bottom + 24,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _showEditHint
                ? _SkillsHintToast(
                    key: const ValueKey('skills-hint-toast'),
                    label: l10n.skillsEditHint,
                    onDismiss: _dismissHint,
                  )
                : const SizedBox.shrink(
                    key: ValueKey('skills-hint-hidden'),
                  ),
          ),
        ),
      ],
    );
  }

  Color _abilityColor(ColorScheme scheme, String ability) {
    return switch (ability) {
      'Strength' => scheme.error,
      'Dexterity' => scheme.primary,
      'Constitution' => scheme.tertiary,
      'Intelligence' => scheme.secondary,
      'Wisdom' => scheme.primary,
      'Charisma' => scheme.tertiary,
      _ => scheme.primary,
    };
  }

  IconData _abilityIcon(String ability) {
    return switch (ability) {
      'Strength' => Icons.fitness_center,
      'Dexterity' => Icons.directions_run,
      'Constitution' => Icons.favorite_border,
      'Intelligence' => Icons.psychology_outlined,
      'Wisdom' => Icons.visibility_outlined,
      'Charisma' => Icons.theater_comedy_outlined,
      _ => Icons.circle_outlined,
    };
  }

  @override
  bool get wantKeepAlive => true;
}

class _SkillsHintToast extends StatelessWidget {
  const _SkillsHintToast({
    super.key,
    required this.label,
    required this.onDismiss,
  });

  final String label;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxTextWidth = (MediaQuery.sizeOf(context).width - 118)
        .clamp(160.0, 360.0)
        .toDouble();

    return Center(
      child: Material(
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxTextWidth),
                child: Text(
                  label,
                  softWrap: true,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                color: scheme.onSurfaceVariant,
                tooltip: AppLocalizations.of(context)!.dialogClose,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.row,
    required this.label,
    required this.accentColor,
    required this.onLongPress,
  });

  final SkillRowVm row;
  final String label;
  final Color accentColor;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isExpert = row.isExpert;
    final isProf = row.isProficient;
    final stateColor = isExpert
        ? scheme.tertiary
        : isProf
        ? accentColor
        : scheme.outline;
    final backgroundColor = isExpert
        ? scheme.tertiaryContainer.withValues(alpha: 0.28)
        : isProf
        ? accentColor.withValues(alpha: 0.10)
        : scheme.surfaceContainerLow;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isProf
                  ? stateColor.withValues(alpha: 0.42)
                  : scheme.outlineVariant.withValues(alpha: 0.68),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: isProf ? 0.16 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isExpert
                      ? Icons.star_rounded
                      : isProf
                      ? Icons.check_circle_outline
                      : Icons.circle_outlined,
                  size: 17,
                  color: stateColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isProf ? FontWeight.w700 : FontWeight.w500,
                    color: isProf ? scheme.onSurface : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (isExpert || isProf) ...[
                DetailPill(
                  label: isExpert ? '2x' : '+PB',
                  icon: isExpert ? Icons.star_rounded : Icons.check,
                  color: stateColor,
                  dense: true,
                ),
                const SizedBox(width: 10),
              ],
              SizedBox(
                width: 42,
                child: Text(
                  sign(row.bonus),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isProf ? stateColor : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
