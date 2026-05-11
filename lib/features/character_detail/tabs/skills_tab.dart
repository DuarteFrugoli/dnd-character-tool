part of '../character_detail_screen.dart';

// ── Skills Tab ────────────────────────────────────────────────────────────────

class _SkillsTab extends ConsumerWidget {
  const _SkillsTab({
    required this.character,
    required this.characterId,
    required this.isEditing,
  });
  final Character character;
  final String characterId;
  final bool isEditing;

  void _cycleSkill(String skillName, WidgetRef ref) {
    final c = ref.read(characterDetailProvider(characterId)).valueOrNull;
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
        .read(characterDetailProvider(characterId).notifier)
        .updateSkillProficiencies(profs, experts);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final profSet =
        character.skillProficiencies.map((s) => s.toLowerCase()).toSet();
    final expertSet =
        character.skillExpertises.map((s) => s.toLowerCase()).toSet();

    return Column(
      children: [
        if (isEditing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: scheme.primaryContainer.withAlpha(80),
            child: Row(children: [
              Icon(Icons.touch_app_outlined, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Toque para alternar: nenhum → proficiente → experiente',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                      ),
                ),
              ),
            ]),
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
                onTap: isEditing ? () => _cycleSkill(skillName, ref) : null,
                leading: Icon(
                  isExpert
                      ? Icons.star_rounded
                      : isProf
                          ? Icons.circle
                          : Icons.circle_outlined,
                  size: 16,
                  color: isProf ? scheme.primary : scheme.outlineVariant,
                ),
                title: Text(skillName),
                subtitle: Text(
                  ability.substring(0, 3).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                trailing: isEditing
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
