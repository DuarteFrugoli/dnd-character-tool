import 'package:dnd_character_tool/data/datasources/srd/srd_models.dart';
import 'package:dnd_character_tool/data/models/models.dart';

enum LevelUpAsiMode { asi, feat }

enum LevelUpWizardPage {
  features,
  subclass,
  asi,
  featureChoices,
  hp,
  cantrips,
  spellSwap,
  spells,
  summary,
}

class LevelUpWizardState {
  LevelUpWizardState({
    required this.newLevel,
    this.hpGained = 0,
    this.hpChosen = false,
    this.asiMode = LevelUpAsiMode.asi,
    this.asiChanges = const {},
    this.cantripsLearned = const [],
    this.spellsLearned = const [],
    this.featureChoices = const [],
  });

  final int newLevel;
  int hpGained;
  bool hpChosen;
  LevelUpAsiMode asiMode;
  Map<String, int> asiChanges;
  SrdFeat? featChosen;
  String? subclassChosen;
  List<KnownSpell> cantripsLearned;
  List<KnownSpell> spellsLearned;
  List<CharacterFeatureChoice> featureChoices;
  String? spellSwapped;
  KnownSpell? swapReplacement;

  LevelUpWizardState copyWith({
    int? hpGained,
    bool? hpChosen,
    LevelUpAsiMode? asiMode,
    Map<String, int>? asiChanges,
    Object? featChosen = _sentinel,
    Object? subclassChosen = _sentinel,
    List<KnownSpell>? cantripsLearned,
    List<KnownSpell>? spellsLearned,
    List<CharacterFeatureChoice>? featureChoices,
    Object? spellSwapped = _sentinel,
    Object? swapReplacement = _sentinel,
  }) {
    final state = LevelUpWizardState(
      newLevel: newLevel,
      hpGained: hpGained ?? this.hpGained,
      hpChosen: hpChosen ?? this.hpChosen,
      asiMode: asiMode ?? this.asiMode,
      asiChanges: asiChanges ?? this.asiChanges,
      cantripsLearned: cantripsLearned ?? this.cantripsLearned,
      spellsLearned: spellsLearned ?? this.spellsLearned,
      featureChoices: featureChoices ?? this.featureChoices,
    );
    state.featChosen = featChosen == _sentinel
        ? this.featChosen
        : featChosen as SrdFeat?;
    state.subclassChosen = subclassChosen == _sentinel
        ? this.subclassChosen
        : subclassChosen as String?;
    state.spellSwapped = spellSwapped == _sentinel
        ? this.spellSwapped
        : spellSwapped as String?;
    state.swapReplacement = swapReplacement == _sentinel
        ? this.swapReplacement
        : swapReplacement as KnownSpell?;
    return state;
  }

  static const _sentinel = Object();
}
