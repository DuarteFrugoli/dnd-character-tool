import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../core/units/unit_system_provider.dart';
import '../../core/units/unit_formatter.dart';
import '../providers/providers.dart';

// ── Public helpers ────────────────────────────────────────────────────────────

void showClassDetailSheet(
  BuildContext context,
  SrdClass cls,
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
  SrdClass cls,
  SrdSubclass sub,
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
  SrdRace race,
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
            child: Text(
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

  final SrdClass cls;
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
    ref
        .read(srdDataSourceProvider)
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
                  if (cls.isSpellcaster && cls.spellcastingAbility != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.stepSpellcastingLabel}: ${abilityName(l10n, cls.spellcastingAbility!)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: scheme.primary),
                    ),
                  ],
                  if (cls.armorProficiencies.isNotEmpty ||
                      cls.weaponProficiencies.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.detailSheetProficiencies}: '
                      '${[...cls.armorProficiencies, ...cls.weaponProficiencies].join(', ')}',
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
                                    ? Text(
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

  final SrdClass cls;
  final SrdSubclass sub;
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
    ref
        .read(srdDataSourceProvider)
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
                    Text(
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

// ── Race detail sheet ─────────────────────────────────────────────────────────

class _RaceDetailSheet extends ConsumerStatefulWidget {
  const _RaceDetailSheet({required this.race, required this.i18n});

  final SrdRace race;
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
    final race = widget.race;
    final raceName = i18n.raceName(race.name);
    final asiText = [
      for (final entry in race.abilityScoreIncreases.entries)
        '+${entry.value} ${abilityName(l10n, entry.key)}',
      if (race.freeAsiPoints > 0) '${race.freeAsiPoints}x +1',
    ].join(', ');

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
                  '${l10n.stepRaceSpeedLabel}: ${formatDistance(race.speed, ref.watch(unitSystemProvider))}  ·  '
                  '${l10n.stepRaceASILabel}: $asiText',
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
