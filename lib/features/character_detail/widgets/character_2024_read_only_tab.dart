import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/units/unit_formatter.dart';
import '../../../core/units/unit_system_provider.dart';
import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../data/models/models.dart';
import '../../../shared/providers/providers.dart';

class Character2024ReadOnlyTab extends ConsumerWidget {
  const Character2024ReadOnlyTab({
    super.key,
    required this.character,
    required this.tabIndex,
    required this.i18n,
  });

  final Character character;
  final int tabIndex;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return switch (tabIndex) {
      0 => _identity(l10n),
      1 => _stats(ref, l10n),
      2 => _skills(),
      3 => _features(ref, l10n),
      4 => _spells(ref, l10n),
      5 => _inventory(ref, l10n),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _list(List<Widget> children) => ListView(
    key: PageStorageKey('2024-${character.id}-$tabIndex'),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    children: [
      Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            AppLocalizations.of(context)!.character2024ReadOnlyNotice,
          ),
        ),
      ),
      ...children,
    ],
  );

  Widget _identity(AppLocalizations l10n) => _list([
    ListTile(title: Text(l10n.creationStepClass), subtitle: Text(i18n.className(character.primaryClassName))),
    ListTile(title: Text(l10n.creation2024Species), subtitle: Text(i18n.raceName(character.race))),
    ListTile(title: Text(l10n.creationStepBackground), subtitle: Text(i18n.backgroundName(character.background))),
    if (character.playerName.isNotEmpty)
      ListTile(title: Text(l10n.reviewRowPlayer), subtitle: Text(character.playerName)),
    ListTile(title: Text(l10n.reviewRowLanguages), subtitle: Text(character.languages.map(i18n.languageName).join(', '))),
  ]);

  Widget _stats(WidgetRef ref, AppLocalizations l10n) {
    final abilities = character.abilityScores;
    final scores = <String, int>{
      'strength': abilities.strength,
      'dexterity': abilities.dexterity,
      'constitution': abilities.constitution,
      'intelligence': abilities.intelligence,
      'wisdom': abilities.wisdom,
      'charisma': abilities.charisma,
    };
    return _list([
      ListTile(title: Text(l10n.reviewRowMaxHp), subtitle: Text('${character.hitPoints.current} / ${character.hitPoints.maximum}')),
      ListTile(title: Text(l10n.statAC), subtitle: Text('${character.armorClass}')),
      ListTile(title: Text(l10n.statSpeed), subtitle: Text(formatDistance(character.speed, ref.watch(unitSystemProvider)))),
      for (final entry in scores.entries)
        ListTile(title: Text(abilityName(l10n, entry.key)), trailing: Text('${entry.value}')),
    ]);
  }

  Widget _skills() => _list([
    for (final skill in character.skillProficiencies)
      ListTile(
        title: Text(i18n.skillName(skill)),
        trailing: character.skillExpertises.contains(skill)
            ? const Icon(Icons.stars_outlined)
            : null,
      ),
  ]);

  Widget _features(WidgetRef ref, AppLocalizations l10n) {
    final origins = ref.watch(srd2024SpeciesProvider);
    final traits = ref.watch(srdRaceTraitsForPackProvider(character.contentPackId));
    final classFeatures = [
      for (final entry in character.classEntries)
        ref.watch(srdClassFeaturesForPackProvider((character.contentPackId, entry.className))),
    ];
    final subclassFeatures = ref.watch(srdAllSubclassFeaturesForPackProvider(character.contentPackId));
    if (origins.hasError || traits.hasError || subclassFeatures.hasError || classFeatures.any((state) => state.hasError)) {
      return Center(child: Text(l10n.featuresLoadError));
    }
    if (origins.valueOrNull == null || traits.valueOrNull == null ||
        subclassFeatures.valueOrNull == null || classFeatures.any((state) => state.valueOrNull == null)) {
      return const Center(child: CircularProgressIndicator());
    }
    final species = origins.valueOrNull!
        .where((entry) => entry.name == character.race).firstOrNull;
    if (species == null) return Center(child: Text(l10n.featuresLoadError));
    final sections = <Widget>[];
    for (var index = 0; index < character.classEntries.length; index++) {
      final entry = character.classEntries[index];
      sections.add(Padding(
        padding: const EdgeInsets.all(12),
        child: Text(i18n.className(entry.className), style: const TextStyle(fontWeight: FontWeight.bold)),
      ));
      for (final feature in classFeatures[index].valueOrNull!.where((feature) => feature.level <= entry.level)) {
        sections.add(_description(
          i18n.classFeatureName(entry.className, feature.name) ?? feature.name,
          i18n.classFeatureDescription(entry.className, feature.name) ?? feature.description,
        ));
      }
      final subclassName = entry.subclassName;
      if (subclassName != null) {
        for (final feature in (subclassFeatures.valueOrNull![entry.className]?[subclassName] ?? const <SrdClassFeature>[])
            .where((feature) => feature.level <= entry.level)) {
          sections.add(_description(
            i18n.subclassFeatureName(entry.className, subclassName, feature.name) ?? feature.name,
            i18n.subclassFeatureDescription(entry.className, subclassName, feature.name) ?? feature.description,
          ));
        }
      }
    }
    sections.add(Padding(
      padding: const EdgeInsets.all(12),
      child: Text(i18n.raceName(species.name), style: const TextStyle(fontWeight: FontWeight.bold)),
    ));
    for (final trait in species.traits) {
      sections.add(_description(
        i18n.raceTraitName(trait),
        i18n.raceTraitDescription(trait) ?? traits.valueOrNull![trait] ?? '',
      ));
    }
    for (final feat in character.extraFeatures.where((feature) => feature.effectiveSourceType == 'feat')) {
      sections.add(_description(
        i18n.featName(feat.name) ?? feat.name,
        i18n.featDescription(feat.name) ?? feat.description,
      ));
    }
    return _list(sections);
  }

  Widget _spells(WidgetRef ref, AppLocalizations l10n) {
    final catalog = ref.watch(srdSpellsForPackProvider(character.contentPackId));
    if (catalog.hasError) return Center(child: Text(l10n.featuresLoadError));
    if (catalog.valueOrNull == null) return const Center(child: CircularProgressIndicator());
    final spellsByName = {for (final spell in catalog.valueOrNull!) spell.name: spell};
    final known = [...character.spells]..sort((a, b) {
      final byLevel = a.level.compareTo(b.level);
      return byLevel == 0 ? a.name.compareTo(b.name) : byLevel;
    });
    return _list([
      for (var level = 1; level <= character.spellSlots.total.length; level++)
        if (character.spellSlots.total[level - 1] > 0)
          ListTile(
            title: Text(l10n.spellsSlotLevel(level)),
            trailing: Text('${character.spellSlots.total[level - 1] - character.spellSlots.used[level - 1]} / ${character.spellSlots.total[level - 1]}'),
          ),
      for (final spell in known)
        _description(
          i18n.spellName(spell.name),
          [
            spell.level == 0 ? l10n.spellsCantrips : l10n.spellsLevelN(spell.level),
            if (spell.isPrepared) l10n.spellsPrepared,
            i18n.spellDescription(spell.name) ?? spellsByName[spell.name]?.description ?? '',
          ].where((text) => text.isNotEmpty).join(' | '),
        ),
    ]);
  }

  Widget _inventory(WidgetRef ref, AppLocalizations l10n) {
    final catalog = ref.watch(srdItemsForPackProvider(character.contentPackId));
    if (catalog.hasError) return Center(child: Text(l10n.featuresLoadError));
    if (catalog.valueOrNull == null) return const Center(child: CircularProgressIndicator());
    return _list([
      for (final item in character.equipment)
        _description(
          '${item.quantity}x ${i18n.equipmentName(item.name)}',
          i18n.equipmentDescription(item.name) ??
              item.description ??
              catalog.valueOrNull![item.name.toLowerCase()]?.description ??
              '',
        ),
    ]);
  }

  Widget _description(String title, String body) => body.isEmpty
      ? ListTile(title: Text(title))
      : ExpansionTile(title: Text(title), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(alignment: Alignment.centerLeft, child: Text(body)),
          ),
        ]);
}
