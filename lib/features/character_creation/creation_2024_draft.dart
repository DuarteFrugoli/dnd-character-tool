import 'package:uuid/uuid.dart';

import '../../data/character_progression/choice_effects.dart';
import '../../data/character_progression/progression_2024_engine.dart';
import '../../data/constants/armor_class.dart';
import '../../data/conversion/edition_conversion_2024.dart';
import '../../data/custom_background.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/feature_choice_option_resolver.dart';
import '../../data/models/models.dart';
import '../../data/rulesets/ruleset_ids.dart';
import '../../data/datasources/srd/srd_2024_creation_catalog.dart';

const creation2024Abilities = <String>[
  'strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma',
];

enum Creation2024AbilityMethod {
  standardArray,
  pointBuy,
  rolledDice,

  /// Scores carried from a 2014 sheet being converted, edited freely.
  fromSheet,
}

const _pointBuyCosts = <int, int>{8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9};

String creation2024AbilityName(String ability) =>
    '${ability[0].toUpperCase()}${ability.substring(1)}';

class Creation2024Draft {
  final String id = const Uuid().v4();
  Creation2024Class? characterClass;
  Creation2024Species? species;
  Creation2024Background? background;
  String name = '';
  String playerName = '';
  String? size;
  final Map<String, int> baseAbilities = {};
  Creation2024AbilityMethod abilityMethod = Creation2024AbilityMethod.standardArray;
  final List<int> rolledScores = [];
  int rollGeneration = 0;
  final Map<String, int> assignedRolls = {};
  final Map<String, int> backgroundBonuses = {};
  final Set<String> skills = {};
  final Set<String> languages = {};
  final Set<String> classTools = {};
  final Set<String> backgroundTools = {};
  final Set<String> preparedWizardSpells = {};
  String? classEquipmentId;
  String? backgroundEquipmentId;
  final Map<String, String> specificEquipment = {};
  List<CharacterFeatureChoice> featureChoices = [];

  /// Converting a 2014 sheet keeps its inventory and money instead of the
  /// 2024 starting equipment.
  bool keepInventory = false;

  Creation2024Draft();

  /// A draft prefilled from a 2014 sheet; every value stays editable.
  factory Creation2024Draft.forConversion(
    Conversion2024Prefill prefill,
    Creation2024Catalog catalog,
  ) {
    final draft = Creation2024Draft()
      ..keepInventory = true
      ..abilityMethod = Creation2024AbilityMethod.fromSheet;
    final cls = catalog.classes.where((c) => c.name == prefill.className).firstOrNull;
    final species = catalog.species.where((s) => s.name == prefill.speciesName).firstOrNull;
    final background = catalog.backgrounds.where((b) => b.name == prefill.backgroundName).firstOrNull;
    if (cls != null) draft.selectClass(cls);
    if (species != null) draft.selectSpecies(species);
    if (background != null) draft.selectBackground(background);
    draft.baseAbilities.addAll(prefill.baseAbilities);
    draft.skills.addAll(prefill.skills);
    draft.languages.addAll(prefill.languages);
    return draft;
  }

  void selectClass(Creation2024Class value) {
    characterClass = value;
    skills.clear();
    classTools.clear();
    classEquipmentId = null;
    specificEquipment.clear();
    preparedWizardSpells.clear();
    featureChoices = [];
  }

  void selectSpecies(Creation2024Species value) {
    species = value;
    size = value.sizes.length == 1 ? value.sizes.first : null;
    featureChoices = [];
  }

  void selectBackground(Creation2024Background value) {
    background = value;
    backgroundBonuses.clear();
    backgroundEquipmentId = null;
    backgroundTools.clear();
    specificEquipment.removeWhere((key, _) => key.startsWith('background:'));
    skills.removeAll(value.skills);
    featureChoices = [];
  }

  Map<String, int> get finalAbilities {
    return {
      for (final ability in creation2024Abilities)
        ability: (baseAbilities[ability] ?? 10) + (backgroundBonuses[ability] ?? 0),
    };
  }

