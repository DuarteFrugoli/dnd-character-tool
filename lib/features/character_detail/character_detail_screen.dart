import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/srd/srd_data_source.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';
import 'character_detail_provider.dart';

// ── Skill → Ability mapping ───────────────────────────────────────────────────

const _skillAbility = <String, String>{
  'Acrobatics': 'Dexterity',
  'Animal Handling': 'Wisdom',
  'Arcana': 'Intelligence',
  'Athletics': 'Strength',
  'Deception': 'Charisma',
  'History': 'Intelligence',
  'Insight': 'Wisdom',
  'Intimidation': 'Charisma',
  'Investigation': 'Intelligence',
  'Medicine': 'Wisdom',
  'Nature': 'Intelligence',
  'Perception': 'Wisdom',
  'Performance': 'Charisma',
  'Persuasion': 'Charisma',
  'Religion': 'Intelligence',
  'Sleight of Hand': 'Dexterity',
  'Stealth': 'Dexterity',
  'Survival': 'Wisdom',
};

// ── Helpers ───────────────────────────────────────────────────────────────────

String _mod(int score) {
  final m = ((score - 10) / 2).floor();
  return m >= 0 ? '+$m' : '$m';
}

String _sign(int n) => n >= 0 ? '+$n' : '$n';

// ── Screen ────────────────────────────────────────────────────────────────────

class CharacterDetailScreen extends ConsumerStatefulWidget {
  const CharacterDetailScreen({super.key, required this.characterId});
  final String characterId;

  @override
  ConsumerState<CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _goBack() => context.canPop() ? context.pop() : context.go('/');

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterDetailProvider(widget.characterId));
    return state.when(
      loading: () => Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: _goBack)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _goBack),
          title: const Text('Character'),
        ),
        body: Center(child: Text('Error loading character: $e')),
      ),
      data: _buildLoaded,
    );
  }

  Widget _buildLoaded(Character character) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _goBack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              character.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              '${character.characterClass}  ·  ${character.race}'
              '${character.subrace != null ? ' (${character.subrace})' : ''}'
              '  ·  Lv ${character.level}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bedtime_outlined),
            tooltip: 'Long Rest',
            onPressed: () => _confirmLongRest(),
          ),
          IconButton(
            icon: Icon(_editMode
                ? Icons.check_circle_outlined
                : Icons.edit_outlined),
            tooltip: _editMode ? 'Done editing' : 'Edit character',
            color: _editMode
                ? Theme.of(context).colorScheme.primary
                : null,
            onPressed: () {
              final entering = !_editMode;
              setState(() => _editMode = entering);
              if (entering) _tabs.animateTo(0);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Skills'),
            Tab(text: 'Features'),
            Tab(text: 'Spells'),
            Tab(text: 'Inventory'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _StatsTab(character: character, characterId: widget.characterId, isEditing: _editMode),
          _SkillsTab(character: character),
          _FeaturesTab(character: character, characterId: widget.characterId),
          _SpellsTab(character: character, characterId: widget.characterId),
          _InventoryTab(character: character, characterId: widget.characterId),
          _NotesTab(character: character, characterId: widget.characterId),
        ],
      ),
    );
  }

  Future<void> _confirmLongRest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Long Rest'),
        content:
            const Text('Restore HP to maximum and recover all spell slots?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rest'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .longRest();
    }
  }

}

