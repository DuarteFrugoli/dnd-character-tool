import 'package:flutter/material.dart';

import '../../data/datasources/srd/srd_data_source.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/models/spell.dart';

// ── Spell Browser Sheet ───────────────────────────────────────────────────────

/// Full-featured spell browser shown as a draggable modal bottom sheet.
///
/// Filters: "my class only" toggle, level, school, casting time.
/// Tapping a row opens [SpellDetailSheet]; the + button adds immediately.
class SpellBrowserSheet extends StatefulWidget {
  const SpellBrowserSheet({
    super.key,
    required this.characterClass,
    required this.maxSpellLevel,
    required this.knownSpells,
    required this.onAddSpell,
  });

  final String characterClass;

  /// Highest spell slot level the character can cast (from SpellcastingEngine).
  final int maxSpellLevel;

  /// Snapshot of spells already on the character at open time.
  final List<KnownSpell> knownSpells;

  /// Called when the user adds a spell. The parent is responsible for
  /// persisting the change via the provider.
  final void Function(SrdSpell) onAddSpell;

  @override
  State<SpellBrowserSheet> createState() => _SpellBrowserSheetState();
}

class _SpellBrowserSheetState extends State<SpellBrowserSheet> {
  List<SrdSpell>? _allSpells;
  final _searchCtrl = TextEditingController();
  String _search = '';
  int? _levelFilter;
  String? _schoolFilter;
  String? _castingFilter; // 'action' | 'bonus_action' | 'reaction' | 'longer'
  bool _concentrationFilter = false;
  bool _ritualFilter = false;
  bool _myClassOnly = true;

  /// Tracks added spells locally so the UI updates instantly without waiting
  /// for the parent's provider rebuild.
  late Set<String> _knownNames;

  static const _schools = [
    'Evocation',
    'Abjuration',
    'Conjuration',
    'Divination',
    'Enchantment',
    'Illusion',
    'Necromancy',
    'Transmutation',
  ];

  static const _castingOptions = <(String, String)>[
    ('action', 'Action'),
    ('bonus_action', 'Bonus'),
    ('reaction', 'Reaction'),
    ('longer', 'Longer'),
  ];

  @override
  void initState() {
    super.initState();
    _knownNames = {for (final s in widget.knownSpells) s.name.toLowerCase()};
    _searchCtrl.addListener(
      () => setState(() => _search = _searchCtrl.text.trim()),
    );
    _loadSpells();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSpells() async {
    final all = await SrdDataSource.instance.getSpells();
    if (mounted) setState(() => _allSpells = all);
  }

  List<SrdSpell> get _filtered {
    if (_allSpells == null) return const [];
    final className = widget.characterClass.toLowerCase();
    final query = _search.toLowerCase();
    final longer = {'minute', 'hour', 'special'};

    return _allSpells!.where((s) {
      if (s.level > widget.maxSpellLevel) return false;
      if (_myClassOnly &&
          !s.classes.any((c) => c.toLowerCase() == className)) {
        return false;
      }
      if (_levelFilter != null && s.level != _levelFilter) return false;
      if (_schoolFilter != null &&
          s.school.toLowerCase() != _schoolFilter!.toLowerCase()) {
        return false;
      }
      if (_castingFilter != null) {
        if (_castingFilter == 'longer') {
          if (!longer.contains(s.castingTimeType)) return false;
        } else {
          if (s.castingTimeType != _castingFilter) return false;
        }
      }
      if (_concentrationFilter && !s.concentration) return false;
      if (_ritualFilter && !s.ritual) return false;
      if (query.isNotEmpty && !s.name.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.level != b.level
          ? a.level.compareTo(b.level)
          : a.name.compareTo(b.name));
  }

  void _addSpell(SrdSpell spell) {
    widget.onAddSpell(spell);
    setState(() => _knownNames.add(spell.name.toLowerCase()));
  }

  void _openDetail(SrdSpell spell) {
    final isKnown = _knownNames.contains(spell.name.toLowerCase());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SpellDetailSheet(
        spell: spell,
        isKnown: isKnown,
        onAdd: isKnown
            ? null
            : () {
                _addSpell(spell);
                Navigator.pop(context);
              },
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _filtered;
    final isLoading = _allSpells == null;
    final maxLvl = widget.maxSpellLevel;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (_, scrollCtrl) => Column(
        children: [
          // ── Drag handle ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title row ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Row(
              children: [
                Text(
                  'Browse Spells',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search spells...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _searchCtrl.clear,
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Filter chips ───────────────────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // "My class" toggle
                FilterChip(
                  label: Text(_capitalize(widget.characterClass)),
                  selected: _myClassOnly,
                  onSelected: (v) => setState(() => _myClassOnly = v),
                ),
                const SizedBox(width: 6),
                const VerticalDivider(width: 1),
                const SizedBox(width: 6),
                // Level chips
                for (int lvl = 0; lvl <= maxLvl; lvl++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(lvl == 0 ? 'Cantrip' : 'Lvl $lvl'),
                      selected: _levelFilter == lvl,
                      onSelected: (v) =>
                          setState(() => _levelFilter = v ? lvl : null),
                    ),
                  ),
                const VerticalDivider(width: 1),
                const SizedBox(width: 6),
                // Casting time chips
                for (final opt in _castingOptions)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(opt.$2),
                      selected: _castingFilter == opt.$1,
                      onSelected: (v) =>
                          setState(() => _castingFilter = v ? opt.$1 : null),
                    ),
                  ),
                const VerticalDivider(width: 1),
                const SizedBox(width: 6),
                // Concentration & ritual chips
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: const Text('Conc.'),
                    selected: _concentrationFilter,
                    onSelected: (v) =>
                        setState(() => _concentrationFilter = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: const Text('Ritual'),
                    selected: _ritualFilter,
                    onSelected: (v) => setState(() => _ritualFilter = v),
                  ),
                ),
                const VerticalDivider(width: 1),
                const SizedBox(width: 6),
                // School chips
                for (final school in _schools)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(school),
                      selected: _schoolFilter == school,
                      onSelected: (v) =>
                          setState(() => _schoolFilter = v ? school : null),
                    ),
                  ),
              ],
            ),
          ),