  bool get abilitiesComplete {
    if (baseAbilities.length != 6 ||
        !baseAbilities.keys.toSet().containsAll(creation2024Abilities)) {
      return false;
    }
    final baseComplete = switch (abilityMethod) {
      Creation2024AbilityMethod.standardArray =>
        baseAbilities.values.toSet().length == 6 &&
            baseAbilities.values.toSet().containsAll(const [15, 14, 13, 12, 10, 8]),
      Creation2024AbilityMethod.pointBuy =>
        baseAbilities.values.every(_pointBuyCosts.containsKey) &&
            baseAbilities.values.map((score) => _pointBuyCosts[score]!).reduce((a, b) => a + b) <= 27,
      Creation2024AbilityMethod.fromSheet =>
        baseAbilities.values.every((score) => score >= 1 && score <= 20),
      Creation2024AbilityMethod.rolledDice =>
        rolledScores.length == 6 && assignedRolls.length == 6 &&
            assignedRolls.values.toSet().length == 6 &&
            assignedRolls.entries.every((entry) =>
                entry.value >= 0 && entry.value < 6 &&
                baseAbilities[entry.key] == rolledScores[entry.value]),
    };
    if (!baseComplete) return false;
    final bg = background;
    if (bg == null || backgroundBonuses.keys.any((key) => !bg.abilities.contains(key))) {
      return false;
    }
    final bonuses = backgroundBonuses.values.toList()..sort();
    return bonuses.length == 2 && bonuses[0] == 1 && bonuses[1] == 2 ||
        bonuses.length == 3 && bonuses.every((value) => value == 1);
  }

  bool get proficienciesComplete {
    final cls = characterClass;
    final bg = background;
    if (cls == null || bg == null) return false;
    final allowedSkills = cls.skillChoices.isAny
        ? null
        : cls.skillChoices.from.toSet();
    return skills.length == cls.skillChoices.count &&
        (allowedSkills == null || skills.every(allowedSkills.contains)) &&
        skills.every((skill) => !bg.skills.contains(skill)) &&
        classTools.length == (cls.toolChoice?.count ?? 0) &&
        backgroundTools.length == (bg.toolChoice?.count ?? 0) &&
        languages.length == 2 &&
        !languages.contains('Common');
  }

  bool get equipmentComplete {
    final cls = characterClass;
    final bg = background;
    if (cls == null || bg == null) return false;
    if (keepInventory) return true;
    final classChoice = cls.equipmentChoices.where((value) => value.id == classEquipmentId).firstOrNull;
    final backgroundChoice = bg.equipmentChoices.where((value) => value.id == backgroundEquipmentId).firstOrNull;
    if (classChoice == null || backgroundChoice == null) return false;
    bool resolved(Creation2024Equipment choice, String source) {
      for (var index = 0; index < choice.items.length; index++) {
        final item = choice.items[index];
        if (item.choiceFrom != null) continue;
        if (item.selection == 'proficient_tool' && classTools.length == 1) continue;
        if ((item.category != null || item.selection != null) &&
            specificEquipment['$source:$index'] == null) {
          return false;
        }
      }
      return true;
    }
    return resolved(classChoice, 'class') && resolved(backgroundChoice, 'background');
  }

  List<FeatureChoiceRequest> requests(Creation2024Catalog catalog) {
    final result = <FeatureChoiceRequest>[];
    final cls = characterClass;
    if (cls != null) {
      for (final name in (cls.levelOne['features'] as List<dynamic>).cast<String>()) {
        result.addAll(FeatureChoiceEngine.requestsForClassFeature(
          catalog: catalog.choices,
          className: cls.name,
          sourceClassEntryId: 'primary',
          featureName: name,
          level: 1,
        ));
      }
      final cantrips = (cls.levelOne['cantripsKnown'] as num?)?.toInt() ?? 0;
      final spells = cls.name == 'Wizard'
          ? 6
          : (cls.levelOne['preparedSpells'] as num?)?.toInt() ?? 0;
      if (cantrips > 0) {
        result.add(_spellRequest(cls, 'cantrips', 'cantrip', cantrips));
      }
      if (spells > 0) {
        result.add(_spellRequest(cls, 'prepared_spells', 'spell', spells));
      }
    }
    final selectedSpecies = species;
    if (selectedSpecies != null) {
      for (final trait in selectedSpecies.traits) {
        result.addAll(FeatureChoiceEngine.requestsForRaceTrait(
          catalog: catalog.choices,
          traitName: trait,
          level: 1,
        ));
      }
    }
    final selectedBackground = background;
    if (selectedBackground != null) {
      result.addAll(_featRequests(catalog, selectedBackground.featName, 'background', selectedBackground.featChoices));
    }
    if (selectedSpecies?.name == 'Human') {
      final selectedFeat = featureChoices
          .where((choice) => choice.sourceType == FeatureChoiceSourceType.raceTrait && choice.featureName == 'Versatile')
          .firstOrNull?.values.firstOrNull;
      if (selectedFeat != null) {
        result.addAll(_featRequests(catalog, selectedFeat, 'species', const {}));
      }
    }
    return result;
  }

