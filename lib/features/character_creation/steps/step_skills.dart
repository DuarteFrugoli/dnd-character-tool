import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/srd/srd_data_source.dart';
import '../../../data/datasources/srd/srd_models.dart';
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
    final draft = ref.watch(characterDraftProvider);
    final cls = draft.selectedClass;
    if (cls == null) return const SizedBox.shrink();

    return FutureBuilder<List<SrdSkill>>(
      future: _skillsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allSkills = snap.data ?? [];
        final granted = draft.grantedSkills;
        final needed = cls.skillChoices.count;
        final allowedPool = cls.skillChoices.isAny
            ? allSkills.map((s) => s.name).toList()
            : cls.skillChoices.from;
        final chosen = List<String>.from(draft.chosenSkills);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Choose $needed skill${needed > 1 ? 's' : ''} from your class list.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (granted.isNotEmpty) ...[
              Text('Granted by background:',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: granted
                    .map((s) => Chip(
                          label: Text(s),
                          avatar: const Icon(Icons.lock, size: 14),
                        ))
                    .toList(),
              ),
              const Divider(height: 24),
            ],
            Text('Class skill choices ($needed):',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            ...allowedPool.map((skillName) {
              final isGranted = granted.contains(skillName);
              final isChosen = chosen.contains(skillName);
              final canAdd = !isGranted &&
                  (!isChosen
                      ? chosen.length < needed
                      : true);
              final skill = allSkills
                  .where((s) => s.name == skillName)
                  .firstOrNull;

              return CheckboxListTile(
                title: Text(skillName),
                subtitle: skill != null
                    ? Text(skill.ability,
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
