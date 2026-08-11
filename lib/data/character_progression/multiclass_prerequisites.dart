import '../models/models.dart';

class MulticlassAbilityRequirement {
  const MulticlassAbilityRequirement(this.ability, this.minimum);

  final String ability;
  final int minimum;

  bool isMetBy(AbilityScores scores) => scores[ability] >= minimum;

  String get debugLabel => '${_abilityLabel(ability)} $minimum';
}

class MulticlassPrerequisiteOption {
  const MulticlassPrerequisiteOption(this.requirements);

  final List<MulticlassAbilityRequirement> requirements;

  bool isMetBy(AbilityScores scores) {
    return requirements.every((requirement) => requirement.isMetBy(scores));
  }

  String get debugLabel {
    return requirements
        .map((requirement) => requirement.debugLabel)
        .join(' and ');
  }
}

class MulticlassPrerequisiteResult {
  const MulticlassPrerequisiteResult({
    required this.className,
    required this.options,
    required this.isMet,
  });

  final String className;
  final List<MulticlassPrerequisiteOption> options;
  final bool isMet;

  bool get hasRequirements => options.isNotEmpty;

  String get debugLabel {
    if (options.isEmpty) return '';
    return options.map((option) => option.debugLabel).join(' or ');
  }
}

class MulticlassAddClassCheck {
  const MulticlassAddClassCheck({
    required this.targetClass,
    required this.alreadyHasTargetClass,
    required this.currentClassResults,
    required this.targetClassResult,
  });

  final String targetClass;
  final bool alreadyHasTargetClass;
  final List<MulticlassPrerequisiteResult> currentClassResults;
  final MulticlassPrerequisiteResult targetClassResult;

  bool get currentClassesMeetRequirements {
    return currentClassResults.every((result) => result.isMet);
  }

  bool get canAddClass {
    return !alreadyHasTargetClass &&
        currentClassesMeetRequirements &&
        targetClassResult.isMet;
  }

  List<MulticlassPrerequisiteResult> get failedResults {
    return [
      ...currentClassResults.where((result) => !result.isMet),
      if (!targetClassResult.isMet) targetClassResult,
    ];
  }
}

class MulticlassPrerequisites {
  const MulticlassPrerequisites._();

  static MulticlassPrerequisiteResult resultForClass(
    String className,
    AbilityScores scores,
  ) {
    final options = optionsForClass(className);
    return MulticlassPrerequisiteResult(
      className: className,
      options: options,
      isMet: options.isEmpty ||
          options.any((option) => option.isMetBy(scores)),
    );
  }

  static List<MulticlassPrerequisiteOption> optionsForClass(String className) {
    return _requirements[className.toLowerCase()] ?? const [];
  }

  static MulticlassAddClassCheck validateAddClass({
    required Character character,
    required String targetClass,
  }) {
    final targetKey = targetClass.toLowerCase();
    final existingClassNames = <String>{};
    final currentResults = <MulticlassPrerequisiteResult>[];

    for (final entry in character.classEntries) {
      final key = entry.className.toLowerCase();
      if (!existingClassNames.add(key)) continue;
      currentResults.add(
        resultForClass(entry.className, character.abilityScores),
      );
    }

    return MulticlassAddClassCheck(
      targetClass: targetClass,
      alreadyHasTargetClass: existingClassNames.contains(targetKey),
      currentClassResults: currentResults,
      targetClassResult: resultForClass(targetClass, character.abilityScores),
    );
  }

  static bool canAddClass({
    required Character character,
    required String targetClass,
  }) {
    return validateAddClass(
      character: character,
      targetClass: targetClass,
    ).canAddClass;
  }

  static const _requirements = <String, List<MulticlassPrerequisiteOption>>{
    'barbarian': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('strength', 13),
      ]),
    ],
    'bard': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('charisma', 13),
      ]),
    ],
    'cleric': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('wisdom', 13),
      ]),
    ],
    'druid': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('wisdom', 13),
      ]),
    ],
    'fighter': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('strength', 13),
      ]),
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('dexterity', 13),
      ]),
    ],
    'monk': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('dexterity', 13),
        MulticlassAbilityRequirement('wisdom', 13),
      ]),
    ],
    'paladin': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('strength', 13),
        MulticlassAbilityRequirement('charisma', 13),
      ]),
    ],
    'ranger': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('dexterity', 13),
        MulticlassAbilityRequirement('wisdom', 13),
      ]),
    ],
    'rogue': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('dexterity', 13),
      ]),
    ],
    'sorcerer': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('charisma', 13),
      ]),
    ],
    'warlock': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('charisma', 13),
      ]),
    ],
    'wizard': [
      MulticlassPrerequisiteOption([
        MulticlassAbilityRequirement('intelligence', 13),
      ]),
    ],
  };
}

String _abilityLabel(String ability) {
  switch (ability.toLowerCase()) {
    case 'strength':
      return 'Strength';
    case 'dexterity':
      return 'Dexterity';
    case 'constitution':
      return 'Constitution';
    case 'intelligence':
      return 'Intelligence';
    case 'wisdom':
      return 'Wisdom';
    case 'charisma':
      return 'Charisma';
    default:
      return ability;
  }
}
