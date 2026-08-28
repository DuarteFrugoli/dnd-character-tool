import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/models/models.dart';
import '../../shared/providers/providers.dart';
import 'character_draft_provider.dart';

Future<CreationFeatureChoiceData> loadCreationFeatureChoiceData(
  WidgetRef ref,
  CharacterDraft draft,
) async {
  final srd = ref.read(srdDataSourceProvider);
  final i18n = ref.read(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
  final selectedClass = draft.selectedClass;
  final selectedRace = draft.selectedRace;
  if (selectedClass == null || selectedRace == null) {
    return CreationFeatureChoiceData.empty(i18n);
  }

  final results = await Future.wait([
    srd.getClassFeatures(selectedClass.name),
    srd.getAllSubclassFeatures(),
    srd.getFeatureChoiceCatalog(),
    srd.getSkills(),
    srd.getTools(),
    srd.getSpells(),
    srd.getLanguages(),
    srd.getWeapons(),
    srd.getFeats(),
  ]);
  final classFeatures = results[0] as List<SrdClassFeature>;
  final allSubclassFeatures =
      results[1] as Map<String, Map<String, List<SrdClassFeature>>>;
  final catalog = results[2] as SrdFeatureChoiceCatalog;
  final skills = results[3] as List<SrdSkill>;
  final tools = results[4] as List<SrdTool>;
  final spells = results[5] as List<SrdSpell>;
  final languages = results[6] as List<SrdLanguage>;
  final weapons = results[7] as List<SrdWeapon>;
  final feats = results[8] as List<SrdFeat>;

  final requests = _requestsForDraft(
    draft: draft,
    catalog: catalog,
    classFeatures: classFeatures,
    allSubclassFeatures: allSubclassFeatures,
    feats: feats,
  );

  return CreationFeatureChoiceData(
    requests: requests,
    catalog: catalog,
    previewCharacter: _previewCharacter(draft),
    i18n: i18n,
    skills: skills,
    tools: tools,
    spells: spells,
    languages: languages,
    weapons: weapons,
    feats: feats,
  );
}

String creationFeatureChoiceDraftKey(CharacterDraft draft) {
  return [
    draft.selectedClass?.name ?? '',
    draft.selectedSubclass?.name ?? '',
    draft.selectedRace?.name ?? '',
    draft.selectedSubrace?.name ?? '',
    draft.selectedBackground?.name ?? '',
    _selectedBonusFeatName(draft) ?? '',
  ].join('|');
}

String creationFeatureChoiceRequestFeatureLabel(
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
    _ => request.featureName,
  };
}

List<FeatureChoiceRequest> _requestsForDraft({
  required CharacterDraft draft,
  required SrdFeatureChoiceCatalog catalog,
  required List<SrdClassFeature> classFeatures,
  required Map<String, Map<String, List<SrdClassFeature>>> allSubclassFeatures,
  required List<SrdFeat> feats,
}) {
  final requests = <FeatureChoiceRequest>[];
  final seen = <String>{};

  void addAll(Iterable<FeatureChoiceRequest> items) {
    for (final item in items) {
      if (seen.add(item.key)) requests.add(item);
    }
  }

  final selectedClass = draft.selectedClass;
  if (selectedClass != null) {
    for (final feature in classFeatures.where((feature) => feature.level <= 1)) {
      addAll(
        FeatureChoiceEngine.requestsForClassFeature(
          catalog: catalog,
          className: selectedClass.name,
          featureName: feature.name,
          level: 1,
        ),
      );
    }

    final selectedSubclass = draft.selectedSubclass;
    if (selectedSubclass != null && selectedClass.subclassLevel <= 1) {
      final subclassFeatures =
          allSubclassFeatures[selectedClass.name]?[selectedSubclass.name] ??
          const <SrdClassFeature>[];
      for (final feature in subclassFeatures.where(
        (feature) => feature.level <= 1,
      )) {
        addAll(
          FeatureChoiceEngine.requestsForSubclassFeature(
            catalog: catalog,
            className: selectedClass.name,
            subclassName: selectedSubclass.name,
            featureName: feature.name,
            level: 1,
          ),
        );
      }
    }
  }

  final raceTraits = [
    ...?draft.selectedRace?.traits,
    ...?draft.selectedSubrace?.traits,
  ];
  for (final trait in raceTraits) {
    if (_traitHandledByExistingCreationUi(draft, trait)) continue;
    addAll(
      FeatureChoiceEngine.requestsForRaceTrait(
        catalog: catalog,
        traitName: trait,
        level: 1,
      ),
    );
  }

  final selectedFeatName = _selectedBonusFeatName(draft);
  final selectedFeat = selectedFeatName == null
      ? null
      : feats.firstWhereOrNull((feat) => feat.name == selectedFeatName);
  if (selectedFeat != null) {
    addAll(
      FeatureChoiceEngine.requestsForFeat(
        catalog: catalog,
        featName: selectedFeat.name,
        level: 1,
      ),
    );
  }

  return requests;
}