// ── Stats Tab ─────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab({
    required this.character,
    required this.characterId,
    required this.isEditing,
  });
  final Character character;
  final String characterId;
  final bool isEditing;

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab> {
  // HP tracker
  final _amountCtrl = TextEditingController(text: '1');

  // Edit mode controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bgCtrl;
  late final TextEditingController _alignCtrl;
  late final TextEditingController _playerCtrl;
  late final TextEditingController _hpMaxCtrl;
  late final TextEditingController _speedCtrl;
  final TextEditingController _langCtrl = TextEditingController();

  // Focus nodes
  final _nameFocus = FocusNode();
  final _bgFocus = FocusNode();
  final _alignFocus = FocusNode();
  final _playerFocus = FocusNode();
  final _hpMaxFocus = FocusNode();
  final _speedFocus = FocusNode();
  final _langFocus = FocusNode();

  CharacterDetailNotifier get _notifier =>
      ref.read(characterDetailProvider(widget.characterId).notifier);

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _nameCtrl = TextEditingController(text: c.name);
    _bgCtrl = TextEditingController(text: c.background);
    _alignCtrl = TextEditingController(text: c.alignment);
    _playerCtrl = TextEditingController(text: c.playerName);
    _hpMaxCtrl = TextEditingController(text: '${c.hitPoints.maximum}');
    _speedCtrl = TextEditingController(text: '${c.speed}');

    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) _notifier.updateName(_nameCtrl.text);
    });
    _bgFocus.addListener(() {
      if (!_bgFocus.hasFocus) _notifier.updateBackground(_bgCtrl.text);
    });
    _alignFocus.addListener(() {
      if (!_alignFocus.hasFocus) _notifier.updateAlignment(_alignCtrl.text);
    });
    _playerFocus.addListener(() {
      if (!_playerFocus.hasFocus) _notifier.updatePlayerName(_playerCtrl.text);
    });
    _hpMaxFocus.addListener(() {
      if (!_hpMaxFocus.hasFocus) {
        final v = int.tryParse(_hpMaxCtrl.text);
        if (v != null) _notifier.updateHpMax(v);
      }
    });
    _speedFocus.addListener(() {
      if (!_speedFocus.hasFocus) {
        final v = int.tryParse(_speedCtrl.text);
        if (v != null) _notifier.updateSpeed(v);
      }
    });
  }

  @override
  void didUpdateWidget(_StatsTab old) {
    super.didUpdateWidget(old);
    final c = widget.character;
    if (!_nameFocus.hasFocus) _nameCtrl.text = c.name;
    if (!_bgFocus.hasFocus) _bgCtrl.text = c.background;
    if (!_alignFocus.hasFocus) _alignCtrl.text = c.alignment;
    if (!_playerFocus.hasFocus) _playerCtrl.text = c.playerName;
    if (!_hpMaxFocus.hasFocus) _hpMaxCtrl.text = '${c.hitPoints.maximum}';
    if (!_speedFocus.hasFocus) _speedCtrl.text = '${c.speed}';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _bgCtrl.dispose();
    _alignCtrl.dispose();
    _playerCtrl.dispose();
    _hpMaxCtrl.dispose();
    _speedCtrl.dispose();
    _langCtrl.dispose();
    _nameFocus.dispose();
    _bgFocus.dispose();
    _alignFocus.dispose();
    _playerFocus.dispose();
    _hpMaxFocus.dispose();
    _speedFocus.dispose();
    _langFocus.dispose();
    super.dispose();
  }

  Future<void> _showSetTempHpDialog(BuildContext context) async {
    final currentTemp = widget.character.hitPoints.temporary;
    final ctrl = TextEditingController(
      text: currentTemp > 0 ? '$currentTemp' : '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final parsed = int.tryParse(ctrl.text);
          final isValid = parsed != null &&
              parsed > 0 &&
              (currentTemp == 0 || parsed > currentTemp);
          return AlertDialog(
            title: Text(currentTemp > 0 ? 'Temporary HP' : 'Add Temporary HP'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentTemp > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Current: +$currentTemp temp HP',
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Temp HP',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setLocal(() {}),
                  onSubmitted: (_) {
                    final n = int.tryParse(ctrl.text);
                    if (n != null && n > 0 && (currentTemp == 0 || n > currentTemp)) {
                      Navigator.pop(ctx, n);
                    }
                  },
                ),
                if (currentTemp > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Temp HP doesn\'t stack — only higher values replace the current.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              if (currentTemp > 0)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 0),
                  child: const Text('Remove'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isValid ? () => Navigator.pop(ctx, parsed) : null,
                child: Text(currentTemp > 0 ? 'Replace' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
    // ctrl é variável local — não precisa de dispose manual
    if (result != null && context.mounted) {
      ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .setTemporaryHp(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
    final isEditing = widget.isEditing;
    final hp = character.hitPoints;
    final isDead = hp.isDead;
    final isFull = hp.current >= hp.maximum;
    final scheme = Theme.of(context).colorScheme;
    final notifier = _notifier;
    final equippedArmor = character.equipment
        .where((e) => e.itemType == ItemType.armor && e.isEquipped)
        .toList();
    final bodyArmor =
        equippedArmor.where((e) => e.properties?['isShield'] != true).toList();
    final usingShield =
        equippedArmor.any((e) => e.properties?['isShield'] == true);
    final armorSummary = bodyArmor.isEmpty
        ? (usingShield ? 'No armor + Shield' : 'No armor')
        : '${bodyArmor.first.name}${usingShield ? ' + Shield' : ''}';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
        children: [
          // ── Identity ──────────────────────────────────────────────────────
          _Section(
          title: 'Identity',
          child: isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineField(
                        label: 'Name',
                        controller: _nameCtrl,
                        focusNode: _nameFocus),
                    _InlineField(
                        label: 'Background',
                        controller: _bgCtrl,
                        focusNode: _bgFocus),
                    _InlineField(
                        label: 'Alignment',
                        controller: _alignCtrl,
                        focusNode: _alignFocus),
                    _InlineField(
                        label: 'Player',
                        controller: _playerCtrl,
                        focusNode: _playerFocus),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(
                              'Level',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            onPressed: character.level > 1
                                ? () => notifier
                                    .updateLevel(character.level - 1)
                                : null,
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${character.level}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            onPressed: character.level < 20
                                ? () => notifier
                                    .updateLevel(character.level + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    // Languages chips
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 96,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Languages',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: scheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (character.languages.isNotEmpty)
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: character.languages
                                        .map((lang) => Chip(
                                              label: Text(lang),
                                              labelStyle: const TextStyle(
                                                  fontSize: 12),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              onDeleted: () {
                                                final updated = List<
                                                    String>.from(
                                                  character.languages,
                                                )..remove(lang);
                                                notifier
                                                    .updateLanguages(updated);
                                              },
                                            ))
                                        .toList(),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _langCtrl,
                                        focusNode: _langFocus,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          hintText: 'Add language…',
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8),
                                        ),
                                        onSubmitted: (v) {
                                          final s = v.trim();
                                          if (s.isNotEmpty &&
                                              !character.languages.contains(
                                                  s)) {
                                            notifier.updateLanguages([
                                              ...character.languages,
                                              s,
                                            ]);
                                          }
                                          _langCtrl.clear();
                                          _langFocus.requestFocus();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton.filled(
                                      icon: const Icon(Icons.add, size: 18),
                                      tooltip: 'Add',
                                      onPressed: () {
                                        final s = _langCtrl.text.trim();
                                        if (s.isNotEmpty &&
                                            !character.languages
                                                .contains(s)) {
                                          notifier.updateLanguages([
                                            ...character.languages,
                                            s,
                                          ]);
                                        }
                                        _langCtrl.clear();
                                        _langFocus.requestFocus();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (character.subclass != null)
                      _InfoRow('Subclass', character.subclass!),
                  ],
                )
              : Column(
                  children: [
                    if (character.background.isNotEmpty)
                      _InfoRow('Background', character.background),
                    if (character.subclass != null)
                      _InfoRow('Subclass', character.subclass!),
                    if (character.alignment.isNotEmpty)
                      _InfoRow('Alignment', character.alignment),
                    if (character.playerName.isNotEmpty)
                      _InfoRow('Player', character.playerName),
                    _InfoRow(
                      'Languages',
                      character.languages.isEmpty
                          ? '—'
                          : character.languages.join(', '),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 12),

        // ── HP Tracker ────────────────────────────────────────────────────
        _Section(
          title: 'Hit Points',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${hp.current}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDead
                              ? scheme.error
                              : isFull
                                  ? scheme.primary
                                  : null,
                        ),
                  ),
                  Text(
                    ' / ${hp.maximum}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 8),
                  if (hp.temporary > 0) ...[
                    Chip(
                      label: Text('+${hp.temporary} temp'),
                      backgroundColor: scheme.tertiaryContainer,
                      labelStyle: TextStyle(color: scheme.onTertiaryContainer),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    const SizedBox(width: 4),
                  ],
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.shield_outlined, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: scheme.tertiaryContainer,
                        foregroundColor: scheme.onTertiaryContainer,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        fixedSize: const Size(32, 32),
                      ),
                      tooltip: hp.temporary > 0
                          ? 'Change temp HP'
                          : 'Add temp HP',
                      onPressed: () => _showSetTempHpDialog(context),
                    ),
                  ),
                ],
              ),
              if (isDead)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Unconscious / Dying',
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.errorContainer,
                        foregroundColor: scheme.onErrorContainer,
                      ),
                      onPressed: () {
                        final n = int.tryParse(_amountCtrl.text) ?? 0;
                        if (n > 0) {
                          ref
                              .read(characterDetailProvider(widget.characterId)
                                  .notifier)
                              .adjustHp(-n);
                        }
                      },
                      child: const Text('Damage'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                      ),
                      onPressed: () {
                        final n = int.tryParse(_amountCtrl.text) ?? 0;
                        if (n > 0) {
                          ref
                              .read(characterDetailProvider(widget.characterId)
                                  .notifier)
                              .adjustHp(n);
                        }
                      },
                      child: const Text('Heal'),
                    ),
                  ),
                ],
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                _InlineField(
                  label: 'Max HP',
                  controller: _hpMaxCtrl,
                  focusNode: _hpMaxFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Combat Stats ──────────────────────────────────────────────────
        _Section(
          title: 'Combat',
          child: isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineField(
                      label: 'Speed (ft)',
                      controller: _speedCtrl,
                      focusNode: _speedFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatChip('AC', '${character.armorClass}'),
                        _StatChip('Armor', armorSummary),
                        _StatChip(
                            'Initiative', _sign(character.initiative)),
                        _StatChip('Prof Bonus',
                            _sign(character.proficiencyBonus)),
                        _StatChip('Passive Perc',
                            '${character.passivePerception}'),
                      ],
                    ),
                  ],
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatChip('AC', '${character.armorClass}'),
                    _StatChip('Armor', armorSummary),
                    _StatChip('Speed', '${character.speed} ft'),
                    _StatChip('Initiative', _sign(character.initiative)),
                    _StatChip(
                        'Prof Bonus', _sign(character.proficiencyBonus)),
                    _StatChip(
                        'Passive Perc', '${character.passivePerception}'),
                  ],
                ),
        ),
        const SizedBox(height: 12),

        // ── Ability Scores ────────────────────────────────────────────────
        _Section(
          title: 'Ability Scores',
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isEditing ? 0.75 : 1.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _AbilityCardEdit('STR', character.abilityScores.strength,
                  'strength', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit('DEX', character.abilityScores.dexterity,
                  'dexterity', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit('CON', character.abilityScores.constitution,
                  'constitution', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit('INT', character.abilityScores.intelligence,
                  'intelligence', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit('WIS', character.abilityScores.wisdom,
                  'wisdom', notifier: notifier, isEditing: isEditing),
              _AbilityCardEdit('CHA', character.abilityScores.charisma,
                  'charisma', notifier: notifier, isEditing: isEditing),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Saving Throws ─────────────────────────────────────────────────
        if (character.savingThrowProficiencies.isNotEmpty)
          _Section(
            title: 'Saving Throw Proficiencies',
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: character.savingThrowProficiencies
                  .map((s) => Chip(label: Text(s)))
                  .toList(),
            ),
          ),
      ],
      ),
    );
  }
}

// ── Skills Tab ────────────────────────────────────────────────────────────────

class _SkillsTab extends StatelessWidget {
  const _SkillsTab({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profSet =
        character.skillProficiencies.map((s) => s.toLowerCase()).toSet();
    final expertSet =
        character.skillExpertises.map((s) => s.toLowerCase()).toSet();

    return ListView.builder(
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
          trailing: Text(
            _sign(bonus),
            style: TextStyle(
              fontWeight: isProf ? FontWeight.bold : FontWeight.normal,
              color: isProf ? scheme.primary : null,
            ),
          ),
        );
      },
    );
  }
}

