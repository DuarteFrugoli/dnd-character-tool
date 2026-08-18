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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Icon(Icons.touch_app_outlined, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                l10n.skillsEditHint,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: PageStorageKey('skills-${widget.characterId}'),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 192),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final row = rows[i];
              final skillName = row.skillName;
              final ability = row.ability;
              final isExpert = row.isExpert;
              final isProf = row.isProficient;

              return ListTile(
                dense: true,
                onLongPress: () => _cycleSkill(skillName),
                leading: Icon(
                  isExpert
                      ? Icons.star_rounded
                      : isProf
                      ? Icons.circle
                      : Icons.circle_outlined,
                  size: 16,
                  color: isProf ? scheme.primary : scheme.outlineVariant,
                ),
                title: Text(i18n.skillName(skillName)),
                subtitle: Text(
                  abilityLabels[ability] ??
                      ability.substring(0, 3).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                trailing: Text(
                  sign(row.bonus),
                  style: TextStyle(
                    fontWeight: isProf ? FontWeight.bold : FontWeight.normal,
                    color: isProf ? scheme.primary : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
