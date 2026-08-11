import 'package:dnd_character_tool/data/character_progression/character_progression.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  String cls = 'Fighter',
  int level = 1,
  AbilityScores scores = const AbilityScores(),
  List<CharacterClassEntry> classes = const [],
}) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    name: 'Test Hero',
    race: 'Human',
    characterClass: cls,
    level: level,
    classes: classes,
    abilityScores: scores,
    hitPoints: const HitPoints(maximum: 10, current: 10),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('MulticlassPrerequisites.resultForClass', () {
    test('fighter accepts Strength or Dexterity 13', () {
      expect(
        MulticlassPrerequisites.resultForClass(
          'Fighter',
          const AbilityScores(strength: 13, dexterity: 8),
        ).isMet,
        isTrue,
      );
      expect(
        MulticlassPrerequisites.resultForClass(
          'Fighter',
          const AbilityScores(strength: 8, dexterity: 13),
        ).isMet,
        isTrue,
      );
      expect(
        MulticlassPrerequisites.resultForClass(
          'Fighter',
          const AbilityScores(strength: 12, dexterity: 12),
        ).isMet,
        isFalse,
      );
    });

    test('monk requires Dexterity and Wisdom 13', () {
      expect(
        MulticlassPrerequisites.resultForClass(
          'Monk',
          const AbilityScores(dexterity: 13, wisdom: 13),
        ).isMet,
        isTrue,
      );
      expect(
        MulticlassPrerequisites.resultForClass(
          'Monk',
          const AbilityScores(dexterity: 13, wisdom: 12),
        ).isMet,
        isFalse,
      );
    });

    test('unknown classes have no hardcoded requirement', () {
      final result = MulticlassPrerequisites.resultForClass(
        'Homebrew Class',
        const AbilityScores(),
      );

      expect(result.hasRequirements, isFalse);
      expect(result.isMet, isTrue);
    });
  });

  group('MulticlassPrerequisites.validateAddClass', () {
    test('requires both current classes and target class to qualify', () {
      final character = _character(
        cls: 'Wizard',
        level: 3,
        scores: const AbilityScores(intelligence: 12, wisdom: 13),
      );

      final check = MulticlassPrerequisites.validateAddClass(
        character: character,
        targetClass: 'Cleric',
      );

      expect(check.targetClassResult.isMet, isTrue);
      expect(check.currentClassesMeetRequirements, isFalse);
      expect(check.canAddClass, isFalse);
      expect(check.failedResults.single.className, 'Wizard');
    });

    test('allows adding a class when current and target requirements are met', () {
      final character = _character(
        cls: 'Wizard',
        level: 3,
        scores: const AbilityScores(intelligence: 13, wisdom: 13),
      );

      final check = MulticlassPrerequisites.validateAddClass(
        character: character,
        targetClass: 'Cleric',
      );

      expect(check.currentClassesMeetRequirements, isTrue);
      expect(check.targetClassResult.isMet, isTrue);
      expect(check.canAddClass, isTrue);
    });

    test('blocks adding the same class twice', () {
      final character = _character(
        cls: 'Fighter',
        scores: const AbilityScores(strength: 13),
      );

      final check = MulticlassPrerequisites.validateAddClass(
        character: character,
        targetClass: 'Fighter',
      );

      expect(check.alreadyHasTargetClass, isTrue);
      expect(check.canAddClass, isFalse);
    });

    test('checks every existing class only once', () {
      final character = _character(
        cls: 'Fighter',
        level: 4,
        scores: const AbilityScores(strength: 13, intelligence: 13),
        classes: const [
          CharacterClassEntry(
            id: 'fighter-1',
            className: 'Fighter',
            level: 3,
            isStartingClass: true,
          ),
          CharacterClassEntry(
            id: 'fighter-2',
            className: 'Fighter',
            level: 1,
          ),
        ],
      );

      final check = MulticlassPrerequisites.validateAddClass(
        character: character,
        targetClass: 'Wizard',
      );

      expect(check.currentClassResults, hasLength(1));
      expect(check.canAddClass, isTrue);
    });
  });
}
