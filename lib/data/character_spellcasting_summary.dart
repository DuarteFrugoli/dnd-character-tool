import 'models/models.dart';
import 'spellcasting_engine.dart';

class CharacterSpellcastingOrigin {
  final CharacterClassEntry classEntry;
  final SpellcastingEngine engine;
  final List<KnownSpell> spells;

  const CharacterSpellcastingOrigin({
    required this.classEntry,
    required this.engine,
    required this.spells,
  });

  List<KnownSpell> get cantrips =>
      spells.where((spell) => spell.level == 0).toList();
}

class CharacterSpellcastingSummary {
  final List<CharacterSpellcastingOrigin> origins;
  final List<KnownSpell> unassignedSpells;
  final SpellSlots standardSlots;
  final SpellSlots pactMagicSlots;

  const CharacterSpellcastingSummary({
    required this.origins,
    required this.unassignedSpells,
    required this.standardSlots,
    required this.pactMagicSlots,
  });

  bool get hasSpellcasting => origins.isNotEmpty;

  CharacterSpellcastingOrigin? get primaryOrigin {
    for (final origin in origins) {
      if (origin.classEntry.isStartingClass) return origin;
    }
    return origins.isEmpty ? null : origins.first;
  }

  SpellcastingEngine? get primaryEngine => primaryOrigin?.engine;

  factory CharacterSpellcastingSummary.fromCharacter(Character character) {
    final origins = <CharacterSpellcastingOrigin>[];
    final assignedSpellIndexes = <int>{};

    for (final entry in character.classEntries) {
      final engine = SpellcastingEngine.forClass(
        className: entry.className,
        classLevel: entry.level,
        abilityScores: character.abilityScores,
        proficiencyBonus: character.proficiencyBonus,
        subclass: entry.subclassName,
      );
      if (engine == null) continue;
      final spells = <KnownSpell>[];
      for (var i = 0; i < character.spells.length; i++) {
        final spell = character.spells[i];
        final matchesEntry = spell.sourceClassEntryId == entry.id;
        final legacyClassMatch =
            spell.sourceClassEntryId == null &&
            spell.sourceClass == entry.className;
        final matches = matchesEntry || legacyClassMatch;
        if (matches) {
          assignedSpellIndexes.add(i);
          spells.add(spell);
        }
      }
      origins.add(
        CharacterSpellcastingOrigin(
          classEntry: entry,
          engine: engine,
          spells: spells,
        ),
      );
    }

    final unassignedSpells = <KnownSpell>[];
    for (var i = 0; i < character.spells.length; i++) {
      if (!assignedSpellIndexes.contains(i)) {
        unassignedSpells.add(character.spells[i]);
      }
    }

    return CharacterSpellcastingSummary(
      origins: origins,
      unassignedSpells: unassignedSpells,
      standardSlots: _standardSlotsFor(character, origins),
      pactMagicSlots: _pactMagicSlotsFor(character, origins),
    );
  }

  static SpellSlots _standardSlotsFor(
    Character character,
    List<CharacterSpellcastingOrigin> origins,
  ) {
    final standardOrigins = origins.where((origin) {
      return origin.engine.progressionType != SpellProgressionType.pact;
    }).toList();
    if (standardOrigins.isEmpty) return const SpellSlots();
    if (standardOrigins.length == 1 && origins.length == 1) {
      return _withUsedClamped(
        character.spellSlots,
        standardOrigins.first.engine.slotsPerLevel,
      );
    }

    var casterLevel = 0;
    for (final origin in standardOrigins) {
      casterLevel += _multiclassCasterLevelContribution(origin.engine);
    }
    final total = SpellcastingEngine.slotsForMulticlassCasterLevel(casterLevel);
    return _withUsedClamped(character.spellSlots, total);
  }

  static SpellSlots _pactMagicSlotsFor(
    Character character,
    List<CharacterSpellcastingOrigin> origins,
  ) {
    final pactOrigins = origins.where((origin) {
      return origin.engine.progressionType == SpellProgressionType.pact;
    }).toList();
    if (pactOrigins.isEmpty) return const SpellSlots();
    final total = List<int>.filled(9, 0);
    for (final origin in pactOrigins) {
      final slots = origin.engine.slotsPerLevel;
      for (var i = 0; i < total.length; i++) {
        total[i] += slots[i];
      }
    }
    final current = character.pactMagicSlots.total.any((slot) => slot > 0)
        ? character.pactMagicSlots
        : pactOrigins.length == 1 && origins.length == 1
        ? character.spellSlots
        : const SpellSlots();
    return _withUsedClamped(current, total);
  }

  static int _multiclassCasterLevelContribution(SpellcastingEngine engine) {
    switch (engine.progressionType) {
      case SpellProgressionType.full:
        return engine.classLevel;
      case SpellProgressionType.half:
        return (engine.classLevel / 2).floor();
      case SpellProgressionType.third:
        return (engine.classLevel / 3).floor();
      case SpellProgressionType.pact:
        return 0;
    }
  }

  static SpellSlots _withUsedClamped(SpellSlots current, List<int> total) {
    final used = List<int>.generate(9, (i) {
      final currentUsed = i < current.used.length ? current.used[i] : 0;
      return currentUsed.clamp(0, total[i]).toInt();
    });
    return SpellSlots(total: total, used: used);
  }
}
