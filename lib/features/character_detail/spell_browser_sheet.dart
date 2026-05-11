import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/srd/srd_data_source.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../shared/providers/providers.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/models/spell.dart';

// ── Spell Browser Sheet ───────────────────────────────────────────────────────

/// Full-featured spell browser shown as a draggable modal bottom sheet.
///
/// Filters: "my class only" toggle, level, school, casting time.
/// Tapping a row opens [SpellDetailSheet]; the + button adds immediately.
class SpellBrowserSheet extends ConsumerStatefulWidget {
  const SpellBrowserSheet({
    super.key,
    required this.characterClass,
    required this.maxSpellLevel,
    required this.knownSpells,
    required this.onAddSpell,
    this.onRemoveSpell,
    this.isPrepareAll = false,
    this.onTogglePrepared,
  });

  final String characterClass;

  /// Highest spell slot level the character can cast (from SpellcastingEngine).
  final int maxSpellLevel;

  /// Snapshot of spells already on the character at open time.
  final List<KnownSpell> knownSpells;

  /// Called when the user adds a spell. The parent is responsible for
  /// persisting the change via the provider.
  final void Function(SrdSpell) onAddSpell;

  /// Called when the user removes a spell from within the browser.
  final void Function(String spellName)? onRemoveSpell;

  /// True for Cleric, Druid, Paladin, Artificer — the class spell list is shown
  /// dynamically; the browser is used for extras only.
  final bool isPrepareAll;

  /// For prepare-all: toggles prepared state for a class-list spell.
  final void Function(String spellName, bool prepare)? onTogglePrepared;

  @override
  ConsumerState<SpellBrowserSheet> createState() => _SpellBrowserSheetState();
}

// ── Filter state (extracted so the panel sheet can mutate it) ────────────────

class _SpellFilters {
  int? level;
  String? school;
  String? castingType; // 'action' | 'bonus_action' | 'reaction' | 'longer'
  bool concentration = false;
  bool ritual = false;

  /// Selected class names. Empty = all classes shown.
  Set<String> classes = {};

  /// When true, spells above the character's current max slot level are shown.
  bool showAllLevels = false;

  /// Number of active filters for the badge (classes counts as 1 if non-empty).
  int get activeCount =>
      (level != null ? 1 : 0) +
      (school != null ? 1 : 0) +
      (castingType != null ? 1 : 0) +
      (concentration ? 1 : 0) +
      (ritual ? 1 : 0) +
      (classes.isNotEmpty ? 1 : 0) +
      (showAllLevels ? 1 : 0);

  void reset() {
    level = null;
    school = null;
    castingType = null;
    concentration = false;
    ritual = false;
    classes = {};
    showAllLevels = false;
  }

  _SpellFilters clone() => _SpellFilters()
    ..level = level
    ..school = school
    ..castingType = castingType
    ..concentration = concentration
    ..ritual = ritual
    ..classes = Set.of(classes)
    ..showAllLevels = showAllLevels;
}

// ── State ─────────────────────────────────────────────────────────────────────

class _SpellBrowserSheetState extends ConsumerState<SpellBrowserSheet> {
  List<SrdSpell>? _allSpells;
  final _searchCtrl = TextEditingController();
  String _search = '';
  final _filters = _SpellFilters();

  /// True when the header chip is showing "my class only" (shortcut).
  bool get _myClassOnly =>
      _filters.classes.length == 1 &&
      _filters.classes.first.toLowerCase() ==
          widget.characterClass.toLowerCase();

  late Set<String> _knownNames;

  /// For prepare-all: all spell names in the class list (already "known" by rule).
  Set<String> _classSpellNames = {};

  /// For prepare-all: names of spells currently prepared.
  late Set<String> _preparedNames;

  @override
  void initState() {
    super.initState();
    _knownNames = {for (final s in widget.knownSpells) s.name.toLowerCase()};
    _preparedNames = {
      for (final s in widget.knownSpells)
        if (s.isPrepared) s.name.toLowerCase()
    };
    // Pre-select the character's class as default filter.
    _filters.classes = {widget.characterClass.toLowerCase()};
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
    if (mounted) {
      setState(() {
        _allSpells = all;
        if (widget.isPrepareAll) {
          final cls = widget.characterClass.toLowerCase();
          _classSpellNames = {
            for (final s in all)
              if (s.classes.contains(cls) && s.level > 0) s.name.toLowerCase()
          };
        }
      });
    }
  }