  FeatureChoiceRequest _spellRequest(Creation2024Class cls, String id, String type, int count) => FeatureChoiceRequest(
    sourceType: FeatureChoiceSourceType.classFeature,
    sourceClass: cls.name,
    sourceClassEntryId: 'primary',
    featureName: cls.name == 'Warlock' ? 'Pact Magic' : 'Spellcasting',
    level: 1,
    requirement: SrdFeatureChoiceRequirement(
      id: id,
      type: type,
      count: count,
      spellClass: cls.name.toLowerCase(),
      spellLevel: type == 'spell' ? 1 : 0,
    ),
    requiredCount: count,
  );

  List<FeatureChoiceRequest> _featRequests(
    Creation2024Catalog catalog,
    String featName,
    String origin,
    Map<String, String> fixed,
  ) {
    return FeatureChoiceEngine.requestsForFeat(
      catalog: catalog.choices,
      featName: featName,
      level: 1,
    ).map((request) {
      final fixedValue = fixed[request.choiceId];
      final excludedClass = origin == 'species' && featName == 'Magic Initiate' &&
              background?.featName == 'Magic Initiate'
          ? background?.featChoices['spell_class']
          : null;
      final spellClasses = excludedClass == null || request.choiceId != 'spell_class'
          ? null
          : catalog.choices.optionSources[request.requirement.optionsSource]
              ?.where((option) => option.id != excludedClass).toList();
      return FeatureChoiceRequest(
        sourceType: request.sourceType,
        sourceClassEntryId: origin,
        sourceName: request.sourceName,
        featureName: request.featureName,
        level: request.level,
        requirement: fixedValue == null && spellClasses == null
            ? request.requirement
            : SrdFeatureChoiceRequirement(
                id: request.choiceId,
                type: 'option',
                options: spellClasses ?? [SrdFeatureChoiceOption(id: fixedValue!, name: creation2024AbilityName(fixedValue))],
              ),
        requiredCount: request.requiredCount,
      );
    }).toList();
  }

  void reconcileChoices(Creation2024Catalog catalog) {
    final next = requests(catalog);
    featureChoices = [
      for (final request in next)
        request.findIn(featureChoices) ??
            (request.requirement.options.length == 1 && request.requirement.optionsSource == null
                ? request.toChoice([request.requirement.options.first.id])
                : request.emptyChoice()),
    ];
  }

  void setChoices(Creation2024Catalog catalog, List<CharacterFeatureChoice> next) {
    final previous = featureChoices;
    featureChoices = next;
    final currentRequests = requests(catalog);
    final changedDependents = <String>{};
    for (final request in currentRequests) {
      final parentId = request.requirement.spellClassFromChoice ??
          request.requirement.whenChoiceId;
      if (parentId == null) continue;
      final parent = currentRequests.where((entry) =>
          entry.sourceType == request.sourceType &&
          entry.sourceClass == request.sourceClass &&
          entry.sourceClassEntryId == request.sourceClassEntryId &&
          entry.sourceName == request.sourceName &&
          entry.featureName == request.featureName &&
          entry.choiceId == parentId).firstOrNull;
      if (parent?.findIn(previous)?.values.firstOrNull !=
          parent?.findIn(next)?.values.firstOrNull) {
        changedDependents.add(request.key);
      }
    }
    featureChoices = [
      for (final request in currentRequests)
        changedDependents.contains(request.key)
            ? request.emptyChoice()
            : request.findIn(next) ?? request.emptyChoice(),
    ];
    reconcileChoices(catalog);
  }

  bool choicesComplete(Creation2024Catalog catalog) {
    reconcileChoices(catalog);
    final extraLanguages = featureChoices.where((choice) =>
        choice.sourceClass == 'Rogue' && choice.choiceId == 'additional_language')
        .expand((choice) => choice.values);
    if (extraLanguages.any((value) =>
        value == 'common' ||
        languages.any((language) => FeatureChoiceOptionResolver.idFromName(language) == value))) {
      return false;
    }
    return FeatureChoiceEngine.allComplete(requests(catalog), featureChoices);
  }

  List<String> get wizardSpellbook => featureChoices
      .where((choice) =>
          choice.sourceType == FeatureChoiceSourceType.classFeature &&
          choice.sourceClass == 'Wizard' &&
          choice.choiceId == 'prepared_spells')
      .expand((choice) => choice.values)
      .toList();

