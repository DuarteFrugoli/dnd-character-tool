import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/character_progression/character_progression.dart';
import '../../data/constants/level_up_rules.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/responsive_layout.dart';
import 'character_detail_provider.dart';
import 'level_up_wizard_sheet.dart';
import 'widgets/feature_choice_editor.dart';

Future<void> openLevelResetSheet(
  BuildContext context,
  Character character,
  String characterId,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => const _ResetLevelsConfirmDialog(),
  );
  if (confirmed != true || !context.mounted) return;

  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, _, _) =>
          _LevelResetFlow(character: character, characterId: characterId),
      transitionsBuilder: (_, animation, _, child) {
        final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 280),
    ),
  );
}

class _ResetLevelsConfirmDialog extends StatefulWidget {
  const _ResetLevelsConfirmDialog();

  @override
  State<_ResetLevelsConfirmDialog> createState() =>
      _ResetLevelsConfirmDialogState();
}

class _ResetLevelsConfirmDialogState extends State<_ResetLevelsConfirmDialog> {
  static const _initialDelaySeconds = 3;
  Timer? _timer;
  int _secondsRemaining = _initialDelaySeconds;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsRemaining = 0);
      } else if (mounted) {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.resetLevelsTitle),
      content: Text(l10n.resetLevelsConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton.tonal(
          onPressed: _secondsRemaining == 0
              ? () => Navigator.of(context).pop(true)
              : null,
          child: Text(
            _secondsRemaining == 0
                ? l10n.dialogContinue
                : l10n.resetLevelsCountdown(_secondsRemaining),
          ),
        ),
      ],
    );
  }
}

class _LevelResetFlow extends ConsumerStatefulWidget {
  const _LevelResetFlow({required this.character, required this.characterId});

  final Character character;
  final String characterId;

  @override
  ConsumerState<_LevelResetFlow> createState() => _LevelResetFlowState();
}

class _LevelResetFlowState extends ConsumerState<_LevelResetFlow> {
  _ResetLevelsData? _data;
  bool _loading = true;
  bool _loadingClassFeatures = false;
  bool _saving = false;
  String? _selectedClassName;
  String? _selectedSubclassName;
  List<SrdClassFeature> _classFeatures = const [];
  List<FeatureChoiceRequest> _featureChoiceRequests = const [];
  List<CharacterFeatureChoice> _featureChoices = const [];
  final Set<String> _selectedSkills = {};
  final Map<String, Set<String>> _selectedToolsByRequest = {};
  late bool _rebuildToPreviousLevel;

  @override
  void initState() {
    super.initState();
    _rebuildToPreviousLevel = widget.character.totalLevel > 1;
    _load();
  }

  SrdClass? get _selectedClass {
    final data = _data;
    final name = _selectedClassName;
    if (data == null || name == null) return null;
    return data.classes.firstWhereOrNull(
      (srdClass) => srdClass.name.toLowerCase() == name.toLowerCase(),
    );
  }

  bool get _needsSubclass {
    final srdClass = _selectedClass;
    return srdClass != null &&
        srdClass.subclassLevel == 1 &&
        srdClass.subclasses.isNotEmpty;
  }

  int get _initialHp {
    final srdClass = _selectedClass;
    if (srdClass == null) return 1;
    return (srdClass.hitDie +
            widget.character.abilityScores.constitutionModifier)
        .clamp(1, 9999)
        .toInt();
  }

  List<String> get _skillOptions {
    final data = _data;
    final srdClass = _selectedClass;
    if (data == null || srdClass == null) return const [];
    final from = srdClass.skillChoices.from;
    if (from.any((skill) => skill.toLowerCase() == 'any')) {
      return data.skills.map((skill) => skill.name).toList();
    }
    return from;
  }

  int get _skillChoiceCount => _selectedClass?.skillChoices.count ?? 0;

