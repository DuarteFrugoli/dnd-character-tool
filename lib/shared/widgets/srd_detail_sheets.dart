import 'rules_text.dart';
import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../../data/datasources/srd/srd_2024_creation_catalog.dart';
import '../../data/datasources/srd/srd_data_source.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/rulesets/ruleset_ids.dart';
import '../../data/rulesets/srd_content_pack.dart';
import '../../core/units/unit_system_provider.dart';
import '../../core/units/unit_formatter.dart';
import '../providers/providers.dart';

// ── Detail models ─────────────────────────────────────────────────────────────

/// What the class sheet shows, from the class data of either edition.
class ClassDetail {
  const ClassDetail({
    required this.packId,
    required this.name,
    required this.hitDie,
    required this.savingThrows,
    required this.subclassFeatureName,
    this.subclassLevel = 3,
    this.primaryAbilities = const [],
    this.spellcastingAbility,
    this.proficiencies = const [],
    this.skillChoices,
    this.subclasses = const [],
  });

  factory ClassDetail.from2014(SrdClass cls) => ClassDetail(
    packId: ContentPackId.srd51,
    name: cls.name,
    hitDie: cls.hitDie,
    savingThrows: cls.savingThrows,
    subclassFeatureName: cls.subclassFeatureName,
    subclassLevel: cls.subclassLevel,
    spellcastingAbility: cls.spellcastingAbility,
    proficiencies: [...cls.armorProficiencies, ...cls.weaponProficiencies],
    skillChoices: cls.skillChoices,
    subclasses: [for (final sub in cls.subclasses) (name: sub.name, description: sub.description)],
  );

  factory ClassDetail.from2024(
    Creation2024Class cls,
    List<Creation2024Subclass> subclasses, {
    required String subclassFeatureName,
  }) => ClassDetail(
    packId: ContentPackId.srd521,
    name: cls.name,
    hitDie: cls.hitDie,
    savingThrows: cls.savingThrows,
    subclassFeatureName: subclassFeatureName,
    subclassLevel: cls.subclassLevel,
    primaryAbilities: cls.primaryAbilities,
    spellcastingAbility: cls.spellcastingAbility,
    proficiencies: [...cls.armorProficiencies, ...cls.weaponProficiencies],
    skillChoices: cls.skillChoices,
    subclasses: [for (final sub in subclasses) (name: sub.name, description: sub.description)],
  );

  final ContentPackId packId;
  final String name;
  final int hitDie;
  final List<String> savingThrows;
  final String subclassFeatureName;

  /// Class level at which the subclass applies; it can be chosen earlier.
  final int subclassLevel;
  final List<String> primaryAbilities;
  final String? spellcastingAbility;
  final List<String> proficiencies;
  final SrdSkillChoice? skillChoices;
  final List<SubclassSummary> subclasses;
}

typedef SubclassSummary = ({String name, String description});

/// What the race or species sheet shows, from the data of either edition.
class SpeciesDetail {
  const SpeciesDetail({
    required this.packId,
    required this.name,
    required this.speed,
    required this.traits,
    this.sizes = const [],
    this.abilityIncreases = const {},
    this.freeAbilityIncreases = 0,
    this.subraces = const [],
    this.lineages = const [],
  });

  factory SpeciesDetail.from2014(SrdRace race) => SpeciesDetail(
    packId: ContentPackId.srd51,
    name: race.name,
    speed: race.speed,
    traits: race.traits,
    abilityIncreases: race.abilityScoreIncreases,
    freeAbilityIncreases: race.freeAsiPoints,
    subraces: race.subraces,
  );

  factory SpeciesDetail.from2024(Creation2024Species species) => SpeciesDetail(
    packId: ContentPackId.srd521,
    name: species.name,
    speed: species.speed,
    traits: species.traits,
    sizes: species.sizes,
    lineages: [
      for (final lineage in species.lineages)
        if (lineage case {'id': final String id, 'name': final String name}) (id: id, name: name),
    ],
  );

  final ContentPackId packId;
  final String name;
  final int speed;
  final List<String> traits;

  /// 2024 size options (`Small`, `Medium`).
  final List<String> sizes;

  /// 2014 racial increases.
  final Map<String, int> abilityIncreases;
  final int freeAbilityIncreases;
  final List<SrdSubrace> subraces;
  final List<({String id, String name})> lineages;
}

SrdDataSource _sourceFor(ContentPackId packId) =>
    SrdDataSource.forPack(SrdContentPackRegistry.forId(packId));

// ── Public helpers ────────────────────────────────────────────────────────────

void showClassDetailSheet(
  BuildContext context,
  ClassDetail cls,
  SrdI18nService i18n,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ClassDetailSheet(cls: cls, i18n: i18n),
  );
}

