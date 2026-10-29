import '../character_detail_dependencies.dart';
import '../../../data/datasources/srd/srd_2024_creation_catalog.dart';
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
    final classData = classes.where((entry) => entry.name == character.primaryClassName).firstOrNull;
    final castingAbility = classData?.spellcastingAbility;
    final spellAttack = castingAbility == null
        ? null
        : ((character.abilityScores[castingAbility] - 10) / 2).floor() +
              character.proficiencyBonus;
    final preparedLimit = (classData?.levelOne['preparedSpells'] as num?)?.toInt() ?? 0;
    final preparedCount = character.spells.where(
      (spell) => spell.level > 0 && spell.isPrepared && !spell.isAlwaysPrepared &&
          spell.sourceClass == character.primaryClassName,
    ).length;
    final slots = character.spellSlots;
    final pactSlots = character.pactMagicSlots;

    return Scaffold(
      body: ListView(
        key: PageStorageKey('spells-2024-$characterId'),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 96 + MediaQuery.viewPaddingOf(context).bottom),
        children: [
          if (spellAttack != null) ...[
            ListTile(
              title: Text(l10n.spellsSpellcasting),
              subtitle: Text(abilityName(l10n, castingAbility!)),
            ),
            ListTile(
              title: Text(l10n.spellsAttack),
              trailing: Text(spellAttack >= 0 ? '+$spellAttack' : '$spellAttack'),
            ),
            ListTile(
              title: Text(l10n.spellsSaveDC),
              trailing: Text('${8 + spellAttack}'),
            ),
          ],
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
          if (preparedLimit > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('${l10n.spellsPrepared}: $preparedCount / $preparedLimit'),
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
              classData: classData,
              preparedCount: preparedCount,
              preparedLimit: preparedLimit,
              characterId: characterId,
              contentPackId: packId,
              i18n: i18n,
            ),
          ],
        ],
      ),
      floatingActionButton: classData == null
          ? null
          : FloatingActionButton(
              tooltip: l10n.spellsTooltipAdd,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => _Add2024SpellSheet(
                  character: character,
                  characterId: characterId,
                  classData: classData,
                  spells: spells,
                  i18n: i18n,
                ),
              ),
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _Known2024SpellTile extends ConsumerWidget {
  const _Known2024SpellTile({
    required this.spell,
    required this.data,
    required this.character,
    required this.classData,
    required this.preparedCount,
    required this.preparedLimit,
    required this.characterId,
    required this.contentPackId,
    required this.i18n,
  });

  final KnownSpell spell;
  final SrdSpell? data;
  final Character character;
  final Creation2024Class? classData;
  final int preparedCount;
  final int preparedLimit;
  final String characterId;
  final ContentPackId contentPackId;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final magicInitiateAbility = spell.sourceFeature == 'Magic Initiate'
        ? character.featureChoices
            .where((choice) =>
                choice.featureName == 'Magic Initiate' &&
                choice.choiceId == 'spellcasting_ability')
            .firstOrNull
            ?.values.firstOrNull
        : null;
    final castingAbility = magicInitiateAbility ??
        (spell.sourceClass == classData?.name
            ? classData?.spellcastingAbility
            : null);
    final attackBonus = castingAbility == null
        ? null
        : ((character.abilityScores[castingAbility] - 10) / 2).floor() +
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
    return ListTile(
      title: Text(i18n.spellName(spell.name)),
      subtitle: spell.level > 0 && spell.isPrepared ? Text(l10n.spellsPrepared) : null,
      trailing: spell.isAlwaysPrepared || spell.level == 0
          ? null
          : IconButton(
              tooltip: spell.isPrepared ? l10n.spellActionPrepared : l10n.spellActionPrepare,
              onPressed: !spell.isPrepared && preparedCount >= preparedLimit
                  ? null
                  : () => ref.read(characterDetailProvider(characterId).notifier).togglePrepared(spell.name),
              icon: Icon(spell.isPrepared ? Icons.bookmark : Icons.bookmark_border),
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
    required this.character,
    required this.characterId,
    required this.classData,
    required this.spells,
    required this.i18n,
  });

  final Character character;
  final String characterId;
  final Creation2024Class classData;
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
    final current = ref.watch(characterDetailProvider(widget.characterId)).valueOrNull ?? widget.character;
    final className = widget.classData.name.toLowerCase();
    final maxLevel = [
      for (var index = 0; index < current.spellSlots.total.length; index++)
        if (current.spellSlots.total[index] > 0) index + 1,
      for (var index = 0; index < current.pactMagicSlots.total.length; index++)
        if (current.pactMagicSlots.total[index] > 0) index + 1,
    ].fold<int>(0, (max, level) => level > max ? level : max);
    final cantripLimit = (widget.classData.levelOne['cantripsKnown'] as num?)?.toInt() ?? 0;
    final spellLimit = widget.classData.name == 'Wizard'
        ? 6
        : (widget.classData.levelOne['preparedSpells'] as num?)?.toInt() ?? 0;
    final classSpells = current.spells.where((spell) => spell.sourceClass?.toLowerCase() == className).toList();
    final cantripCount = classSpells.where((spell) => spell.level == 0).length;
    final spellCount = classSpells.where((spell) => spell.level > 0 && !spell.isAlwaysPrepared).length;
    final names = current.spells.map((spell) => spell.name.toLowerCase()).toSet();
    final matches = widget.spells.where((spell) {
      if (!spell.classes.contains(className) || names.contains(spell.name.toLowerCase())) return false;
      if (spell.level == 0 ? cantripCount >= cantripLimit : spell.level > maxLevel || spellCount >= spellLimit) return false;
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
                        isPrepared: widget.classData.name != 'Wizard' || spell.level == 0,
                        sourceType: 'class',
                        sourceClass: widget.classData.name,
                        sourceClassEntryId: current.primaryClass.id,
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
