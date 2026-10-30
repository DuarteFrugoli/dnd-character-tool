import 'package:dnd_character_tool/shared/widgets/rules_text.dart';
import 'package:flutter/material.dart';

import '../../data/custom_background.dart';
import '../../data/datasources/srd/srd_2024_creation_catalog.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../l10n/ability_l10n.dart';
import '../../l10n/app_localizations.dart';
import 'creation_2024_draft.dart';

/// Builds a 2024 background: three abilities for the increases, an Origin
/// feat, two skills, one tool of any kind (picked with the other tools) and
/// 50 GP instead of an equipment package.
Future<Creation2024Background?> openCustomBackground2024Page(
  BuildContext context, {
  required Creation2024Catalog catalog,
  required SrdI18nService i18n,
  Creation2024Background? initial,
}) {
  return Navigator.of(context).push<Creation2024Background>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _CustomBackground2024Page(
        catalog: catalog,
        i18n: i18n,
        initial: initial,
      ),
    ),
  );
}

class _CustomBackground2024Page extends StatefulWidget {
  const _CustomBackground2024Page({
    required this.catalog,
    required this.i18n,
    this.initial,
  });

  final Creation2024Catalog catalog;
  final SrdI18nService i18n;
  final Creation2024Background? initial;

  @override
  State<_CustomBackground2024Page> createState() => _CustomBackground2024PageState();
}

class _CustomBackground2024PageState extends State<_CustomBackground2024Page> {
  late final TextEditingController _name;
  final Set<String> _abilities = {};
  final Set<String> _skills = {};
  String? _feat;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _abilities.addAll(initial?.abilities ?? const []);
    _skills.addAll(initial?.skills ?? const []);
    _feat = initial?.featName;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Creation2024Background? get _result {
    final name = _name.text.trim();
    if (name.isEmpty ||
        _feat == null ||
        _abilities.length != CustomBackground.abilityCount2024 ||
        _skills.length != CustomBackground.skillCount) {
      return null;
    }
    return Creation2024Background.custom(
      name: name,
      abilities: [
        for (final ability in creation2024Abilities)
          if (_abilities.contains(ability)) ability,
      ],
      featName: _feat!,
      skills: _skills.toList(),
      toolCategories: {for (final tool in widget.catalog.tools) tool.category}.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final i18n = widget.i18n;
    final result = _result;
    final originFeats = [
      for (final feat in widget.catalog.feats)
        if (feat.category == 'origin') feat,
    ];
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
          Text(
            l10n.customBackgroundAbilities(CustomBackground.abilityCount2024),
            style: theme.textTheme.titleSmall,
          ),
          Wrap(
            spacing: 6,
            children: [
              for (final ability in creation2024Abilities)
                FilterChip(
                  label: Text(abilityName(l10n, ability)),
                  selected: _abilities.contains(ability),
                  onSelected: (selected) => setState(() {
                    if (!selected) {
                      _abilities.remove(ability);
                    } else if (_abilities.length < CustomBackground.abilityCount2024) {
                      _abilities.add(ability);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.creation2024OriginFeat, style: theme.textTheme.titleSmall),
          RadioGroup<String>(
            groupValue: _feat,
            onChanged: (value) => setState(() => _feat = value),
            child: Column(
              children: [
                for (final feat in originFeats)
                  RadioListTile<String>(
                    value: feat.name,
                    title: Text(i18n.featName(feat.name) ?? feat.name),
                    subtitle: RulesText(
                      i18n.featDescription(feat.name) ?? feat.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.customBackgroundSkills(CustomBackground.skillCount),
            style: theme.textTheme.titleSmall,
          ),
          Wrap(
            spacing: 6,
            children: [
              for (final skill in widget.catalog.skills)
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
          Text(l10n.customBackgroundTool2024, style: theme.textTheme.bodySmall),
          Text(
            l10n.customBackgroundGold2024(CustomBackground.gold2024),
            style: theme.textTheme.bodySmall,
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
  }
}