String? _selectedBonusFeatName(CharacterDraft draft) {
  return draft.featureChoices
      .firstWhereOrNull(
        (choice) =>
            choice.sourceType == FeatureChoiceSourceType.raceTrait &&
            choice.sourceName == 'Bonus Feat' &&
            choice.choiceId == 'feat',
      )
      ?.values
      .firstOrNull;
}

bool _traitHandledByExistingCreationUi(CharacterDraft draft, String trait) {
  if (trait == 'Tool Proficiency' &&
      draft.selectedRace?.traits.contains(trait) == true) {
    return true;
  }

  if (trait == 'Extra Language' &&
      draft.selectedRace?.traits.contains(trait) == true) {
    return draft.selectedRace!.languages.any(
      (language) => language.toLowerCase().contains('of your choice'),
    );
  }

  return false;
}

Character _previewCharacter(CharacterDraft draft) {
  final attrs = draft.finalAttributes;
  final now = DateTime.now();
  return Character(
    id: draft.id,
    name: draft.name.trim().isEmpty ? 'Preview' : draft.name.trim(),
    playerName: draft.playerName,
    race: draft.selectedRace?.name ?? '',
    subrace: draft.selectedSubrace?.name,
    characterClass: draft.selectedClass?.name ?? '',
    subclass: draft.selectedSubclass?.name,
    level: 1,
    background: draft.selectedBackground?.name ?? '',
    abilityScores: AbilityScores(
      strength: attrs['Strength'] ?? 10,
      dexterity: attrs['Dexterity'] ?? 10,
      constitution: attrs['Constitution'] ?? 10,
      intelligence: attrs['Intelligence'] ?? 10,
      wisdom: attrs['Wisdom'] ?? 10,
      charisma: attrs['Charisma'] ?? 10,
    ),
    hitPoints: const HitPoints(maximum: 1, current: 1),
    savingThrowProficiencies: draft.selectedClass?.savingThrows ?? const [],
    skillProficiencies: [...draft.grantedSkills, ...draft.chosenSkills],
    languages: [...draft.fixedRaceLanguages, ...draft.chosenLanguages],
    createdAt: now,
    updatedAt: now,
  );
}

class CreationFeatureChoiceData {
  const CreationFeatureChoiceData({
    required this.requests,
    required this.catalog,
    required this.previewCharacter,
    required this.i18n,
    required this.skills,
    required this.tools,
    required this.spells,
    required this.languages,
    required this.weapons,
    required this.feats,
  });

  factory CreationFeatureChoiceData.empty(SrdI18nService i18n) {
    final now = DateTime.now();
    return CreationFeatureChoiceData(
      requests: const [],
      catalog: const SrdFeatureChoiceCatalog(
        optionSources: {},
        classFeatures: {},
        subclassFeatures: {},
        raceTraits: {},
        feats: {},
      ),
      previewCharacter: Character(
        id: 'preview',
        name: 'Preview',
        race: '',
        characterClass: '',
        abilityScores: const AbilityScores(),
        hitPoints: const HitPoints(maximum: 1, current: 1),
        createdAt: now,
        updatedAt: now,
      ),
      i18n: i18n,
      skills: const [],
      tools: const [],
      spells: const [],
      languages: const [],
      weapons: const [],
      feats: const [],
    );
  }

  final List<FeatureChoiceRequest> requests;
  final SrdFeatureChoiceCatalog catalog;
  final Character previewCharacter;
  final SrdI18nService i18n;
  final List<SrdSkill> skills;
  final List<SrdTool> tools;
  final List<SrdSpell> spells;
  final List<SrdLanguage> languages;
  final List<SrdWeapon> weapons;
  final List<SrdFeat> feats;
}
