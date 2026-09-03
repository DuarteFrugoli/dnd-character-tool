import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
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
}
