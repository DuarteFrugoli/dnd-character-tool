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
          if (draft.selectedSubclass != null)
            _Row(
              draft.selectedClass?.subclassFeatureName ?? 'Subclass',
              draft.selectedSubclass!.name,
            ),
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
          if (draft.fixedRaceLanguages.isNotEmpty)
            _Row('Languages', draft.fixedRaceLanguages.join(', ')),
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
        // ── Language Choices ────────────────────────────────────────────────────────
        if (draft.languageChoicesNeeded > 0)
          const _LanguageChoiceSection(),
        // ── Starting Equipment ─────────────────────────────────────────────────────
        if (draft.selectedBackground != null &&
            draft.selectedBackground!.startingEquipment.isNotEmpty)
          _StartingEquipmentSection(
            allItems: draft.selectedBackground!.startingEquipment,
            selectedItems: draft.selectedStartingEquipment,
            onToggle: (item) => ref
                .read(characterDraftProvider.notifier)
                .toggleStartingItem(item),
            onToggleAll: (selectAll) {
              final notifier =
                  ref.read(characterDraftProvider.notifier);
              if (selectAll) {
                for (final item
                    in draft.selectedBackground!.startingEquipment) {
                  if (!draft.selectedStartingEquipment.contains(item)) {
                    notifier.toggleStartingItem(item);
                  }
                }
              } else {
                for (final item
                    in draft.selectedBackground!.startingEquipment) {
                  if (draft.selectedStartingEquipment.contains(item)) {
                    notifier.toggleStartingItem(item);
                  }
                }
              }
            },
          ),
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

class _StartingEquipmentSection extends StatelessWidget {
  const _StartingEquipmentSection({
    required this.allItems,
    required this.selectedItems,
    required this.onToggle,
    required this.onToggleAll,
  });

  final List<String> allItems;
  final List<String> selectedItems;
  final void Function(String item) onToggle;
  final void Function(bool selectAll) onToggleAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final allSelected = allItems.every(selectedItems.contains);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Starting Equipment',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.primary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => onToggleAll(!allSelected),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    allSelected ? 'Deselect all' : 'Select all',
                    style: TextStyle(fontSize: 12, color: scheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Uncheck items you don\'t want to add to your inventory.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            ...allItems.map((item) {
              final isSelected = selectedItems.contains(item);
              final isGold =
                  RegExp(r'^\d+\s*gp$', caseSensitive: false).hasMatch(item.trim());
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: isSelected,
                onChanged: (_) => onToggle(item),
                title: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: isGold
                    ? Icon(Icons.monetization_on_outlined,
                        size: 16, color: scheme.tertiary)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Language Choice Section ───────────────────────────────────────────────────

const _kDndLanguages = [
  'Abyssal', 'Celestial', 'Common', 'Deep Speech', 'Draconic',
  'Dwarvish', 'Elvish', 'Giant', 'Gnomish', 'Goblin',
  'Halfling', 'Infernal', 'Orc', 'Primordial', 'Sylvan', 'Undercommon',
];

class _LanguageChoiceSection extends ConsumerStatefulWidget {
  const _LanguageChoiceSection();

  @override
  ConsumerState<_LanguageChoiceSection> createState() =>
      _LanguageChoiceSectionState();
}

class _LanguageChoiceSectionState
    extends ConsumerState<_LanguageChoiceSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(characterDraftProvider);
    final scheme = Theme.of(context).colorScheme;
    final needed = draft.languageChoicesNeeded;
    final chosen = draft.chosenLanguages;
    final canAdd = chosen.length < needed;

    void addLanguage(String lang) {
      final trimmed = lang.trim();
      if (trimmed.isEmpty || chosen.contains(trimmed)) return;
      if (chosen.length >= needed) return;
      ref
          .read(characterDraftProvider.notifier)
          .setChosenLanguages([...chosen, trimmed]);
    }

    void removeLanguage(String lang) {
      ref.read(characterDraftProvider.notifier).setChosenLanguages(
            chosen.where((l) => l != lang).toList(),
          );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Language Choices',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.primary),
                ),
                const Spacer(),
                Text(
                  '${chosen.length} / $needed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: chosen.length >= needed
                            ? scheme.primary
                            : scheme.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Choose $needed language(s) granted by your race or background.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (chosen.isNotEmpty) ...[const SizedBox(height: 8), Wrap(
              spacing: 4,
              runSpacing: 4,
              children: chosen
                  .map((lang) => Chip(
                        label: Text(lang),
                        labelStyle: const TextStyle(fontSize: 12),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        onDeleted: () => removeLanguage(lang),
                      ))
                  .toList(),
            )],
            if (canAdd) ...[const SizedBox(height: 8), Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Type a language…',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                    ),
                    onSubmitted: (v) {
                      addLanguage(v);
                      _ctrl.clear();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    addLanguage(_ctrl.text);
                    _ctrl.clear();
                  },
                ),
              ],
            ), const SizedBox(height: 8), Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _kDndLanguages
                  .where((l) =>
                      !chosen.contains(l) &&
                      !draft.fixedRaceLanguages.contains(l))
                  .map((lang) => ActionChip(
                        label: Text(lang),
                        labelStyle: const TextStyle(fontSize: 11),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 2),
                        onPressed: () => addLanguage(lang),
                      ))
                  .toList(),
            )],
          ],
        ),
      ),
    );
  }
}
