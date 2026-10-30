import '../character_detail_dependencies.dart';
import '../../../data/character_progression/progression_2024_engine.dart';
import '../../../data/rulesets/ruleset_ids.dart';
import '../widgets/spells/spell_widgets.dart';
import '../widgets/dice/contextual_roll_sheet.dart';
import '../../../l10n/ability_l10n.dart';

class Spells2024Tab extends ConsumerWidget {
  const Spells2024Tab({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterState = ref.watch(characterDetailProvider(characterId));
    if (characterState.hasError) {
      return Center(child: Text(AppLocalizations.of(context)!.featuresLoadError));
    }
    final character = characterState.valueOrNull;
    if (character == null) return const Center(child: CircularProgressIndicator());
    final packId = character.contentPackId;
    final spellsState = ref.watch(srdSpellsForPackProvider(packId));
    final classesState = ref.watch(srd2024ClassesProvider);
    final i18nState = ref.watch(srdI18nForPackProvider(packId));
    if (spellsState.hasError || classesState.hasError || i18nState.hasError) {
      return Center(child: Text(AppLocalizations.of(context)!.featuresLoadError));
    }
    final spells = spellsState.valueOrNull;
    final classes = classesState.valueOrNull;
    final i18n = i18nState.valueOrNull;
    if (spells == null || classes == null || i18n == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = AppLocalizations.of(context)!;
    final spellIndexByName = {for (final spell in spells) spell.name.toLowerCase(): spell};
    final known = [...character.spells]
      ..sort((a, b) {
        final level = a.level.compareTo(b.level);
        return level != 0 ? level : i18n.spellName(a.name).compareTo(i18n.spellName(b.name));
      });
    final castings = Progression2024Engine.spellcastingFor(character, classes);
    final slots = character.spellSlots;
    final pactSlots = character.pactMagicSlots;

    return Scaffold(
      body: ListView(
        key: PageStorageKey('spells-2024-$characterId'),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 96 + MediaQuery.viewPaddingOf(context).bottom),
        children: [
          if (character.concentrationSpell != null)
            ConcentrationBanner(
              spellName: character.concentrationSpell!,
              i18n: i18n,
              onBreak: () => ref
                  .read(characterDetailProvider(characterId).notifier)
                  .setConcentration(null),
            ),
          for (final casting in castings)
            _CastingSummary(
              casting: casting,
              character: character,
              showClass: castings.length > 1,
              i18n: i18n,
            ),
          for (final (label, pool, pact) in [
            (l10n.spellsSlots, slots, false),
            (l10n.spellsPactMagicSlots, pactSlots, true),
          ])
            if (pool.total.any((count) => count > 0)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(label, style: Theme.of(context).textTheme.titleMedium),
              ),
              for (var index = 0; index < pool.total.length; index++)
                if (pool.total[index] > 0)
                  SpellSlotRow(
                    level: index + 1,
                    total: pool.total[index],
                    used: pool.used[index],
                    onUse: () => pact
                        ? ref.read(characterDetailProvider(characterId).notifier).usePactMagicSlot(index + 1)
                        : ref.read(characterDetailProvider(characterId).notifier).useSpellSlot(index + 1),
                    onRestore: () => pact
                        ? ref.read(characterDetailProvider(characterId).notifier).restorePactMagicSlot(index + 1)
                        : ref.read(characterDetailProvider(characterId).notifier).restoreSpellSlot(index + 1),
                  ),
            ],
          if (known.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.spellsEmpty),
            ),
          for (var spellIndex = 0; spellIndex < known.length; spellIndex++) ...[
            if (spellIndex == 0 || known[spellIndex - 1].level != known[spellIndex].level)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 6),
                child: Text(
                  known[spellIndex].level == 0 ? l10n.spellsCantrips : l10n.spellsLevelN(known[spellIndex].level),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            _Known2024SpellTile(
              spell: known[spellIndex],
              data: spellIndexByName[known[spellIndex].name.toLowerCase()],
              character: character,
              casting: _castingFor(castings, known[spellIndex]),
              characterId: characterId,
              contentPackId: packId,
              i18n: i18n,
            ),
          ],
        ],
      ),
      floatingActionButton: castings.isEmpty
          ? null
          : FloatingActionButton(
              tooltip: l10n.spellsTooltipAdd,
              onPressed: () async {
                final casting = castings.length == 1
                    ? castings.single
                    : await _pickCasting(context, castings, i18n);
                if (casting == null || !context.mounted) return;
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => _Add2024SpellSheet(
                    characterId: characterId,
                    casting: casting,
                    spells: spells,
                    i18n: i18n,
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  static ClassSpellcasting2024? _castingFor(
    List<ClassSpellcasting2024> castings,
    KnownSpell spell,
  ) {
    return castings.firstWhereOrNull((c) => c.entry.id == spell.sourceClassEntryId) ??
        castings.firstWhereOrNull((c) => c.cls.name == spell.sourceClass);
  }

  Future<ClassSpellcasting2024?> _pickCasting(
    BuildContext context,
    List<ClassSpellcasting2024> castings,
    SrdI18nService i18n,
  ) {
    return showModalBottomSheet<ClassSpellcasting2024>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(sheetContext)!.spells2024ChooseClass,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final casting in castings)
              ListTile(
                title: Text('${i18n.className(casting.cls.name)} ${casting.entry.level}'),
                onTap: () => Navigator.pop(sheetContext, casting),
              ),
          ],
        ),
      ),
    );
  }
}

