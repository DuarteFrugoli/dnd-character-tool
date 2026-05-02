import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
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
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Skills'),
            Tab(text: 'Spells'),
            Tab(text: 'Inventory'),
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
          _InventoryTab(character: character, characterId: widget.characterId),
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
    final equippedArmor = character.equipment
      .where((e) => e.itemType == ItemType.armor && e.isEquipped)
      .toList();
    final bodyArmor = equippedArmor
      .where((e) => e.properties?['isShield'] != true)
      .toList();
    final usingShield =
      equippedArmor.any((e) => e.properties?['isShield'] == true);
    final armorSummary = bodyArmor.isEmpty
      ? (usingShield ? 'No armor + Shield' : 'No armor')
      : '${bodyArmor.first.name}${usingShield ? ' + Shield' : ''}';

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
              _StatChip('Armor', armorSummary),
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
        padding: const EdgeInsets.all(16),
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
                            onEditingComplete: _saveCurrency,
                            onTapOutside: (_) => _saveCurrency(),
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
                title: 'Equipped (${equipped.length})',
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

// ── Ammunition Section ────────────────────────────────────────────────────────

class _AmmunitionSection extends ConsumerWidget {
  const _AmmunitionSection(
      {required this.items, required this.characterId});
  final List<EquipmentItem> items;
  final String characterId;

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
                            notifier.removeEquipmentItem(item.id),
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

  Widget _buildSrdList<T>({
    required List<T>? items,
    required String Function(T) getName,
    required String Function(T) getSubtitle,
    required String Function(T) getCategory,
    required String? Function(T) getDescription,
    required ItemType Function(T) getItemType,
    Map<String, dynamic>? Function(T)? getProperties,
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
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
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

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final item = filtered[i];
        return ListTile(
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
      },
    );
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
                _buildSrdList<SrdWeapon>(
                  items: _weapons,
                  getName: (w) => w.name,
                  getSubtitle: (w) =>
                      '${w.category}  ·  ${w.damage} ${w.damageType}  ·  ${w.cost}',
                  getCategory: (w) => w.category,
                  getDescription: (w) => w.properties.isNotEmpty
                      ? w.properties.join(', ')
                      : null,
                  getItemType: (_) => ItemType.weapon,
                  getProperties: (w) => {
                    'damageDice': w.damage,
                    'damageType': w.damageType,
                  },
                ),
                // Armor
                _buildSrdList<SrdArmor>(
                  items: _armors,
                  getName: (a) => a.isShield ? a.name : '${a.name} Armor',
                  getSubtitle: (a) => a.isShield
                      ? 'Shield  ·  +${a.acBonus} AC  ·  ${a.cost}'
                      : '${a.type}  ·  AC ${a.baseAC}${a.addDexModifier ? " + DEX" : ""}${a.maxDexBonus != null ? " (max +${a.maxDexBonus})" : ""}  ·  ${a.cost}',
                  getCategory: (_) => 'armor',
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
                ),
                // Gear
                _buildSrdList<SrdGearItem>(
                  items: _gear,
                  getName: (g) => _stripPackNotation(g.name),
                  getSubtitle: (g) => '${g.category}  ·  ${g.cost}',
                  getCategory: (g) => g.category,
                  getDescription: (g) =>
                      g.description.isNotEmpty ? g.description : null,
                  getItemType: (g) => g.category == 'ammunition'
                      ? ItemType.ammunition
                      : ItemType.gear,
                ),
                // Magic Items
                _buildSrdList<SrdMagicItem>(
                  items: _magic,
                  getName: (m) => m.name,
                  getSubtitle: (m) =>
                      '${m.type}  ·  ${m.rarity}${m.requiresAttunement ? "  ·  attunement" : ""}',
                  getCategory: (m) => m.type,
                  getDescription: (m) => m.description,
                  getItemType: (m) => m.itemType,
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
      subtitle: item.description != null
          ? Text(
              item.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, color: scheme.onSurfaceVariant),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        color: scheme.error,
        tooltip: 'Remove',
        onPressed: () => notifier.removeEquipmentItem(item.id),
      ),
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
