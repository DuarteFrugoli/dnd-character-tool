import 'package:dnd_character_tool/data/datasources/srd/srd_data_source.dart';
import 'package:dnd_character_tool/data/rulesets/srd_content_pack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final srd521 = SrdDataSource.forPack(SrdContentPackRegistry.srd521);
  final srd51 = SrdDataSource.forPack(SrdContentPackRegistry.srd51);

  test('2024 Origin feats join the SRD feats only in the 2024 pack', () async {
    final feats2024 = {for (final feat in await srd521.getFeats()) feat.name: feat};
    for (final name in ['Crafter', 'Healer', 'Lucky', 'Musician', 'Tavern Brawler', 'Tough']) {
      expect(feats2024[name]?.category, 'origin', reason: name);
      expect(feats2024[name]!.description, isNotEmpty);
    }
    final feats2014 = (await srd51.getFeats()).map((feat) => feat.name);
    expect(feats2014, isNot(contains('Crafter')));
  });

  test('Aasimar traits have text and limited uses', () async {
    final traits = await srd521.getRaceTraits();
    for (final name in [
      'Celestial Resistance', 'Healing Hands', 'Light Bearer', 'Celestial Revelation',
    ]) {
      expect(traits[name], isNotEmpty, reason: name);
    }
    final usages = await srd521.getFeatureUsageCatalog();
    expect(usages.raceTraits['Healing Hands']?.resourceId, '2024_healing_hands');
    final revelation = usages.raceTraits['Celestial Revelation']!;
    expect(revelation.minCharacterLevel, 3);
    expect(usages.resource(revelation.resourceId)?.name, 'Celestial Revelation');
  });

  test('Lucky has Luck Points and Crafter and Musician ask for tools', () async {
    final usages = await srd521.getFeatureUsageCatalog();
    final lucky = usages.feats['Lucky']!;
    expect(usages.resource(lucky.resourceId)?.name, 'Luck Points');

    final choices = await srd521.getFeatureChoiceCatalog();
    final tools = {for (final tool in await srd521.getTools()) tool.name: tool.category};
    for (final (source, category) in [
      ('crafter_tools_2024', 'artisans_tools'),
      ('musical_instruments_2024', 'musical_instruments'),
    ]) {
      final options = choices.optionSources[source]!;
      expect(options, isNotEmpty);
      for (final option in options) {
        expect(tools[option.name], category, reason: option.name);
      }
    }
  });
}
