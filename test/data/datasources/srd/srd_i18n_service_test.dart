import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── SrdI18nService.english ─────────────────────────────────────────────────
  //
  // The english service is a no-op: every lookup returns the original English
  // string unchanged. This is the fallback used when:
  //   - the device locale is 'en'
  //   - the i18n file for the locale is missing or malformed
  //
  // These tests document (and protect) the expected fallback contract.

  group('SrdI18nService.english – fallback contract', () {
    final svc = SrdI18nService.english;

    test('spellName returns the input unchanged', () {
      expect(svc.spellName('Fire Bolt'), 'Fire Bolt');
      expect(svc.spellName('Cure Wounds'), 'Cure Wounds');
    });

    test('spellName preserves original capitalisation', () {
      // Callers use the English name as stored in the character model.
      // The fallback must not lowercase it.
      expect(svc.spellName('FIREBALL'), 'FIREBALL');
      expect(svc.spellName('fire bolt'), 'fire bolt');
    });

    test('spellDescription returns null (no translation)', () {
      expect(svc.spellDescription('Fire Bolt'), isNull);
    });

    test('spellHigherLevels returns null', () {
      expect(svc.spellHigherLevels('Cure Wounds'), isNull);
    });

    test('spell casting time and duration return the English text', () {
      expect(svc.spellCastingTime('Fire Bolt', 'Action'), 'Action');
      expect(svc.spellDurationOf('Bless', 'Concentration, up to 1 minute'),
          'Concentration, up to 1 minute');
    });

    test('raceName returns input unchanged', () {
      expect(svc.raceName('Human'), 'Human');
      expect(svc.raceName('Elf'), 'Elf');
    });

    test('subraceName returns input unchanged', () {
      expect(svc.subraceName('High Elf'), 'High Elf');
    });

    test('backgroundName returns input unchanged', () {
      expect(svc.backgroundName('Acolyte'), 'Acolyte');
    });

    test('backgroundEquipmentName returns input unchanged', () {
      expect(svc.backgroundEquipmentName('Crowbar'), 'Crowbar');
    });

    test('className returns input unchanged', () {
      expect(svc.className('Wizard'), 'Wizard');
    });

    test('subclassName returns the subclass input unchanged', () {
      expect(svc.subclassName('Fighter', 'Champion'), 'Champion');
    });

    test('subclassDescription returns null', () {
      expect(svc.subclassDescription('Fighter', 'Champion'), isNull);
    });

    test('skillName returns input unchanged', () {
      expect(svc.skillName('Perception'), 'Perception');
    });

    test('raceTraitName returns input unchanged', () {
      expect(svc.raceTraitName('Darkvision'), 'Darkvision');
    });

    test('raceTraitDescription returns null', () {
      expect(svc.raceTraitDescription('Darkvision'), isNull);
    });

    test('toolName returns input unchanged', () {
      expect(svc.toolName("Thieves' Tools"), "Thieves' Tools");
    });

    test('locale is en', () {
      expect(svc.locale, 'en');
    });
  });

  // ── load('en') ────────────────────────────────────────────────────────────
  //
  // Calling load() with locale 'en' must return the no-op english service
  // without attempting to read any bundle files (they don't exist for 'en').

  group('SrdI18nService.load', () {
    test("load('en') returns the english no-op service", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final svc = await SrdI18nService.load('en');
      // Must be the same singleton
      expect(identical(svc, SrdI18nService.english), isTrue);
    });

    test("load('pt') translates known skills and tools", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final svc = await SrdI18nService.load('pt');

      expect(svc.skillName('Acrobatics'), 'Acrobacia');
      expect(svc.toolName("Thieves' tools"), contains('Ferramentas'));
      expect(svc.toolName("Thieves' tools").toLowerCase(), contains('ladr'));
    });

    test("load('pt') translates class equipment aliases", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final svc = await SrdI18nService.load('pt');

      expect(svc.backgroundEquipmentName("Thieves' tools"), contains('ladr'));
      expect(svc.backgroundEquipmentName('Arrows'), isNot('Arrows'));
    });
  });

  group('2024 spell casting time and duration', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    for (final (locale, action, smite, minute) in [
      ('pt', 'Ação', 'Ação Bônus, realizada imediatamente após acertar uma criatura com uma arma à Distância', 'Concentração, até 1 minuto'),
      ('de', 'Aktion', 'Bonusaktion, unmittelbar nachdem du eine Kreatur mit einer Fernkampfwaffe getroffen hast', 'Konzentration, bis zu 1 Minute'),
      ('ja', 'アクション', '遠隔武器でクリーチャーに命中した直後に行うボーナス・アクション', '精神集中、最大1分'),
    ]) {
      test('$locale reads them from the 2024 overlay', () async {
        final i18n = await SrdI18nService.load(
          locale,
          pack: SrdContentPackRegistry.srd521,
        );
        expect(i18n.spellCastingTime('Fire Bolt', 'Action'), action);
        expect(
          i18n.spellCastingTime(
            'Hail of Thorns',
            'Bonus Action, which you take immediately after hitting a creature with a Ranged weapon',
          ),
          smite,
        );
        expect(
          i18n.spellDurationOf('Bless', 'Concentration, up to 1 minute'),
          minute,
        );
        // Spells without an overlay entry fall back to the term translation.
        expect(i18n.spellCastingTime('Unknown Spell', 'Action'), i18n.castingTime('Action'));
      });
    }

    test('2014 sheets keep the Portuguese term translation', () async {
      final i18n = await SrdI18nService.load('pt');
      expect(i18n.spellCastingTime('Fire Bolt', '1 action'), i18n.castingTime('1 action'));
      expect(i18n.castingTime('1 action'), isNot('1 action'));
    });
  });
}

