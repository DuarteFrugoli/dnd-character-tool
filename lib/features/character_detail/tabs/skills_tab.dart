part of '../character_detail_screen.dart';

// ── Skills Tab ────────────────────────────────────────────────────────────────

class _SkillsTab extends ConsumerStatefulWidget {
  const _SkillsTab({
    required this.character,
    required this.characterId,
  });
  final Character character;
  final String characterId;

  @override
  ConsumerState<_SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends ConsumerState<_SkillsTab> {
  bool _isEditing = false;

  void _cycleSkill(String skillName) {
    final c = ref
        .read(characterDetailProvider(widget.characterId))
        .valueOrNull;
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
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;
    final character = widget.character;
    final abilityLabels = {
      'Strength': l10n.abilityStr,
      'Dexterity': l10n.abilityDex,
      'Constitution': l10n.abilityCon,
      'Intelligence': l10n.abilityInt,
      'Wisdom': l10n.abilityWis,
      'Charisma': l10n.abilityCha,
    };
    final scheme = Theme.of(context).colorScheme;
    final profSet =
        character.skillProficiencies.map((s) => s.toLowerCase()).toSet();
    final expertSet =
        character.skillExpertises.map((s) => s.toLowerCase()).toSet();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_isEditing)
                Row(children: [
                  Icon(Icons.touch_app_outlined, size: 14, color: scheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.skillsEditHint,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                        ),
                  ),
                ])
              else
                const SizedBox.shrink(),
              if (!_isEditing)
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(l10n.detailEditButton),
                  onPressed: () => setState(() => _isEditing = true),
                )
              else
                FilledButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: Text(l10n.dialogSave),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 192),
            itemCount: _skillAbility.length,
            itemBuilder: (context, i) {
              final skillName = _skillAbility.keys.elementAt(i);
              final ability = _skillAbility[skillName]!;
              final lower = skillName.toLowerCase();
              final isExpert = expertSet.contains(lower);
              final isProf = isExpert || profSet.contains(lower);

              final score = character.abilityScores[ability];
              final abilityMod = ((score - 10) / 2).floor();
              final bonus = abilityMod +
                  (isExpert
                      ? character.proficiencyBonus * 2
                      : isProf
                          ? character.proficiencyBonus
                          : 0);

              return ListTile(
                dense: true,
                onTap: _isEditing ? () => _cycleSkill(skillName) : null,
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
                  abilityLabels[ability] ?? ability.substring(0, 3).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                trailing: _isEditing
                    ? Icon(Icons.swap_vert, size: 16, color: scheme.outline)
                    : Text(
                        _sign(bonus),
                        style: TextStyle(
                          fontWeight:
                              isProf ? FontWeight.bold : FontWeight.normal,
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
}