          // ── Result count ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isLoading
                    ? 'Loading...'
                    : '${filtered.length} spell${filtered.length == 1 ? '' : 's'}',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          const Divider(height: 10),

          // ── Spell list ─────────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No spells match the current filters.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: scheme.outline),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: filtered.length,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
                        itemBuilder: (_, i) {
                          final spell = filtered[i];
                          final isKnown = _knownNames
                              .contains(spell.name.toLowerCase());
                          return _SpellBrowserTile(
                            spell: spell,
                            isKnown: isKnown,
                            onTap: () => _openDetail(spell),
                            onAdd: isKnown ? null : () => _addSpell(spell),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Spell Browser Tile ────────────────────────────────────────────────────────

class _SpellBrowserTile extends StatelessWidget {
  const _SpellBrowserTile({
    required this.spell,
    required this.isKnown,
    required this.onTap,
    this.onAdd,
  });

  final SrdSpell spell;
  final bool isKnown;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  static String _castingLabel(String type) {
    switch (type) {
      case 'bonus_action':
        return 'Bonus action';
      case 'reaction':
        return 'Reaction';
      case 'minute':
        return '1+ min';
      case 'hour':
        return '1+ hr';
      case 'special':
        return 'Special';
      default:
        return 'Action';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final levelStr = spell.level == 0 ? 'Cantrip' : 'Level ${spell.level}';
    final castStr = _castingLabel(spell.castingTimeType);

    final extras = [
      if (spell.concentration) 'C',
      if (spell.ritual) 'R',
    ].join('  ');

    return ListTile(
      title: Text(
        spell.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '$levelStr · ${spell.school} · $castStr'
        '${extras.isNotEmpty ? '  ·  $extras' : ''}',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: scheme.onSurfaceVariant),
      ),
      onTap: onTap,
      trailing: IconButton(
        icon: Icon(
          isKnown ? Icons.check_circle : Icons.add_circle_outline,
          color: scheme.primary,
        ),
        tooltip: isKnown ? null : 'Add to character',
        onPressed: isKnown ? null : onAdd,
      ),
    );
  }
}

// ── Spell Detail Sheet ────────────────────────────────────────────────────────

/// Shows full spell info. Opened from the browser or directly from a spell row.
class SpellDetailSheet extends StatelessWidget {
  const SpellDetailSheet({
    super.key,
    required this.spell,
    required this.isKnown,
    this.onAdd,
  });

  final SrdSpell spell;
  final bool isKnown;

  /// Null when the spell is already on the character.
  final VoidCallback? onAdd;

  static String _ordinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  String _componentsStr() {
    final base = spell.components.join(', ');
    if (spell.material != null) return '$base (${spell.material})';
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (_, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ── Name ─────────────────────────────────────────────────────────
          Text(spell.name,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),

          // ── Level / school ────────────────────────────────────────────────
          Text(
            spell.level == 0
                ? '${spell.school} cantrip'
                : '${_ordinal(spell.level)}-level ${spell.school.toLowerCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // ── Stat rows ─────────────────────────────────────────────────────
          _StatRow('Casting time', spell.castingTime),
          _StatRow('Range', spell.range),
          _StatRow('Duration', spell.duration),
          _StatRow('Components', _componentsStr()),
          if (spell.concentration) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: scheme.secondary),
                const SizedBox(width: 6),
                Text(
                  'Requires concentration',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
          if (spell.ritual) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.auto_fix_high, size: 14, color: scheme.tertiary),
                const SizedBox(width: 6),
                Text(
                  'Can be cast as a ritual',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // ── Description ───────────────────────────────────────────────────
          Text(
            spell.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          // ── At Higher Levels ──────────────────────────────────────────────
          if (spell.higherLevels != null) ...[
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'At Higher Levels. ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: spell.higherLevels!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          // ── Classes ───────────────────────────────────────────────────────
          const SizedBox(height: 16),
          Text(
            'Classes: ${spell.classes.join(', ')}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),

          // ── Action button ─────────────────────────────────────────────────
          const SizedBox(height: 24),
          if (!isKnown && onAdd != null)
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add to character'),
              onPressed: onAdd,
            )
          else
            OutlinedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Already in your spell list'),
              onPressed: null,
            ),
        ],
      ),
    );
  }
}

// ── Stat Row ──────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child:
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
