import 'package:dnd_character_tool/data/rulesets/ruleset_ids.dart';
import 'package:dnd_character_tool/data/datasources/srd/srd_i18n_service.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:dnd_character_tool/shared/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog providers keep spells in their own edition', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final oldSpells = await container.read(
      srdSpellsForPackProvider(ContentPackId.srd51).future,
    );
    final newSpells = await container.read(
      srdSpellsForPackProvider(ContentPackId.srd521).future,
    );
    final oldSpiritGuardians = oldSpells.singleWhere(
      (spell) => spell.name == 'Spirit Guardians',
    );
    final newSpiritGuardians = newSpells.singleWhere(
      (spell) => spell.name == 'Spirit Guardians',
    );

    expect(oldSpiritGuardians.description, isNot(newSpiritGuardians.description));
    expect(
      newSpells.where((spell) => spell.name == "Nystul's Magic Aura"),
      isEmpty,
    );
    expect(
      oldSpells.where((spell) => spell.name == "Nystul's Magic Aura"),
      isNotEmpty,
    );
    expect(
      await container.read(srdSpellsForPackProvider(ContentPackId.srd51).future),
      same(oldSpells),
    );
  });

  test('2024 origin data cannot enter the 2014 parsers', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final source = container.read(srdDataSourceForPackProvider(ContentPackId.srd521));
    await expectLater(source.getRaces(), throwsUnsupportedError);
    await expectLater(source.getClasses(), throwsUnsupportedError);
    await expectLater(source.getBackgrounds(), throwsUnsupportedError);
  });

  test('English translation fallback remains in the selected pack', () {
    expect(
      SrdI18nService.englishForPack(SrdContentPackRegistry.srd51).pack.id,
      ContentPackId.srd51,
    );
    expect(
      SrdI18nService.englishForPack(SrdContentPackRegistry.srd521).pack.id,
      ContentPackId.srd521,
    );
  });
}
