import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/feature_choice_engine.dart';
import 'character_draft_provider.dart';
import '../character_list/character_list_provider.dart';
import 'steps/step_class.dart';
import 'steps/step_race.dart';
import 'steps/step_background.dart';
import 'steps/step_skills.dart';
import 'steps/step_attributes.dart';
import 'steps/step_name.dart';
import 'steps/step_feature_choices.dart';
import 'steps/step_review.dart';
import 'widgets/step_indicator.dart';

List<String> _getStepTitles(AppLocalizations l10n) => [
  l10n.creationStepClass,
  l10n.creationStepRace,
  l10n.creationStepBackground,
  l10n.creationStepSkills,
  l10n.creationStepAttributes,
  l10n.creationStepName,
  l10n.featureChoicesTitle,
  l10n.creationStepReview,
];

class CharacterCreationScreen extends ConsumerStatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  ConsumerState<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState
    extends ConsumerState<CharacterCreationScreen> {
  int _currentStep = 0;

  List<String> get _stepTitles => _getStepTitles(AppLocalizations.of(context)!);

  void _next() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.creationDiscardTitle),
        content: Text(l10n.creationDiscardContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.dialogDiscard),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      ref.read(characterDraftProvider.notifier).reset();
      context.go('/');
    }
  }

  bool _isStepValid(CharacterDraft draft) {
    return switch (_currentStep) {
      0 => draft.selectedClass != null,
      1 => draft.selectedRace != null &&
          (draft.selectedRace!.subraces.isEmpty ||
              draft.selectedSubrace != null),
      2 => draft.selectedBackground != null,
      3 => _skillsComplete(draft),
      4 => draft.baseAttributes.length == 6 && draft.racialAsiComplete,
      5 => true, // nome é opcional
      6 => draft.featureChoicesLoaded &&
          FeatureChoiceEngine.allComplete(
            draft.featureChoiceRequests,
            draft.featureChoices,
          ),
      7 => (draft.languageChoicesNeeded == 0 ||
              draft.chosenLanguages.length >= draft.languageChoicesNeeded) &&
          (draft.toolChoicesNeeded == 0 ||
              (draft.chosenToolProficiencies.length >=
                      draft.toolChoicesNeeded &&
                  !draft.chosenToolProficiencies
                      .take(draft.toolChoicesNeeded)
                      .any((s) => s.isEmpty))) &&
          (draft.equipmentChoicesNeeded == 0 ||
              draft.resolvedEquipmentChoices.length >=
                  draft.equipmentChoicesNeeded) &&
          draft.classEquipmentComplete &&
          draft.featureChoicesLoaded &&
          FeatureChoiceEngine.allComplete(
            draft.featureChoiceRequests,
            draft.featureChoices,
          ),
      _ => false,
    };
  }

  bool _skillsComplete(CharacterDraft draft) {
    if (draft.selectedClass == null) return false;
    final needed = draft.selectedClass!.skillChoices.count;
    return draft.chosenSkills.length >= needed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(characterDraftProvider);
    final stepTitles = _getStepTitles(l10n);
    final steps = [
      const StepClass(),
      const StepRace(),
      const StepBackground(),
      const StepSkills(),
      const StepAttributes(),
      const StepName(),
      const StepFeatureChoices(),
      StepReview(onFinish: _finishCreation),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(stepTitles[_currentStep]),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.creationTooltipCancel,
          onPressed: _cancel,
        ),
      ),
      body: Column(
        children: [
          StepIndicator(
            totalSteps: stepTitles.length,
            currentStep: _currentStep,
          ),
          Expanded(child: steps[_currentStep]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: _back,
                  child: Text(l10n.creationBack),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _isStepValid(draft)
                    ? (_currentStep == stepTitles.length - 1
                        ? _finishCreation
                        : _next)
                    : null,
                child: Text(
                  _currentStep == stepTitles.length - 1
                      ? l10n.creationCreateCharacter
                      : l10n.dialogContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finishCreation() async {
    if (!_isStepValid(ref.read(characterDraftProvider))) return;
    final created = await ref.read(characterDraftProvider.notifier).buildAndSave(
      ref,
      fallbackName: AppLocalizations.of(context)!.reviewUnnamedHero,
    );
    ref.read(characterDraftProvider.notifier).reset();
    await ref.read(characterListProvider.notifier).updateSingle(created);
    if (mounted) context.go('/');
  }
}
