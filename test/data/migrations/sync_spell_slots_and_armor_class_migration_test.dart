import 'package:dnd_character_tool/data/migrations/character_migration.dart';
import 'package:dnd_character_tool/data/migrations/migrations/sync_spell_slots_and_armor_class_migration.dart';
import 'package:dnd_character_tool/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({
  String cls = 'Fighter',
  String? subclass,
  int level = 1,
  AbilityScores scores = const AbilityScores(),
  List<EquipmentItem> equipment = const [],
  List<CharacterFeatureChoice> featureChoices = const [],
  SpellSlots spellSlots = const SpellSlots(),
  int armorClass = 10,
}) {
  final now = DateTime(2024);
  return Character(
    id: 'character-id',
    dataVersion: 5,
    name: 'Test Hero',
    race: 'Human',
    characterClass: cls,
    subclass: subclass,
    level: level,
    abilityScores: scores,
    hitPoints: const HitPoints(maximum: 10, current: 10),
    equipment: equipment,
    featureChoices: featureChoices,
    spellSlots: spellSlots,
    armorClass: armorClass,
    createdAt: now,
    updatedAt: now,
  );
}

EquipmentItem _chainMail() {
  return EquipmentItem(
    name: 'Chain Mail',
    category: 'armor',
    itemType: ItemType.armor,
    isEquipped: true,
    properties: const {'baseAC': 16, 'addDexModifier': false},
  );
}

void main() {
  const context = CharacterMigrationContext(itemsByName: {});

  group('SyncSpellSlotsAndArmorClassMigration', () {
    test('syncs caster spell slots for old characters', () {
      final result = const SyncSpellSlotsAndArmorClassMigration().migrate(
        _character(
          cls: 'Wizard',
          scores: const AbilityScores(intelligence: 16),
        ),
        context,
      );

      expect(result.character.spellSlots.total, [2, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(result.changes.single.code, 'spell_slots_synced');
    });

    test('recalculates armor class with Defense Fighting Style', () {
      final result = const SyncSpellSlotsAndArmorClassMigration().migrate(
        _character(
          equipment: [_chainMail()],
          featureChoices: const [
            CharacterFeatureChoice(
              sourceType: 'classFeature',
              sourceClass: 'Fighter',
              featureName: 'Fighting Style',
              choiceId: 'fighting_style',
              values: ['defense'],
            ),
          ],
          armorClass: 16,
        ),
        context,
      );

      expect(result.character.armorClass, 17);
      expect(result.changes.single.code, 'armor_class_recalculated');
    });
  });
}