  List<_ToolChoiceRequest> get _toolChoiceRequests {
    final srdClass = _selectedClass;
    if (srdClass == null) return const [];
    final requests = <_ToolChoiceRequest>[];
    for (var i = 0; i < srdClass.toolProficiencies.length; i++) {
      final entry = srdClass.toolProficiencies[i];
      if (!_isToolChoice(entry)) continue;
      final lower = entry.toLowerCase();
      requests.add(
        _ToolChoiceRequest(
          id: 'class_tool_$i',
          count: _toolChoiceCountFor(entry),
          categories: {
            if (lower.contains('artisan')) 'artisans_tools',
            if (lower.contains('musical instrument')) 'musical_instruments',
            if (lower.contains('gaming set')) 'gaming_sets',
          },
        ),
      );
    }
    return requests;
  }

  List<String> get _fixedToolProficiencyLabels {
    final srdClass = _selectedClass;
    if (srdClass == null) return const [];
    return [
      for (final tool in srdClass.toolProficiencies)
        if (!_isToolChoice(tool) && tool.trim().isNotEmpty)
          'Tool Proficiency: ${tool.trim()}',
    ];
  }

  bool get _toolChoicesComplete {
    for (final request in _toolChoiceRequests) {
      final selected = _selectedToolsByRequest[request.id] ?? const <String>{};
      if (selected.length < request.count) return false;
    }
    return true;
  }

  bool get _isComplete {
    if (_selectedClass == null) return false;
    if (_needsSubclass && _selectedSubclassName == null) return false;
    if (_selectedSkills.length < _skillChoiceCount) return false;
    if (!_toolChoicesComplete) return false;
    return FeatureChoiceEngine.allComplete(
      _featureChoiceRequests,
      _featureChoices,
    );
  }

  bool get _canRebuildToPreviousLevel => widget.character.totalLevel > 1;

  bool get _shouldRebuildToPreviousLevel =>
      _canRebuildToPreviousLevel && _rebuildToPreviousLevel;

  int get _targetRebuildLevel =>
      widget.character.totalLevel.clamp(1, 20).toInt();

