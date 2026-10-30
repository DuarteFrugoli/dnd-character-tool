import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/custom_background.dart';
import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../shared/providers/providers.dart';

/// Builds a 2014 background following "Customizing a Background": a feature
/// from any background, two skills, two tools or languages in total and the
/// equipment package of a background.
Future<SrdBackground?> openCustomBackground2014Page(
  BuildContext context, {
  SrdBackground? initial,
}) {
  return Navigator.of(context).push<SrdBackground>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _CustomBackground2014Page(initial: initial),
    ),
  );
}

class _CustomBackground2014Page extends ConsumerStatefulWidget {
  const _CustomBackground2014Page({this.initial});

  final SrdBackground? initial;

  @override
  ConsumerState<_CustomBackground2014Page> createState() =>
      _CustomBackground2014PageState();
}

class _CustomBackground2014PageState
    extends ConsumerState<_CustomBackground2014Page> {
  late final TextEditingController _name;
  late final Future<(List<SrdBackground>, List<SrdSkill>, List<SrdTool>)> _data;
  String? _featureSource;
  String? _equipmentSource;
  final Set<String> _skills = {};
  final Set<String> _tools = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _featureSource = initial?.featureSource;
    _skills.addAll(initial?.skillProficiencies ?? const []);
    _tools.addAll(initial?.toolProficiencies ?? const []);
    _data = _load();
  }

  Future<(List<SrdBackground>, List<SrdSkill>, List<SrdTool>)> _load() async {
    final srd = ref.read(srdDataSourceProvider);
    return (await srd.getBackgrounds(), await srd.getSkills(), await srd.getTools());
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  SrdBackground? _build(List<SrdBackground> backgrounds) {
    final featureBackground =
        backgrounds.where((b) => b.name == _featureSource).firstOrNull;
    final equipmentBackground =
        backgrounds.where((b) => b.name == _equipmentSource).firstOrNull;
    final name = _name.text.trim();
    if (name.isEmpty ||
        featureBackground == null ||
        equipmentBackground == null ||
        _skills.length != CustomBackground.skillCount ||
        _tools.length > CustomBackground.toolsAndLanguages2014) {
      return null;
    }
    return SrdBackground(
      name: name,
      skillProficiencies: _skills.toList(),
      toolProficiencies: _tools.toList(),
      languages: CustomBackground.toolsAndLanguages2014 - _tools.length,
      startingEquipment: equipmentBackground.startingEquipment,
      feature: featureBackground.feature,
      variants: const [],
      featureSource: featureBackground.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final i18n = ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.customBackgroundTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final (backgrounds, skills, tools) = data;
        _equipmentSource ??= widget.initial == null
            ? null
            : backgrounds
                  .where((b) => _sameList(b.startingEquipment, widget.initial!.startingEquipment))
                  .firstOrNull
                  ?.name;
        final result = _build(backgrounds);
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.customBackgroundTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.customBackgroundName),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _featureSource,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.customBackgroundFeature),
                items: [
                  for (final bg in backgrounds)
                    DropdownMenuItem(
                      value: bg.name,
                      child: Text(
                        '${i18n.backgroundFeatureName(bg.name) ?? bg.feature.name} '
                        '(${i18n.backgroundName(bg.name)})',
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _featureSource = value),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.customBackgroundSkills(CustomBackground.skillCount),
                style: theme.textTheme.titleSmall,
              ),
              Wrap(
                spacing: 6,
                children: [
                  for (final skill in skills)
                    FilterChip(
                      label: Text(i18n.skillName(skill.name)),
                      selected: _skills.contains(skill.name.toLowerCase()),
                      onSelected: (selected) => setState(() {
                        final id = skill.name.toLowerCase();
                        if (!selected) {
                          _skills.remove(id);
                        } else if (_skills.length < CustomBackground.skillCount) {
                          _skills.add(id);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.customBackgroundTools2014(CustomBackground.toolsAndLanguages2014),
                style: theme.textTheme.titleSmall,
              ),
              Text(
                l10n.customBackgroundLanguages(
                  CustomBackground.toolsAndLanguages2014 - _tools.length,
                ),
                style: theme.textTheme.bodySmall,
              ),
              Wrap(
                spacing: 6,
                children: [
                  for (final tool in tools)
                    FilterChip(
                      label: Text(i18n.toolName(tool.name)),
                      selected: _tools.contains(tool.name),
                      onSelected: (selected) => setState(() {
                        if (!selected) {
                          _tools.remove(tool.name);
                        } else if (_tools.length < CustomBackground.toolsAndLanguages2014) {
                          _tools.add(tool.name);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _equipmentSource,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.customBackgroundEquipment2014),
                items: [
                  for (final bg in backgrounds)
                    DropdownMenuItem(value: bg.name, child: Text(i18n.backgroundName(bg.name))),
                ],
                onChanged: (value) => setState(() => _equipmentSource = value),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                onPressed: result == null ? null : () => Navigator.of(context).pop(result),
                child: Text(l10n.customBackgroundSave),
              ),
            ),
          ),
        );
      },
    );
  }

  static bool _sameList(List<String> a, List<String> b) =>
      a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((same) => same);
}