/// Counts of class-table spells for one class entry.
({int cantrips, int spells, int prepared}) _classSpellCounts(
  Character character,
  CharacterClassEntry entry,
) {
  var cantrips = 0;
  var spells = 0;
  var prepared = 0;
  for (final spell in character.spells) {
    if (!Progression2024Engine.countsAgainstClassLimits(spell, entry)) continue;
    if (spell.level == 0) {
      cantrips++;
    } else {
      spells++;
      if (spell.isPrepared) prepared++;
    }
  }
  return (cantrips: cantrips, spells: spells, prepared: prepared);
}

int _modifier(int score) => ((score - 10) / 2).floor();

class _CastingSummary extends StatelessWidget {
  const _CastingSummary({
    required this.casting,
    required this.character,
    required this.showClass,
    required this.i18n,
  });

  final ClassSpellcasting2024 casting;
  final Character character;
  final bool showClass;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final attack = _modifier(character.abilityScores[casting.ability]) +
        character.proficiencyBonus;
    final counts = _classSpellCounts(character, casting.entry);
    final spellbook = casting.spellbookSize;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showClass
                  ? '${i18n.className(casting.cls.name)} ${casting.entry.level} · ${abilityName(l10n, casting.ability)}'
                  : '${l10n.spellsSpellcasting}: ${abilityName(l10n, casting.ability)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.spellsAttack} ${attack >= 0 ? '+$attack' : '$attack'} · '
              '${l10n.spellsSaveDC} ${8 + attack}',
            ),
            if (casting.cantripsKnown > 0)
              Text(l10n.spells2024Cantrips(counts.cantrips, casting.cantripsKnown)),
            if (spellbook != null)
              Text(l10n.spells2024Spellbook(counts.spells, spellbook)),
            if (casting.preparedSpells > 0)
              Text('${l10n.spellsPrepared}: ${spellbook == null ? counts.spells : counts.prepared} / ${casting.preparedSpells}'),
          ],
        ),
      ),
    );
  }
}

class _Known2024SpellTile extends ConsumerWidget {
  const _Known2024SpellTile({
    required this.spell,
    required this.data,
    required this.character,
    required this.casting,
    required this.characterId,
    required this.contentPackId,
    required this.i18n,
  });