  Future<void> _load() async {
    final srd = ref.read(srdDataSourceProvider);
    final i18n =
        ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final results = await Future.wait([
      srd.getClasses(),
      srd.getAllSubclassFeatures(),
      srd.getFeatureChoiceCatalog(),
      srd.getSkills(),
      srd.getTools(),
      srd.getSpells(),
      srd.getLanguages(),
      srd.getWeapons(),
      srd.getFeats(),
    ]);
    if (!mounted) return;

    final data = _ResetLevelsData(
      classes: results[0] as List<SrdClass>,
      allSubclassFeatures:
          results[1] as Map<String, Map<String, List<SrdClassFeature>>>,
      catalog: results[2] as SrdFeatureChoiceCatalog,
      skills: results[3] as List<SrdSkill>,
      tools: results[4] as List<SrdTool>,
      spells: results[5] as List<SrdSpell>,
      languages: results[6] as List<SrdLanguage>,
      weapons: results[7] as List<SrdWeapon>,
      feats: results[8] as List<SrdFeat>,
      i18n: i18n,
    );
    final currentClass = data.classes.firstWhereOrNull(
      (srdClass) =>
          srdClass.name.toLowerCase() ==
          widget.character.primaryClassName.toLowerCase(),
    );
    final selectedClass = currentClass ?? data.classes.firstOrNull;
    _data = data;
    _selectedClassName = selectedClass?.name;
    _selectedSubclassName = _initialSubclassFor(selectedClass);
    await _loadClassFeaturesFor(_selectedClassName);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  String? _initialSubclassFor(SrdClass? srdClass) {
    if (srdClass == null || srdClass.subclassLevel != 1) return null;
    final current = widget.character.primarySubclassName;
    if (current == null) return null;
    final exists = srdClass.subclasses.any(
      (subclass) => subclass.name.toLowerCase() == current.toLowerCase(),
    );
    return exists ? current : null;
  }

  Future<void> _loadClassFeaturesFor(String? className) async {
    if (className == null) return;
    if (mounted) setState(() => _loadingClassFeatures = true);
    final features = await ref
        .read(srdDataSourceProvider)
        .getClassFeatures(className);
    if (!mounted || className != _selectedClassName) return;
    setState(() {
      _classFeatures = features;
      _loadingClassFeatures = false;
      _refreshFeatureChoices();
    });
  }

  void _selectClass(String? className) {
    if (className == null || className == _selectedClassName) return;
    setState(() {
      _selectedClassName = className;
      _selectedSubclassName = _initialSubclassFor(_selectedClass);
      _selectedSkills.clear();
      _selectedToolsByRequest.clear();
      _featureChoices = const [];
      _featureChoiceRequests = const [];
    });
    _loadClassFeaturesFor(className);
  }

  void _selectSubclass(String? subclassName) {
    setState(() {
      _selectedSubclassName = subclassName;
      _featureChoices = const [];
      _refreshFeatureChoices();
    });
  }

  void _refreshFeatureChoices() {
    final data = _data;
    final srdClass = _selectedClass;
    if (data == null || srdClass == null) {
      _featureChoiceRequests = const [];
      _featureChoices = const [];
      return;
    }

    final classFeatures = _classFeatures
        .where((feature) => feature.level == 1)
        .toList();
    final subclassFeatures = _selectedSubclassName == null
        ? const <SrdClassFeature>[]
        : data.allSubclassFeatures[srdClass.name]?[_selectedSubclassName]
                  ?.where((feature) => feature.level == 1)
                  .toList() ??
              const <SrdClassFeature>[];

    final requests = FeatureChoiceEngine.requestsForLevelUp(
      catalog: data.catalog,
      character: _previewCharacter(),
      newLevel: 1,
      newClassFeatures: classFeatures,
      newSubclassFeatures: subclassFeatures,
      targetClassEntryId: 'primary',
      targetClassName: srdClass.name,
      subclassName: _selectedSubclassName,
    );
    _featureChoiceRequests = requests;
    _featureChoices = [
      for (final request in requests)
        request.findIn(_featureChoices) ?? request.emptyChoice(),
    ];
  }

  Character _previewCharacter() {
    final srdClass = _selectedClass;
    if (srdClass == null) return widget.character;
    return CharacterLevelResetEngine.resetToLevelOne(
      widget.character,
      CharacterLevelResetResult(
        className: srdClass.name,
        subclassName: _selectedSubclassName,
        hitDie: srdClass.hitDie,
        savingThrowProficiencies: srdClass.savingThrows,
        skillProficiencies: _selectedSkills.toList(),
        proficiencyFeatureLabels: _proficiencyFeatureLabels(),
        featureChoices: _featureChoices,
      ),
    );
  }

  List<String> _proficiencyFeatureLabels() {
    final labels = <String>[..._fixedToolProficiencyLabels];
    for (final selected in _selectedToolsByRequest.values) {
      for (final tool in selected) {
        labels.add('Tool Proficiency: $tool');
      }
    }
    return _uniqueStrings(labels);
  }

  Future<void> _applyReset() async {
    final result = _buildResult();
    if (result == null) return;
    setState(() => _saving = true);
    try {
      var updated = CharacterLevelResetEngine.resetToLevelOne(
        widget.character,
        result,
      );
      var syncInnateSpellsAfterSave = result.subclassName != null;

      if (_shouldRebuildToPreviousLevel) {
        final rebuild = await _collectLevelUpRebuild(updated);
        if (!mounted) return;
        if (rebuild == null) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.resetLevelsRebuildCancelled,
              ),
            ),
          );
          return;
        }
        updated = rebuild.character;
        syncInnateSpellsAfterSave =
            syncInnateSpellsAfterSave || rebuild.syncInnateSpellsAfterSave;
      }

      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .saveRebuiltLevels(
            updated,
            syncInnateSpellsAfterSave: syncInnateSpellsAfterSave,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _shouldRebuildToPreviousLevel
                ? l10n.resetLevelsRebuiltApplied(updated.totalLevel)
                : l10n.resetLevelsApplied,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.detailErrorLoading(error.toString()),
          ),
        ),
      );
    }
  }

  Future<_CollectedLevelRebuild?> _collectLevelUpRebuild(
    Character levelOneCharacter,
  ) async {
    var current = levelOneCharacter;
    var syncInnateSpellsAfterSave = false;
    final targetLevel = _targetRebuildLevel;
    final messenger = ScaffoldMessenger.of(context);

    for (
      var nextLevel = current.totalLevel + 1;
      nextLevel <= targetLevel;
      nextLevel++
    ) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              AppLocalizations.of(
                context,
              )!.resetLevelsRebuildStep(nextLevel, targetLevel),
            ),
          ),
        );

      final levelUp = await openLevelUpWizardSheet(
        context,
        current,
        widget.characterId,
        applyOnConfirm: false,
      );
      if (!mounted) return null;
      messenger.hideCurrentSnackBar();
      if (levelUp == null) return null;

      current = CharacterProgressionEngine.applyLevelUp(current, levelUp);
      if (current.xpTrackingEnabled) {
        current = current.copyWith(
          experiencePoints: levelToMinXp(current.totalLevel),
        );
      }
      syncInnateSpellsAfterSave =
          syncInnateSpellsAfterSave || levelUp.subclassChosen != null;
    }

    return _CollectedLevelRebuild(
      character: current,
      syncInnateSpellsAfterSave: syncInnateSpellsAfterSave,
    );
  }

  CharacterLevelResetResult? _buildResult() {
    final srdClass = _selectedClass;
    if (srdClass == null || !_isComplete) return null;
    return CharacterLevelResetResult(
      className: srdClass.name,
      subclassName: _needsSubclass ? _selectedSubclassName : null,
      hitDie: srdClass.hitDie,
      savingThrowProficiencies: srdClass.savingThrows,
      skillProficiencies: _selectedSkills.toList(),
      proficiencyFeatureLabels: _proficiencyFeatureLabels(),
      featureChoices: _featureChoices
          .where((choice) => choice.values.isNotEmpty)
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = _data;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resetLevelsTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading || data == null
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveScaffoldBody(
              maxWidth: 840,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  _buildIntroCard(context),
                  const SizedBox(height: 16),
                  _buildClassSection(context, data),
                  if (_canRebuildToPreviousLevel) ...[
                    const SizedBox(height: 16),
                    _buildRebuildSection(context),
                  ],
                  const SizedBox(height: 16),
                  _buildSkillsSection(context, data),
                  if (_toolChoiceRequests.isNotEmpty ||
                      _fixedToolProficiencyLabels.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildToolsSection(context, data),
                  ],
                  if (_featureChoiceRequests.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildFeatureChoicesSection(context, data),
                  ],
                  const SizedBox(height: 16),
                  _buildSummarySection(context, data),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: _isComplete && !_saving ? _applyReset : null,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restart_alt),
          label: Text(
            _isComplete
                ? (_shouldRebuildToPreviousLevel
                      ? l10n.resetLevelsApplyAndRebuild(_targetRebuildLevel)
                      : l10n.resetLevelsApply)
                : l10n.resetLevelsIncomplete,
          ),
        ),
      ),
    );
  }

  Widget _buildRebuildSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: SwitchListTile(
        value: _rebuildToPreviousLevel,
        onChanged: _saving
            ? null
            : (value) => setState(() => _rebuildToPreviousLevel = value),
        secondary: const Icon(Icons.auto_fix_high),
        title: Text(l10n.resetLevelsRebuildTitle(_targetRebuildLevel)),
        subtitle: Text(l10n.resetLevelsRebuildSubtitle(_targetRebuildLevel)),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: scheme.error),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.resetLevelsIntro)),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSection(BuildContext context, _ResetLevelsData data) {
    final l10n = AppLocalizations.of(context)!;
    final srdClass = _selectedClass;
    return _ResetSection(
      title: l10n.creationStepClass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedClassName,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.creationStepClass),
            items: [
              for (final srdClass in data.classes)
                DropdownMenuItem(
                  value: srdClass.name,
                  child: Text(data.i18n.className(srdClass.name)),
                ),
            ],
            onChanged: _saving ? null : _selectClass,
          ),
          if (_needsSubclass) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubclassName,
              isExpanded: true,
              decoration: InputDecoration(
                labelText:
                    data.i18n.classSubclassFeatureName(srdClass!.name) ??
                    l10n.labelSubclass,
                helperText: l10n.resetLevelsSubclassRequired,
              ),
              items: [
                for (final subclass in srdClass.subclasses)
                  DropdownMenuItem(
                    value: subclass.name,
                    child: Text(
                      data.i18n.subclassName(srdClass.name, subclass.name),
                    ),
                  ),
              ],
              onChanged: _saving ? null : _selectSubclass,
            ),
          ],
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.favorite_outline,
            text: l10n.resetLevelsInitialHp(_initialHp),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, _ResetLevelsData data) {
    final l10n = AppLocalizations.of(context)!;
    if (_skillChoiceCount == 0) {
      return _ResetSection(
        title: l10n.creationStepSkills,
        child: Text(l10n.detailNone),
      );
    }
    return _ResetSection(
      title: l10n.creationStepSkills,
      trailing: _CountChip(
        current: _selectedSkills.length,
        total: _skillChoiceCount,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.resetLevelsSelectSkills(_skillChoiceCount)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in _skillOptions)
                FilterChip(
                  label: Text(data.i18n.skillName(skill)),
                  selected: _selectedSkills.contains(skill),
                  onSelected: _saving
                      ? null
                      : (selected) {
                          setState(() {
                            if (selected) {
                              if (_selectedSkills.length < _skillChoiceCount) {
                                _selectedSkills.add(skill);
                              }
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolsSection(BuildContext context, _ResetLevelsData data) {
    final l10n = AppLocalizations.of(context)!;
    final fixedTools = _fixedToolProficiencyLabels
        .map((label) => label.replaceFirst('Tool Proficiency: ', ''))
        .toList();
    final choiceRequests = _toolChoiceRequests;
    return _ResetSection(
      title: l10n.featuresTabTools,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fixedTools.isNotEmpty) ...[
            Text(l10n.resetLevelsFixedTools),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tool in fixedTools)
                  Chip(label: Text(data.i18n.toolName(tool))),
              ],
            ),
          ],
          for (var i = 0; i < choiceRequests.length; i++) ...[
            if (fixedTools.isNotEmpty || i > 0) const SizedBox(height: 12),
            _buildToolChoice(context, data, choiceRequests[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildToolChoice(
    BuildContext context,
    _ResetLevelsData data,
    _ToolChoiceRequest request,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final selected = _selectedToolsByRequest[request.id] ?? <String>{};
    final options = data.tools
        .where(
          (tool) =>
              request.categories.isEmpty ||
              request.categories.contains(tool.category),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.resetLevelsSelectTools(request.count))),
            _CountChip(current: selected.length, total: request.count),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tool in options)
              FilterChip(
                label: Text(data.i18n.toolName(tool.name)),
                selected: selected.contains(tool.name),
                onSelected: _saving
                    ? null
                    : (checked) {
                        setState(() {
                          final next = Set<String>.from(selected);
                          if (checked) {
                            if (next.length < request.count) {
                              next.add(tool.name);
                            }
                          } else {
                            next.remove(tool.name);
                          }
                          _selectedToolsByRequest[request.id] = next;
                        });
                      },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureChoicesSection(
    BuildContext context,
    _ResetLevelsData data,
  ) {
    final height = MediaQuery.sizeOf(context).height * 0.5;
    return _loadingClassFeatures
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: height.clamp(320.0, 520.0).toDouble(),
            child: FeatureChoiceEditor(
              requests: _featureChoiceRequests,
              initialChoices: _featureChoices,
              catalog: data.catalog,
              character: _previewCharacter(),
              i18n: data.i18n,
              skills: data.skills,
              tools: data.tools,
              spells: data.spells,
              languages: data.languages,
              weapons: data.weapons,
              feats: data.feats,
              featureLabelBuilder: (request) =>
                  _featureChoiceRequestFeatureLabel(request, data.i18n),
              onChanged: (choices) {
                setState(() => _featureChoices = choices);
              },
            ),
          );
  }

  Widget _buildSummarySection(BuildContext context, _ResetLevelsData data) {
    final l10n = AppLocalizations.of(context)!;
    final srdClass = _selectedClass;
    final rows = <Widget>[
      if (srdClass != null)
        _InfoRow(
          icon: Icons.shield_outlined,
          text: '${data.i18n.className(srdClass.name)} 1',
        ),
      if (_selectedSubclassName != null && srdClass != null)
        _InfoRow(
          icon: Icons.account_tree_outlined,
          text: data.i18n.subclassName(srdClass.name, _selectedSubclassName!),
        ),
      _InfoRow(
        icon: Icons.favorite_outline,
        text: l10n.resetLevelsInitialHp(_initialHp),
      ),
      if (srdClass != null)
        _InfoRow(
          icon: Icons.fact_check_outlined,
          text:
              '${l10n.stepSavesLabel}: '
              '${srdClass.savingThrows.map(_abilityLabel).join(', ')}',
        ),
    ];
    return _ResetSection(
      title: l10n.levelUpStepSummary,
      child: Column(children: rows),
    );
  }

  String _abilityLabel(String value) {
    final l10n = AppLocalizations.of(context)!;
    switch (value.toLowerCase()) {
      case 'strength':
        return l10n.abilityStr;
      case 'dexterity':
        return l10n.abilityDex;
      case 'constitution':
        return l10n.abilityCon;
      case 'intelligence':
        return l10n.abilityInt;
      case 'wisdom':
        return l10n.abilityWis;
      case 'charisma':
        return l10n.abilityCha;
      default:
        return value;
    }
  }

  static bool _isToolChoice(String value) {
    final lower = value.toLowerCase();
    return lower.contains('one ') ||
        lower.contains('two ') ||
        lower.contains('three ') ||
        lower.contains('of your choice');
  }

  static int _toolChoiceCountFor(String value) {
    final lower = value.toLowerCase();
    for (final entry in const {
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
    }.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 1;
  }

  static List<String> _uniqueStrings(Iterable<String> values) {
    final result = <String>[];
    final seen = <String>{};
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed.toLowerCase())) result.add(trimmed);
    }
    return result;
  }
}

String _featureChoiceRequestFeatureLabel(
  FeatureChoiceRequest request,
  SrdI18nService i18n,
) {
  return switch (request.sourceType) {
    FeatureChoiceSourceType.classFeature =>
      i18n.classFeatureName(request.sourceClass, request.featureName) ??
          request.featureName,
    FeatureChoiceSourceType.subclassFeature =>
      i18n.subclassFeatureName(
            request.sourceClass,
            request.sourceSubclass ?? '',
            request.featureName,
          ) ??
          request.featureName,
    FeatureChoiceSourceType.raceTrait => i18n.raceTraitName(
      request.sourceName ?? request.featureName,
    ),
    FeatureChoiceSourceType.feat =>
      i18n.featName(request.sourceName ?? request.featureName) ??
          request.featureName,
    FeatureChoiceSourceType.multiclassProficiency => i18n.className(
      request.sourceClass,
    ),
    _ => request.featureName,
  };
}

class _ResetSection extends StatelessWidget {
  const _ResetSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final complete = current >= total;
    return Chip(
      label: Text(
        AppLocalizations.of(
          context,
        )!.featureChoicesSelectedCount(current, total),
      ),
      backgroundColor: complete
          ? scheme.primaryContainer
          : scheme.errorContainer,
    );
  }
}

class _ToolChoiceRequest {
  const _ToolChoiceRequest({
    required this.id,
    required this.count,
    required this.categories,
  });

  final String id;
  final int count;
  final Set<String> categories;
}

class _CollectedLevelRebuild {
  const _CollectedLevelRebuild({
    required this.character,
    required this.syncInnateSpellsAfterSave,
  });

  final Character character;
  final bool syncInnateSpellsAfterSave;
}

class _ResetLevelsData {
  const _ResetLevelsData({
    required this.classes,
    required this.allSubclassFeatures,
    required this.catalog,
    required this.skills,
    required this.tools,
    required this.spells,
    required this.languages,
    required this.weapons,
    required this.feats,
    required this.i18n,
  });

  final List<SrdClass> classes;
  final Map<String, Map<String, List<SrdClassFeature>>> allSubclassFeatures;
  final SrdFeatureChoiceCatalog catalog;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final List<SrdLanguage> languages;
  final List<SrdWeapon> weapons;
  final List<SrdFeat> feats;
  final SrdI18nService i18n;
}