// ── Features Tab ──────────────────────────────────────────────────────────────

class _FeaturesTab extends ConsumerStatefulWidget {
  const _FeaturesTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  ConsumerState<_FeaturesTab> createState() => _FeaturesTabState();
}

class _FeaturesTabState extends ConsumerState<_FeaturesTab> {
  late Future<_FeaturesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_FeaturesData> _load() async {
    final srd = SrdDataSource.instance;
    final subclassName = widget.character.subclass ?? '';
    final results = await Future.wait([
      srd.getClassFeatures(widget.character.characterClass),
      srd.getRaces(),
      srd.getBackgrounds(),
      srd.getRaceTraits(),
      srd.getSubclassFeatures(widget.character.characterClass, subclassName),
    ]);
    final classFeatures = results[0] as List<SrdClassFeature>;
    final races = results[1] as List<SrdRace>;
    final backgrounds = results[2] as List<SrdBackground>;
    final traitDescriptions = results[3] as Map<String, String>;
    final subclassFeatures = results[4] as List<SrdClassFeature>;

    final race =
        races.where((r) => r.name == widget.character.race).firstOrNull;
    final subrace = race?.subraces
        .where((s) => s.name == widget.character.subrace)
        .firstOrNull;
    final bg = backgrounds
        .where((b) => b.name == widget.character.background)
        .firstOrNull;

    return _FeaturesData(
      classFeatures: classFeatures
          .where((f) => f.level <= widget.character.level)
          .toList(),
      raceTraits: race?.traits ?? [],
      subraceTraits: subrace?.traits ?? [],
      traitDescriptions: traitDescriptions,
      backgroundFeatureName: bg?.feature.name,
      backgroundFeatureDescription: bg?.feature.description,
      subclassName: subclassName,
      subclassFeatures: subclassFeatures
          .where((f) => f.level <= widget.character.level)
          .toList(),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddFeatureSheet(characterId: widget.characterId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final extraFeatures = widget.character.extraFeatures;
    return FutureBuilder<_FeaturesData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || !snap.hasData) {
          return const Center(child: Text('Erro ao carregar features.'));
        }
        final data = snap.data!;
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
            children: [
              _RacialTraitsSection(
                raceName: widget.character.race,
                subraceName: widget.character.subrace,
                raceTraits: data.raceTraits,
                subraceTraits: data.subraceTraits,
                traitDescriptions: data.traitDescriptions,
              ),
              if (data.backgroundFeatureName != null) ...[
                const SizedBox(height: 24),
                _BackgroundFeatureSection(
                  backgroundName: widget.character.background,
                  featureName: data.backgroundFeatureName!,
                  featureDescription: data.backgroundFeatureDescription ?? '',
                ),
              ],
              const SizedBox(height: 24),
              _ClassFeaturesSection(
                className: widget.character.characterClass,
                features: data.classFeatures,
              ),
              if (data.subclassFeatures.isNotEmpty) ...[const SizedBox(height: 24), _SubclassFeaturesSection(subclassName: data.subclassName, features: data.subclassFeatures)],
              if (extraFeatures.isNotEmpty) ...[
                const SizedBox(height: 24),
                _ExtraFeaturesSection(
                  features: extraFeatures,
                  characterId: widget.characterId,
                ),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAddSheet,
            tooltip: 'Adicionar feature',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _FeaturesData {
  final List<SrdClassFeature> classFeatures;
  final List<String> raceTraits;
  final List<String> subraceTraits;
  final Map<String, String> traitDescriptions;
  final String? backgroundFeatureName;
  final String? backgroundFeatureDescription;
  final String subclassName;
  final List<SrdClassFeature> subclassFeatures;

  const _FeaturesData({
    required this.classFeatures,
    required this.raceTraits,
    required this.subraceTraits,
    required this.traitDescriptions,
    this.backgroundFeatureName,
    this.backgroundFeatureDescription,
    required this.subclassName,
    required this.subclassFeatures,
  });
}

class _RacialTraitsSection extends StatelessWidget {
  const _RacialTraitsSection({
    required this.raceName,
    required this.subraceName,
    required this.raceTraits,
    required this.subraceTraits,
    required this.traitDescriptions,
  });

  final String raceName;
  final String? subraceName;
  final List<String> raceTraits;
  final List<String> subraceTraits;
  final Map<String, String> traitDescriptions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final allTraits = [...raceTraits, ...subraceTraits];
    if (allTraits.isEmpty) return const SizedBox.shrink();

    final title =
        subraceName != null && subraceName!.isNotEmpty ? subraceName! : raceName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Racial Traits — $title',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...allTraits.map((trait) {
          final desc = traitDescriptions[trait];
          if (desc == null || desc.isEmpty) {
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  trait,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Icon(Icons.info_outline,
                    size: 16, color: scheme.onSurfaceVariant),
              ),
            );
          }
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              title: Text(
                trait,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Text(
                  desc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _BackgroundFeatureSection extends StatelessWidget {
  const _BackgroundFeatureSection({
    required this.backgroundName,
    required this.featureName,
    required this.featureDescription,
  });

  final String backgroundName;
  final String featureName;
  final String featureDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Feature — $backgroundName',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ExpansionTile(
            title: Text(
              featureName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  featureDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExtraFeaturesSection extends ConsumerWidget {
  const _ExtraFeaturesSection({
    required this.features,
    required this.characterId,
  });

  final List<CharacterExtraFeature> features;
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final notifier =
        ref.read(characterDetailProvider(characterId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extra Features',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...features.map((f) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        f.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f.sourceClass,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Nível ${f.level}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: scheme.error,
                  tooltip: 'Remover',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove feature?'),
                        content: Text('"${f.name}" will be removed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: scheme.error,
                              foregroundColor: scheme.onError,
                            ),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      notifier.removeExtraFeature(f.name, f.sourceClass);
                    }
                  },
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      f.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _ClassFeaturesSection extends StatelessWidget {
  const _ClassFeaturesSection({
    required this.className,
    required this.features,
  });

  final String className;
  final List<SrdClassFeature> features;

  Color _typeColor(String type, ColorScheme scheme) {
    switch (type) {
      case 'active':
        return scheme.primary;
      case 'subclass':
        return scheme.tertiary;
      case 'asi':
        return scheme.secondary;
      default:
        return scheme.outline;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'active':
        return 'Active';
      case 'passive':
        return 'Passive';
      case 'subclass':
        return 'Subclass';
      case 'asi':
        return 'ASI';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (features.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class Features — $className',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Nenhuma feature disponível.'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class Features — $className',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...features.map((f) {
          final typeColor = _typeColor(f.type, scheme);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      f.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(30),
                      border: Border.all(color: typeColor.withAlpha(100)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _typeLabel(f.type),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    'Nível ${f.level}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (f.uses != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${f.uses!.amount}× / ${f.uses!.rechargeLabel}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.primary),
                    ),
                  ],
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    f.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Subclass Features Section ─────────────────────────────────────────────────

class _SubclassFeaturesSection extends StatelessWidget {
  const _SubclassFeaturesSection({
    required this.subclassName,
    required this.features,
  });

  final String subclassName;
  final List<SrdClassFeature> features;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subclass Features — $subclassName',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...features.map((f) {
          final typeColor =
              f.type == 'active' ? scheme.primary : scheme.outline;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      f.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(30),
                      border: Border.all(color: typeColor.withAlpha(100)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      f.type == 'active' ? 'Active' : 'Passive',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Nível ${f.level}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    f.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Add Feature Sheet ─────────────────────────────────────────────────────────

class _AddFeatureSheet extends ConsumerStatefulWidget {
  const _AddFeatureSheet({required this.characterId});
  final String characterId;

  @override
  ConsumerState<_AddFeatureSheet> createState() => _AddFeatureSheetState();
}

class _AddFeatureSheetState extends ConsumerState<_AddFeatureSheet>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  final _customNameCtrl = TextEditingController();
  final _customDescCtrl = TextEditingController();
  bool _customTypeActive = false;

  late final TabController _tabs;

  static const _tabLabels = [
    'Classe', 'Subclasse', 'Racial', 'Background', 'Custom',
  ];

  Map<String, List<SrdClassFeature>>? _allClassFeatures;
  Map<String, Map<String, List<SrdClassFeature>>>? _allSubclassFeatures;
  List<SrdRace>? _races;
  Map<String, String>? _raceTraits;
  List<SrdBackground>? _backgrounds;
  String? _loadError;

  static const _classOrder = [
    'Barbarian', 'Bard', 'Cleric', 'Druid', 'Fighter', 'Monk',
    'Paladin', 'Ranger', 'Rogue', 'Sorcerer', 'Warlock', 'Wizard',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        _search.clear();
        setState(() {});
      }
    });
    _search.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    _customNameCtrl.dispose();
    _customDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final srd = ref.read(srdDataSourceProvider);
      final results = await Future.wait([
        Future(() async {
          final map = <String, List<SrdClassFeature>>{};
          await Future.wait(_classOrder.map((cls) async {
            map[cls] = await srd.getClassFeatures(cls);
          }));
          return map;
        }),
        srd.getAllSubclassFeatures(),
        srd.getRaces(),
        srd.getRaceTraits(),
        srd.getBackgrounds(),
      ]);
      if (mounted) {
        setState(() {
          _allClassFeatures =
              results[0] as Map<String, List<SrdClassFeature>>;
          _allSubclassFeatures =
              results[1] as Map<String, Map<String, List<SrdClassFeature>>>;
          _races = results[2] as List<SrdRace>;
          _raceTraits = results[3] as Map<String, String>;
          _backgrounds = results[4] as List<SrdBackground>;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notifier =
        ref.read(characterDetailProvider(widget.characterId).notifier);
    final character =
        ref.watch(characterDetailProvider(widget.characterId)).valueOrNull;
    final existingKeys = {
      ...?character?.extraFeatures.map((f) => '${f.sourceClass}:${f.name}'),
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Add Feature',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search field (hidden on Custom tab, index 4)
          if (_tabs.index != 4)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _search.clear(),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          // TabBar
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          ),
          // Body
          Expanded(
            child: _loadError != null
                ? Center(
                    child: Text('Erro: $_loadError',
                        style: TextStyle(color: scheme.error)))
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _buildClassList(existingKeys, notifier, scheme),
                      _buildSubclassList(existingKeys, notifier, scheme),
                      _buildRacialList(existingKeys, notifier, scheme),
                      _buildBackgroundList(existingKeys, notifier, scheme),
                      _buildCustomForm(notifier, scheme, scrollCtrl),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Shared tile builder ───────────────────────────────────────────────────

  Widget _buildTile({
    required SrdClassFeature feature,
    required String sourceLabel,
    required String sourceKey,
    required Set<String> existingKeys,
    required CharacterDetailNotifier notifier,
    required ColorScheme scheme,
    String? subtitle,
  }) {
    final key = '$sourceKey:${feature.name}';
    final alreadyAdded = existingKeys.contains(key);
    return ListTile(
      title: Text(feature.name, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle ?? 'Nível ${feature.level} · ${feature.type}',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: alreadyAdded
          ? SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child:
                    Icon(Icons.check_circle, color: scheme.primary, size: 24),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: scheme.primary,
              onPressed: () async {
                await notifier.addExtraFeature(feature, sourceKey);
                if (mounted) setState(() {});
              },
            ),
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  // ── Classe tab ────────────────────────────────────────────────────────────

  Widget _buildClassList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
  ) {
    if (_allClassFeatures == null) return const Center(child: CircularProgressIndicator());
    final q = _search.text.toLowerCase();

    if (q.isNotEmpty) {
      final results = <(String, SrdClassFeature)>[];
      for (final cls in _classOrder) {
        for (final f in _allClassFeatures![cls] ?? <SrdClassFeature>[]) {
          if (f.name.toLowerCase().contains(q) ||
              f.description.toLowerCase().contains(q)) {
            results.add((cls, f));
          }
        }
      }
      if (results.isEmpty) {
        return _emptySearch(q);
      }
      return ListView(
        children: results
            .map((r) => _buildTile(
                  feature: r.$2,
                  sourceLabel: r.$1,
                  sourceKey: r.$1,
                  existingKeys: existingKeys,
                  notifier: notifier,
                  scheme: scheme,
                ))
            .toList(),
      );
    }

    final slivers = <Widget>[];
    for (final cls in _classOrder) {
      final features = _allClassFeatures![cls] ?? [];
      if (features.isEmpty) continue;
      slivers.add(SliverStickyHeader(
        header: _GroupHeader(label: cls),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _buildTile(
              feature: features[i],
              sourceLabel: cls,
              sourceKey: cls,
              existingKeys: existingKeys,
              notifier: notifier,
              scheme: scheme,
            ),
            childCount: features.length,
          ),
        ),
      ));
    }
    return CustomScrollView(slivers: slivers);
  }

  // ── Subclasse tab ─────────────────────────────────────────────────────────

  Widget _buildSubclassList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
  ) {
    if (_allSubclassFeatures == null) return const Center(child: CircularProgressIndicator());
    final q = _search.text.toLowerCase();
    final allSub = _allSubclassFeatures!;

    if (q.isNotEmpty) {
      final results = <(String, SrdClassFeature)>[];
      for (final cls in _classOrder) {
        final subMap = allSub[cls] ?? {};
        for (final subName in subMap.keys) {
          for (final f in subMap[subName]!) {
            if (f.name.toLowerCase().contains(q) ||
                f.description.toLowerCase().contains(q) ||
                subName.toLowerCase().contains(q)) {
              results.add((subName, f));
            }
          }
        }
      }
      if (results.isEmpty) return _emptySearch(q);
      return ListView(
        children: results
            .map((r) => _buildTile(
                  feature: r.$2,
                  sourceLabel: r.$1,
                  sourceKey: r.$1,
                  existingKeys: existingKeys,
                  notifier: notifier,
                  scheme: scheme,
                ))
            .toList(),
      );
    }

    final slivers = <Widget>[];
    for (final cls in _classOrder) {
      final subMap = allSub[cls];
      if (subMap == null || subMap.isEmpty) continue;
      for (final subName in subMap.keys) {
        final features = subMap[subName]!;
        if (features.isEmpty) continue;
        slivers.add(SliverStickyHeader(
          header: _GroupHeader(label: '$cls — $subName'),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildTile(
                feature: features[i],
                sourceLabel: subName,
                sourceKey: subName,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
              ),
              childCount: features.length,
            ),
          ),
        ));
      }
    }
    return CustomScrollView(slivers: slivers);
  }

  // ── Racial tab ────────────────────────────────────────────────────────────

  Widget _buildRacialList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
  ) {
    if (_races == null || _raceTraits == null) return const Center(child: CircularProgressIndicator());
    final q = _search.text.toLowerCase();
    final traitMap = _raceTraits!;

    SrdClassFeature traitToFeature(String traitName) => SrdClassFeature(
          name: traitName,
          level: 1,
          type: 'passive',
          description: traitMap[traitName] ?? '',
        );

    if (q.isNotEmpty) {
      final results = <(String, SrdClassFeature)>[];
      for (final race in _races!) {
        for (final t in race.traits) {
          final f = traitToFeature(t);
          if (t.toLowerCase().contains(q) ||
              f.description.toLowerCase().contains(q)) {
            results.add((race.name, f));
          }
        }
        for (final sub in race.subraces) {
          for (final t in sub.traits) {
            final f = traitToFeature(t);
            if (t.toLowerCase().contains(q) ||
                f.description.toLowerCase().contains(q)) {
              results.add((sub.name, f));
            }
          }
        }
      }
      if (results.isEmpty) return _emptySearch(q);
      return ListView(
        children: results
            .map((r) => _buildTile(
                  feature: r.$2,
                  sourceLabel: r.$1,
                  sourceKey: r.$1,
                  existingKeys: existingKeys,
                  notifier: notifier,
                  scheme: scheme,
                  subtitle: r.$1,
                ))
            .toList(),
      );
    }

    final slivers = <Widget>[];
    for (final race in _races!) {
      final allEntries = <(String sourceKey, SrdClassFeature)>[];
      for (final t in race.traits) {
        allEntries.add((race.name, traitToFeature(t)));
      }
      for (final sub in race.subraces) {
        for (final t in sub.traits) {
          allEntries.add((sub.name, traitToFeature(t)));
        }
      }
      if (allEntries.isEmpty) continue;

      slivers.add(SliverStickyHeader(
        header: _GroupHeader(label: race.name),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final (key, f) = allEntries[i];
              return _buildTile(
                feature: f,
                sourceLabel: key,
                sourceKey: key,
                existingKeys: existingKeys,
                notifier: notifier,
                scheme: scheme,
                subtitle: key == race.name ? race.name : '${race.name} — $key',
              );
            },
            childCount: allEntries.length,
          ),
        ),
      ));
    }
    return CustomScrollView(slivers: slivers);
  }

  // ── Custom tab ────────────────────────────────────────────────────────────

  Widget _buildCustomForm(
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
    ScrollController scrollCtrl,
  ) {
    return SingleChildScrollView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _customNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customDescCtrl,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Tipo:'),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Passive'),
                selected: !_customTypeActive,
                onSelected: (_) => setState(() => _customTypeActive = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Active'),
                selected: _customTypeActive,
                onSelected: (_) => setState(() => _customTypeActive = true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _customNameCtrl.text.trim().isEmpty
                ? null
                : () async {
                    final f = SrdClassFeature(
                      name: _customNameCtrl.text.trim(),
                      level: 1,
                      type: _customTypeActive ? 'active' : 'passive',
                      description: _customDescCtrl.text.trim(),
                    );
                    await notifier.addExtraFeature(f, 'Custom');
                    _customNameCtrl.clear();
                    _customDescCtrl.clear();
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${f.name} adicionada!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Feature'),
          ),
        ],
      ),
    );
  }

  // ── Background tab ───────────────────────────────────────────────────────

  Widget _buildBackgroundList(
    Set<String> existingKeys,
    CharacterDetailNotifier notifier,
    ColorScheme scheme,
  ) {
    if (_backgrounds == null) return const Center(child: CircularProgressIndicator());
    final q = _search.text.toLowerCase();

    SrdClassFeature bgToFeature(SrdBackground bg) => SrdClassFeature(
          name: bg.feature.name,
          level: 1,
          type: 'passive',
          description: bg.feature.description,
        );

    if (q.isNotEmpty) {
      final results = <(String, SrdClassFeature)>[];
      for (final bg in _backgrounds!) {
        final f = bgToFeature(bg);
        if (bg.name.toLowerCase().contains(q) ||
            f.name.toLowerCase().contains(q) ||
            f.description.toLowerCase().contains(q)) {
          results.add((bg.name, f));
        }
      }
      if (results.isEmpty) return _emptySearch(q);
      return ListView(
        children: results
            .map((r) => _buildTile(
                  feature: r.$2,
                  sourceLabel: r.$1,
                  sourceKey: r.$1,
                  existingKeys: existingKeys,
                  notifier: notifier,
                  scheme: scheme,
                  subtitle: r.$1,
                ))
            .toList(),
      );
    }

    final slivers = <Widget>[];
    for (final bg in _backgrounds!) {
      final f = bgToFeature(bg);
      slivers.add(SliverStickyHeader(
        header: _GroupHeader(label: bg.name),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => _buildTile(
              feature: f,
              sourceLabel: bg.name,
              sourceKey: bg.name,
              existingKeys: existingKeys,
              notifier: notifier,
              scheme: scheme,
              subtitle: bg.name,
            ),
            childCount: 1,
          ),
        ),
      ));
    }
    return CustomScrollView(slivers: slivers);
  }

  Widget _emptySearch(String q) => Center(
        child: Text(
          'Nenhuma feature encontrada para "$q"',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
}


// ── Spells Tab ────────────────────────────────────────────────────────────────

class _SpellsTab extends ConsumerWidget {
  const _SpellsTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = character.spellSlots;
    final hasSlots = slots.total.any((t) => t > 0);
    final hasSpells = character.spells.isNotEmpty;

    if (!hasSlots && !hasSpells) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_fix_high_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No spells or spell slots',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Spell slots are not assigned for this character.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
      children: [
        if (hasSlots) ...[
          Text('Spell Slots', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (int lvl = 1; lvl <= 9; lvl++)
            if (slots.total[lvl - 1] > 0)
              _SpellSlotRow(
                level: lvl,
                total: slots.total[lvl - 1],
                used: slots.used[lvl - 1],
                onUse: () => ref
                    .read(characterDetailProvider(characterId).notifier)
                    .useSpellSlot(lvl),
                onRestore: () => ref
                    .read(characterDetailProvider(characterId).notifier)
                    .restoreSpellSlot(lvl),
              ),
          const SizedBox(height: 16),
        ],
        if (hasSpells) ...[
          Text('Known Spells', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...character.spells.map(
            (spell) => ListTile(
              title: Text(spell.name),
              subtitle: Text(
                spell.level == 0
                    ? 'Cantrip'
                    : 'Level ${spell.level}'
                        '${spell.school != null ? '  ·  ${spell.school}' : ''}',
              ),
              trailing: spell.isPrepared
                  ? const Icon(Icons.check_circle_outline)
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _SpellSlotRow extends StatelessWidget {
  const _SpellSlotRow({
    required this.level,
    required this.total,
    required this.used,
    required this.onUse,
    required this.onRestore,
  });

  final int level;
  final int total;
  final int used;
  final VoidCallback onUse;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = total - used;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              'Lvl $level',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 4,
              children: List.generate(total, (i) {
                final isUsed = i >= remaining;
                return GestureDetector(
                  onTap: isUsed ? onRestore : onUse,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUsed ? null : scheme.primaryContainer,
                      border: Border.all(
                        color: isUsed ? scheme.outlineVariant : scheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Text(
            '$remaining/$total',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

// ── Notes Tab ─────────────────────────────────────────────────────────────────

class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  Future<void> _showNoteView(
    BuildContext context,
    WidgetRef ref,
    CharacterNote note,
  ) async {
    final shouldEdit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _NoteViewSheet(note: note),
    );
    if (shouldEdit == true && context.mounted) {
      _openNoteSheet(context, ref, existing: note);
    }
  }

  void _openNoteSheet(
    BuildContext context,
    WidgetRef ref, {
    CharacterNote? existing,
  }) {
    final notifier =
        ref.read(characterDetailProvider(characterId).notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _NoteEditorSheet(
        existing: existing,
        notifier: notifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final notifier =
        ref.read(characterDetailProvider(characterId).notifier);
    final notes = character.notes;

    // Dados de personagem da criação (personality, backstory, features)
    final p = character.personality;
    final hasLegacy = p.traits.isNotEmpty ||
        p.ideals.isNotEmpty ||
        p.bonds.isNotEmpty ||
        p.flaws.isNotEmpty ||
        character.backstory.isNotEmpty ||
        character.features.isNotEmpty;

    return Scaffold(
      body: notes.isEmpty && !hasLegacy
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_outlined,
                      size: 64, color: scheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first note.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
              children: [
                // ── User notes ─────────────────────────────────────────
                ...notes.map((note) => _NoteCard(
                      note: note,
                      onView: () => _showNoteView(context, ref, note),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete note?'),
                            content: note.title.isNotEmpty
                                ? Text('"${note.title}" will be permanently deleted.')
                                : const Text('This note will be permanently deleted.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) notifier.deleteNote(note.id);
                      },
                    )),

                // ── Legacy data from character creation ────────────────
                if (hasLegacy) ...[
                  if (notes.isNotEmpty) const SizedBox(height: 8),
                  if (p.traits.isNotEmpty)
                    _Section(
                        title: 'Personality Traits',
                        child: Text(p.traits)),
                  if (p.ideals.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(title: 'Ideals', child: Text(p.ideals)),
                  ],
                  if (p.bonds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(title: 'Bonds', child: Text(p.bonds)),
                  ],
                  if (p.flaws.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(title: 'Flaws', child: Text(p.flaws)),
                  ],
                  if (character.backstory.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(
                        title: 'Backstory',
                        child: Text(character.backstory)),
                  ],
                  if (character.features.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(
                      title: 'Features & Traits',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: character.features
                            .map((f) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 4),
                                  child: Text('• $f'),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteSheet(context, ref),
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Note Editor Sheet ─────────────────────────────────────────────────────────

class _NoteEditorSheet extends StatefulWidget {
  const _NoteEditorSheet({required this.notifier, this.existing});
  final CharacterDetailNotifier notifier;
  final CharacterNote? existing;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl =
        TextEditingController(text: widget.existing?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }
    if (widget.existing == null) {
      widget.notifier.addNote(CharacterNote(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
      ));
    } else {
      widget.notifier.updateNote(widget.existing!.copyWith(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    widget.existing == null ? 'New Note' : 'Edit Note',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  TextField(
                    controller: _titleCtrl,
                    autofocus: widget.existing == null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentCtrl,
                    autofocus: false,
                    maxLines: 10,
                    minLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _save,
                    child: Text(
                        widget.existing == null ? 'Add Note' : 'Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Note View Sheet ───────────────────────────────────────────────────────────

class _NoteViewSheet extends StatelessWidget {
  const _NoteViewSheet({required this.note});
  final CharacterNote note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateStr =
        '${note.createdAt.day.toString().padLeft(2, '0')}/'
        '${note.createdAt.month.toString().padLeft(2, '0')}/'
        '${note.createdAt.year}';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: note.title.isNotEmpty
                      ? Text(
                          note.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        )
                      : const SizedBox.shrink(),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit note',
                  onPressed: () => Navigator.pop(context, true),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (note.content.isNotEmpty)
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 12),
                Text(
                  dateStr,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note Card ─────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onView,
    required this.onDelete,
  });

  final CharacterNote note;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final contentStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: scheme.onSurfaceVariant);
    final dateStr =
        '${note.createdAt.day.toString().padLeft(2, '0')}/'
        '${note.createdAt.month.toString().padLeft(2, '0')}/'
        '${note.createdAt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.title.isNotEmpty)
                      Text(
                        note.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    if (note.content.isNotEmpty) ...[if (note.title.isNotEmpty) const SizedBox(height: 4),
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          const maxLines = 3;
                          final tp = TextPainter(
                            text:
                                TextSpan(text: note.content, style: contentStyle),
                            maxLines: maxLines,
                            textDirection: TextDirection.ltr,
                          )..layout(maxWidth: constraints.maxWidth);
                          final isOverflow = tp.didExceedMaxLines;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.content,
                                maxLines: maxLines,
                                overflow: TextOverflow.ellipsis,
                                style: contentStyle,
                              ),
                              if (isOverflow) ...[const SizedBox(height: 2),
                                Text(
                                  'Read more',
                                  style: Theme.of(ctx).textTheme.labelSmall
                                      ?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      dateStr,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: scheme.error,
                tooltip: 'Delete note',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Inventory Tab ────────────────────────────────────────────────────────────

class _InventoryTab extends ConsumerStatefulWidget {
  const _InventoryTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  ConsumerState<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<_InventoryTab> {
  // Moedas — controladores locais sincronizados com o modelo
  late final Map<String, TextEditingController> _currencyCtrl;

  static const _coins = ['cp', 'sp', 'ep', 'gp', 'pp'];
  static const _coinLabels = {
    'cp': 'Copper',
    'sp': 'Silver',
    'ep': 'Electrum',
    'gp': 'Gold',
    'pp': 'Platinum',
  };

  @override
  void initState() {
    super.initState();
    final currency = widget.character.currency;
    _currencyCtrl = {
      for (final c in _coins)
        c: TextEditingController(text: '${currency[c] ?? 0}')
    };
  }

  @override
  void didUpdateWidget(_InventoryTab old) {
    super.didUpdateWidget(old);
    // Atualiza controladores se os valores mudaram externamente
    final currency = widget.character.currency;
    for (final c in _coins) {
      final val = '${currency[c] ?? 0}';
      if (_currencyCtrl[c]!.text != val) {
        _currencyCtrl[c]!.text = val;
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _currencyCtrl.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _saveCurrency() {
    final map = <String, int>{
      for (final c in _coins)
        c: int.tryParse(_currencyCtrl[c]!.text) ?? 0,
    };
    ref
        .read(characterDetailProvider(widget.characterId).notifier)
        .updateCurrency(map);
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddItemSheet(characterId: widget.characterId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
    final scheme = Theme.of(context).colorScheme;
    final ammo = character.equipment
        .where((e) => e.itemType == ItemType.ammunition)
        .toList();
    final nonAmmo =
        character.equipment.where((e) => e.itemType != ItemType.ammunition);
    final equipped = nonAmmo.where((e) => e.isEquipped).toList();
    final carried = nonAmmo.where((e) => !e.isEquipped).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
        children: [
          // ── Currency ────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _coins.map((c) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: TextField(
                            controller: _currencyCtrl[c],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: _coinLabels[c],
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                            ),
                            onEditingComplete: () {
                              _saveCurrency();
                              FocusScope.of(context).unfocus();
                            },
                            onTapOutside: (_) {
                              _saveCurrency();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Ammunition ──────────────────────────────────────────────────
          if (ammo.isNotEmpty) ...[
            _AmmunitionSection(
              items: ammo,
              characterId: widget.characterId,
            ),
            const SizedBox(height: 12),
          ],

          // ── Equipped ────────────────────────────────────────────────────
          if (equipped.isNotEmpty) ...
            [
              _Section(
                title: 'Equipped (${equipped.length})  ·  AC ${character.armorClass}',
                child: Column(
                  children: equipped
                      .map((item) => _ItemTile(
                            item: item,
                            characterId: widget.characterId,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

          // ── Carried ─────────────────────────────────────────────────────
          _Section(
            title: carried.isEmpty && equipped.isEmpty && ammo.isEmpty
                ? 'Inventory'
                : 'Carried (${carried.length})',
            child: carried.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No items yet. Tap + to add.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : Column(
                    children: carried
                        .map((item) => _ItemTile(
                              item: item,
                              characterId: widget.characterId,
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<int?> _showRemoveQuantityDialog(
  BuildContext context,
  EquipmentItem item,
) async {
  if (item.quantity <= 1) {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove item?'),
        content: Text('Remove ${item.name} from inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    return confirm == true ? 1 : null;
  }

  int selected = 1;
  final qtyCtrl = TextEditingController(text: '1');

  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Remove item?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name),
            const SizedBox(height: 10),
            Text('Will remove: $selected of ${item.quantity}'),
            const SizedBox(height: 12),
            Slider(
              value: selected.toDouble(),
              min: 1,
              max: item.quantity.toDouble(),
              divisions: item.quantity > 1 ? item.quantity - 1 : null,
              label: '$selected',
              onChanged: (v) {
                final next = v.round().clamp(1, item.quantity);
                setState(() {
                  selected = next;
                  qtyCtrl.text = '$selected';
                });
              },
            ),
            const SizedBox(height: 6),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Quantity to remove',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onChanged: (text) {
                final parsed = int.tryParse(text);
                if (parsed == null) return;
                final clamped = parsed.clamp(1, item.quantity);
                if (clamped != selected) {
                  setState(() => selected = clamped);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, selected),
            child: const Text('Remove'),
          ),
        ],
      ),
    ),
  );

  qtyCtrl.dispose();
  return result;
}

// ── Ammunition Section ────────────────────────────────────────────────────────

class _AmmunitionSection extends ConsumerWidget {
  const _AmmunitionSection(
      {required this.items, required this.characterId});
  final List<EquipmentItem> items;
  final String characterId;

  Future<void> _confirmRemoveAmmo(
    BuildContext context,
    CharacterDetailNotifier notifier,
    EquipmentItem item,
  ) async {
    final amount = await _showRemoveQuantityDialog(context, item);
    if (amount != null) {
      await notifier.removeEquipmentQuantity(item.id, amount);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final notifier =
        ref.read(characterDetailProvider(characterId).notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ammunition',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.primary),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(item.name,
                            style: const TextStyle(fontSize: 14)),
                      ),
                      // Diminuir
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        onPressed: () =>
                            notifier.adjustItemQuantity(item.id, -1),
                      ),
                      // Quantidade
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Aumentar
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        onPressed: () =>
                            notifier.adjustItemQuantity(item.id, 1),
                      ),
                      // Remover
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: scheme.error,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        onPressed: () =>
                          _confirmRemoveAmmo(context, notifier, item),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Add Item Bottom Sheet ─────────────────────────────────────────────────────

class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet({required this.characterId});
  final String characterId;

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _search = TextEditingController();

  List<SrdWeapon>? _weapons;
  List<SrdArmor>? _armors;
  List<SrdGearItem>? _gear;
  List<SrdMagicItem>? _magic;
  String? _loadError;

  static const _tabLabels = ['Weapons', 'Armor', 'Gear', 'Magic', 'Custom'];

  /// Remove notação de pacote do nome: "Arrows (20)" → "Arrows"
  static String _stripPackNotation(String name) =>
      name.replaceAll(RegExp(r'\s*\(\d+\)\s*$'), '').trim();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        _search.clear();
        setState(() {});
      }
    });
    _search.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final srd = ref.read(srdDataSourceProvider);
      final results = await Future.wait([
        srd.getWeapons(),
        srd.getArmors(),
        srd.getGear(),
        srd.getMagicItems(),
      ]);
      if (mounted) {
        setState(() {
          _weapons = results[0] as List<SrdWeapon>;
          _armors = results[1] as List<SrdArmor>;
          _gear = results[2] as List<SrdGearItem>;
          _magic = results[3] as List<SrdMagicItem>;
        });
      }
    } catch (e, st) {
      debugPrint('_loadData error: $e\n$st');
      if (mounted) setState(() => _loadError = e.toString());
    }
  }

  void _addItem(EquipmentItem item) {
    ref
        .read(characterDetailProvider(widget.characterId).notifier)
        .addEquipmentItem(item);
    Navigator.pop(context);
  }

  // Mostra dialog de confirmação com quantidade antes de adicionar
  Future<void> _confirmAdd({
    required String name,
    required String category,
    required ItemType itemType,
    required String? description,
    Map<String, dynamic>? properties,
  }) async {
    final qtyCtrl = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(name),
        content: Row(
          children: [
            const Text('Quantity:'),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: TextField(
                controller: qtyCtrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _addItem(EquipmentItem(
        name: name,
        category: category,
        itemType: itemType,
        quantity: int.tryParse(qtyCtrl.text) ?? 1,
        description: description,
        properties: properties,
      ));
    }
    // qtyCtrl é variável local — não precisa de dispose manual
  }

  // Lista agrupada por categoria, com cabeçalhos. Ao pesquisar, exibe lista plana.
  Widget _buildGroupedSrdList<T>({
    required List<T>? items,
    required String Function(T) getName,
    required String Function(T) getSubtitle,
    required String Function(T) getCategory,
    required String Function(T) getGroup,
    required String? Function(T) getDescription,
    required ItemType Function(T) getItemType,
    Map<String, dynamic>? Function(T)? getProperties,
    required List<String> groupOrder,
    required Map<String, String> groupLabels,
  }) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading items:\n$_loadError',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (items == null) return const Center(child: CircularProgressIndicator());

    final q = _search.text.toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((e) => getName(e).toLowerCase().contains(q)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No results for "$q"',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    Widget buildTile(T item) => ListTile(
          title: Text(getName(item), style: const TextStyle(fontSize: 14)),
          subtitle: Text(
            getSubtitle(item),
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _confirmAdd(
              name: getName(item),
              category: getCategory(item),
              itemType: getItemType(item),
              description: getDescription(item),
              properties: getProperties?.call(item),
            ),
          ),
        );

    // Com busca activa: lista plana sem cabeçalhos.
    if (q.isNotEmpty) {
      return ListView(children: filtered.map(buildTile).toList());
    }

    // Sem busca: agrupa por categoria com cabeçalhos fixos (sticky).
    final grouped = <String, List<T>>{for (final key in groupOrder) key: []};
    for (final item in filtered) {
      final g = getGroup(item);
      (grouped[g] ??= []).add(item);
    }

    final slivers = <Widget>[];
    for (final key in groupOrder) {
      final group = grouped[key];
      if (group == null || group.isEmpty) continue;
      slivers.add(SliverStickyHeader(
        header: _GroupHeader(label: groupLabels[key] ?? key),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => buildTile(group[i]),
            childCount: group.length,
          ),
        ),
      ));
    }

    return CustomScrollView(slivers: slivers);
  }

  Widget _buildCustomTab() {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'adventuring gear');
    final qtyCtrl = TextEditingController(text: '1');
    final descCtrl = TextEditingController();
    final scheme = Theme.of(context).colorScheme;

    return StatefulBuilder(
      builder: (ctx, setInner) {
        var selectedType = ItemType.gear;

        return StatefulBuilder(
          builder: (ctx2, setType) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: false,
                  decoration: const InputDecoration(
                      labelText: 'Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ItemType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                      labelText: 'Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(
                        value: ItemType.weapon, child: Text('Weapon')),
                    DropdownMenuItem(
                        value: ItemType.armor, child: Text('Armor')),
                    DropdownMenuItem(
                        value: ItemType.consumable, child: Text('Consumable')),
                    DropdownMenuItem(
                        value: ItemType.gear, child: Text('Gear')),
                  ],
                  onChanged: (v) {
                    if (v != null) setType(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: 'Quantity', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    _addItem(EquipmentItem(
                      name: name,
                      category: categoryCtrl.text.trim().isEmpty
                          ? 'adventuring gear'
                          : categoryCtrl.text.trim(),
                      itemType: selectedType,
                      quantity: int.tryParse(qtyCtrl.text) ?? 1,
                      description: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                    ));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                  child: const Text('Add Custom Item'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCustomTab = _tabs.index == 4;

    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Add Item',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Barra de busca (oculta na aba Custom)
          if (!isCustomTab)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search ${_tabLabels[_tabs.index]}...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _search.clear(),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // Weapons
                _buildGroupedSrdList<SrdWeapon>(
                  items: _weapons,
                  getName: (w) => w.name,
                  getSubtitle: (w) =>
                      '${w.damage} ${w.damageType}  ·  ${w.cost}',
                  getCategory: (w) => w.category,
                  getGroup: (w) => w.category,
                  getDescription: (w) => w.properties.isNotEmpty
                      ? w.properties.join(', ')
                      : null,
                  getItemType: (_) => ItemType.weapon,
                  getProperties: (w) => {
                    'damageDice': w.damage,
                    'damageType': w.damageType,
                  },
                  groupOrder: const [
                    'simple melee',
                    'simple ranged',
                    'martial melee',
                    'martial ranged',
                  ],
                  groupLabels: const {
                    'simple melee': 'Simple Melee',
                    'simple ranged': 'Simple Ranged',
                    'martial melee': 'Martial Melee',
                    'martial ranged': 'Martial Ranged',
                  },
                ),
                // Armor
                _buildGroupedSrdList<SrdArmor>(
                  items: _armors,
                  getName: (a) => a.isShield ? a.name : '${a.name} Armor',
                  getSubtitle: (a) => a.isShield
                      ? '+${a.acBonus} AC  ·  ${a.cost}'
                      : 'AC ${a.baseAC}${a.addDexModifier ? " + DEX" : ""}${a.maxDexBonus != null ? " (max +${a.maxDexBonus})" : ""}  ·  ${a.cost}',
                  getCategory: (_) => 'armor',
                  getGroup: (a) => a.type,
                  getDescription: (a) => a.stealthDisadvantage
                      ? 'Stealth disadvantage'
                      : null,
                  getItemType: (_) => ItemType.armor,
                  getProperties: (a) => {
                    'baseAC': a.baseAC,
                    'addDexModifier': a.addDexModifier,
                    'maxDexBonus': a.maxDexBonus,
                    'isShield': a.isShield,
                    'acBonus': a.acBonus,
                  },
                  groupOrder: const ['light', 'medium', 'heavy', 'shield'],
                  groupLabels: const {
                    'light': 'Light Armor',
                    'medium': 'Medium Armor',
                    'heavy': 'Heavy Armor',
                    'shield': 'Shields',
                  },
                ),
                // Gear
                _buildGroupedSrdList<SrdGearItem>(
                  items: _gear,
                  getName: (g) => _stripPackNotation(g.name),
                  getSubtitle: (g) => g.cost,
                  getCategory: (g) => g.category,
                  getGroup: (g) => g.category,
                  getDescription: (g) =>
                      g.description.isNotEmpty ? g.description : null,
                  getItemType: (g) => g.category == 'ammunition'
                      ? ItemType.ammunition
                      : ItemType.gear,
                  groupOrder: const [
                    'adventuring gear',
                    'ammunition',
                    'arcane focus',
                    'clothing',
                    'container',
                    'poison',
                  ],
                  groupLabels: const {
                    'adventuring gear': 'Adventuring Gear',
                    'ammunition': 'Ammunition',
                    'arcane focus': 'Arcane Focus',
                    'clothing': 'Clothing',
                    'container': 'Container',
                    'poison': 'Poison',
                  },
                ),
                // Magic Items
                _buildGroupedSrdList<SrdMagicItem>(
                  items: _magic,
                  getName: (m) => m.name,
                  getSubtitle: (m) =>
                      '${m.rarity}${m.requiresAttunement ? "  ·  attunement" : ""}',
                  getCategory: (m) => m.type,
                  getGroup: (m) => m.type,
                  getDescription: (m) => m.description,
                  getItemType: (m) => m.itemType,
                  groupOrder: const [
                    'potion',
                    'ring',
                    'wand',
                    'weapon',
                    'armor',
                    'wondrous item',
                  ],
                  groupLabels: const {
                    'potion': 'Potions',
                    'ring': 'Rings',
                    'wand': 'Wands',
                    'weapon': 'Weapons',
                    'armor': 'Armor',
                    'wondrous item': 'Wondrous Items',
                  },
                ),
                // Custom
                _buildCustomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item Tile ─────────────────────────────────────────────────────────────────

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item, required this.characterId});
  final EquipmentItem item;
  final String characterId;

  Future<void> _confirmRemoveItem(
    BuildContext context,
    CharacterDetailNotifier notifier,
  ) async {
    final amount = await _showRemoveQuantityDialog(context, item);
    if (amount != null) {
      await notifier.removeEquipmentQuantity(item.id, amount);
    }
  }

  static String? _itemMeta(EquipmentItem item) {
    final props = item.properties;

    if (item.itemType == ItemType.weapon && props != null) {
      final dice = props['damageDice']?.toString();
      final type = props['damageType']?.toString();
      if (dice != null && dice.isNotEmpty && type != null && type.isNotEmpty) {
        return '$dice $type';
      }
      if (dice != null && dice.isNotEmpty) return dice;
    }

    if (item.itemType == ItemType.armor && props != null) {
      final isShield = props['isShield'] == true;
      if (isShield) {
        final bonus = (props['acBonus'] as num?)?.toInt() ?? 2;
        return 'Shield  ·  +$bonus AC';
      }

      final baseAc = (props['baseAC'] as num?)?.toInt();
      if (baseAc != null) {
        final addDex = props['addDexModifier'] as bool? ?? true;
        final maxDex = (props['maxDexBonus'] as num?)?.toInt();
        if (!addDex) return 'AC $baseAc';
        if (maxDex != null) return 'AC $baseAc + DEX (max +$maxDex)';
        return 'AC $baseAc + DEX';
      }
    }

    return null;
  }

  static IconData _leadingIcon(ItemType type, bool equipped) {
    switch (type) {
      case ItemType.weapon:
        return equipped ? Icons.sports_kabaddi : Icons.sports_kabaddi_outlined;
      case ItemType.armor:
        return equipped ? Icons.shield : Icons.shield_outlined;
      case ItemType.consumable:
        return Icons.local_drink_outlined;
      case ItemType.ammunition:
        return Icons.arrow_upward;
      case ItemType.gear:
        return Icons.backpack_outlined;
    }
  }

  static bool _isBodyArmor(EquipmentItem item) {
    if (item.itemType != ItemType.armor) return false;
    final props = item.properties;
    if (props == null) return false;
    if (props['isShield'] == true) return false;
    return props.containsKey('baseAC');
  }

  static int _calcArmorClass(Character c, List<EquipmentItem> equipment) {
    final dexMod = c.abilityScores.dexterityModifier;
    int base = 10 + dexMod;
    int shieldBonus = 0;

    for (final it in equipment) {
      if (!it.isEquipped || it.itemType != ItemType.armor) continue;
      final props = it.properties;
      if (props == null) continue;

      if (props['isShield'] == true) {
        shieldBonus = (props['acBonus'] as num?)?.toInt() ?? 2;
      } else {
        final baseAC = (props['baseAC'] as num?)?.toInt() ?? 10;
        final addDex = props['addDexModifier'] as bool? ?? true;
        final maxDex = (props['maxDexBonus'] as num?)?.toInt();
        int armorAC = baseAC;
        if (addDex) {
          armorAC += maxDex != null ? dexMod.clamp(-99, maxDex) : dexMod;
        }
        base = armorAC;
      }
    }

    return base + shieldBonus;
  }

  Future<void> _onEquipTap(
    BuildContext context,
    WidgetRef ref,
    CharacterDetailNotifier notifier,
  ) async {
    final character = ref.read(characterDetailProvider(characterId)).valueOrNull;

    // Troca de armadura corporal exige confirmação, mostrando CA atual e prevista.
    if (character != null && _isBodyArmor(item) && !item.isEquipped) {
      final equippedBodyArmors = character.equipment
          .where((e) => e.id != item.id && e.isEquipped && _isBodyArmor(e))
          .toList();

      if (equippedBodyArmors.isNotEmpty) {
        final equippedBodyArmor = equippedBodyArmors.first;
        final simulated = character.equipment.map((e) {
          if (e.id == equippedBodyArmor.id) return e.copyWith(isEquipped: false);
          if (e.id == item.id) return e.copyWith(isEquipped: true);
          return e;
        }).toList();
        final nextAc = _calcArmorClass(character, simulated);

        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Replace equipped armor?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current: ${equippedBodyArmor.name}'),
                const SizedBox(height: 8),
                Text('AC now: ${character.armorClass}'),
                Text('AC after: $nextAc'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Swap armor'),
              ),
            ],
          ),
        );

        if (confirm != true) return;
        await notifier.toggleEquipped(item.id, forceArmorSwap: true);
        return;
      }
    }

    await notifier.toggleEquipped(item.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(characterDetailProvider(characterId).notifier);
    final canEquip =
        item.itemType == ItemType.weapon || item.itemType == ItemType.armor;
    final meta = _itemMeta(item);

    String? subtitleText;
    if (meta != null && item.description != null && item.description!.isNotEmpty) {
      subtitleText = '$meta  ·  ${item.description!}';
    } else {
      subtitleText = meta ?? item.description;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: canEquip
          ? GestureDetector(
              onTap: () => _onEquipTap(context, ref, notifier),
              child: Tooltip(
                message: item.isEquipped ? 'Unequip' : 'Equip',
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: item.isEquipped
                      ? scheme.primary
                      : scheme.surfaceContainerHighest,
                  child: Icon(
                    _leadingIcon(item.itemType, item.isEquipped),
                    size: 16,
                    color: item.isEquipped
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : CircleAvatar(
              radius: 16,
              backgroundColor: scheme.surfaceContainerHighest,
              child: Icon(
                _leadingIcon(item.itemType, false),
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ),
      title: Text(
        item.quantity > 1 ? '${item.name} ×${item.quantity}' : item.name,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, color: scheme.onSurfaceVariant),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        color: scheme.error,
        tooltip: 'Remove',
        onPressed: () => _confirmRemoveItem(context, notifier),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

// ── Group Header (non-sticky) ────────────────────────────────────────────────

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

class _AbilityCard extends StatelessWidget {
  const _AbilityCard(this.abbr, this.score);
  final String abbr;
  final int score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
        ],
      ),
    );
  }
}
