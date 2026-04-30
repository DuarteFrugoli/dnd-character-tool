import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              '${character.characterClass}  ·  ${character.race}'
              '${character.subrace != null ? ' (${character.subrace})' : ''}'
              '  ·  Lv ${character.level}',
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
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => _showEditDialog(character),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Skills'),
            Tab(text: 'Spells'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _StatsTab(character: character, characterId: widget.characterId),
          _SkillsTab(character: character),
          _SpellsTab(character: character, characterId: widget.characterId),
          _NotesTab(character: character),
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

  void _showEditDialog(Character character) {
    final nameCtrl = TextEditingController(text: character.name);
    final levelCtrl = TextEditingController(text: character.level.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Character'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: levelCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Level',
                helperText: '1 – 20',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final notifier = ref
                  .read(characterDetailProvider(widget.characterId).notifier);
              notifier.updateName(nameCtrl.text);
              final lvl = int.tryParse(levelCtrl.text);
              if (lvl != null) notifier.updateLevel(lvl);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Stats Tab ─────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab> {
  final _amountCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
    final hp = character.hitPoints;
    final isDead = hp.isDead;
    final isFull = hp.current >= hp.maximum;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Identity ──────────────────────────────────────────────────────
        _Section(
          title: 'Identity',
          child: Column(
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
              // HP numbers
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
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
                  if (hp.temporary > 0) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('+${hp.temporary} temp'),
                      backgroundColor: scheme.tertiaryContainer,
                      labelStyle:
                          TextStyle(color: scheme.onTertiaryContainer),
                    ),
                  ],
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

              // Amount + buttons
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
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Combat Stats ──────────────────────────────────────────────────
        _Section(
          title: 'Combat',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip('AC', '${character.armorClass}'),
              _StatChip('Speed', '${character.speed} ft'),
              _StatChip('Initiative', _sign(character.initiative)),
              _StatChip('Prof Bonus', _sign(character.proficiencyBonus)),
              _StatChip('Passive Perc', '${character.passivePerception}'),
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
            childAspectRatio: 1.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _AbilityCard('STR', character.abilityScores.strength),
              _AbilityCard('DEX', character.abilityScores.dexterity),
              _AbilityCard('CON', character.abilityScores.constitution),
              _AbilityCard('INT', character.abilityScores.intelligence),
              _AbilityCard('WIS', character.abilityScores.wisdom),
              _AbilityCard('CHA', character.abilityScores.charisma),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
      padding: const EdgeInsets.all(16),
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

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final p = character.personality;
    final hasContent = p.traits.isNotEmpty ||
        p.ideals.isNotEmpty ||
        p.bonds.isNotEmpty ||
        p.flaws.isNotEmpty ||
        character.backstory.isNotEmpty ||
        character.features.isNotEmpty;

    if (!hasContent) {
      return Center(
        child: Text(
          'No notes yet',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (p.traits.isNotEmpty)
          _Section(title: 'Personality Traits', child: Text(p.traits)),
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
          _Section(title: 'Backstory', child: Text(character.backstory)),
        ],
        if (character.features.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Section(
            title: 'Features & Traits',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: character.features
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $f'),
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

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