  Character build(Creation2024Catalog catalog, {required String fallbackName}) {
    if (characterClass == null || species == null || background == null ||
        size == null || !abilitiesComplete || !proficienciesComplete ||
        !equipmentComplete || !choicesComplete(catalog) ||
        characterClass!.name == 'Wizard' &&
            (preparedWizardSpells.length != 4 ||
                !wizardSpellbook.toSet().containsAll(preparedWizardSpells))) {
      throw StateError('Incomplete 2024 character');
    }
    final cls = characterClass!;
    final bg = background!;
    final selectedClassEquipment = keepInventory
        ? null
        : cls.equipmentChoices.firstWhere((choice) => choice.id == classEquipmentId);
    final selectedBackgroundEquipment = keepInventory
        ? null
        : bg.equipmentChoices.firstWhere((choice) => choice.id == backgroundEquipmentId);
    final equipment = <EquipmentItem>[];
    void addItem(String name, int quantity, {String? variant}) {
      final data = catalog.items[name.toLowerCase()];
      if (data != null && data.contents.isNotEmpty) {
        for (final content in data.contents) {
          addItem(content.name, content.quantity * quantity);
        }
        return;
      }
      final tool = catalog.tools.where((entry) => entry.name == name).firstOrNull;
      equipment.add(EquipmentItem(
        name: variant == null ? name : '$name ($variant)',
        quantity: quantity,
        category: data?.category ?? (tool == null ? 'gear' : 'tools'),
        itemType: data?.asItemType ?? ItemType.gear,
        weight: data?.weight ?? tool?.weight ?? 0,
        description: data?.description,
        properties: {
          ...?data?.properties,
          'variant': ?variant,
        },
      ));
    }
    for (final (source, option) in [
      if (selectedClassEquipment != null) ('class', selectedClassEquipment),
      if (selectedBackgroundEquipment != null) ('background', selectedBackgroundEquipment),
    ]) {
      for (var index = 0; index < option.items.length; index++) {
        final item = option.items[index];
        final name = item.choiceFrom == 'toolProficiencyChoices'
            ? backgroundTools.firstOrNull
            : item.selection == 'proficient_tool' && classTools.length == 1
                ? classTools.first
                : specificEquipment['$source:$index'] ?? item.name;
        if (name != null) addItem(name, item.quantity, variant: item.variant);
      }
    }
    EquipmentItem? bodyArmor;
    EquipmentItem? shield;
    for (final item in equipment) {
      if (item.itemType != ItemType.armor) continue;
      if (item.properties?['isShield'] == true) {
        shield ??= item;
      } else {
        bodyArmor ??= item;
      }
    }
    final equipped = [
      for (final item in equipment)
        identical(item, bodyArmor) || identical(item, shield)
            ? item.copyWith(isEquipped: true)
            : item,
    ];
    final attrs = finalAbilities;
    final con = attrs['constitution']!;
    final hp = cls.hitDie + ((con - 10) / 2).floor() +
        (species!.traits.contains('Dwarven Toughness') ? 1 : 0);
    final spellsByName = {for (final spell in catalog.spells) spell.name.toLowerCase(): spell};
    final toolById = {
      for (final tool in catalog.tools)
        FeatureChoiceOptionResolver.idFromName(tool.name): tool.name,
    };
    final knownSpells = <KnownSpell>[];
    final characterLanguages = <String>{
      'Common',
      ...languages,
      ?Progression2024Engine.classLanguages[cls.name],
    };
    final skillsGranted = <String>{...bg.skills, ...skills};
    final expertise = <String>{};
    final toolsGranted = <String>{...bg.tools, ...cls.toolProficiencies, ...classTools, ...backgroundTools};
    final extraFeatures = <CharacterExtraFeature>[];
    final originFeats = <(String, String)>[
      ('Background', bg.featName),
      for (final choice in featureChoices.where((choice) => choice.featureName == 'Versatile'))
        for (final value in choice.values) ('Species', value),
    ];
    for (final (origin, feat) in originFeats) {
      final data = catalog.feats.where((entry) => entry.name == feat).firstOrNull;
      if (data == null) continue;
      extraFeatures.add(CharacterExtraFeature(
        sourceClass: 'Feat',
        sourceType: FeatureChoiceSourceType.feat,
        sourceFeature: origin,
        sourceClassEntryId: origin.toLowerCase(),
        name: feat,
        level: 1,
        type: 'passive',
        description: data.description,
      ));
    }
    final activeRequests = requests(catalog);
    for (final choice in featureChoices) {
      final request = activeRequests.where((entry) => entry.findIn([choice]) != null).firstOrNull;
      if (request == null || !request.isApplicable(featureChoices)) continue;
      final type = request.requirement.type;
      for (final value in choice.values) {
        final name = value.replaceAll('_', ' ');
        if (type == 'skill') {
          skillsGranted.add(name);
        } else if (type == 'skill_expertise' || type == 'skill_or_tool_expertise' && value.startsWith('skill:')) {
          expertise.add(value.replaceFirst('skill:', '').replaceAll('_', ' '));
        } else if (type == 'skill_or_tool' && value.startsWith('skill:')) {
          skillsGranted.add(value.replaceFirst('skill:', '').replaceAll('_', ' '));
        } else if (type == 'skill_or_tool' && value.startsWith('tool:')) {
          final id = value.replaceFirst('tool:', '');
          toolsGranted.add(toolById[id] ?? id.replaceAll('_', ' '));
        } else if (type == 'tool') {
          toolsGranted.add(toolById[value] ?? name);
        } else if (type == 'language') {
          characterLanguages.add(catalog.languages.where((entry) => FeatureChoiceOptionResolver.idFromName(entry.name) == value).firstOrNull?.name ?? name);
        } else if (type == 'cantrip' || type == 'spell') {
          final spell = spellsByName[value.toLowerCase()];
          final spellName = spell?.name ?? value;
          if (knownSpells.any((entry) => entry.name == spellName)) continue;
          knownSpells.add(KnownSpell(
            name: spellName,
            level: spell?.level ?? (type == 'cantrip' ? 0 : 1),
            isPrepared: type == 'cantrip' ||
                choice.sourceType == FeatureChoiceSourceType.feat ||
                cls.name != 'Wizard' || preparedWizardSpells.contains(spellName),
            isAlwaysPrepared: choice.sourceType == FeatureChoiceSourceType.feat,
            sourceType: choice.sourceType,
            sourceClass: choice.sourceClass.isEmpty ? null : choice.sourceClass,
            sourceFeature: choice.featureName,
            sourceClassEntryId: choice.sourceClassEntryId,
          ));
        }
      }
    }
    final lineageChoice = featureChoices.where((choice) =>
        choice.sourceType == FeatureChoiceSourceType.raceTrait &&
        choice.choiceId == 'lineage').firstOrNull?.values.firstOrNull;
    final lineage = species!.lineages.where((entry) => entry['id'] == lineageChoice).firstOrNull;
    if (lineage != null) {
      for (final spellName in [
        if (lineage['cantrip'] is String) lineage['cantrip'] as String,
        ...List<String>.from(lineage['cantrips'] as List<dynamic>? ?? const []),
        ...List<String>.from(lineage['preparedSpells'] as List<dynamic>? ?? const []),
      ]) {
        if (knownSpells.any((entry) => entry.name == spellName)) continue;
        knownSpells.add(KnownSpell(
          name: spellName,
          level: spellsByName[spellName.toLowerCase()]?.level ?? 0,
          isAlwaysPrepared: true,
          sourceType: FeatureChoiceSourceType.raceTrait,
          sourceFeature: lineageChoice,
        ));
      }
    }
    final classSpell = Progression2024Engine.classLevelOneSpells[cls.name];
    for (final (spellName, sourceType, sourceClass, feature) in [
      if (species!.name == 'Tiefling')
        ('Thaumaturgy', FeatureChoiceSourceType.raceTrait, null, 'Otherworldly Presence'),
      if (classSpell != null)
        (classSpell.$1, FeatureChoiceSourceType.classFeature, cls.name, classSpell.$2),
    ]) {
      if (knownSpells.any((entry) => entry.name == spellName)) continue;
      knownSpells.add(KnownSpell(
        name: spellName,
        level: spellsByName[spellName.toLowerCase()]?.level ?? 0,
        isAlwaysPrepared: true,
        sourceType: sourceType,
        sourceClass: sourceClass,
        sourceFeature: feature,
      ));
    }
    final now = DateTime.now();
    final slots = (cls.levelOne['spellSlots'] as List<dynamic>? ?? const []).map((value) => (value as num).toInt()).toList();
    final classChoices = [
      ...featureChoices,
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.background,
        sourceName: bg.name,
        featureName: 'Ability Score Increase',
        choiceId: 'ability_scores',
        values: [
          for (final ability in bg.abilities)
            if (backgroundBonuses.containsKey(ability))
              '$ability:${backgroundBonuses[ability]}',
        ],
      ),
      if (bg.isCustom) CustomBackground.skillsChoice(bg.name, bg.skills),
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.background,
        sourceName: bg.name,
        featureName: 'Tool Proficiency',
        choiceId: 'tools',
        values: backgroundTools.map(FeatureChoiceOptionResolver.idFromName).toList(),
      ),
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: cls.name,
        sourceClassEntryId: 'primary',
        featureName: ChoiceEffects.classSkillsFeature,
        choiceId: 'skills',
        values: skills.map(FeatureChoiceOptionResolver.idFromName).toList(),
      ),
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.classFeature,
        sourceClass: cls.name,
        sourceClassEntryId: 'primary',
        featureName: 'Tool Proficiency',
        choiceId: 'tools',
        values: classTools.map(FeatureChoiceOptionResolver.idFromName).toList(),
      ),
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.origin,
        featureName: 'Languages',
        choiceId: 'languages',
        values: languages.map(FeatureChoiceOptionResolver.idFromName).toList(),
      ),
      if (!keepInventory) ...[
        CharacterFeatureChoice(
          sourceType: FeatureChoiceSourceType.background,
          sourceName: bg.name,
          featureName: 'Starting Equipment',
          choiceId: 'equipment',
          values: [backgroundEquipmentId!],
        ),
        CharacterFeatureChoice(
          sourceType: FeatureChoiceSourceType.classFeature,
          sourceClass: cls.name,
          sourceClassEntryId: 'primary',
          featureName: 'Starting Equipment',
          choiceId: 'equipment',
          values: [classEquipmentId!],
        ),
      ],
      CharacterFeatureChoice(
        sourceType: FeatureChoiceSourceType.raceTrait,
        sourceName: species!.name,
        featureName: 'Size',
        choiceId: 'size',
        values: [size!],
      ),
    ];
    var character = Character(
      id: id,
      rulesetId: RulesetId.dnd2024,
      contentPackId: ContentPackId.srd521,
      name: name.trim().isEmpty ? fallbackName : name.trim(),
      playerName: playerName.trim(),
      race: species!.name,
      characterClass: cls.name,
      classes: [CharacterClassEntry(id: 'primary', className: cls.name, level: 1, isStartingClass: true)],
      background: bg.name,
      abilityScores: AbilityScores(
        strength: attrs['strength']!, dexterity: attrs['dexterity']!,
        constitution: con, intelligence: attrs['intelligence']!,
        wisdom: attrs['wisdom']!, charisma: attrs['charisma']!,
      ),
      hitPoints: HitPoints(maximum: hp, current: hp),
      speed: (lineage?['speed'] as num?)?.toInt() ?? species!.speed,
      savingThrowProficiencies: cls.savingThrows,
      skillProficiencies: skillsGranted.toList(),
      skillExpertises: expertise.toList(),
      equipment: equipped,
      currency: {
        'cp': 0, 'sp': 0, 'ep': 0, 'pp': 0,
        'gp': (selectedClassEquipment?.gp ?? 0) + (selectedBackgroundEquipment?.gp ?? 0),
      },
      spells: knownSpells,
      spellSlots: SpellSlots(total: List<int>.generate(9, (index) => index < slots.length ? slots[index] : 0)),
      pactMagicSlots: SpellSlots(total: [
        (cls.levelOne['pactMagicSlots'] as num?)?.toInt() ?? 0,
        ...List<int>.filled(8, 0),
      ]),
      hitDicePools: [CharacterHitDiePool(dieSize: cls.hitDie, total: 1, sourceClass: cls.name, sourceClassEntryId: 'primary')],
      levelHistory: [
        CharacterLevelRecord(
          characterLevel: 1,
          classEntryId: 'primary',
          className: cls.name,
          classLevel: 1,
          hitPointsGained: hp,
          hitPointMethod: HitPointGainMethod.maximum,
          baseAbilityScores: {
            for (final ability in creation2024Abilities)
              ability: baseAbilities[ability] ?? 10,
          },
        ),
      ],
      features: [for (final tool in toolsGranted) 'Tool Proficiency: $tool'],
      extraFeatures: extraFeatures,
      featureChoices: classChoices,
      languages: characterLanguages.toList(),
      creationMode: CreationMode.guided,
      createdAt: now,
      updatedAt: now,
    );
    character = character.copyWith(armorClass: calcArmorClass(character));
    return character;
  }
}