void showSubclassDetailSheet(
  BuildContext context,
  ClassDetail cls,
  SubclassSummary sub,
  SrdI18nService i18n,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _SubclassDetailSheet(cls: cls, sub: sub, i18n: i18n),
  );
}

void showRaceDetailSheet(
  BuildContext context,
  SpeciesDetail race,
  SrdI18nService i18n,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RaceDetailSheet(race: race, i18n: i18n),
  );
}

void showSubraceDetailSheet(
  BuildContext context,
  SrdRace race,
  SrdSubrace subrace,
  SrdI18nService i18n,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        _SubraceDetailSheet(race: race, subrace: subrace, i18n: i18n),
  );
}

// ── Shared private widgets ────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

Widget _sectionHeader(BuildContext context, String title) {
  final scheme = Theme.of(context).colorScheme;
  return Container(
    color: scheme.surface,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: scheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.name,
    required this.description,
    this.badge,
  });

  final String name;
  final String description;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: RulesText(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Class detail sheet ────────────────────────────────────────────────────────

class _ClassDetailSheet extends ConsumerStatefulWidget {
  const _ClassDetailSheet({required this.cls, required this.i18n});

  final ClassDetail cls;
  final SrdI18nService i18n;

  @override
  ConsumerState<_ClassDetailSheet> createState() => _ClassDetailSheetState();
}

class _ClassDetailSheetState extends ConsumerState<_ClassDetailSheet> {
  List<SrdClassFeature>? _features;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sourceFor(widget.cls.packId)
        .getClassFeatures(widget.cls.name)
        .then((f) {
          if (mounted) setState(() => _features = f);
        })
        .catchError((Object e) {
          if (mounted) setState(() => _error = e.toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final cls = widget.cls;
    final i18n = widget.i18n;
    final clsName = i18n.className(cls.name);
    final subclassFeature =
        i18n.classSubclassFeatureName(cls.name) ?? cls.subclassFeatureName;

    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        final grouped = <int, List<SrdClassFeature>>{};
        if (_features != null) {
          for (final f in _features!) {
            grouped.putIfAbsent(f.level, () => []).add(f);
          }
        }
        final levels = grouped.keys.toList()..sort();

        return Column(
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clsName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.stepHitDieLabel}: d${cls.hitDie}  ·  '
                    '${l10n.stepSavesLabel}: ${cls.savingThrows.map((s) => abilityName(l10n, s)).join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (cls.primaryAbilities.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.detailSheetPrimaryAbility}: '
                      '${cls.primaryAbilities.map((a) => abilityName(l10n, a)).join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (cls.spellcastingAbility != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.stepSpellcastingLabel}: ${abilityName(l10n, cls.spellcastingAbility!)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: scheme.primary),
                    ),
                  ],
                  if (cls.skillChoices case final skills?) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.stepClassSkillChoices(skills.count)} '
                      '${skills.isAny ? l10n.detailSheetAnySkills : skills.from.map(i18n.skillName).join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (cls.proficiencies.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.detailSheetProficiencies}: '
                      '${cls.proficiencies.map(i18n.term).join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _error != null
                  ? Center(child: Text(_error!))
                  : _features == null
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      controller: scrollCtrl,
                      slivers: [
                        ...levels.map(
                          (lvl) => SliverStickyHeader(
                            header: _sectionHeader(
                              context,
                              l10n.charCardLevel(lvl),
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((_, i) {
                                final f = grouped[lvl]![i];
                                final displayName =
                                    i18n.classFeatureName(cls.name, f.name) ??
                                    f.name;
                                final displayDesc =
                                    i18n.classFeatureDescription(
                                      cls.name,
                                      f.name,
                                    ) ??
                                    f.description;
                                final badge = f.type == 'subclass'
                                    ? subclassFeature
                                    : null;
                                return _FeatureTile(
                                  name: displayName,
                                  description: displayDesc,
                                  badge: badge,
                                );
                              }, childCount: grouped[lvl]!.length),
                            ),
                          ),
                        ),
                        if (cls.subclasses.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: _sectionHeader(
                              context,
                              l10n.detailSheetAvailableSubclasses(
                                subclassFeature,
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((_, i) {
                              final sub = cls.subclasses[i];
                              final subName = i18n.subclassName(
                                cls.name,
                                sub.name,
                              );
                              final subDesc =
                                  i18n.subclassDescription(
                                    cls.name,
                                    sub.name,
                                  ) ??
                                  sub.description;
                              return ListTile(
                                title: Text(
                                  subName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: subDesc.isNotEmpty
                                    ? RulesText(
                                        subDesc,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      )
                                    : null,
                                dense: true,
                              );
                            }, childCount: cls.subclasses.length),
                          ),
                        ],
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height:
                                MediaQuery.of(context).viewPadding.bottom + 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Subclass detail sheet ─────────────────────────────────────────────────────

class _SubclassDetailSheet extends ConsumerStatefulWidget {
  const _SubclassDetailSheet({
    required this.cls,
    required this.sub,
    required this.i18n,
  });

  final ClassDetail cls;
  final SubclassSummary sub;
  final SrdI18nService i18n;

  @override
  ConsumerState<_SubclassDetailSheet> createState() =>
      _SubclassDetailSheetState();
}

class _SubclassDetailSheetState extends ConsumerState<_SubclassDetailSheet> {
  List<SrdClassFeature>? _features;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sourceFor(widget.cls.packId)
        .getAllSubclassFeatures()
        .then((all) {
          final features =
              all[widget.cls.name]?[widget.sub.name] ??
              const <SrdClassFeature>[];
          if (mounted) setState(() => _features = features);
        })
        .catchError((Object e) {
          if (mounted) setState(() => _error = e.toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final i18n = widget.i18n;
    final cls = widget.cls;
    final sub = widget.sub;
    final subName = i18n.subclassName(cls.name, sub.name);
    final subDesc =
        i18n.subclassDescription(cls.name, sub.name) ?? sub.description;

    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        final grouped = <int, List<SrdClassFeature>>{};
        if (_features != null) {
          for (final f in _features!) {
            grouped.putIfAbsent(f.level, () => []).add(f);
          }
        }
        final levels = grouped.keys.toList()..sort();

        return Column(
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subDesc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    RulesText(
                      subDesc,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _error != null
                  ? Center(child: Text(_error!))
                  : _features == null
                  ? const Center(child: CircularProgressIndicator())
                  : levels.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          l10n.detailSheetSubclassFeaturePlaceholder,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : CustomScrollView(
                      controller: scrollCtrl,
                      slivers: [
                        ...levels.map(
                          (lvl) => SliverStickyHeader(
                            header: _sectionHeader(
                              context,
                              l10n.charCardLevel(lvl),
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((_, i) {
                                final f = grouped[lvl]![i];
                                final displayName =
                                    i18n.subclassFeatureName(
                                      cls.name,
                                      sub.name,
                                      f.name,
                                    ) ??
                                    i18n.anySubclassFeatureName(
                                      sub.name,
                                      f.name,
                                    ) ??
                                    f.name;
                                final displayDesc =
                                    i18n.subclassFeatureDescription(
                                      cls.name,
                                      sub.name,
                                      f.name,
                                    ) ??
                                    i18n.anySubclassFeatureDescription(
                                      sub.name,
                                      f.name,
                                    ) ??
                                    f.description;
                                return _FeatureTile(
                                  name: displayName,
                                  description: displayDesc,
                                );
                              }, childCount: grouped[lvl]!.length),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height:
                                MediaQuery.of(context).viewPadding.bottom + 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Subclass selector ─────────────────────────────────────────────────────────

/// Subclass choice under the selected class in character creation. The
/// player may choose it before the class level at which it applies.
class SubclassSelector extends StatelessWidget {
  const SubclassSelector({
    super.key,
    required this.cls,
    required this.i18n,
    required this.selected,
    required this.onSelect,
  });

  final ClassDetail cls;
  final SrdI18nService i18n;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final subclassFeature =
        i18n.classSubclassFeatureName(cls.name) ?? cls.subclassFeatureName;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.stepChooseSubclassPrompt(subclassFeature, cls.subclassLevel),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          ...cls.subclasses.map((sub) {
            final isSelected = selected == sub.name;
            final subName = i18n.subclassName(cls.name, sub.name);
            final subDesc =
                i18n.subclassDescription(cls.name, sub.name) ?? sub.description;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: isSelected ? scheme.secondaryContainer : scheme.surface,
              child: InkWell(
                onTap: () => onSelect(isSelected ? null : sub.name),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subName,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            RulesText(
                              subDesc,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: isSelected
                              ? scheme.onSecondaryContainer
                              : scheme.onSurfaceVariant,
                          size: 20,
                        ),
                        tooltip: l10n.detailSheetInfoTooltip,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            showSubclassDetailSheet(context, cls, sub, i18n),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: scheme.secondary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Race detail sheet ─────────────────────────────────────────────────────────

class _RaceDetailSheet extends ConsumerStatefulWidget {
  const _RaceDetailSheet({required this.race, required this.i18n});

  final SpeciesDetail race;
  final SrdI18nService i18n;

  @override
  ConsumerState<_RaceDetailSheet> createState() => _RaceDetailSheetState();
}

class _RaceDetailSheetState extends ConsumerState<_RaceDetailSheet> {
  Map<String, String>? _traitDescriptions;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sourceFor(widget.race.packId)
        .getRaceTraits()
        .then((traits) {
          if (mounted) setState(() => _traitDescriptions = traits);
        })
        .catchError((Object e) {
          if (mounted) setState(() => _error = e.toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final i18n = widget.i18n;
    final race = widget.race;
    final raceName = i18n.raceName(race.name);
    final asiText = [
      for (final entry in race.abilityIncreases.entries)
        '+${entry.value} ${abilityName(l10n, entry.key)}',
      if (race.freeAbilityIncreases > 0) '${race.freeAbilityIncreases}x +1',
    ].join(', ');
    final sizeText = race.sizes
        .map((size) => size == 'Small' ? l10n.creation2024SizeSmall : l10n.creation2024SizeMedium)
        .join(' / ');

    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const _SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  raceName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    '${l10n.stepRaceSpeedLabel}: ${formatDistance(race.speed, ref.watch(unitSystemProvider))}',
                    if (sizeText.isNotEmpty) '${l10n.creation2024Size}: $sizeText',
                    if (asiText.isNotEmpty) '${l10n.stepRaceASILabel}: $asiText',
                  ].join('  ·  '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _error != null
                ? Center(child: Text(_error!))
                : _traitDescriptions == null
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    controller: scrollCtrl,
                    slivers: [
                      if (race.traits.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _sectionHeader(
                            context,
                            l10n.detailSheetTraits,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((_, i) {
                            final traitKey = race.traits[i];
                            final displayName = i18n.raceTraitName(traitKey);
                            final displayDesc =
                                i18n.raceTraitDescription(traitKey) ??
                                _traitDescriptions![traitKey] ??
                                '';
                            return _FeatureTile(
                              name: displayName,
                              description: displayDesc,
                            );
                          }, childCount: race.traits.length),
                        ),
                      ],
                      if (race.lineages.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _sectionHeader(context, l10n.detailSheetLineages),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => ListTile(
                              title: Text(
                                i18n.optionSourceName(race.lineages[i].id) ?? race.lineages[i].name,
                                style: const TextStyle(fontSize: 14),
                              ),
                              dense: true,
                            ),
                            childCount: race.lineages.length,
                          ),
                        ),
                      ],
                      if (race.subraces.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _sectionHeader(
                            context,
                            l10n.detailSheetAvailableSubraces,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((_, i) {
                            final sub = race.subraces[i];
                            final subName = i18n.subraceName(sub.name);
                            final subAsiText = sub.abilityScoreIncreases.entries
                                .map(
                                  (e) =>
                                      '+${e.value} ${abilityName(l10n, e.key)}',
                                )
                                .join(', ');
                            return ListTile(
                              title: Text(
                                subName,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: subAsiText.isNotEmpty
                                  ? Text(
                                      '${l10n.stepRaceASILabel}: $subAsiText',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    )
                                  : null,
                              dense: true,
                            );
                          }, childCount: race.subraces.length),
                        ),
                      ],
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height:
                              MediaQuery.of(context).viewPadding.bottom + 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Subrace detail sheet ──────────────────────────────────────────────────────

class _SubraceDetailSheet extends ConsumerStatefulWidget {
  const _SubraceDetailSheet({
    required this.race,
    required this.subrace,
    required this.i18n,
  });

  final SrdRace race;
  final SrdSubrace subrace;
  final SrdI18nService i18n;

  @override
  ConsumerState<_SubraceDetailSheet> createState() =>
      _SubraceDetailSheetState();
}

class _SubraceDetailSheetState extends ConsumerState<_SubraceDetailSheet> {
  Map<String, String>? _traitDescriptions;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref
        .read(srdDataSourceProvider)
        .getRaceTraits()
        .then((traits) {
          if (mounted) setState(() => _traitDescriptions = traits);
        })
        .catchError((Object e) {
          if (mounted) setState(() => _error = e.toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final i18n = widget.i18n;
    final subrace = widget.subrace;
    final subName = i18n.subraceName(subrace.name);
    final asiText = subrace.abilityScoreIncreases.entries
        .map((e) => '+${e.value} ${abilityName(l10n, e.key)}')
        .join(', ');

    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const _SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (asiText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.stepRaceASILabel}: $asiText',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _error != null
                ? Center(child: Text(_error!))
                : _traitDescriptions == null
                ? const Center(child: CircularProgressIndicator())
                : subrace.traits.isEmpty
                ? const SizedBox.shrink()
                : CustomScrollView(
                    controller: scrollCtrl,
                    slivers: [
                      SliverToBoxAdapter(
                        child: _sectionHeader(context, l10n.detailSheetTraits),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((_, i) {
                          final traitKey = subrace.traits[i];
                          final displayName = i18n.raceTraitName(traitKey);
                          final displayDesc =
                              i18n.raceTraitDescription(traitKey) ??
                              _traitDescriptions![traitKey] ??
                              '';
                          return _FeatureTile(
                            name: displayName,
                            description: displayDesc,
                          );
                        }, childCount: subrace.traits.length),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height:
                              MediaQuery.of(context).viewPadding.bottom + 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
