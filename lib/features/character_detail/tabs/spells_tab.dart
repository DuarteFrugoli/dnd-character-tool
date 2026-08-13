import '../character_detail_dependencies.dart';
import '../widgets/spells/spell_widgets.dart';

/// Classes that have access to their full class spell list and prepare daily.
/// Wizard is not included: it uses a spellbook and the player adds spells.
bool _isPrepareAllClass(String className) {
  const prepareAll = {'cleric', 'druid', 'paladin', 'artificer'};
  return prepareAll.contains(className.toLowerCase());
}

class SpellsTab extends ConsumerStatefulWidget {
  const SpellsTab({
    super.key,
    required this.character,
    required this.characterId,
  });

  final Character character;
  final String characterId;

  @override
  ConsumerState<SpellsTab> createState() => _SpellsTabState();
}

class _SpellsTabState extends ConsumerState<SpellsTab>
    with AutomaticKeepAliveClientMixin {
  Map<String, SrdSpell>? _spellIndex;
  List<SrdSpell>? _classAllSpells;

  /// Spells that are always prepared due to the character's subclass feature.
  List<SrdSpell>? _subclassAlwaysSpells;

  List<KnownSpell> _displaySpells = const [];
  List<KnownSpell> _extraSpells = const [];
  Map<int, List<KnownSpell>> _byLevel = const {};
  Map<int, List<KnownSpell>> _extraByLevel = const {};

  String _spellcastingLoadKey(Character character) {
    return character.classEntries
        .map(
          (entry) =>
              '${entry.id}:${entry.className}:${entry.subclassName}:${entry.level}',
        )
        .join('|');
  }

  bool _spellMatchesClassEntry(KnownSpell spell, CharacterClassEntry entry) {
    if (spell.sourceClassEntryId == entry.id) return true;
    return spell.sourceClassEntryId == null &&
        spell.sourceClass?.toLowerCase() == entry.className.toLowerCase();
  }

  void _rebuildSpellDisplayData() {
    final character = widget.character;
    final spellcastingSummary = CharacterSpellcastingSummary.fromCharacter(
      character,
    );
    final primaryOrigin = spellcastingSummary.primaryOrigin;
    final engine = primaryOrigin?.engine;
    final spellcastingClass =
        primaryOrigin?.classEntry ?? character.primaryClass;
    final isPrepareAll =
        engine != null && _isPrepareAllClass(spellcastingClass.className);

    List<KnownSpell> displaySpells;
    List<KnownSpell> extraSpells = [];

    if (isPrepareAll && _classAllSpells != null) {
      final classSpellNamesSet = {
        for (final spell in _classAllSpells!) spell.name.toLowerCase(),
      };
      final preparedNames = {for (final spell in character.spells) spell.name};
      final maxLevel = engine.maxSpellLevel;
      final alwaysNames = _subclassAlwaysSpells != null
          ? {
              for (final spell in _subclassAlwaysSpells!)
                spell.name.toLowerCase(),
            }
          : <String>{};
      final classSpells = _classAllSpells!
          .where((spell) => spell.level > 0 && spell.level <= maxLevel)
          .map((spell) {
            final isAlways = alwaysNames.contains(spell.name.toLowerCase());
            return KnownSpell(
              name: spell.name,
              level: spell.level,
              isPrepared: isAlways || preparedNames.contains(spell.name),
              isAlwaysPrepared: isAlways,
              sourceType: isAlways ? 'subclassFeature' : 'class',
              sourceClass: spellcastingClass.className,
              sourceSubclass: spellcastingClass.subclassName,
              sourceClassEntryId: spellcastingClass.id,
            );
          })
          .toList();
      final extraSubclassSpells =
          _subclassAlwaysSpells
              ?.where(
                (spell) =>
                    spell.level <= maxLevel &&
                    !classSpellNamesSet.contains(spell.name.toLowerCase()),
              )
              .map(
                (spell) => KnownSpell(
                  name: spell.name,
                  level: spell.level,
                  isPrepared: true,
                  isAlwaysPrepared: true,
                  sourceType: 'subclassFeature',
                  sourceClass: spellcastingClass.className,
                  sourceSubclass: spellcastingClass.subclassName,
                  sourceClassEntryId: spellcastingClass.id,
                ),
              )
              .toList() ??
          [];
      final cantrips = character.spells
          .where(
            (spell) =>
                spell.level == 0 &&
                _spellMatchesClassEntry(spell, spellcastingClass),
          )
          .toList();
      displaySpells = [...cantrips, ...classSpells, ...extraSubclassSpells];
      extraSpells = character.spells
          .where(
            (spell) =>
                spell.level > 0 &&
                !classSpellNamesSet.contains(spell.name.toLowerCase()),
          )
          .toList();
    } else {
      displaySpells = character.spells;
    }

    final byLevel = <int, List<KnownSpell>>{};
    for (final spell in displaySpells) {
      (byLevel[spell.level] ??= []).add(spell);
    }
    final extraByLevel = <int, List<KnownSpell>>{};
    for (final spell in extraSpells) {
      (extraByLevel[spell.level] ??= []).add(spell);
    }

    _displaySpells = displaySpells;
    _extraSpells = extraSpells;
    _byLevel = byLevel;
    _extraByLevel = extraByLevel;
  }

  @override
  void initState() {
    super.initState();
    _loadSpells();
  }

  @override
  void didUpdateWidget(SpellsTab old) {
    super.didUpdateWidget(old);
    if (_spellcastingLoadKey(old.character) !=
        _spellcastingLoadKey(widget.character)) {
      _loadSpells();
    } else if (old.character != widget.character) {
      _rebuildSpellDisplayData();
    }
  }

  Future<void> _loadSpells() async {
    final List<SrdSpell> all;
    try {
      all = await ref.read(srdSpellsProvider.future);
    } catch (e, st) {
      debugPrint('_loadSpells error: $e\n$st');
      return;
    }
    if (!mounted) return;
    final character = widget.character;
    final spellcastingOrigin = CharacterSpellcastingSummary.fromCharacter(
      character,
    ).primaryOrigin;
    final spellcastingClass = spellcastingOrigin?.classEntry;
    final cls = spellcastingClass?.className.toLowerCase() ?? '';
    final subclass = spellcastingClass?.subclassName;
    final isPrepareAll = _isPrepareAllClass(cls);
    setState(() {
      _spellIndex = {for (final spell in all) spell.name.toLowerCase(): spell};
      _classAllSpells = null;
      _subclassAlwaysSpells = null;
      if (isPrepareAll) {
        _classAllSpells = all
            .where((spell) => spell.classes.contains(cls))
            .toList();
        if (subclass != null && subclass.isNotEmpty) {
          _subclassAlwaysSpells = all
              .where(
                (spell) =>
                    spell.level > 0 &&
                    spell.subclassSpells.any(
                      (ref) => ref.className == cls && ref.subclass == subclass,
                    ),
              )
              .toList();
        }
      }
      _rebuildSpellDisplayData();
    });
  }

  void _showSpellDetail({
    required BuildContext context,
    required SrdSpell spell,
    required bool isKnown,
    VoidCallback? onRemove,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          SpellDetailSheet(spell: spell, isKnown: isKnown, onRemove: onRemove),
    );
  }

  String? _spellOriginLabel(
    KnownSpell spell,
    CharacterSpellcastingSummary summary,
    SrdI18nService i18n,
  ) {
    if (summary.origins.length <= 1) return null;
    final origin = summary.origins.firstWhereOrNull((origin) {
      return _spellMatchesClassEntry(spell, origin.classEntry);
    });
    final className = origin?.classEntry.className ?? spell.sourceClass;
    if (className == null || className.isEmpty) return null;
    return i18n.className(className);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final character = widget.character;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spellcastingSummary = CharacterSpellcastingSummary.fromCharacter(
      character,
    );
    final primaryOrigin = spellcastingSummary.primaryOrigin;
    final engine = primaryOrigin?.engine;
    final spellcastingClass =
        primaryOrigin?.classEntry ?? character.primaryClass;
    final isCaster = engine != null;
    final hasSpells = character.spells.isNotEmpty;
    final standardSlots = spellcastingSummary.standardSlots;
    final pactMagicSlots = spellcastingSummary.pactMagicSlots;
    final hasStandardSlots = standardSlots.total.any((total) => total > 0);
    final hasPactMagicSlots = pactMagicSlots.total.any((total) => total > 0);
    final hasSlots = hasStandardSlots || hasPactMagicSlots;
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
                color: scheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.spellsNoSpellcasting,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.spellsNoSpellcastingDesc,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isPrepareAll =
        isCaster && _isPrepareAllClass(spellcastingClass.className);
    final levels = _byLevel.keys.toList()..sort();
    final prepares =
        isCaster &&
        KnownSpellCasting.classPrepares(spellcastingClass.className);
    final originSpells = primaryOrigin == null
        ? character.spells
        : character.spells
              .where(
                (spell) =>
                    _spellMatchesClassEntry(spell, primaryOrigin.classEntry),
              )
              .toList();
    final preparedCount = originSpells
        .where(
          (spell) =>
              spell.level > 0 && (spell.isPrepared || spell.isAlwaysPrepared),
        )
        .length;
    final nonCantrips = originSpells.where((spell) => spell.level > 0).toList();
    final cantripCount = originSpells.where((spell) => spell.level == 0).length;

    return Scaffold(
      body: _spellIndex == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              key: PageStorageKey('spells-${widget.characterId}'),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (engine != null) ...[
                        SpellcastingBanner(
                          engine: engine,
                          preparedCount: prepares ? preparedCount : null,
                          maxPrepared: prepares ? engine.maxPrepared : null,
                          knownCount: !prepares ? nonCantrips.length : null,
                          maxKnown: !prepares ? engine.maxKnown : null,
                          cantripCount: cantripCount,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (hasStandardSlots) ...[
                        Text(
                          l10n.spellsSlots,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        for (int level = 1; level <= 9; level++)
                          if (standardSlots.total[level - 1] > 0)
                            SpellSlotRow(
                              level: level,
                              total: standardSlots.total[level - 1],
                              used: standardSlots.used[level - 1],
                              onUse: () => ref
                                  .read(
                                    characterDetailProvider(
                                      widget.characterId,
                                    ).notifier,
                                  )
                                  .useSpellSlot(level),
                              onRestore: () => ref
                                  .read(
                                    characterDetailProvider(
                                      widget.characterId,
                                    ).notifier,
                                  )
                                  .restoreSpellSlot(level),
                            ),
                        const SizedBox(height: 16),
                      ],
                      if (hasPactMagicSlots) ...[
                        Text(
                          l10n.spellsPactMagicSlots,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        for (int level = 1; level <= 9; level++)
                          if (pactMagicSlots.total[level - 1] > 0)
                            SpellSlotRow(
                              level: level,
                              total: pactMagicSlots.total[level - 1],
                              used: pactMagicSlots.used[level - 1],
                              onUse: () => ref
                                  .read(
                                    characterDetailProvider(
                                      widget.characterId,
                                    ).notifier,
                                  )
                                  .usePactMagicSlot(level),
                              onRestore: () => ref
                                  .read(
                                    characterDetailProvider(
                                      widget.characterId,
                                    ).notifier,
                                  )
                                  .restorePactMagicSlot(level),
                            ),
                        const SizedBox(height: 16),
                      ],
                      if (character.innateSpells.isNotEmpty) ...[
                        Text(
                          l10n.spellsInnateHeader,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        for (final innate in character.innateSpells)
                          InnateSpellRow(
                            spell: innate,
                            i18n: i18n,
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
                              final spell =
                                  _spellIndex?[innate.name.toLowerCase()];
                              if (spell == null) return;
                              _showSpellDetail(
                                context: context,
                                spell: spell,
                                isKnown: true,
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                      ],
                      if (character.concentrationSpell != null)
                        ConcentrationBanner(
                          spellName: character.concentrationSpell!,
                          i18n: i18n,
                          onBreak: () => ref
                              .read(
                                characterDetailProvider(
                                  widget.characterId,
                                ).notifier,
                              )
                              .setConcentration(null),
                        ),
                    ]),
                  ),
                ),
                if (_displaySpells.isNotEmpty)
                  for (final level in levels) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: SpellLevelHeader(level: level),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 4)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final spell = _byLevel[level]![index];
                          final isDisabled = character.disabledSpells.contains(
                            spell.name,
                          );
                          final canDisable =
                              isPrepareAll &&
                              spell.level > 0 &&
                              !spell.isAlwaysPrepared;
                          return SpellRow(
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
                                  (known) => known.name == spell.name,
                                )) {
                                  notifier.removeSpell(spell.name);
                                } else {
                                  notifier.addSpell(
                                    KnownSpell(
                                      name: spell.name,
                                      level: spell.level,
                                      isPrepared: true,
                                      sourceType: 'class',
                                      sourceClass: spellcastingClass.className,
                                      sourceSubclass:
                                          spellcastingClass.subclassName,
                                      sourceClassEntryId: spellcastingClass.id,
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
                                              ? l10n.spellsEnableTitle
                                              : l10n.spellsDisableTitle,
                                        ),
                                        content: Text(
                                          isDisabled
                                              ? l10n.spellsEnableContent(
                                                  i18n.spellName(spell.name),
                                                )
                                              : l10n.spellsDisableContent(
                                                  i18n.spellName(spell.name),
                                                ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text(l10n.dialogCancel),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text(
                                              isDisabled
                                                  ? l10n.spellsEnable
                                                  : l10n.spellsDisable,
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
                              final srdSpell =
                                  _spellIndex![spell.name.toLowerCase()];
                              if (srdSpell == null) return;
                              _showSpellDetail(
                                context: context,
                                spell: srdSpell,
                                isKnown: isPrepareAll
                                    ? character.spells.any(
                                        (known) => known.name == spell.name,
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
                              );
                            },
                            characterId: widget.characterId,
                            concentrationSpell: character.concentrationSpell,
                            originLabel: _spellOriginLabel(
                              spell,
                              spellcastingSummary,
                              i18n,
                            ),
                            i18n: i18n,
                          );
                        }, childCount: _byLevel[level]!.length),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ]
                else if (isCaster && !isPrepareAll)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          l10n.spellsEmpty,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_extraSpells.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.spellsExtrasHeader,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.outline,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  for (final level in _extraByLevel.keys.toList()..sort()) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: SpellLevelHeader(level: level),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 4)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final spell = _extraByLevel[level]![index];
                          return SpellRow(
                            spell: spell,
                            srdSpell: _spellIndex![spell.name.toLowerCase()],
                            showPrepareToggle:
                                prepares && !spell.isAlwaysPrepared,
                            onTogglePrepared: () => ref
                                .read(
                                  characterDetailProvider(
                                    widget.characterId,
                                  ).notifier,
                                )
                                .togglePrepared(spell.name),
                            onTap: () {
                              final srdSpell =
                                  _spellIndex![spell.name.toLowerCase()];
                              if (srdSpell == null) return;
                              _showSpellDetail(
                                context: context,
                                spell: srdSpell,
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
                              );
                            },
                            characterId: widget.characterId,
                            concentrationSpell: character.concentrationSpell,
                            originLabel: _spellOriginLabel(
                              spell,
                              spellcastingSummary,
                              i18n,
                            ),
                            i18n: i18n,
                          );
                        }, childCount: _extraByLevel[level]!.length),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ],
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 192)),
              ],
            ),
      floatingActionButton: isCaster
          ? FloatingActionButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => SpellBrowserSheet(
                  characterClass: engine.spellListClass,
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
                          sourceType: 'class',
                          sourceClass: spellcastingClass.className,
                          sourceSubclass: spellcastingClass.subclassName,
                          sourceClassEntryId: spellcastingClass.id,
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
                                sourceType: 'class',
                                sourceClass: spellcastingClass.className,
                                sourceSubclass: spellcastingClass.subclassName,
                                sourceClassEntryId: spellcastingClass.id,
                              ),
                            );
                          } else {
                            notifier.removeSpell(name);
                          }
                        }
                      : null,
                ),
              ),
              tooltip: l10n.spellsTooltipAdd,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
