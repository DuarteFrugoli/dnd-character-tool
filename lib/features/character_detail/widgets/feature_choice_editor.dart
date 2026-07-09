part of '../character_detail_screen.dart';

class _FeatureChoiceEditor extends StatefulWidget {
  const _FeatureChoiceEditor({
    required this.requests,
    required this.initialChoices,
    required this.catalog,
    required this.character,
    required this.i18n,
    required this.skills,
    required this.tools,
    required this.spells,
    required this.onChanged,
  });

  final List<FeatureChoiceRequest> requests;
  final List<CharacterFeatureChoice> initialChoices;
  final SrdFeatureChoiceCatalog catalog;
  final Character character;
  final SrdI18nService i18n;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final ValueChanged<List<CharacterFeatureChoice>> onChanged;

  @override
  State<_FeatureChoiceEditor> createState() => _FeatureChoiceEditorState();
}

class _FeatureChoiceEditorState extends State<_FeatureChoiceEditor> {
  late Map<String, List<String>> _values;

  @override
  void initState() {
    super.initState();
    _values = _initialValues();
  }

  @override
  void didUpdateWidget(covariant _FeatureChoiceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requests != widget.requests ||
        oldWidget.initialChoices != widget.initialChoices) {
      _values = _initialValues();
    }
  }

  Map<String, List<String>> _initialValues() {
    return {
      for (final request in widget.requests)
        request.key: List<String>.from(
          request.findIn(widget.initialChoices)?.values ?? const [],
        ),
    };
  }

  void _emit() {
    widget.onChanged([
      for (final request in widget.requests)
        request.toChoice(_values[request.key] ?? const []),
    ]);
  }

  void _setSingle(FeatureChoiceRequest request, String value) {
    setState(() {
      _values[request.key] = [value];
    });
    _emit();
  }

  void _toggle(FeatureChoiceRequest request, String value, bool selected) {
    setState(() {
      final current = List<String>.from(_values[request.key] ?? const []);
      if (selected) {
        if (!current.contains(value) && current.length < request.requiredCount) {
          current.add(value);
        }
      } else {
        current.remove(value);
      }
      _values[request.key] = current;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.requests.isEmpty) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppLocalizations.of(context)!.featureChoicesTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final request in widget.requests) _buildRequest(context, request),
      ],
    );
  }

  Widget _buildRequest(BuildContext context, FeatureChoiceRequest request) {
    final l10n = AppLocalizations.of(context)!;
    final values = _values[request.key] ?? const [];
    final options = _optionsFor(request);
    final complete = values.length >= request.requiredCount;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.featureName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Chip(
                  label: Text(
                    l10n.featureChoicesSelectedCount(
                      values.length,
                      request.requiredCount,
                    ),
                  ),
                  backgroundColor:
                      complete ? scheme.primaryContainer : scheme.errorContainer,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.featureChoicesChooseCount(
                _choiceLabel(request.requirement),
                request.requiredCount,
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.featureChoicesChooseDependencyFirst,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              )
            else if (request.requiredCount == 1)
              RadioGroup<String>(
                groupValue: values.firstOrNull,
                onChanged: (value) {
                  if (value != null) _setSingle(request, value);
                },
                child: Column(
                  children: [
                    for (final option in options)
                      RadioListTile<String>(
                        value: option.id,
                        dense: true,
                        title: Text(option.name),
                        subtitle: option.description == null
                            ? null
                            : Text(option.description!),
                      ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (final option in options)
                    CheckboxListTile(
                      value: values.contains(option.id),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(option.name),
                      subtitle: option.description == null
                          ? null
                          : Text(option.description!),
                      onChanged: (checked) {
                        _toggle(request, option.id, checked ?? false);
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<SrdFeatureChoiceOption> _optionsFor(FeatureChoiceRequest request) {
    final req = request.requirement;
    if (req.options.isNotEmpty) return _featureOptions(request, req.options);
    if (req.optionsSource != null) {
      return _featureOptions(
        request,
        widget.catalog.optionSources[req.optionsSource!] ?? const [],
        optionsSource: req.optionsSource,
      );
    }

    switch (req.type) {
      case 'skill':
        return _skillOptions();
      case 'skill_expertise':
        return _skillOptions(onlyProficient: true);
      case 'skill_or_tool':
        return [
          ..._skillOptions(prefix: true),
          ...widget.tools.map(
            (tool) => SrdFeatureChoiceOption(
              id: 'tool:${_idFromName(tool.name)}',
              name: widget.i18n.toolName(tool.name),
              description: tool.category,
            ),
          ),
          if (req.allowThievesTools)
            SrdFeatureChoiceOption(
              id: 'tool:thieves_tools',
              name: widget.i18n.toolName("Thieves' Tools"),
              description: 'Tool',
            ),
        ];
      case 'skill_or_tool_expertise':
        return [
          ..._skillOptions(onlyProficient: true, prefix: true),
          if (req.allowThievesTools)
            SrdFeatureChoiceOption(
              id: 'tool:thieves_tools',
              name: widget.i18n.toolName("Thieves' Tools"),
              description: 'Tool',
            ),
        ];
      case 'tool':
        return widget.tools
            .map(
              (tool) => SrdFeatureChoiceOption(
                id: _idFromName(tool.name),
                name: widget.i18n.toolName(tool.name),
                description: tool.category,
              ),
            )
            .toList();
      case 'language':
        return _languageOptions
            .map(
              (option) => SrdFeatureChoiceOption(
                id: option.id,
                name: widget.i18n.languageName(option.name),
                description: option.description,
              ),
            )
            .toList();
      case 'cantrip':
      case 'spell':
        return _spellOptions(request);
      case 'weapon':
        return _basicWeaponOptions
            .map(
              (option) => SrdFeatureChoiceOption(
                id: option.id,
                name: widget.i18n.equipmentName(option.name),
                description: option.description,
              ),
            )
            .toList();
      default:
        return const [];
    }
  }

  List<SrdFeatureChoiceOption> _featureOptions(
    FeatureChoiceRequest request,
    Iterable<SrdFeatureChoiceOption> options, {
    String? optionsSource,
  }) {
    return options
        .map(
          (option) => SrdFeatureChoiceOption(
            id: option.id,
            name: widget.i18n.featureChoiceOptionName(
                  sourceType: request.sourceType,
                  sourceClass: request.sourceClass,
                  sourceSubclass: request.sourceSubclass,
                  sourceName: request.sourceName,
                  featureName: request.featureName,
                  choiceId: request.choiceId,
                  optionId: option.id,
                  optionsSource: optionsSource,
                ) ??
                option.name,
            description: widget.i18n.featureChoiceOptionDescription(
                  sourceType: request.sourceType,
                  sourceClass: request.sourceClass,
                  sourceSubclass: request.sourceSubclass,
                  sourceName: request.sourceName,
                  featureName: request.featureName,
                  choiceId: request.choiceId,
                  optionId: option.id,
                  optionsSource: optionsSource,
                ) ??
                option.description,
          ),
        )
        .toList();
  }

  List<SrdFeatureChoiceOption> _skillOptions({
    bool onlyProficient = false,
    bool prefix = false,
  }) {
    final proficiencies = widget.character.skillProficiencies
        .map((skill) => skill.toLowerCase())
        .toSet();
    final skills = onlyProficient && proficiencies.isNotEmpty
        ? widget.skills
            .where((skill) => proficiencies.contains(skill.name.toLowerCase()))
        : widget.skills;
    return skills
        .map(
          (skill) => SrdFeatureChoiceOption(
            id: prefix
                ? 'skill:${_idFromName(skill.name)}'
                : _idFromName(skill.name),
            name: widget.i18n.skillName(skill.name),
            description: skill.ability.toUpperCase(),
          ),
        )
        .toList();
  }

  List<SrdFeatureChoiceOption> _spellOptions(FeatureChoiceRequest request) {
    final req = request.requirement;
    final spellClass = req.spellClass ?? _selectedSpellClass();
    if (spellClass == null || spellClass.isEmpty) return const [];
    final anyClass = spellClass == 'any';
    final spellLevel = req.type == 'cantrip' ? 0 : req.spellLevel;
    final minSpellLevel = req.minSpellLevel ?? (req.type == 'spell' ? 1 : 0);
    final maxSpellLevel = req.maxSpellLevelAtLevel(request.level);
    return widget.spells
        .where((spell) =>
            anyClass || spell.classes.contains(spellClass.toLowerCase()))
        .where((spell) {
          if (spellLevel != null) return spell.level == spellLevel;
          if (spell.level < minSpellLevel) return false;
          return maxSpellLevel == null || spell.level <= maxSpellLevel;
        })
        .map(
          (spell) => SrdFeatureChoiceOption(
            id: spell.name,
            name: widget.i18n.spellName(spell.name),
            description: spell.level == 0
                ? widget.i18n.spellSchool(spell.school)
                : '${spell.level} - ${widget.i18n.spellSchool(spell.school)}',
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  String? _selectedSpellClass() {
    for (final request in widget.requests) {
      if (request.choiceId != 'spell_class') continue;
      final values = _values[request.key];
      if (values != null && values.isNotEmpty) return values.first;
    }
    return null;
  }

  static String _idFromName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), '_')
        .replaceAll(RegExp(r'_+$'), '')
        .replaceAll(RegExp(r'^_+'), '');
  }

  static String _choiceLabel(SrdFeatureChoiceRequirement requirement) {
    switch (requirement.type) {
      case 'ability':
        return 'ability';
      case 'cantrip':
        return 'cantrip';
      case 'damageType':
        return 'damage type';
      case 'language':
        return 'language';
      case 'maneuver':
        return 'maneuver';
      case 'skill':
      case 'skill_expertise':
        return 'skill';
      case 'skill_or_tool':
      case 'skill_or_tool_expertise':
        return 'skill or tool';
      case 'spell':
        return 'spell';
      case 'tool':
        return 'tool';
      case 'weapon':
        return 'weapon';
      default:
        return 'option';
    }
  }
}

const _languageOptions = [
  SrdFeatureChoiceOption(id: 'common', name: 'Common'),
  SrdFeatureChoiceOption(id: 'dwarvish', name: 'Dwarvish'),
  SrdFeatureChoiceOption(id: 'elvish', name: 'Elvish'),
  SrdFeatureChoiceOption(id: 'giant', name: 'Giant'),
  SrdFeatureChoiceOption(id: 'gnomish', name: 'Gnomish'),
  SrdFeatureChoiceOption(id: 'goblin', name: 'Goblin'),
  SrdFeatureChoiceOption(id: 'halfling', name: 'Halfling'),
  SrdFeatureChoiceOption(id: 'orc', name: 'Orc'),
  SrdFeatureChoiceOption(id: 'abyssal', name: 'Abyssal'),
  SrdFeatureChoiceOption(id: 'celestial', name: 'Celestial'),
  SrdFeatureChoiceOption(id: 'draconic', name: 'Draconic'),
  SrdFeatureChoiceOption(id: 'deep_speech', name: 'Deep Speech'),
  SrdFeatureChoiceOption(id: 'infernal', name: 'Infernal'),
  SrdFeatureChoiceOption(id: 'primordial', name: 'Primordial'),
  SrdFeatureChoiceOption(id: 'sylvan', name: 'Sylvan'),
  SrdFeatureChoiceOption(id: 'undercommon', name: 'Undercommon'),
];

const _basicWeaponOptions = [
  SrdFeatureChoiceOption(id: 'club', name: 'Club'),
  SrdFeatureChoiceOption(id: 'dagger', name: 'Dagger'),
  SrdFeatureChoiceOption(id: 'greatclub', name: 'Greatclub'),
  SrdFeatureChoiceOption(id: 'handaxe', name: 'Handaxe'),
  SrdFeatureChoiceOption(id: 'javelin', name: 'Javelin'),
  SrdFeatureChoiceOption(id: 'light_hammer', name: 'Light Hammer'),
  SrdFeatureChoiceOption(id: 'mace', name: 'Mace'),
  SrdFeatureChoiceOption(id: 'quarterstaff', name: 'Quarterstaff'),
  SrdFeatureChoiceOption(id: 'sickle', name: 'Sickle'),
  SrdFeatureChoiceOption(id: 'spear', name: 'Spear'),
  SrdFeatureChoiceOption(id: 'crossbow_light', name: 'Crossbow, Light'),
  SrdFeatureChoiceOption(id: 'dart', name: 'Dart'),
  SrdFeatureChoiceOption(id: 'shortbow', name: 'Shortbow'),
  SrdFeatureChoiceOption(id: 'sling', name: 'Sling'),
  SrdFeatureChoiceOption(id: 'battleaxe', name: 'Battleaxe'),
  SrdFeatureChoiceOption(id: 'flail', name: 'Flail'),
  SrdFeatureChoiceOption(id: 'glaive', name: 'Glaive'),
  SrdFeatureChoiceOption(id: 'greataxe', name: 'Greataxe'),
  SrdFeatureChoiceOption(id: 'greatsword', name: 'Greatsword'),
  SrdFeatureChoiceOption(id: 'halberd', name: 'Halberd'),
  SrdFeatureChoiceOption(id: 'lance', name: 'Lance'),
  SrdFeatureChoiceOption(id: 'longsword', name: 'Longsword'),
  SrdFeatureChoiceOption(id: 'maul', name: 'Maul'),
  SrdFeatureChoiceOption(id: 'morningstar', name: 'Morningstar'),
  SrdFeatureChoiceOption(id: 'pike', name: 'Pike'),
  SrdFeatureChoiceOption(id: 'rapier', name: 'Rapier'),
  SrdFeatureChoiceOption(id: 'scimitar', name: 'Scimitar'),
  SrdFeatureChoiceOption(id: 'shortsword', name: 'Shortsword'),
  SrdFeatureChoiceOption(id: 'trident', name: 'Trident'),
  SrdFeatureChoiceOption(id: 'war_pick', name: 'War Pick'),
  SrdFeatureChoiceOption(id: 'warhammer', name: 'Warhammer'),
  SrdFeatureChoiceOption(id: 'whip', name: 'Whip'),
  SrdFeatureChoiceOption(id: 'blowgun', name: 'Blowgun'),
  SrdFeatureChoiceOption(id: 'crossbow_hand', name: 'Crossbow, Hand'),
  SrdFeatureChoiceOption(id: 'crossbow_heavy', name: 'Crossbow, Heavy'),
  SrdFeatureChoiceOption(id: 'longbow', name: 'Longbow'),
  SrdFeatureChoiceOption(id: 'net', name: 'Net'),
];

String _featureChoiceValueLabel(
  String value,
  List<FeatureChoiceRequest> requests,
  SrdFeatureChoiceCatalog catalog,
  SrdI18nService i18n,
  List<SrdSkill> skills,
  List<SrdTool> tools,
  List<SrdSpell> spells,
) {
  for (final request in requests) {
    final temp = _FeatureChoiceOptionResolver(
      request: request,
      catalog: catalog,
      i18n: i18n,
      skills: skills,
      tools: tools,
      spells: spells,
    );
    final label = temp.labelFor(value);
    if (label != null) return label;
  }
  return value;
}

class _FeatureChoiceOptionResolver {
  _FeatureChoiceOptionResolver({
    required this.request,
    required this.catalog,
    required this.i18n,
    required this.skills,
    required this.tools,
    required this.spells,
  });

  final FeatureChoiceRequest request;
  final SrdFeatureChoiceCatalog catalog;
  final SrdI18nService i18n;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;

  String? labelFor(String value) {
    final featureOption = _featureOption(value);
    if (featureOption != null) {
      return i18n.featureChoiceOptionName(
            sourceType: request.sourceType,
            sourceClass: request.sourceClass,
            sourceSubclass: request.sourceSubclass,
            sourceName: request.sourceName,
            featureName: request.featureName,
            choiceId: request.choiceId,
            optionId: featureOption.id,
            optionsSource: request.requirement.optionsSource,
          ) ??
          featureOption.name;
    }

    for (final option in _dynamicOptions()) {
      if (option.id == value) return option.name;
    }
    return null;
  }

  String? descriptionFor(String value) {
    final featureOption = _featureOption(value);
    if (featureOption != null) {
      return i18n.featureChoiceOptionDescription(
            sourceType: request.sourceType,
            sourceClass: request.sourceClass,
            sourceSubclass: request.sourceSubclass,
            sourceName: request.sourceName,
            featureName: request.featureName,
            choiceId: request.choiceId,
            optionId: featureOption.id,
            optionsSource: request.requirement.optionsSource,
          ) ??
          featureOption.description;
    }

    for (final option in _dynamicOptions()) {
      if (option.id == value) return option.description;
    }
    return null;
  }

  List<SrdFeatureChoiceOption> _dynamicOptions() {
    return [
      ...skills.map(
        (skill) => SrdFeatureChoiceOption(
          id: _FeatureChoiceEditorState._idFromName(skill.name),
          name: i18n.skillName(skill.name),
          description: skill.ability.toUpperCase(),
        ),
      ),
      ...skills.map(
        (skill) => SrdFeatureChoiceOption(
          id: 'skill:${_FeatureChoiceEditorState._idFromName(skill.name)}',
          name: i18n.skillName(skill.name),
          description: skill.ability.toUpperCase(),
        ),
      ),
      ...tools.map(
        (tool) => SrdFeatureChoiceOption(
          id: _FeatureChoiceEditorState._idFromName(tool.name),
          name: i18n.toolName(tool.name),
          description: tool.category,
        ),
      ),
      ...tools.map(
        (tool) => SrdFeatureChoiceOption(
          id: 'tool:${_FeatureChoiceEditorState._idFromName(tool.name)}',
          name: i18n.toolName(tool.name),
          description: tool.category,
        ),
      ),
      if (request.requirement.allowThievesTools)
        SrdFeatureChoiceOption(
          id: 'tool:thieves_tools',
          name: i18n.toolName("Thieves' Tools"),
          description: 'Tool',
        ),
      ..._languageOptions.map(
        (option) => SrdFeatureChoiceOption(
          id: option.id,
          name: i18n.languageName(option.name),
        ),
      ),
      ..._basicWeaponOptions.map(
        (option) => SrdFeatureChoiceOption(
          id: option.id,
          name: i18n.equipmentName(option.name),
        ),
      ),
      ...spells.map((spell) => SrdFeatureChoiceOption(
            id: spell.name,
            name: i18n.spellName(spell.name),
            description: spell.level == 0
                ? i18n.spellSchool(spell.school)
                : '${spell.level} - ${i18n.spellSchool(spell.school)}',
          )),
    ];
  }

  SrdFeatureChoiceOption? _featureOption(String value) {
    SrdFeatureChoiceOption? option;
    for (final candidate in request.requirement.options) {
      if (candidate.id == value) option = candidate;
    }
    final optionsSource = request.requirement.optionsSource;
    if (option == null && optionsSource != null) {
      for (final candidate in catalog.optionSources[optionsSource] ?? const []) {
        if (candidate.id == value) option = candidate;
      }
    }
    return option;
  }
}