  List<SrdSpell> get _filtered {
    if (_allSpells == null) return const [];
    final query = _search.toLowerCase();
    final longer = {'minute', 'hour', 'special'};

    return _allSpells!.where((s) {
      if (!_filters.showAllLevels && s.level > widget.maxSpellLevel) {
        return false;
      }
      if (_filters.classes.isNotEmpty &&
          !s.classes.any((c) => _filters.classes.contains(c.toLowerCase()))) {
        return false;
      }
      if (_filters.level != null && s.level != _filters.level) return false;
      if (_filters.school != null &&
          s.school.toLowerCase() != _filters.school!.toLowerCase()) {
        return false;
      }
      if (_filters.castingType != null) {
        if (_filters.castingType == 'longer') {
          if (!longer.contains(s.castingTimeType)) return false;
        } else {
          if (s.castingTimeType != _filters.castingType) return false;
        }
      }
      if (_filters.concentration && !s.concentration) return false;
      if (_filters.ritual && !s.ritual) return false;
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

  void _removeSpell(SrdSpell spell) {
    widget.onRemoveSpell?.call(spell.name);
    setState(() => _knownNames.remove(spell.name.toLowerCase()));
  }

  void _togglePrepared(SrdSpell spell, bool prepare) {
    widget.onTogglePrepared?.call(spell.name, prepare);
    setState(() {
      if (prepare) {
        _preparedNames.add(spell.name.toLowerCase());
      } else {
        _preparedNames.remove(spell.name.toLowerCase());
      }
    });
  }

  void _openDetail(SrdSpell spell) {
    final nameLower = spell.name.toLowerCase();
    final isClassSpell = widget.isPrepareAll && _classSpellNames.contains(nameLower);
    final isPrepared = _preparedNames.contains(nameLower);
    final isKnown = isClassSpell || _knownNames.contains(nameLower);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SpellDetailSheet(
        spell: spell,
        isKnown: isKnown,
        isClassSpell: isClassSpell,
        isPrepared: isPrepared,
        onAdd: isKnown
            ? null
            : () {
                _addSpell(spell);
                Navigator.pop(context);
              },
        onRemove: (!isClassSpell && isKnown && widget.onRemoveSpell != null)
            ? () => _removeSpell(spell)
            : null,
        onTogglePrepared: isClassSpell
            ? () => _togglePrepared(spell, !isPrepared)
            : null,
      ),
    );
  }

  Future<void> _openFilterPanel() async {
    // Pass a clone so the panel can Cancel without mutating state.
    final draft = _filters.clone();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FilterPanelSheet(
        filters: draft,
        maxSpellLevel: widget.maxSpellLevel,
        characterClass: widget.characterClass,
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        _filters.level = draft.level;
        _filters.school = draft.school;
        _filters.castingType = draft.castingType;
        _filters.concentration = draft.concentration;
        _filters.ritual = draft.ritual;
        _filters.classes = draft.classes;
        _filters.showAllLevels = draft.showAllLevels;
      });
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final scheme = Theme.of(context).colorScheme;
    final filtered = _filtered;
    final isLoading = _allSpells == null;
    final activeFilters = _filters.activeCount;

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
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
            child: Row(
              children: [
                Text(
                  'Browse Spells',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                // Filter button with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: activeFilters > 0 ? scheme.primary : null,
                      ),
                      tooltip: 'Filters',
                      onPressed: _openFilterPanel,
                    ),
                    if (activeFilters > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$activeFilters',
                              style: TextStyle(
                                color: scheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Search + class chip ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(_capitalize(widget.characterClass)),
                  selected: _myClassOnly,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _filters.classes = {widget.characterClass.toLowerCase()};
                    } else {
                      _filters.classes = {};
                    }
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ── Active filter summary ──────────────────────────────────────────
          if (activeFilters > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _filterSummary(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _filters.reset()),
                    child: Text(
                      'Clear all',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Result count ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                        padding: EdgeInsets.fromLTRB(8, 0, 8, MediaQuery.of(context).viewPadding.bottom),
                        itemBuilder: (_, i) {
                          final spell = filtered[i];
                          final nameLower = spell.name.toLowerCase();
                          final isClassSpell = widget.isPrepareAll &&
                              _classSpellNames.contains(nameLower);
                          final isPrepared = _preparedNames.contains(nameLower);
                          final isKnown = isClassSpell ||
                              _knownNames.contains(nameLower);
                          return _SpellBrowserTile(
                            spell: spell,
                            displayName: i18n.spellName(spell.name),
                            isKnown: isKnown,
                            isClassSpell: isClassSpell,
                            isPrepared: isPrepared,
                            onTap: () => _openDetail(spell),
                            onAdd: isKnown ? null : () => _addSpell(spell),
                            onTogglePrepared: isClassSpell
                                ? () => _togglePrepared(spell, !isPrepared)
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _filterSummary() {
    final parts = <String>[];
    if (_filters.level != null) {
      parts.add(_filters.level == 0 ? 'Cantrip' : 'Lvl ${_filters.level}');
    }
    if (_filters.school != null) parts.add(_filters.school!);
    if (_filters.castingType != null) {
      const labels = {
        'action': 'Action',
        'bonus_action': 'Bonus action',
        'reaction': 'Reaction',
        'longer': 'Longer cast',
      };
      parts.add(labels[_filters.castingType] ?? _filters.castingType!);
    }
    if (_filters.concentration) parts.add('Concentration');
    if (_filters.ritual) parts.add('Ritual');
    if (_filters.showAllLevels) parts.add('All levels');
    if (_filters.classes.isNotEmpty) {
      parts.add(_filters.classes
          .map((c) => c[0].toUpperCase() + c.substring(1))
          .join(', '));
    }
    return parts.join(' · ');
  }
}

// ── Filter Panel Sheet ────────────────────────────────────────────────────────

/// Editable filter panel. Mutates [filters] in-place; returns true on Apply.
class _FilterPanelSheet extends StatefulWidget {
  const _FilterPanelSheet({
    required this.filters,
    required this.maxSpellLevel,
    required this.characterClass,
  });

  final _SpellFilters filters;
  final int maxSpellLevel;
  final String characterClass;

  @override
  State<_FilterPanelSheet> createState() => _FilterPanelSheetState();
}

class _FilterPanelSheetState extends State<_FilterPanelSheet> {
  static const _schools = [
    'Evocation', 'Abjuration', 'Conjuration', 'Divination',
    'Enchantment', 'Illusion', 'Necromancy', 'Transmutation',
  ];

  static const _castingOptions = <(String, String)>[
    ('action', 'Action'),
    ('bonus_action', 'Bonus action'),
    ('reaction', 'Reaction'),
    ('longer', 'Longer cast (1 min+)'),
  ];

  static const _allClasses = [
    'bard', 'cleric', 'druid', 'paladin', 'ranger',
    'sorcerer', 'warlock', 'wizard', 'artificer',
  ];

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final f = widget.filters;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Column(
          children: [
            // Handle
            Padding(
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

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
              child: Row(
                children: [
                  Text('Filters',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => f.reset()),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable body
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewPadding.bottom),
                children: [
                  // ── Classes ──────────────────────────────────────────────
                  _SectionLabel('Classes'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final cls in _allClasses)
                        FilterChip(
                          label: Text(_cap(cls)),
                          selected: f.classes.contains(cls),
                          onSelected: (v) => setState(() {
                            if (v) {
                              f.classes = {...f.classes, cls};
                            } else {
                              f.classes = f.classes
                                  .where((c) => c != cls)
                                  .toSet();
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No class selected = show all classes',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // ── Level ────────────────────────────────────────────────
                  _SectionLabel('Spell Level'),
                  SwitchListTile(
                    title: const Text('Show all spell levels'),
                    subtitle: Text(
                      'Include spells above your current max '
                      '(Lvl ${widget.maxSpellLevel})',
                    ),
                    value: f.showAllLevels,
                    onChanged: (v) => setState(() => f.showAllLevels = v),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (int lvl = 0; lvl <= (f.showAllLevels ? 9 : widget.maxSpellLevel); lvl++)
                        ChoiceChip(
                          label: Text(lvl == 0 ? 'Cantrip' : 'Lvl $lvl'),
                          selected: f.level == lvl,
                          onSelected: (v) =>
                              setState(() => f.level = v ? lvl : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Casting time ─────────────────────────────────────────
                  _SectionLabel('Casting Time'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final opt in _castingOptions)
                        ChoiceChip(
                          label: Text(opt.$2),
                          selected: f.castingType == opt.$1,
                          onSelected: (v) => setState(
                              () => f.castingType = v ? opt.$1 : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Properties ───────────────────────────────────────────
                  _SectionLabel('Properties'),
                  CheckboxListTile(
                    title: const Text('Concentration'),
                    subtitle: const Text(
                        'Only spells that require concentration'),
                    value: f.concentration,
                    onChanged: (v) =>
                        setState(() => f.concentration = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                  CheckboxListTile(
                    title: const Text('Ritual'),
                    subtitle:
                        const Text('Only spells that can be cast as rituals'),
                    value: f.ritual,
                    onChanged: (v) => setState(() => f.ritual = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                  const SizedBox(height: 16),

                  // ── School ───────────────────────────────────────────────
                  _SectionLabel('School of Magic'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final school in _schools)
                        ChoiceChip(
                          label: Text(school),
                          selected: f.school == school,
                          onSelected: (v) =>
                              setState(() => f.school = v ? school : null),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Apply button
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.of(context).viewPadding.bottom),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
}

// ── Spell Browser Tile ────────────────────────────────────────────────────────

class _SpellBrowserTile extends StatelessWidget {
  const _SpellBrowserTile({
    required this.spell,
    required this.isKnown,
    required this.onTap,
    this.isClassSpell = false,
    this.isPrepared = false,
    this.onAdd,
    this.onTogglePrepared,
    this.displayName,
  });

  final SrdSpell spell;
  final bool isKnown;
  final bool isClassSpell;
  final bool isPrepared;
  final VoidCallback onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onTogglePrepared;
  final String? displayName;

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
        displayName ?? spell.name,
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
      trailing: isClassSpell
          ? IconButton(
              icon: Icon(
                isPrepared ? Icons.check_box : Icons.check_box_outline_blank,
                color: isPrepared ? scheme.primary : scheme.outlineVariant,
              ),
              tooltip: isPrepared ? 'Unprepare' : 'Prepare',
              onPressed: onTogglePrepared,
            )
          : IconButton(
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
class SpellDetailSheet extends ConsumerWidget {
  const SpellDetailSheet({
    super.key,
    required this.spell,
    required this.isKnown,
    this.isClassSpell = false,
    this.isPrepared = false,
    this.onAdd,
    this.onRemove,
    this.onTogglePrepared,
  });

  final SrdSpell spell;
  final bool isKnown;

  /// True when this spell is already in the class list (prepare-all class).
  final bool isClassSpell;

  /// True when the spell is currently prepared.
  final bool isPrepared;

  /// Null when the spell is already on the character.
  final VoidCallback? onAdd;

  /// When provided, a discrete "Remove from spell list" button is shown.
  final VoidCallback? onRemove;

  /// For prepare-all class spells: toggles prepared state.
  final VoidCallback? onTogglePrepared;

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove spell'),
        content: Text('Remove "${spell.name}" from your spell list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Remove',
              style: TextStyle(
                  color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onRemove!();
      Navigator.pop(context);
    }
  }

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
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (_, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.of(context).viewPadding.bottom),
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
          Text(i18n.spellName(spell.name),
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
            i18n.spellDescription(spell.name) ?? spell.description,
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
                    text: i18n.spellHigherLevels(spell.name) ?? spell.higherLevels!,
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
          if (isClassSpell) ...[
            // Prepare-all class: show info + prepare/unprepare toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta magia já faz parte da lista da sua classe e não precisa ser aprendida.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (onTogglePrepared != null)
              isPrepared
                  ? OutlinedButton.icon(
                      icon: const Icon(Icons.check_box),
                      label: const Text('Preparada — toque para despreparar'),
                      onPressed: onTogglePrepared,
                    )
                  : FilledButton.icon(
                      icon: const Icon(Icons.check_box_outline_blank),
                      label: const Text('Preparar para hoje'),
                      onPressed: onTogglePrepared,
                    ),
          ] else if (!isKnown && onAdd != null)
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add to character'),
              onPressed: onAdd,
            )
          else ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.check),
              label: Text(onRemove != null
                  ? 'In your spell list — tap to remove'
                  : 'Already in your spell list'),
              onPressed:
                  onRemove != null ? () => _confirmRemove(context) : null,
            ),
          ],
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
