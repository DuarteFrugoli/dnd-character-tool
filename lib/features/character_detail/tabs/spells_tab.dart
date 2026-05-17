part of '../character_detail_screen.dart';

// ── Spells Tab ────────────────────────────────────────────────────────────────

/// Classes that have access to their full class spell list and prepare daily.
/// Wizard is NOT included: it uses a spellbook (player adds spells manually).
bool _isPrepareAllClass(String className) {
  const prepareAll = {'cleric', 'druid', 'paladin', 'artificer'};
  return prepareAll.contains(className.toLowerCase());
}

class _SpellsTab extends ConsumerStatefulWidget {
  const _SpellsTab({required this.character, required this.characterId});
  final Character character;
  final String characterId;

  @override
  ConsumerState<_SpellsTab> createState() => _SpellsTabState();
}

class _SpellsTabState extends ConsumerState<_SpellsTab> {
  Map<String, SrdSpell>? _spellIndex;
  List<SrdSpell>? _classAllSpells;

  /// Spells that are always prepared due to the character's subclass feature.
  List<SrdSpell>? _subclassAlwaysSpells;

  @override
  void initState() {
    super.initState();
    _loadSpells();
    // Sync spell slots on first load for characters that predate auto-sync
    // (characters created before updateLevel() started calling _applySlotSync).
    // Also auto-populate racial innate spells on first load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = ref
          .read(characterDetailProvider(widget.characterId))
          .valueOrNull;
      if (c != null && c.spellSlots.total.every((t) => t == 0)) {
        ref
            .read(characterDetailProvider(widget.characterId).notifier)
            .syncSpellSlots();
      }
      ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .syncInnateSpells();
    });
  }

  Future<void> _loadSpells() async {
    final all = await ref.read(srdDataSourceProvider).getSpells();
    if (!mounted) return;
    final character = widget.character;
    final cls = character.characterClass.toLowerCase();
    final subclass = character.subclass;
    final isPrepareAll = _isPrepareAllClass(cls);
    setState(() {
      _spellIndex = {for (final s in all) s.name.toLowerCase(): s};
      if (isPrepareAll) {
        _classAllSpells = all.where((s) => s.classes.contains(cls)).toList();
        if (subclass != null && subclass.isNotEmpty) {
          _subclassAlwaysSpells = all
              .where(
                (s) =>
                    s.level > 0 &&
                    s.subclassSpells.any(
                      (ref) => ref.className == cls && ref.subclass == subclass,
                    ),
              )
              .toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
    final engine = SpellcastingEngine.forClass(
      className: character.characterClass,
      classLevel: character.level,
      abilityScores: character.abilityScores,
      proficiencyBonus: character.proficiencyBonus,
      subclass: character.subclass,
    );
    final isCaster = engine != null;
    final hasSpells = character.spells.isNotEmpty;
    final hasSlots = character.spellSlots.total.any((t) => t > 0);
    final hasInnate = character.innateSpells.isNotEmpty;

    if (!isCaster && !hasSlots && !hasSpells && !hasInnate) {
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
                AppLocalizations.of(context)!.spellsNoSpellcasting,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.spellsNoSpellcastingDesc,
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

    // Detect prepare-all class: only Cleric, Druid, Paladin, Artificer
    // Wizard (spellbook) is NOT prepare-all — player adds spells manually
    final isPrepareAll =
        isCaster && _isPrepareAllClass(character.characterClass);

    // Build display list: full class list for prepare-all, character.spells for known
    List<KnownSpell> displaySpells;
    List<KnownSpell> extraSpells =
        []; // non-class spells added manually to prepare-all
    if (isPrepareAll && _classAllSpells != null) {
      final classSpellNamesSet = {
        for (final s in _classAllSpells!) s.name.toLowerCase(),
      };
      final preparedNames = {for (final s in character.spells) s.name};
      final maxLevel = engine.maxSpellLevel;
      // Names that are always prepared due to subclass
      final alwaysNames = _subclassAlwaysSpells != null
          ? {for (final s in _subclassAlwaysSpells!) s.name.toLowerCase()}
          : <String>{};
      final classSpells = _classAllSpells!
          .where((srd) => srd.level > 0 && srd.level <= maxLevel)
          .map((srd) {
            final isAlways = alwaysNames.contains(srd.name.toLowerCase());
            return KnownSpell(
              name: srd.name,
              level: srd.level,
              isPrepared: isAlways || preparedNames.contains(srd.name),
              isAlwaysPrepared: isAlways,
            );
          })
          .toList();
      // Subclass spells not already in the class list (e.g. Burning Hands for Light Domain)
      final extraSubclassSpells =
          _subclassAlwaysSpells
              ?.where(
                (srd) =>
                    srd.level <= maxLevel &&
                    !classSpellNamesSet.contains(srd.name.toLowerCase()),
              )
              .map(
                (srd) => KnownSpell(
                  name: srd.name,
                  level: srd.level,
                  isPrepared: true,
                  isAlwaysPrepared: true,
                ),
              )
              .toList() ??
          [];
      // Cantrips are still managed manually via browser for all classes
      final cantrips = character.spells.where((s) => s.level == 0).toList();
      displaySpells = [...cantrips, ...classSpells, ...extraSubclassSpells];
      // Extra spells: in character.spells but NOT in the class list and not subclass
      extraSpells = character.spells
          .where(
            (s) =>
                s.level > 0 &&
                !classSpellNamesSet.contains(s.name.toLowerCase()),
          )
          .toList();
    } else {
      displaySpells = character.spells;
    }

    // Group spells by level
    final byLevel = <int, List<KnownSpell>>{};
    for (final s in displaySpells) {
      (byLevel[s.level] ??= []).add(s);
    }
    final levels = byLevel.keys.toList()..sort();

    // Group extra spells by level
    final extraByLevel = <int, List<KnownSpell>>{};
    for (final s in extraSpells) {
      (extraByLevel[s.level] ??= []).add(s);
    }

    // "prepares" = shows Prepared counter in banner (includes Wizard/spellbook)
    final prepares =
        isCaster && KnownSpellCasting.classPrepares(character.characterClass);
    // Unified: count spells with isPrepared=true in character.spells
    // (class-list spells for prepare-all are stored with isPrepared:true when toggled on)
    final preparedCount = character.spells
        .where((s) => s.level > 0 && (s.isPrepared || s.isAlwaysPrepared))
        .length;
    final nonCantrips = character.spells.where((s) => s.level > 0).toList();
    final cantripCount = character.spells.where((s) => s.level == 0).length;

    return Scaffold(
      body: _spellIndex == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 192),
              children: [
                // ── Spellcasting Banner ─────────────────────────────────────
                if (engine != null) ...[
                  _SpellcastingBanner(
                    engine: engine,
                    preparedCount: prepares ? preparedCount : null,
                    maxPrepared: prepares ? engine.maxPrepared : null,
                    knownCount: !prepares ? nonCantrips.length : null,
                    maxKnown: !prepares ? engine.maxKnown : null,
                    cantripCount: cantripCount,
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Spell Slots ─────────────────────────────────────────────
                if (hasSlots) ...[
                  Text(
                    AppLocalizations.of(context)!.spellsSlots,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (int lvl = 1; lvl <= 9; lvl++)
                    if (character.spellSlots.total[lvl - 1] > 0)
                      _SpellSlotRow(
                        level: lvl,
                        total: character.spellSlots.total[lvl - 1],
                        used: character.spellSlots.used[lvl - 1],
                        onUse: () => ref
                            .read(
                              characterDetailProvider(
                                widget.characterId,
                              ).notifier,
                            )
                            .useSpellSlot(lvl),
                        onRestore: () => ref
                            .read(
                              characterDetailProvider(
                                widget.characterId,
                              ).notifier,
                            )
                            .restoreSpellSlot(lvl),
                      ),
                  const SizedBox(height: 16),
                ],

                // ── Racial / Innate Spells ──────────────────────────────────
                if (character.innateSpells.isNotEmpty) ...[
                  Text(
                    'Magias Raciais',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  for (final innate in character.innateSpells)
                    _InnateSpellRow(
                      spell: innate,
                      onUse: innate.canUse && !innate.isAtWill
                          ? () => ref
                                .read(
                                  characterDetailProvider(
                                    widget.characterId,
                                  ).notifier,
                                )
                                .useInnateSpell(innate.name)
                          : null,
                      onTap: () {
                        final srd = _spellIndex?[innate.name.toLowerCase()];
                        if (srd == null) return;
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) =>
                              SpellDetailSheet(spell: srd, isKnown: true),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],

                // ── Spell list grouped by level ─────────────────────────────
                if (displaySpells.isNotEmpty)
                  for (final lvl in levels) ...[
                    _SpellLevelHeader(level: lvl),
                    const SizedBox(height: 4),
                    for (final spell in byLevel[lvl]!)
                      Builder(
                        builder: (context) {
                          final isDisabled = character.disabledSpells.contains(
                            spell.name,
                          );
                          final canDisable =
                              isPrepareAll &&
                              spell.level > 0 &&
                              !spell.isAlwaysPrepared;
                          return _SpellRow(
                            spell: spell,
                            srdSpell: _spellIndex![spell.name.toLowerCase()],
                            showPrepareToggle:
                                prepares &&
                                spell.level > 0 &&
                                !spell.isAlwaysPrepared &&
                                !isDisabled,
                            onTogglePrepared: () {
                              final notifier = ref.read(
                                characterDetailProvider(
                                  widget.characterId,
                                ).notifier,
                              );
                              if (isPrepareAll) {
                                if (character.spells.any(
                                  (s) => s.name == spell.name,
                                )) {
                                  notifier.removeSpell(spell.name);
                                } else {
                                  notifier.addSpell(
                                    KnownSpell(
                                      name: spell.name,
                                      level: spell.level,
                                      isPrepared: true,
                                    ),
                                  );
                                }
                              } else {
                                notifier.togglePrepared(spell.name);
                              }
                            },
                            isDisabled: isDisabled,
                            onLongPress: canDisable
                                ? () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(
                                          isDisabled
                                              ? 'Reativar magia?'
                                              : 'Desativar magia?',
                                        ),
                                        content: Text(
                                          isDisabled
                                              ? 'Reativar "${spell.name}"? Ela voltará a aparecer normalmente.'
                                              : 'Desativar "${spell.name}"? Ela ficará esmaecida e não poderá ser preparada.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text(
                                              isDisabled
                                                  ? 'Reativar'
                                                  : 'Desativar',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true && context.mounted) {
                                      ref
                                          .read(
                                            characterDetailProvider(
                                              widget.characterId,
                                            ).notifier,
                                          )
                                          .toggleDisabledSpell(spell.name);
                                    }
                                  }
                                : null,
                            onTap: () {
                              final srd =
                                  _spellIndex![spell.name.toLowerCase()];
                              if (srd == null) return;
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (_) => SpellDetailSheet(
                                  spell: srd,
                                  isKnown: isPrepareAll
                                      ? character.spells.any(
                                          (s) => s.name == spell.name,
                                        )
                                      : true,
                                  onRemove:
                                      (isPrepareAll || spell.isAlwaysPrepared)
                                      ? null
                                      : () => ref
                                            .read(
                                              characterDetailProvider(
                                                widget.characterId,
                                              ).notifier,
                                            )
                                            .removeSpell(spell.name),
                                ),
                              );
                            },
                            onRemove: (isPrepareAll || spell.isAlwaysPrepared)
                                ? null
                                : () => ref
                                      .read(
                                        characterDetailProvider(
                                          widget.characterId,
                                        ).notifier,
                                      )
                                      .removeSpell(spell.name),
                          );
                        },
                      ),
                    const SizedBox(height: 8),
                  ]
                else if (isCaster && !isPrepareAll) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.spellsEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],

                // ── Extra spells (non-class spells added to prepare-all) ────
                if (extraSpells.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Magias Extras',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final lvl in extraByLevel.keys.toList()..sort()) ...[
                    _SpellLevelHeader(level: lvl),
                    const SizedBox(height: 4),
                    for (final spell in extraByLevel[lvl]!)
                      _SpellRow(
                        spell: spell,
                        srdSpell: _spellIndex![spell.name.toLowerCase()],
                        showPrepareToggle: prepares && !spell.isAlwaysPrepared,
                        onTogglePrepared: () => ref
                            .read(
                              characterDetailProvider(
                                widget.characterId,
                              ).notifier,
                            )
                            .togglePrepared(spell.name),
                        onTap: () {
                          final srd = _spellIndex![spell.name.toLowerCase()];
                          if (srd == null) return;
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => SpellDetailSheet(
                              spell: srd,
                              isKnown: true,
                              onRemove: spell.isAlwaysPrepared
                                  ? null
                                  : () => ref
                                        .read(
                                          characterDetailProvider(
                                            widget.characterId,
                                          ).notifier,
                                        )
                                        .removeSpell(spell.name),
                            ),
                          );
                        },
                        onRemove: spell.isAlwaysPrepared
                            ? null
                            : () => ref
                                  .read(
                                    characterDetailProvider(
                                      widget.characterId,
                                    ).notifier,
                                  )
                                  .removeSpell(spell.name),
                      ),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            ),
      floatingActionButton: isCaster
          ? FloatingActionButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => SpellBrowserSheet(
                  characterClass: character.characterClass,
                  maxSpellLevel: engine.maxSpellLevel,
                  knownSpells: character.spells,
                  isPrepareAll: isPrepareAll,
                  onAddSpell: (srdSpell) => ref
                      .read(
                        characterDetailProvider(widget.characterId).notifier,
                      )
                      .addSpell(
                        KnownSpell(
                          name: srdSpell.name,
                          level: srdSpell.level,
                          isPrepared: false,
                        ),
                      ),
                  onRemoveSpell: (name) => ref
                      .read(
                        characterDetailProvider(widget.characterId).notifier,
                      )
                      .removeSpell(name),
                  onTogglePrepared: isPrepareAll
                      ? (name, prepare) {
                          final notifier = ref.read(
                            characterDetailProvider(
                              widget.characterId,
                            ).notifier,
                          );
                          if (prepare) {
                            final level =
                                _spellIndex![name.toLowerCase()]?.level ?? 1;
                            notifier.addSpell(
                              KnownSpell(
                                name: name,
                                level: level,
                                isPrepared: true,
                              ),
                            );
                          } else {
                            notifier.removeSpell(name);
                          }
                        }
                      : null,
                ),
              ),
              tooltip: AppLocalizations.of(context)!.spellsTooltipAdd,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// ── Spellcasting Banner ───────────────────────────────────────────────────────

class _SpellcastingBanner extends StatelessWidget {
  const _SpellcastingBanner({
    required this.engine,
    this.preparedCount,
    this.maxPrepared,
    this.knownCount,
    this.maxKnown,
    required this.cantripCount,
  });

  final SpellcastingEngine engine;
  final int? preparedCount;
  final int? maxPrepared;
  final int? knownCount;
  final int? maxKnown;
  final int cantripCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final ability = engine.spellcastingAbility.toUpperCase();
    final modStr = engine.abilityModifier >= 0
        ? '+${engine.abilityModifier}'
        : '${engine.abilityModifier}';

    return Card(
      color: scheme.primaryContainer.withAlpha(80),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.spellsSpellcasting} · $ability ($modStr)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _BannerStat(l10n.spellsAttack, engine.spellAttackFormatted),
                _BannerStat(l10n.spellsSaveDC, '${engine.saveDC}'),
                if (engine.maxCantrips > 0)
                  _BannerStat(
                    l10n.spellsCantrips,
                    '$cantripCount / ${engine.maxCantrips}',
                    warning: cantripCount > engine.maxCantrips,
                  ),
                if (preparedCount != null && maxPrepared != null)
                  _BannerStat(
                    l10n.spellsPrepared,
                    '$preparedCount / $maxPrepared',
                    warning: preparedCount! > maxPrepared!,
                  )
                else if (knownCount != null)
                  _BannerStat(
                    l10n.spellsKnown,
                    maxKnown != null
                        ? '$knownCount / $maxKnown'
                        : '$knownCount',
                    warning: maxKnown != null && knownCount! > maxKnown!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  const _BannerStat(this.label, this.value, {this.warning = false});
  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: warning ? scheme.error : null,
          ),
        ),
      ],
    );
  }
}

// ── Spell Level Header ────────────────────────────────────────────────────────

class _SpellLevelHeader extends StatelessWidget {
  const _SpellLevelHeader({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        level == 0
            ? AppLocalizations.of(context)!.spellsCantrips
            : AppLocalizations.of(context)!.spellsLevelN(level),
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Spell Row ─────────────────────────────────────────────────────────────────

class _SpellRow extends ConsumerWidget {
  const _SpellRow({
    required this.spell,
    required this.srdSpell,
    required this.showPrepareToggle,
    required this.onTogglePrepared,
    required this.onTap,
    this.onRemove,
    this.isDisabled = false,
    this.onLongPress,
  });

  final KnownSpell spell;
  final SrdSpell? srdSpell;
  final bool showPrepareToggle;
  final VoidCallback onTogglePrepared;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool isDisabled;
  final VoidCallback? onLongPress;

  static Color _schoolColor(String school) {
    switch (school.toLowerCase()) {
      case 'evocation':
        return Colors.deepOrange;
      case 'abjuration':
        return Colors.blue;
      case 'conjuration':
        return Colors.amber;
      case 'divination':
        return Colors.cyan;
      case 'enchantment':
        return Colors.purple;
      case 'illusion':
        return Colors.indigo;
      case 'necromancy':
        return Colors.green;
      case 'transmutation':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  static String _schoolAbbr(String school) {
    switch (school.toLowerCase()) {
      case 'evocation':
        return 'Evoc';
      case 'abjuration':
        return 'Abj';
      case 'conjuration':
        return 'Conj';
      case 'divination':
        return 'Div';
      case 'enchantment':
        return 'Ench';
      case 'illusion':
        return 'Illu';
      case 'necromancy':
        return 'Necro';
      case 'transmutation':
        return 'Trans';
      default:
        return school;
    }
  }

  static IconData _castingTimeIcon(String type) {
    switch (type) {
      case 'bonus_action':
        return Icons.flash_on;
      case 'reaction':
        return Icons.rotate_left;
      case 'minute':
      case 'hour':
      case 'special':
        return Icons.timer_outlined;
      default:
        return Icons.bolt;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final scheme = Theme.of(context).colorScheme;
    final srd = srdSpell;
    final isPrepared = spell.isPrepared || spell.isAlwaysPrepared;
    // Dimmed: DM-disabled always, or not-prepared in a prepare class
    final dimmed = isDisabled || (showPrepareToggle && !isPrepared);

    Widget card = Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Prepare toggle or always-prepared icon
              if (showPrepareToggle) ...[
                GestureDetector(
                  onTap: onTogglePrepared,
                  child: Icon(
                    spell.isPrepared
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 20,
                    color: spell.isPrepared
                        ? scheme.primary
                        : scheme.outlineVariant,
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (spell.isAlwaysPrepared) ...[
                Icon(Icons.auto_fix_high, size: 18, color: scheme.tertiary),
                const SizedBox(width: 8),
              ],

              // Name
              Expanded(
                child: Text(
                  i18n.spellName(spell.name),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: dimmed ? scheme.onSurfaceVariant : null,
                  ),
                ),
              ),

              // School badge
              if (srd != null) ...[
                const SizedBox(width: 4),
                _SchoolBadge(
                  label: _schoolAbbr(srd.school),
                  color: _schoolColor(srd.school),
                ),
              ],

              // Casting time icon
              if (srd != null) ...[
                const SizedBox(width: 6),
                Icon(
                  _castingTimeIcon(srd.castingTimeType),
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ],

              // Concentration badge
              if (srd?.concentration == true) ...[
                const SizedBox(width: 4),
                _SmallBadge('C', scheme.secondary),
              ],

              // Ritual badge
              if (srd?.ritual == true) ...[
                const SizedBox(width: 4),
                _SmallBadge('R', scheme.tertiary),
              ],
            ],
          ),
        ),
      ),
    );

    if (onRemove != null) {
      card = Dismissible(
        key: Key('spell_row_${spell.name}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.spellsRemoveTitle),
                  content: Text(
                    AppLocalizations.of(
                      context,
                    )!.spellsRemoveContent(spell.name),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(AppLocalizations.of(context)!.dialogCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(AppLocalizations.of(context)!.dialogRemove),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) => onRemove!(),
        child: card,
      );
    }

    if (isDisabled) {
      card = Opacity(opacity: 0.35, child: card);
    }

    return card;
  }
}

class _SchoolBadge extends StatelessWidget {
  const _SchoolBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      border: Border.all(color: color.withAlpha(100)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withAlpha(40),
      border: Border.all(color: color.withAlpha(150)),
    ),
    child: Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ),
  );
}

// ── Innate Spell Row ──────────────────────────────────────────────────────────

class _InnateSpellRow extends ConsumerWidget {
  const _InnateSpellRow({required this.spell, required this.onUse, this.onTap});

  final InnateSpell spell;
  final VoidCallback? onUse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.auto_fix_high_outlined, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                i18n.spellName(spell.name),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (spell.isAtWill)
              Chip(
                label: Text(AppLocalizations.of(context)!.spellsAtWill),
                side: BorderSide.none,
                backgroundColor: scheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: scheme.onSecondaryContainer,
                  fontSize: 11,
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            else ...[
              Text(
                '${spell.remaining}/${spell.usesPerDay}/dia',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(width: 6),
              ...List.generate(spell.usesPerDay!, (i) {
                final isUsed = i >= spell.remaining;
                return GestureDetector(
                  onTap: isUsed ? null : onUse,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
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
            ],
          ],
        ),
      ),
    );
  }
}

// ── Spell Slot Row ────────────────────────────────────────────────────────────

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
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final remaining = total - used;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              l10n.spellsSlotLevel(level),
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
