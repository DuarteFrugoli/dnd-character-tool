import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/feature_choice_engine.dart';
import 'character_draft_provider.dart';
import 'creation_feature_choice_loader.dart';
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

enum _CreationStepId {
  characterClass,
  race,
  background,
  skills,
  attributes,
  name,
  featureChoices,
  review,
}

class _CreationStep {
  const _CreationStep({
    required this.id,
    required this.title,
    required this.child,
  });

  final _CreationStepId id;
  final String title;
  final Widget child;
}

class CharacterCreationScreen extends ConsumerStatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  ConsumerState<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState
    extends ConsumerState<CharacterCreationScreen> {
  int _currentStep = 0;
  bool _isAdvancing = false;
  String? _featureChoiceLoadErrorKey;
  final _reviewKey = GlobalKey<StepReviewState>();

  List<_CreationStep> _stepsForDraft(
    AppLocalizations l10n,
    CharacterDraft draft,
  ) {
    return [
      _CreationStep(
        id: _CreationStepId.characterClass,
        title: l10n.creationStepClass,
        child: const StepClass(),
      ),
      _CreationStep(
        id: _CreationStepId.race,
        title: l10n.creationStepRace,
        child: const StepRace(),
      ),
      _CreationStep(
        id: _CreationStepId.background,
        title: l10n.creationStepBackground,
        child: const StepBackground(),
      ),
      _CreationStep(
        id: _CreationStepId.skills,
        title: l10n.creationStepSkills,
        child: const StepSkills(),
      ),
      _CreationStep(
        id: _CreationStepId.attributes,
        title: l10n.creationStepAttributes,
        child: const StepAttributes(),
      ),
      _CreationStep(
        id: _CreationStepId.name,
        title: l10n.creationStepName,
        child: const StepName(),
      ),
      if (shouldShowCreationFeatureChoiceStep(
        draft,
        featureChoiceLoadErrorKey: _featureChoiceLoadErrorKey,
      ))
        _CreationStep(
          id: _CreationStepId.featureChoices,
          title: l10n.featureChoicesTitle,
          child: const StepFeatureChoices(),
        ),
      _CreationStep(
        id: _CreationStepId.review,
        title: l10n.creationStepReview,
        child: StepReview(key: _reviewKey),
      ),
    ];
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context)!;
    var draft = ref.read(characterDraftProvider);
    var steps = _stepsForDraft(l10n, draft);
    final currentStep = _clampedStep(steps);
    final current = steps[currentStep];

    if (!_isStepValid(draft, current.id)) return;

    if (current.id == _CreationStepId.name) {
      await _loadFeatureChoicesBeforeReview(draft);
      if (!mounted) return;
      draft = ref.read(characterDraftProvider);
      steps = _stepsForDraft(l10n, draft);
    }

    if (currentStep < steps.length - 1) {
      setState(() => _currentStep = currentStep + 1);
    }
  }

  void _back() {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.read(characterDraftProvider);
    final currentStep = _clampedStep(_stepsForDraft(l10n, draft));
    if (currentStep > 0) {
      setState(() => _currentStep = currentStep - 1);
    }
  }

  int _clampedStep(List<_CreationStep> steps) {
    return _currentStep.clamp(0, steps.length - 1).toInt();
  }

  void _goToStep(_CreationStepId stepId) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.read(characterDraftProvider);
    final steps = _stepsForDraft(l10n, draft);
    final target = steps.indexWhere((step) => step.id == stepId);
    if (target < 0) return;
    setState(() => _currentStep = target);
  }

  Future<void> _loadFeatureChoicesBeforeReview(CharacterDraft draft) async {
    if (draft.featureChoicesLoaded || _isAdvancing) return;
    var loadFailed = false;
    setState(() => _isAdvancing = true);
    try {
      final data = await loadCreationFeatureChoiceData(ref, draft);
      if (!mounted) return;
      ref
          .read(characterDraftProvider.notifier)
          .setFeatureChoiceRequests(data.requests);
    } catch (_) {
      loadFailed = true;
    } finally {
      if (mounted) {
        setState(() {
          _isAdvancing = false;
          _featureChoiceLoadErrorKey = loadFailed
              ? creationFeatureChoiceDraftKey(draft)
              : null;
        });
      }
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

  bool _isStepValid(CharacterDraft draft, _CreationStepId step) {
    return switch (step) {
      _CreationStepId.characterClass => draft.selectedClass != null,
      _CreationStepId.race =>
        draft.selectedRace != null &&
            (draft.selectedRace!.subraces.isEmpty ||
                draft.selectedSubrace != null),
      _CreationStepId.background => draft.selectedBackground != null,
      _CreationStepId.skills => _skillsComplete(draft),
      _CreationStepId.attributes =>
        draft.baseAttributes.length == 6 && draft.racialAsiComplete,
      _CreationStepId.name => true,
      _CreationStepId.featureChoices =>
        draft.featureChoicesLoaded &&
            FeatureChoiceEngine.allComplete(
              draft.featureChoiceRequests,
              draft.featureChoices,
            ),
      _CreationStepId.review =>
        creationReviewFieldsComplete(draft) &&
            draft.featureChoicesLoaded &&
            FeatureChoiceEngine.allComplete(
              draft.featureChoiceRequests,
              draft.featureChoices,
            ),
    };
  }

  _CreationStepId? _firstIncompleteStep(CharacterDraft draft) {
    if (draft.selectedClass == null) return _CreationStepId.characterClass;
    if (draft.selectedRace == null ||
        (draft.selectedRace!.subraces.isNotEmpty &&
            draft.selectedSubrace == null)) {
      return _CreationStepId.race;
    }
    if (draft.selectedBackground == null) return _CreationStepId.background;
    if (!_skillsComplete(draft)) return _CreationStepId.skills;
    if (draft.baseAttributes.length != 6 || !draft.racialAsiComplete) {
      return _CreationStepId.attributes;
    }
    if (!draft.featureChoicesLoaded) return _CreationStepId.featureChoices;
    if (draft.featureChoiceRequests.isNotEmpty &&
        !FeatureChoiceEngine.allComplete(
          draft.featureChoiceRequests,
          draft.featureChoices,
        )) {
      return _CreationStepId.featureChoices;
    }
    if (!creationReviewFieldsComplete(draft)) return _CreationStepId.review;
    return null;
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
    final steps = _stepsForDraft(l10n, draft);
    final currentStep = _clampedStep(steps);
    final current = steps[currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(current.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.creationTooltipCancel,
          onPressed: _cancel,
        ),
      ),
      body: Column(
        children: [
          StepIndicator(totalSteps: steps.length, currentStep: currentStep),
          Expanded(child: current.child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (currentStep > 0)
                OutlinedButton(
                  onPressed: _back,
                  child: Text(l10n.creationBack),
                ),
              const Spacer(),
              FilledButton(
                onPressed:
                    !_isAdvancing &&
                        (current.id == _CreationStepId.review ||
                            _isStepValid(draft, current.id))
                    ? (current.id == _CreationStepId.review
                          ? _finishCreation
                          : _next)
                    : null,
                child: Text(
                  current.id == _CreationStepId.review
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
    final draft = ref.read(characterDraftProvider);
    final incompleteStep = _firstIncompleteStep(draft);
    if (incompleteStep != null) {
      if (incompleteStep == _CreationStepId.review) {
        _reviewKey.currentState?.focusFirstPendingIssue();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.resetLevelsIncomplete),
          ),
        );
      } else {
        _goToStep(incompleteStep);
      }
      return;
    }
    final created = await ref
        .read(characterDraftProvider.notifier)
        .buildAndSave(
          ref,
          fallbackName: AppLocalizations.of(context)!.reviewUnnamedHero,
        );
    ref.read(characterDraftProvider.notifier).reset();
    await ref.read(characterListProvider.notifier).updateSingle(created);
    if (mounted) context.go('/');
  }
}
