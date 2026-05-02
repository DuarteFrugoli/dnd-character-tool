import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'character_draft_provider.dart';
import '../character_list/character_list_provider.dart';
import 'steps/step_class.dart';
import 'steps/step_race.dart';
import 'steps/step_background.dart';
import 'steps/step_skills.dart';
import 'steps/step_attributes.dart';
import 'steps/step_name.dart';
import 'steps/step_review.dart';
import 'widgets/step_indicator.dart';

const _stepTitles = [
  'Class',
  'Race',
  'Background',
  'Skills',
  'Attributes',
  'Name',
  'Review',
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard character?'),
        content:
            const Text('All progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      ref.read(characterDraftProvider.notifier).reset();
      context.go('/create');
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
      4 => draft.baseAttributes.length == 6,
      5 => true, // nome é opcional
      6 => draft.languageChoicesNeeded == 0 ||
          draft.chosenLanguages.length >= draft.languageChoicesNeeded,
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
    final draft = ref.watch(characterDraftProvider);
    final steps = [
      const StepClass(),
      const StepRace(),
      const StepBackground(),
      const StepSkills(),
      const StepAttributes(),
      const StepName(),
      StepReview(onFinish: _finishCreation),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitles[_currentStep]),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: _cancel,
        ),
      ),
      body: Column(
        children: [
          StepIndicator(
            totalSteps: _stepTitles.length,
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
                  child: const Text('Back'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _isStepValid(draft)
                    ? (_currentStep == _stepTitles.length - 1
                        ? _finishCreation
                        : _next)
                    : null,
                child: Text(
                  _currentStep == _stepTitles.length - 1
                      ? 'Create Character'
                      : 'Continue',
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
    await ref.read(characterDraftProvider.notifier).buildAndSave(ref);
    ref.read(characterDraftProvider.notifier).reset();
    ref.invalidate(characterListProvider);
    if (mounted) context.go('/');
  }
}
