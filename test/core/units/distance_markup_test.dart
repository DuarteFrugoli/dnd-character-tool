import 'dart:convert';
import 'dart:io';

import 'package:dnd_character_tool/core/units/distance_markup.dart';
import 'package:dnd_character_tool/core/units/unit_system_provider.dart';
import 'package:flutter_test/flutter_test.dart';

String _render(String text, String language, UnitSystem system) =>
    DistanceMarkup.render(text, languageCode: language, system: system);

void main() {
  test('renders the example in each unit system', () {
    const en = '...within {{distance:5ft}} of the creature.';
    const pt = '...a até {{distance:5ft}} da criatura.';
    expect(_render(en, 'en', UnitSystem.imperial), '...within 5 feet of the creature.');
    expect(_render(en, 'en', UnitSystem.metric), '...within 1.5 meters of the creature.');
    expect(_render(en, 'en', UnitSystem.squares), '...within 1 square of the creature.');
    expect(_render(pt, 'pt', UnitSystem.metric), '...a até 1,5 metro da criatura.');
    expect(_render(pt, 'pt', UnitSystem.imperial), '...a até 5 pés da criatura.');
    expect(_render(pt, 'pt', UnitSystem.squares), '...a até 1 quadrado da criatura.');
  });

  test('converts like the official translations', () {
    expect(_render('{{distance:30ft}}', 'fr', UnitSystem.metric), '9 mètres');
    expect(_render('{{distance:1ft}}', 'pt', UnitSystem.metric), '30 centímetros');
    expect(_render('{{distance:6in}}', 'pt', UnitSystem.metric), '15 centímetros');
    expect(_render('{{distance:1mi}}', 'es', UnitSystem.metric), '1,5 kilómetros');
    expect(_render('{{distance:1000ft}}', 'en', UnitSystem.imperial), '1,000 feet');
    expect(_render('{{distance:20/60ft|short}}', 'en', UnitSystem.metric), '6/18 m');
    expect(_render('{{distance:10+ft}}', 'en', UnitSystem.imperial), '10+ feet');
    expect(_render('{{distance:30ft|num}} to', 'en', UnitSystem.metric), '9 to');
    expect(_render('{{distance:0ft|short}}', 'en', UnitSystem.metric), '0 m');
    expect(_render('a {{distance:0.5in|adj}} bar', 'en', UnitSystem.imperial), 'a 1/2-inch bar');
    expect(_render('{{distance:0.5in}}', 'en', UnitSystem.metric), '1.3 centimeters');
    expect(_render('{{distance:0.5mi}}', 'ru', UnitSystem.imperial), '1/2 мили');
  });

  test('uses the official system when a distance is not whole squares', () {
    expect(_render('{{distance:1mi}}', 'en', UnitSystem.squares), '1 mile');
    expect(_render('{{distance:1mi}}', 'pt', UnitSystem.squares), '1,5 quilômetro');
    expect(_render('{{distance:12ft}}', 'de', UnitSystem.squares), '3,6 Meter');
  });

  test('follows plural rules', () {
    expect(_render('{{distance:1ft}}', 'en', UnitSystem.imperial), '1 foot');
    expect(_render('{{distance:5ft}}', 'fr', UnitSystem.metric), '1,5 mètre');
    expect(_render('{{distance:5ft}}', 'it', UnitSystem.metric), '1,5 metri');
    expect(_render('{{distance:5ft}}', 'ru', UnitSystem.imperial), '5 футов');
    expect(_render('{{distance:5ft}}', 'ru', UnitSystem.metric), '1,5 метра');
    expect(_render('{{distance:10ft}}', 'ru', UnitSystem.squares), '2 клетки');
  });

  test('renders grammatical forms', () {
    expect(_render('ein {{distance:10ft|adj}}-Würfel', 'de', UnitSystem.metric), 'ein 3-Meter-Würfel');
    expect(_render('von {{distance:30ft|dat}}', 'de', UnitSystem.metric), 'von 9 Metern');
    expect(_render('ein {{distance:30ft|shortadj}}-Kegel', 'de', UnitSystem.metric), 'ein 9-m-Kegel');
    expect(_render('ein {{distance:30ft|shortadj}}-Kegel', 'de', UnitSystem.imperial), 'ein 30-Fuß-Kegel');
    expect(_render('von {{distance:30ft|dat}}', 'de', UnitSystem.imperial), 'von 30 Fuß');
    expect(_render('a {{distance:10ft|adj}} cube', 'en', UnitSystem.metric), 'a 3-meter cube');
    expect(_render('{{distance:10ft|adj}}ый куб', 'ru', UnitSystem.metric), '3-метровый куб');
    expect(_render('в пределах {{distance:1ft|gen}}', 'ru', UnitSystem.imperial), 'в пределах 1 фута');
    expect(_render('{{distance:30ft|dat}} kadar', 'tr', UnitSystem.imperial), '30 fite kadar');
    expect(_render('{{distance:30ft|dat}} kadar', 'tr', UnitSystem.metric), '9 metreye kadar');
    expect(_render('{{distance:5280ft|obj}}', 'ko', UnitSystem.imperial), '5,280피트를');
    expect(_render('{{distance:10ft|obj}}', 'ko', UnitSystem.squares), '2칸을');
    expect(_render('{{distance:30ft}}以内', 'ja', UnitSystem.metric), '9メートル以内');
    expect(_render('{{distance:30ft|short}}', 'zh', UnitSystem.imperial), '30尺');
    expect(_render('{{distance:30ft|dat}}', 'en', UnitSystem.imperial), '30 feet');
  });

  test('every SRD text renders in every language and unit system', () {
    final files = [
      ...Directory('assets/data/srd').listSync(recursive: true),
      ...Directory('assets/data/i18n').listSync(recursive: true),
    ].whereType<File>().where((file) => file.path.endsWith('.json'));
    var markers = 0;
    for (final file in files) {
      final language = file.path.contains('i18n') ? file.uri.pathSegments.reversed.elementAt(2) : 'en';
      void walk(dynamic node) {
        if (node is Map) {
          node.values.forEach(walk);
        } else if (node is List) {
          node.forEach(walk);
        } else if (node is String && DistanceMarkup.hasMarkers(node)) {
          markers += DistanceMarkup.pattern.allMatches(node).length;
          for (final system in UnitSystem.values) {
            final rendered = _render(node, language, system);
            expect(rendered.contains('{{'), isFalse, reason: '${file.path}: $node');
          }
        }
      }

      walk(jsonDecode(file.readAsStringSync()));
    }
    expect(markers, greaterThan(10000));
  });
}
