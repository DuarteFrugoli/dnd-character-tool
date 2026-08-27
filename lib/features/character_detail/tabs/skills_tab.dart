import 'dart:async';

import '../character_detail_dependencies.dart';

// ── Skills Tab ────────────────────────────────────────────────────────────────

class SkillsTab extends ConsumerStatefulWidget {
  const SkillsTab({
    super.key,
    required this.skillRows,
    required this.preferences,
    required this.characterId,
  });
  final List<SkillRowVm> skillRows;
  final SkillDisplayPreferences preferences;
  final String characterId;

  @override
  ConsumerState<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends ConsumerState<SkillsTab>
    with AutomaticKeepAliveClientMixin {
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

  Future<void> _openDisplaySettings(SkillDisplayPreferences preferences) async {
    final updated = await showModalBottomSheet<SkillDisplayPreferences>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SkillDisplaySettingsSheet(initial: preferences),
    );
    if (updated == null || !mounted) return;
    await ref
        .read(characterDetailProvider(widget.characterId).notifier)
        .updateSkillDisplayPreferences(updated);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;
    final preferences = widget.preferences;
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
    final sections = _buildSkillSections(
      rows: rows,
      preferences: preferences,
      abilityLabels: abilityLabels,
      l10n: l10n,
      i18n: i18n,
      scheme: scheme,
    );

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            key: PageStorageKey('skills-${widget.characterId}'),
            slivers: [
              for (final section in sections) ...[
                SliverToBoxAdapter(
                  child: DetailSectionHeader(
                    title: section.title,
                    icon: section.icon,
                    accentColor: section.accentColor,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  sliver: SliverList.separated(
                    itemCount: section.rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final row = section.rows[index];
                      return _SkillCard(
                        row: row,
                        label: i18n.skillName(row.skillName),
                        accentColor: section.accentColor,
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
            bottom: MediaQuery.paddingOf(context).bottom + 88,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _showEditHint
                  ? _SkillsHintToast(
                      key: const ValueKey('skills-hint-toast'),
                      label: l10n.skillsEditHint,
                      onDismiss: _dismissHint,
                    )
                  : const SizedBox.shrink(key: ValueKey('skills-hint-hidden')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDisplaySettings(preferences),
        tooltip: l10n.skillsOrganizeTooltip,
        child: const Icon(Icons.tune_outlined),
      ),
    );
  }

  List<_SkillSection> _buildSkillSections({
    required List<SkillRowVm> rows,
    required SkillDisplayPreferences preferences,
    required Map<String, String> abilityLabels,
    required AppLocalizations l10n,
    required SrdI18nService i18n,
    required ColorScheme scheme,
  }) {
    switch (preferences.mode) {
      case SkillDisplayMode.byAbility:
        final grouped = <String, List<SkillRowVm>>{};
        for (final row in rows) {
          grouped.putIfAbsent(row.ability, () => []).add(row);
        }
        final abilityOrder = preferences.abilityOrder;
        final orderedAbilities = [
          for (final ability in abilityOrder)
            if (grouped.containsKey(ability)) ability,
          for (final ability in grouped.keys)
            if (!abilityOrder.contains(ability)) ability,
        ];
        return [
          for (final ability in orderedAbilities)
            _SkillSection(
              title: abilityLabels[ability] ?? ability,
              icon: _abilityIcon(ability),
              accentColor: _abilityColor(scheme, ability),
              rows: _orderedGroupRows(
                grouped[ability]!,
                i18n,
                proficientFirst: preferences.proficientFirstInsideGroups,
              ),
            ),
        ];
      case SkillDisplayMode.proficiencyFirst:
        final proficient = rows.where((row) => row.isProficient).toList()
          ..sort((a, b) => _compareByProficiencyThenLabel(a, b, i18n));
        final other = rows.where((row) => !row.isProficient).toList()
          ..sort((a, b) => _compareBySkillLabel(a, b, i18n));
        return [
          if (proficient.isNotEmpty)
            _SkillSection(
              title: l10n.skillsDisplayProficientSection,
              icon: Icons.verified_outlined,
              accentColor: scheme.primary,
              rows: proficient,
            ),
          if (other.isNotEmpty)
            _SkillSection(
              title: l10n.skillsDisplayOtherSection,
              icon: Icons.circle_outlined,
              accentColor: scheme.outline,
              rows: other,
            ),
        ];
      case SkillDisplayMode.alphabetical:
        final sorted = [...rows]
          ..sort((a, b) => _compareBySkillLabel(a, b, i18n));
        return [
          _SkillSection(
            title: l10n.skillsDisplayAllSection,
            icon: Icons.sort_by_alpha,
            accentColor: scheme.primary,
            rows: sorted,
          ),
        ];
    }
  }

  List<SkillRowVm> _orderedGroupRows(
    List<SkillRowVm> rows,
    SrdI18nService i18n, {
    required bool proficientFirst,
  }) {
    if (!proficientFirst) return rows;
    return [...rows]
      ..sort((a, b) => _compareByProficiencyThenLabel(a, b, i18n));
  }

  int _compareByProficiencyThenLabel(
    SkillRowVm a,
    SkillRowVm b,
    SrdI18nService i18n,
  ) {
    final byRank = _skillProficiencyRank(a).compareTo(_skillProficiencyRank(b));
    if (byRank != 0) return byRank;
    return _compareBySkillLabel(a, b, i18n);
  }

  int _compareBySkillLabel(SkillRowVm a, SkillRowVm b, SrdI18nService i18n) {
    return i18n
        .skillName(a.skillName)
        .toLowerCase()
        .compareTo(i18n.skillName(b.skillName).toLowerCase());
  }

  int _skillProficiencyRank(SkillRowVm row) {
    if (row.isExpert) return 0;
    if (row.isProficient) return 1;
    return 2;
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

class _SkillSection {
  const _SkillSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final List<SkillRowVm> rows;
}

class _SkillDisplaySettingsSheet extends StatefulWidget {
  const _SkillDisplaySettingsSheet({required this.initial});

  final SkillDisplayPreferences initial;

  @override
  State<_SkillDisplaySettingsSheet> createState() =>
      _SkillDisplaySettingsSheetState();
}

class _SkillDisplaySettingsSheetState
    extends State<_SkillDisplaySettingsSheet> {
  late SkillDisplayMode _mode;
  late List<String> _abilityOrder;
  late bool _proficientFirstInsideGroups;

  @override
  void initState() {
    super.initState();
    _mode = widget.initial.mode;
    _abilityOrder = [...widget.initial.abilityOrder];
    _proficientFirstInsideGroups = widget.initial.proficientFirstInsideGroups;
  }

  void _restoreDefault() {
    const defaults = SkillDisplayPreferences();
    setState(() {
      _mode = defaults.mode;
      _abilityOrder = [...defaults.abilityOrder];
      _proficientFirstInsideGroups = defaults.proficientFirstInsideGroups;
    });
  }

  void _save() {
    Navigator.pop(
      context,
      SkillDisplayPreferences(
        mode: _mode,
        abilityOrder: _abilityOrder,
        proficientFirstInsideGroups: _proficientFirstInsideGroups,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final bottomPadding =
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom +
        16;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.skillsDisplayTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.skillsDisplayModeLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            _modeTile(
              l10n.skillsDisplayByAbility,
              Icons.view_agenda_outlined,
              SkillDisplayMode.byAbility,
            ),
            const SizedBox(height: 8),
            _modeTile(
              l10n.skillsDisplayProficiencyFirst,
              Icons.verified_outlined,
              SkillDisplayMode.proficiencyFirst,
            ),
            const SizedBox(height: 8),
            _modeTile(
              l10n.skillsDisplayAlphabetical,
              Icons.sort_by_alpha,
              SkillDisplayMode.alphabetical,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _mode == SkillDisplayMode.byAbility
                  ? Column(
                      key: const ValueKey('ability-order'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 18),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.skillsDisplayProficientFirstInsideGroups,
                          ),
                          value: _proficientFirstInsideGroups,
                          onChanged: (value) => setState(
                            () => _proficientFirstInsideGroups = value,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.skillsDisplayAbilityOrder,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: _abilityOrder.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final ability = _abilityOrder.removeAt(oldIndex);
                              _abilityOrder.insert(newIndex, ability);
                            });
                          },
                          itemBuilder: (context, index) {
                            final ability = _abilityOrder[index];
                            return Card(
                              key: ValueKey(ability),
                              elevation: 0,
                              color: scheme.surfaceContainerLow,
                              child: ListTile(
                                title: Text(_abilityFullLabel(l10n, ability)),
                                trailing: ReorderableDragStartListener(
                                  index: index,
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('ability-order-hidden'),
                    ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: _restoreDefault,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(l10n.skillsDisplayRestoreDefault),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.dialogCancel),
                ),
                FilledButton(onPressed: _save, child: Text(l10n.dialogSave)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeTile(String label, IconData icon, SkillDisplayMode mode) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _mode == mode;
    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.48)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _mode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.48)
                  : scheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? scheme.primary : scheme.outline),
              const SizedBox(width: 12),
              Expanded(child: Text(label)),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? scheme.primary : scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
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
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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

String _abilityFullLabel(AppLocalizations l10n, String ability) {
  return switch (ability) {
    'Strength' => l10n.abilityStrength,
    'Dexterity' => l10n.abilityDexterity,
    'Constitution' => l10n.abilityConstitution,
    'Intelligence' => l10n.abilityIntelligence,
    'Wisdom' => l10n.abilityWisdom,
    'Charisma' => l10n.abilityCharisma,
    _ => ability,
  };
}