  final KnownSpell spell;
  final SrdSpell? data;
  final Character character;
  final ClassSpellcasting2024? casting;
  final String characterId;
  final ContentPackId contentPackId;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Each Magic Initiate instance keeps its own spellcasting ability.
    final magicInitiateAbility = spell.sourceFeature == 'Magic Initiate'
        ? character.featureChoices
            .where((choice) =>
                choice.featureName == 'Magic Initiate' &&
                choice.choiceId == 'spellcasting_ability' &&
                choice.sourceClassEntryId == spell.sourceClassEntryId)
            .firstOrNull
            ?.values.firstOrNull
        : null;
    final castingAbility = magicInitiateAbility ?? this.casting?.ability;
    final attackBonus = castingAbility == null
        ? null
        : _modifier(character.abilityScores[castingAbility]) +
              character.proficiencyBonus;
    final availableLevels = <int>{
      for (var index = 0; index < character.spellSlots.total.length; index++)
        if (character.spellSlots.total[index] > 0) index + 1,
      for (var index = 0; index < character.pactMagicSlots.total.length; index++)
        if (character.pactMagicSlots.total[index] > 0) index + 1,
    };
    final request = data == null
        ? null
        : ContextualSpellRollBuilder.build(
            character: character,
            spell: data!,
            displayName: i18n.spellName(spell.name),
            attackLabel: l10n.spellsAttack,
            damageLabel: l10n.inventoryDetailDamage,
            spellSlotChoiceLabel: l10n.spellsSlots,
            slotLevelLabel: l10n.spellsSlotLevel,
            damageTypeLabel: i18n.damageType,
            spellAttackBonus: attackBonus,
            availableSlotLevels: availableLevels,
          );
    final casting = this.casting;
    final countsAgainstLimit = casting != null &&
        Progression2024Engine.countsAgainstClassLimits(spell, casting.entry);
    // Only Wizards keep unprepared spells (their spellbook); other classes
    // prepare every spell they learn from the class table.
    final canTogglePrepared = countsAgainstLimit &&
        spell.level > 0 &&
        casting.spellbookSize != null;
    final preparedFull = casting != null &&
        _classSpellCounts(character, casting.entry).prepared >=
            casting.preparedSpells;
    final concentrating = character.concentrationSpell == spell.name;
    return ListTile(
      title: Text(i18n.spellName(spell.name)),
      subtitle: spell.level > 0 && spell.isPrepared ? Text(l10n.spellsPrepared) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data?.concentration == true)
            IconButton(
              tooltip: l10n.concentrationTooltip,
              onPressed: () => onConcentrationTap(
                context,
                ref,
                spell.name,
                character.concentrationSpell,
                characterId,
                i18n,
              ),
              icon: Icon(
                concentrating ? Icons.gps_fixed : Icons.gps_not_fixed,
                color: concentrating ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          if (canTogglePrepared)
            IconButton(
              tooltip: spell.isPrepared ? l10n.spellActionPrepared : l10n.spellActionPrepare,
              onPressed: !spell.isPrepared && preparedFull
                  ? null
                  : () => ref.read(characterDetailProvider(characterId).notifier).togglePrepared(spell.name),
              icon: Icon(spell.isPrepared ? Icons.bookmark : Icons.bookmark_border),
            ),
        ],
      ),
      onTap: data == null
          ? null
          : () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => SpellDetailSheet(
                spell: data!,
                isKnown: true,
                contentPackId: contentPackId,
                onRoll: request == null
                    ? null
                    : () => openContextualRollSheet(
                        context,
                        characterId: characterId,
                        request: request,
                      ),
                onRemove: spell.isAlwaysPrepared
                    ? null
                    : () => ref.read(characterDetailProvider(characterId).notifier).removeSpell(spell.name),
              ),
            ),
    );
  }
}

class _Add2024SpellSheet extends ConsumerStatefulWidget {
  const _Add2024SpellSheet({
    required this.characterId,
    required this.casting,
    required this.spells,
    required this.i18n,
  });

  final String characterId;
  final ClassSpellcasting2024 casting;
  final List<SrdSpell> spells;
  final SrdI18nService i18n;

  @override
  ConsumerState<_Add2024SpellSheet> createState() => _Add2024SpellSheetState();
}

class _Add2024SpellSheetState extends ConsumerState<_Add2024SpellSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(characterDetailProvider(widget.characterId)).valueOrNull;
    if (current == null) return const SizedBox.shrink();
    final casting = widget.casting;
    final className = casting.cls.name.toLowerCase();
    final spellLimit = casting.spellbookSize ?? casting.preparedSpells;
    final counts = _classSpellCounts(current, casting.entry);
    final names = current.spells.map((spell) => spell.name.toLowerCase()).toSet();
    final matches = widget.spells.where((spell) {
      if (!spell.classes.contains(className) || names.contains(spell.name.toLowerCase())) return false;
      if (spell.level == 0
          ? counts.cantrips >= casting.cantripsKnown
          : spell.level > casting.maxSpellLevel || counts.spells >= spellLimit) {
        return false;
      }
      return widget.i18n.spellName(spell.name).toLowerCase().contains(_search.text.trim().toLowerCase());
    }).toList()
      ..sort((a, b) {
        final level = a.level.compareTo(b.level);
        return level != 0 ? level : widget.i18n.spellName(a.name).compareTo(widget.i18n.spellName(b.name));
      });

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (context, controller) => Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(children: [
                Expanded(child: Text(l10n.spellBrowserTitle, style: Theme.of(context).textTheme.titleMedium)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.spellBrowserSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(child: Text(l10n.spellBrowserEmpty))
                  : ListView.builder(
                controller: controller,
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final spell = matches[index];
                  return ListTile(
                    title: Text(widget.i18n.spellName(spell.name)),
                    subtitle: Text(spell.level == 0 ? l10n.spellsCantrips : l10n.spellsLevelN(spell.level)),
                    trailing: const Icon(Icons.add),
                    onTap: () async {
                      await ref.read(characterDetailProvider(widget.characterId).notifier).addSpell(KnownSpell(
                        name: spell.name,
                        level: spell.level,
                        isPrepared: casting.spellbookSize == null || spell.level == 0,
                        sourceType: 'class',
                        sourceClass: casting.cls.name,
                        sourceClassEntryId: casting.entry.id,
                      ));
                      if (mounted) setState(() {});
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
