import 'dart:convert';

import 'package:flutter/services.dart';

/// Original English summaries of 2014 PHB spells outside the SRD.
class Supplemental2014Catalog {
  const Supplemental2014Catalog._();

  static const assetPath = 'assets/data/2014/phb_spells.json';
  static const optionsPath = 'assets/data/2014/phb_options.json';

  static Future<Map<String, dynamic>> options() async =>
      jsonDecode(await rootBundle.loadString(optionsPath))
          as Map<String, dynamic>;

  static Future<void> completeSubclassFeatures(List<dynamic> entries) async {
    final extra = await options();
    final sources =
        (extra['featureChoices'] as Map<String, dynamic>)['optionSources']
            as Map<String, dynamic>;
    String choicesText(String source) => (sources[source] as List)
        .map((option) => '${option['name']}: ${option['description']}')
        .join('\n\n');
    for (final entry in entries.cast<Map<String, dynamic>>()) {
      final features = (entry['features'] as List).cast<Map<String, dynamic>>();
      if (entry['subclass'] == 'Circle of the Land') {
        features.add({
          'name': 'Circle Spells',
          'level': 3,
          'type': 'passive',
          'description':
              'Choose Arctic, Coast, Desert, Forest, Grassland, Mountain, Swamp, or Underdark. Gain the terrain spells at druid levels 3, 5, 7 and 9. They are always prepared and do not count against your preparation limit, even when absent from the druid list.',
        });
      } else if (entry['subclass'] == 'Way of the Four Elements') {
        for (final feature in features) {
          if (feature['level'] == 3) {
            feature['description'] =
                '${extra['elementalAttunement']}\n\n'
                'Choose one other discipline at level 3, and one more at levels 6, 11 and 17. '
                'When learning a discipline you may replace one already known. '
                'Discipline spells need no material components; other spell rules still apply. '
                'At monk level 5, spend extra ki to upcast spells that support upcasting. '
                'Maximum total ki per spell: levels 5-8: 3; 9-12: 4; 13-16: 5; 17-20: 6.\n\n'
                '${choicesText('elemental_disciplines_2014')}';
          } else {
            feature['description'] =
                'Learn one additional elemental discipline for which you meet the monk-level requirement. You may also replace one known discipline. Elemental Attunement remains known unless replaced using this rule.';
          }
        }
      } else if (entry['subclass'] == 'Wild Magic') {
        for (final feature in features) {
          if (feature['name'] == 'Wild Magic Surge') {
            final surge = extra['wildMagicSurge'] as Map<String, dynamic>;
            final rows = (surge['outcomes'] as List).map(
              (row) =>
                  '${row['min'].toString().padLeft(2, '0')}-${row['max'] == 100 ? '00' : row['max'].toString().padLeft(2, '0')}: ${row['description']}',
            );
            feature['description'] =
                '${surge['description']}\n\n${rows.join('\n')}';
          } else if (feature['name'] == 'Tides of Chaos') {
            feature['description'] =
                '${feature['description']} After that DM-triggered surge, you regain this feature without waiting for a long rest.';
          }
        }
      } else if (entry['subclass'] == 'Path of the Totem Warrior') {
        const choices = {
          'Totem Spirit': 'totem_spirits_2014',
          'Aspect of the Beast': 'totem_aspects_2014',
          'Totemic Attunement': 'totem_attunements_2014',
        };
        for (final feature in features) {
          final source = choices[feature['name']];
          if (source != null) {
            feature['description'] =
                'Choose one animal independently at this level; it need not match earlier choices.\n\n${choicesText(source)}';
          }
        }
      }
      entry['features'] = features;
    }
  }

  static void merge(Map<String, dynamic> target, Map<String, dynamic> extra) {
    for (final entry in extra.entries) {
      final old = target[entry.key];
      if (old is Map<String, dynamic> && entry.value is Map<String, dynamic>) {
        merge(old, entry.value as Map<String, dynamic>);
      } else if (old == null) {
        target[entry.key] = entry.value;
      } else {
        throw StateError(
          '2014 supplemental catalog conflicts with ${entry.key}.',
        );
      }
    }
  }

  static Future<List<Map<String, dynamic>>> spells() async {
    final catalog =
        jsonDecode(await rootBundle.loadString(assetPath))
            as Map<String, dynamic>;
    return (catalog['spells'] as List).cast<Map<String, dynamic>>();
  }
}
