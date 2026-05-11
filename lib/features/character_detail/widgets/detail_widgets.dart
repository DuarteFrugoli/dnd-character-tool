part of '../character_detail_screen.dart';

// ── Shared widgets ────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 36,
      color: scheme.surfaceContainerLow,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
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
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ── Inline Edit Field ─────────────────────────────────────────────────────────

class _InlineField extends StatelessWidget {
  const _InlineField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Saving Throws Editor ──────────────────────────────────────────────────────

const _kAllAbilities = [
  'Strength', 'Dexterity', 'Constitution',
  'Intelligence', 'Wisdom', 'Charisma',
];

class _SavingThrowsEditor extends StatefulWidget {
  const _SavingThrowsEditor({
    required this.current,
    required this.notifier,
  });
  final List<String> current;
  final CharacterDetailNotifier notifier;

  @override
  State<_SavingThrowsEditor> createState() => _SavingThrowsEditorState();
}

class _SavingThrowsEditorState extends State<_SavingThrowsEditor> {
  late Set<String> _selected;

  // Normalize stored values (may be lowercase) against canonical title-case list.
  Set<String> _normalize(List<String> current) => _kAllAbilities
      .where((a) => current.any((c) => c.toLowerCase() == a.toLowerCase()))
      .toSet();

  @override
  void initState() {
    super.initState();
    _selected = _normalize(widget.current);
  }

  @override
  void didUpdateWidget(_SavingThrowsEditor old) {
    super.didUpdateWidget(old);
    if (old.current != widget.current) {
      _selected = _normalize(widget.current);
    }
  }

  void _toggle(String ability) {
    setState(() {
      if (_selected.contains(ability)) {
        _selected.remove(ability);
      } else {
        _selected.add(ability);
      }
    });
    // Preserve the canonical order (STR → CHA)
    final ordered = _kAllAbilities.where(_selected.contains).toList();
    widget.notifier.updateSavingThrows(ordered);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _kAllAbilities.map((ability) {
        final on = _selected.contains(ability);
        return FilterChip(
          label: Text(ability.substring(0, 3)),
          selected: on,
          onSelected: (_) => _toggle(ability),
        );
      }).toList(),
    );
  }
}

// ── Ability Card Edit ─────────────────────────────────────────────────────────

class _AbilityCardEdit extends StatelessWidget {
  const _AbilityCardEdit(this.abbr, this.score, this.key_,
      {required this.notifier, required this.isEditing});

  final String abbr;
  final int score;
  final String key_;
  final CharacterDetailNotifier notifier;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: isEditing ? scheme.primary : scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isEditing)
            SizedBox(
              height: 28,
              child: IconButton(
                icon: const Icon(Icons.add, size: 14),
                padding: EdgeInsets.zero,
                onPressed:
                    score < 30 ? () => notifier.updateAbilityScore(key_, score + 1) : null,
              ),
            ),
          Text(
            _mod(score),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text('$score', style: Theme.of(context).textTheme.bodySmall),
          Text(
            abbr,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: scheme.primary),
          ),
          if (isEditing)
            SizedBox(
              height: 28,
              child: IconButton(
                icon: const Icon(Icons.remove, size: 14),
                padding: EdgeInsets.zero,
                onPressed:
                    score > 1 ? () => notifier.updateAbilityScore(key_, score - 1) : null,
              ),
            ),
        ],
      ),
    );
  }
}
