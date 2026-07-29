import 'package:dnd_character_tool/data/models/ability_scores.dart';
import 'package:dnd_character_tool/data/models/character.dart';
import 'package:dnd_character_tool/data/models/character_class_entry.dart';
import 'package:dnd_character_tool/data/models/character_hit_die_pool.dart';
import 'package:dnd_character_tool/data/models/hit_points.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Character _makeCharacter({
  AbilityScores scores = const AbilityScores(),
  HitPoints? hp,
  List<String> skillProfs = const [],
  List<String> skillExpertises = const [],
  int proficiencyBonus = 2,
  int level = 1,
  String cls = 'Fighter',
}) {
  final now = DateTime(2024);
  return Character(
    id: 'test-id',
    name: 'Test Hero',
    race: 'Human',
    characterClass: cls,
    level: level,
    abilityScores: scores,
    hitPoints: hp ?? const HitPoints(maximum: 10, current: 10),
    proficiencyBonus: proficiencyBonus,
    skillProficiencies: skillProfs,
    skillExpertises: skillExpertises,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  // ── HitPoints ─────────────────────────────────────────────────────────────
  group('HitPoints', () {
    test('isDead when current = 0 and no temp HP', () {
      const hp = HitPoints(maximum: 10, current: 0, temporary: 0);
      expect(hp.isDead, isTrue);
    });

    test('not dead when temp HP > 0', () {
      const hp = HitPoints(maximum: 10, current: 0, temporary: 5);
      expect(hp.isDead, isFalse);
    });

    test('not dead when current > 0', () {
      const hp = HitPoints(maximum: 10, current: 1, temporary: 0);
      expect(hp.isDead, isFalse);
    });

    test('effective = current + temporary', () {
      const hp = HitPoints(maximum: 10, current: 7, temporary: 3);
      expect(hp.effective, 10);
    });

    test('copyWith preserves fields not specified', () {
      const hp = HitPoints(maximum: 20, current: 15, temporary: 5);
      final copied = hp.copyWith(current: 10);
      expect(copied.maximum, 20);
      expect(copied.current, 10);
      expect(copied.temporary, 5);
    });

    test('JSON round-trip preserves values', () {
      const hp = HitPoints(maximum: 20, current: 15, temporary: 3);
      final json = hp.toJson();
      final restored = HitPoints.fromJson(json);
      expect(restored.maximum, hp.maximum);
      expect(restored.current, hp.current);
      expect(restored.temporary, hp.temporary);
    });
  });

  // ── AbilityScores ─────────────────────────────────────────────────────────
  group('AbilityScores modifiers', () {
    test('score 10 → modifier 0', () {
      const s = AbilityScores(wisdom: 10);
      expect(s.wisdomModifier, 0);
    });

    test('score 16 → modifier +3', () {
      const s = AbilityScores(wisdom: 16);
      expect(s.wisdomModifier, 3);
    });

    test('score 8 → modifier -1', () {
      const s = AbilityScores(dexterity: 8);
      expect(s.dexterityModifier, -1);
    });

    test('score 20 → modifier +5', () {
      const s = AbilityScores(strength: 20);
      expect(s.strengthModifier, 5);
    });

    test('score 1 → modifier -5', () {
      const s = AbilityScores(constitution: 1);
      expect(s.constitutionModifier, -5);
    });

    test('[] operator returns correct score', () {
      const s = AbilityScores(intelligence: 14);
      expect(s['intelligence'], 14);
      expect(s['Intelligence'], 14); // case-insensitive
    });
  });

  // ── Character.passivePerception ───────────────────────────────────────────
  group('Character.passivePerception', () {
    test('base: 10 + wisdom modifier', () {
      final c = _makeCharacter(scores: const AbilityScores(wisdom: 14));
      // wismod = 2, no proficiency → 10 + 2 = 12
      expect(c.passivePerception, 12);
    });

    test('with perception proficiency: + proficiency bonus', () {
      final c = _makeCharacter(
        scores: const AbilityScores(wisdom: 14),
        skillProfs: ['perception'],
        proficiencyBonus: 3,
      );
      // 10 + 2 + 3 = 15
      expect(c.passivePerception, 15);
    });

    test('with perception expertise: + 2 × proficiency bonus', () {
      final c = _makeCharacter(
        scores: const AbilityScores(wisdom: 14),
        skillProfs: ['perception'],
        skillExpertises: ['perception'],
        proficiencyBonus: 3,
      );
      // 10 + 2 + 3 + 3 = 18
      expect(c.passivePerception, 18);
    });

    test('wisdom 10, no proficiency → 10', () {
      final c = _makeCharacter();
      expect(c.passivePerception, 10);
    });
  });

  // ── Character.initiative ──────────────────────────────────────────────────
  group('Character.initiative', () {
    test('equals dexterity modifier', () {
      final c = _makeCharacter(scores: const AbilityScores(dexterity: 16));
      expect(c.initiative, 3);
    });

    test('negative dex → negative initiative', () {
      final c = _makeCharacter(scores: const AbilityScores(dexterity: 8));
      expect(c.initiative, -1);
    });
  });

  // ── Character.copyWith ────────────────────────────────────────────────────
  group('Character.copyWith', () {
    test('changed field is updated', () {
      final c = _makeCharacter();
      final updated = c.copyWith(name: 'New Name');
      expect(updated.name, 'New Name');
    });

    test('unchanged fields are preserved', () {
      final c = _makeCharacter(cls: 'Wizard', level: 5);
      final updated = c.copyWith(name: 'Changed');
      expect(updated.characterClass, 'Wizard');
      expect(updated.level, 5);
      expect(updated.id, c.id);
    });

    test('clearImagePath sets imagePath to null', () {
      final now = DateTime(2024);
      final c = Character(
        id: 'x',
        name: 'x',
        race: 'Human',
        characterClass: 'Fighter',
        abilityScores: const AbilityScores(),
        hitPoints: const HitPoints(maximum: 10, current: 10),
        createdAt: now,
        updatedAt: now,
        imagePath: 'some/path.png',
      );
      final updated = c.copyWith(clearImagePath: true);
      expect(updated.imagePath, isNull);
    });

    test('returns a new object (immutability)', () {
      final c = _makeCharacter();
      final updated = c.copyWith(name: 'Other');
      expect(identical(c, updated), isFalse);
      expect(c.name, 'Test Hero'); // original unchanged
    });
  });

  // ── Character JSON round-trip ─────────────────────────────────────────────
  group('Character multiclass structure helpers', () {
    test('falls back to the legacy single class fields', () {
      final c = _makeCharacter(cls: 'Wizard', level: 5);

      expect(c.classEntries.single.className, 'Wizard');
      expect(c.classEntries.single.level, 5);
      expect(c.totalLevel, 5);
      expect(c.primaryClass.id, 'primary');
      expect(c.classLevel('Wizard'), 5);
    });

    test('uses persisted class entries and hit die pools when present', () {
      final c = _makeCharacter(cls: 'Fighter', level: 5).copyWith(
        classes: const [
          CharacterClassEntry(
            id: 'fighter',
            className: 'Fighter',
            level: 3,
            isStartingClass: true,
          ),
          CharacterClassEntry(id: 'wizard', className: 'Wizard', level: 2),
        ],
        hitDicePools: const [
          CharacterHitDiePool(
            dieSize: 10,
            total: 3,
            used: 1,
            sourceClassEntryId: 'fighter',
          ),
          CharacterHitDiePool(
            dieSize: 6,
            total: 2,
            used: 0,
            sourceClassEntryId: 'wizard',
          ),
        ],
      );

      expect(c.totalLevel, 5);
      expect(c.classLevel('Wizard'), 2);
      expect(c.totalHitDice, 5);
      expect(c.totalHitDiceUsed, 1);
      expect(c.availableHitDice, 4);
    });
  });

  group('Character JSON round-trip', () {
    test('serialisation preserves all basic fields', () {
      final c = _makeCharacter(
        scores: const AbilityScores(strength: 14, dexterity: 12),
        hp: const HitPoints(maximum: 20, current: 15, temporary: 3),
        proficiencyBonus: 3,
      );
      final json = c.toJson();
      final restored = Character.fromJson(json);

      expect(restored.id, c.id);
      expect(restored.name, c.name);
      expect(restored.abilityScores.strength, 14);
      expect(restored.abilityScores.dexterity, 12);
      expect(restored.hitPoints.maximum, 20);
      expect(restored.hitPoints.current, 15);
      expect(restored.hitPoints.temporary, 3);
      expect(restored.proficiencyBonus, 3);
    });
  });
}
