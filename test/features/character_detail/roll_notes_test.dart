import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/data/rulesets/weapon_mastery_rules.dart';
import 'package:dnd_character_tool/features/character_detail/widgets/dice/roll_notes.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mastery notes join the SRD description and the computed value', () async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final i18n = SrdI18nService.englishForPack(SrdContentPackRegistry.srd521);
    final descriptions =
        await SrdDataSource.forPack(SrdContentPackRegistry.srd521).getWeaponMasteries();
    final notes = weaponMasteryNotes(
      l10n: l10n,
      i18n: i18n,
      effect: const WeaponMasteryEffect(
        mastery: 'topple',
        toppleDc: 13,
        alternatives: ['push', 'sap', 'slow'],
      ),
      descriptions: descriptions,
      damageType: 'bludgeoning',
    );
    expect(notes.first.title, 'Mastery: Topple');
    expect(notes.first.text, startsWith(descriptions['topple']!));
    expect(notes.first.text, endsWith('Save DC 13.'));
    expect(notes.last.title, 'Tactical Master');
    expect(notes.last.text, contains('Push, Sap, Slow'));
  });

  test('spell notes explain Agonizing Blast and the beams', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final i18n = SrdI18nService.englishForPack(SrdContentPackRegistry.srd521);
    final notes = spellRollNotes(l10n: l10n, i18n: i18n, damageBonus: 3, beams: 2);
    expect(notes.map((note) => note.title), ['Agonizing Blast', 'Beams']);
    expect(notes.first.text, contains('+3'));
    expect(spellRollNotes(l10n: l10n, i18n: i18n, damageBonus: 0, beams: 1), isEmpty);
  });
}
