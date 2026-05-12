import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_data_source.dart';
import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../shared/providers/providers.dart';
import '../character_draft_provider.dart';

class StepSkills extends ConsumerStatefulWidget {
  const StepSkills({super.key});

  @override
  ConsumerState<StepSkills> createState() => _StepSkillsState();
}

class _StepSkillsState extends ConsumerState<StepSkills> {
  late final Future<List<SrdSkill>> _skillsFuture;

  @override
  void initState() {
    super.initState();
    _skillsFuture = SrdDataSource.instance.getSkills();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(characterDraftProvider);
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final cls = draft.selectedClass;
    if (cls == null) return const SizedBox.shrink();

    return FutureBuilder<List<SrdSkill>>(
      future: _skillsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allSkills = snap.data ?? [];
        final grantedRaw = draft.grantedSkills;
        // Normalize to lowercase for case-insensitive comparison with skills.json
        final grantedLower = grantedRaw.map((s) => s.toLowerCase()).toSet();
        final needed = cls.skillChoices.count;
        final allowedPool = cls.skillChoices.isAny
            ? allSkills.map((s) => s.name).toList()
            : cls.skillChoices.from;
        final chosen = List<String>.from(draft.chosenSkills);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.stepChooseSkillsHint(needed),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (grantedRaw.isNotEmpty) ...[
              Text(l10n.stepGrantedByBackground,
                style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: grantedRaw
                    .map((s) => Chip(
                          label: Text(i18n.skillName(s)),
                          avatar: const Icon(Icons.lock, size: 14),
                        ))
                    .toList(),
              ),
              const Divider(height: 24),
            ],
            Text(l10n.stepClassSkillChoices(needed),
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            ...allowedPool.map((skillName) {
              final isGranted = grantedLower.contains(skillName.toLowerCase());
              final isChosen = chosen.contains(skillName);
              final canAdd = !isGranted &&
                  (!isChosen
                      ? chosen.length < needed
                      : true);
              final skill = allSkills
                  .where((s) => s.name == skillName)
                  .firstOrNull;

              return CheckboxListTile(
                title: Text(i18n.skillName(skillName)),
                subtitle: skill != null
                    ? Text(abilityName(l10n, skill.ability),
                        style: Theme.of(context).textTheme.bodySmall)
                    : null,
                value: isChosen || isGranted,
                onChanged: isGranted
                    ? null
                    : (v) {
                        if (v == true && canAdd) {
                          ref
                              .read(characterDraftProvider.notifier)
                              .setChosenSkills([...chosen, skillName]);
                        } else if (v == false) {
                          ref
                              .read(characterDraftProvider.notifier)
                              .setChosenSkills(
                                  chosen..remove(skillName));
                        }
                      },
                secondary: isGranted
                    ? const Icon(Icons.lock, size: 16)
                    : null,
              );
            }),
          ],
        );
      },
    );
  }
}
