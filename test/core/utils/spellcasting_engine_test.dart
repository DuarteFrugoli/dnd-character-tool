import 'package:dnd_character_tool/data/spellcasting_engine.dart';
import 'package:dnd_character_tool/data/models/ability_scores.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

SpellcastingEngine _engine(
  String cls,
  int level,
  AbilityScores scores, {
  String? subclass,
}) => SpellcastingEngine.forClass(
  className: cls,
  classLevel: level,
  abilityScores: scores,
  proficiencyBonus: _profBonus(level),
  subclass: subclass,
)!;

/// PHB proficiency bonus by total character level (proxy = class level here).
int _profBonus(int level) {
  if (level < 5) return 2;
  if (level < 9) return 3;
  if (level < 13) return 4;
  if (level < 17) return 5;
  return 6;
}

const _avg = AbilityScores(
  strength: 10,
  dexterity: 10,
  constitution: 10,
  intelligence: 10,
  wisdom: 10,
  charisma: 10,
);

const _wis16 = AbilityScores(wisdom: 16); // modifier = +3
const _int18 = AbilityScores(intelligence: 18); // modifier = +4
const _cha14 = AbilityScores(charisma: 14); // modifier = +2

void main() {
  // ── forClass returns null for non-casters ──────────────────────────────────
  group('forClass – non-casters', () {
    test('base Fighter returns null', () {
      expect(
        SpellcastingEngine.forClass(
          className: 'Fighter',
          classLevel: 5,
          abilityScores: _avg,
          proficiencyBonus: 3,
        ),
        isNull,
      );
    });

    test('base Rogue returns null', () {
      expect(
        SpellcastingEngine.forClass(
          className: 'Rogue',
          classLevel: 5,
          abilityScores: _avg,
          proficiencyBonus: 3,
        ),
        isNull,
      );
    });

    test('Barbarian returns null', () {
      expect(
        SpellcastingEngine.forClass(
          className: 'barbarian',
          classLevel: 5,
          abilityScores: _avg,
          proficiencyBonus: 3,
        ),
        isNull,
      );
    });
  });

  // ── Cleric (full-caster, WIS, prepare) ────────────────────────────────────
  group('Cleric', () {
    test('level 3, WIS 16: saveDC = 13', () {
      // 8 + profBonus(2) + wismod(3) = 13
      expect(_engine('cleric', 3, _wis16).saveDC, 13);
    });

    test('level 3, WIS 16: spellAttack = +5', () {
      expect(_engine('cleric', 3, _wis16).spellAttack, 5);
    });

    test('level 3, WIS 16: maxPrepared = 6', () {
      // wismod(3) + level(3) = 6
      expect(_engine('cleric', 3, _wis16).maxPrepared, 6);
    });

    test('maxPrepared minimum is 1 even with negative modifier', () {
      const lowWis = AbilityScores(wisdom: 6); // mod = -2
      // -2 + 1 = -1 → clamped to 1
      expect(_engine('cleric', 1, lowWis).maxPrepared, 1);
    });

    test('level 5: maxSpellLevel = 3', () {
      expect(_engine('cleric', 5, _wis16).maxSpellLevel, 3);
    });

    test('level 1: slotsPerLevel has 2 first-level slots', () {
      final slots = _engine('cleric', 1, _wis16).slotsPerLevel;
      expect(slots[0], 2); // level-1 slots
      expect(slots.sublist(1).every((s) => s == 0), isTrue);
    });

    test('level 9: slotsPerLevel has 4-3-3-3-1 for levels 1-5', () {
      final slots = _engine('cleric', 9, _wis16).slotsPerLevel;
      expect(slots.take(5).toList(), [4, 3, 3, 3, 1]);
    });

    test('maxKnown is null (prepare class)', () {
      expect(_engine('cleric', 5, _wis16).maxKnown, isNull);
    });
  });

  // ── Wizard (full-caster, INT, spellbook / prepare) ────────────────────────
  group('Wizard', () {
    test('level 5, INT 18: saveDC = 15', () {
      // 8 + profBonus(3) + intmod(4) = 15
      expect(_engine('wizard', 5, _int18).saveDC, 15);
    });

    test('level 5, INT 18: maxPrepared = 9', () {
      // intmod(4) + level(5) = 9
      expect(_engine('wizard', 5, _int18).maxPrepared, 9);
    });

    test('level 5: maxSpellLevel = 3', () {
      expect(_engine('wizard', 5, _int18).maxSpellLevel, 3);
    });

    test('maxKnown is null (spellbook class)', () {
      expect(_engine('wizard', 5, _int18).maxKnown, isNull);
    });
  });

  // ── Paladin (half-caster, CHA, prepareHalf) ───────────────────────────────
  group('Paladin', () {
    test('level 5, CHA 14: maxPrepared = 4', () {
      // chamod(2) + floor(5/2=2) = 4
      expect(_engine('paladin', 5, _cha14).maxPrepared, 4);
    });

    test('level 2: no spell slots (Paladin starts slots at level 2)', () {
      // PHB: Paladin gets first slots at level 2
      final slots = _engine('paladin', 2, _cha14).slotsPerLevel;
      expect(slots[0], 2);
    });

    test('level 1: maxSpellLevel = 0', () {
      expect(_engine('paladin', 1, _cha14).maxSpellLevel, 0);
    });

    test('has no cantrips in base SRD', () {
      expect(_engine('paladin', 3, _cha14).maxCantrips, 0);
    });
  });

  group('Ranger', () {
    test('has no cantrips in base SRD', () {
      expect(_engine('ranger', 3, _wis16).maxCantrips, 0);
    });
  });

  // ── Warlock (pact magic, CHA, known) ─────────────────────────────────────
  group('Warlock', () {
    test('level 3: 2 pact slots of level 2', () {
      final engine = _engine('warlock', 3, _cha14);
      final slots = engine.slotsPerLevel;
      // Warlock level 3 → 2 slots at spell level 2
      expect(slots[1], 2); // index 1 = spell level 2
      expect(slots[0], 0); // no level-1 slots
    });

    test('level 3: maxKnown = 4', () {
      expect(_engine('warlock', 3, _cha14).maxKnown, 4);
    });

    test('maxPrepared is null (known class)', () {
      expect(_engine('warlock', 3, _cha14).maxPrepared, isNull);
    });
  });

  // ── Eldritch Knight (Fighter 1/3-caster) ─────────────────────────────────
  group('Eldritch Knight (Fighter subclass)', () {
    test('level 7: has 4+2 slots (1st+2nd)', () {
      final engine = SpellcastingEngine.forClass(
        className: 'Fighter',
        classLevel: 7,
        abilityScores: _int18,
        proficiencyBonus: 3,
        subclass: 'Eldritch Knight',
      )!;
      final slots = engine.slotsPerLevel;
      expect(slots[0], 4);
      expect(slots[1], 2);
    });

    test('level 7: maxKnown = 5', () {
      final engine = SpellcastingEngine.forClass(
        className: 'Fighter',
        classLevel: 7,
        abilityScores: _int18,
        proficiencyBonus: 3,
        subclass: 'Eldritch Knight',
      )!;
      expect(engine.maxKnown, 5);
    });

    test('level 3: has 2 subclass cantrips', () {
      final engine = SpellcastingEngine.forClass(
        className: 'Fighter',
        classLevel: 3,
        abilityScores: _int18,
        proficiencyBonus: 2,
        subclass: 'Eldritch Knight',
      )!;
      expect(engine.maxCantrips, 2);
    });

    test('uses the wizard spell list with abjuration/evocation limits', () {
      final engine = SpellcastingEngine.forClass(
        className: 'Fighter',
        classLevel: 3,
        abilityScores: _int18,
        proficiencyBonus: 2,
        subclass: 'Eldritch Knight',
      )!;
      expect(engine.spellListClass, 'wizard');
      expect(engine.restrictedKnownSpellSchools, {'abjuration', 'evocation'});
      expect(engine.restrictedKnownSpellPicksRequired(3), 2);
    });

    test('level 2: no slots yet (1/3 casters start at level 3)', () {
      final engine = SpellcastingEngine.forClass(
        className: 'Fighter',
        classLevel: 2,
        abilityScores: _int18,
        proficiencyBonus: 2,
        subclass: 'Eldritch Knight',
      )!;
      expect(engine.slotsPerLevel.every((s) => s == 0), isTrue);
    });
  });

  // ── KnownSpellCasting.classPrepares ───────────────────────────────────────
  group('Arcane Trickster (Rogue subclass)', () {
    test('level 3: has Mage Hand plus 2 selectable cantrips', () {
      final engine = SpellcastingEngine.forClass(
        className: 'Rogue',
        classLevel: 3,
        abilityScores: _int18,
        proficiencyBonus: 2,
        subclass: 'Arcane Trickster',
      )!;
      expect(engine.maxCantrips, 3);
      expect(engine.fixedCantripNames, ['Mage Hand']);
      expect(engine.spellListClass, 'wizard');
    });

    test('uses enchantment/illusion limits except unrestricted levels', () {
      final engine = SpellcastingEngine.forClass(
        className: 'Rogue',
        classLevel: 7,
        abilityScores: _int18,
        proficiencyBonus: 3,
        subclass: 'Arcane Trickster',
      )!;
      expect(engine.restrictedKnownSpellSchools, {'enchantment', 'illusion'});
      expect(engine.restrictedKnownSpellPicksRequired(1), 1);

      final unrestricted = SpellcastingEngine.forClass(
        className: 'Rogue',
        classLevel: 8,
        abilityScores: _int18,
        proficiencyBonus: 3,
        subclass: 'Arcane Trickster',
      )!;
      expect(unrestricted.restrictedKnownSpellPicksRequired(1), 0);
    });
  });

  group('KnownSpellCasting.classPrepares', () {
    test('cleric prepares', () {
      expect(KnownSpellCasting.classPrepares('cleric'), isTrue);
    });

    test('druid prepares', () {
      expect(KnownSpellCasting.classPrepares('Druid'), isTrue);
    });

    test('paladin prepares', () {
      expect(KnownSpellCasting.classPrepares('Paladin'), isTrue);
    });

    test('wizard prepares (from spellbook)', () {
      expect(KnownSpellCasting.classPrepares('wizard'), isTrue);
    });

    test('bard does NOT prepare (known-caster)', () {
      expect(KnownSpellCasting.classPrepares('bard'), isFalse);
    });

    test('sorcerer does NOT prepare', () {
      expect(KnownSpellCasting.classPrepares('sorcerer'), isFalse);
    });

    test('warlock does NOT prepare', () {
      expect(KnownSpellCasting.classPrepares('warlock'), isFalse);
    });
  });

  // ── spellAttackFormatted ──────────────────────────────────────────────────
  group('spellAttackFormatted', () {
    test('positive attack is prefixed with +', () {
      expect(_engine('cleric', 3, _wis16).spellAttackFormatted, '+5');
    });

    test('zero attack is prefixed with +', () {
      // WIS 10 (mod 0), profBonus 2 → +2
      expect(_engine('cleric', 1, _avg).spellAttackFormatted, '+2');
    });

    test('negative attack has no extra prefix', () {
      const lowWis = AbilityScores(wisdom: 6); // mod = -2
      // profBonus(2) + (-2) = 0, but still shows +0
      final engine = SpellcastingEngine.forClass(
        className: 'cleric',
        classLevel: 1,
        abilityScores: lowWis,
        proficiencyBonus: 2,
      )!;
      expect(engine.spellAttack, 0);
      expect(engine.spellAttackFormatted, '+0');
    });
  });
}
