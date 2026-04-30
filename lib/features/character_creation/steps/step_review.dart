import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../character_draft_provider.dart';

class StepReview extends ConsumerWidget {
  const StepReview({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(characterDraftProvider);
    final attrs = draft.finalAttributes;
    final con = attrs['Constitution'] ?? 10;
    final conMod = ((con - 10) / 2).floor();
    final hitDie = draft.selectedClass?.hitDie ?? 8;
    final maxHp = hitDie + conMod;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReviewSection(title: 'Identity', children: [
          _Row('Name', draft.name.isEmpty ? 'Unnamed Hero' : draft.name),
          if (draft.playerName.isNotEmpty)
            _Row('Player', draft.playerName),
        ]),
        _ReviewSection(title: 'Class', children: [
          _Row('Class', draft.selectedClass?.name ?? '—'),
          _Row('Hit Die', 'd${draft.selectedClass?.hitDie ?? '—'}'),
          _Row(
            'Saving Throws',
            draft.selectedClass?.savingThrows.join(', ') ?? '—',
          ),
        ]),
        _ReviewSection(title: 'Race', children: [
          _Row('Race', draft.selectedRace?.name ?? '—'),
          if (draft.selectedSubrace != null)
            _Row('Subrace', draft.selectedSubrace!.name),
          _Row('Speed', '${draft.selectedRace?.speed ?? 0} ft'),
        ]),
        _ReviewSection(title: 'Background', children: [
          _Row('Background', draft.selectedBackground?.name ?? '—'),
          _Row(
            'Feature',
            draft.selectedBackground?.feature.name ?? '—',
          ),
        ]),
        _ReviewSection(title: 'Skills', children: [
          _Row('From background', draft.grantedSkills.join(', ')),
          if (draft.chosenSkills.isNotEmpty)
            _Row('Class choices', draft.chosenSkills.join(', ')),
        ]),
        _ReviewSection(title: 'Attributes', children: [
          ...attrs.entries
              .map((e) => _Row(e.key, '${e.value} (${_mod(e.value)})')),
          _Row('Max HP', '$maxHp  (d$hitDie + $conMod CON)'),
          _Row('AC', '${10 + ((attrs['Dexterity'] ?? 10) - 10) ~/ 2}'),
          _Row('Proficiency Bonus', '+2'),
        ]),
        const SizedBox(height: 16),
      ],
    );
  }

  String _mod(int score) {
    final m = ((score - 10) / 2).floor();
    return m >= 0 ? '+$m' : '$m';
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
