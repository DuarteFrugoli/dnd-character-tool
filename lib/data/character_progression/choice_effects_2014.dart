import '../datasources/srd/srd_data_source.dart';
import '../datasources/srd/srd_models.dart';
import '../feature_choice_option_resolver.dart';
import 'choice_effects.dart';

/// SRD 5.1 lookups for choice effects, following 2014 creation: skills,
/// tools, languages and weapons are saved by their catalog names.
class ChoiceEffects2014Data implements ChoiceEffectsData {
  ChoiceEffects2014Data({
    required this.choices,
    required this.spells,
    required List<SrdSkill> skills,
    required List<SrdTool> tools,
    required List<SrdLanguage> languages,
    required List<SrdWeapon> weapons,
    required List<SrdFeat> feats,
    required List<SrdBackground> backgrounds,
  }) : _skills = _byId(skills.map((s) => s.name)),
       _tools = {
         ..._byId(tools.map((t) => t.name)),
         'thieves_tools': "Thieves' tools",
       },
       _languages = _byId(languages.map((l) => l.name)),
       _weapons = _byId(weapons.map((w) => w.name)),
       _feats = {for (final feat in feats) feat.name: feat},
       _backgroundSkills = {
         for (final background in backgrounds)
           background.name: background.skillProficiencies,
       };

  static Future<ChoiceEffects2014Data> load(SrdDataSource srd) async =>
      ChoiceEffects2014Data(
        choices: await srd.getFeatureChoiceCatalog(),
        spells: await srd.getSpells(),
        skills: await srd.getSkills(),
        tools: await srd.getTools(),
        languages: await srd.getLanguages(),
        weapons: await srd.getWeapons(),
        feats: await srd.getFeats(),
        backgrounds: await srd.getBackgrounds(),
      );

  @override
  final SrdFeatureChoiceCatalog choices;
  @override
  final List<SrdSpell> spells;
  final Map<String, String> _skills;
  final Map<String, String> _tools;
  final Map<String, String> _languages;
  final Map<String, String> _weapons;
  final Map<String, SrdFeat> _feats;
  final Map<String, List<String>> _backgroundSkills;

  static Map<String, String> _byId(Iterable<String> names) => {
    for (final name in names) FeatureChoiceOptionResolver.idFromName(name): name,
  };

  @override
  SrdFeat? featNamed(String name) => _feats[name];

  @override
  Iterable<String> backgroundSkills(String background) =>
      _backgroundSkills[background] ?? const [];

  @override
  String skillName(String id) => _skills[id] ?? id;

  @override
  String toolName(String id) => _tools[id] ?? id;

  @override
  String languageName(String id) => _languages[id] ?? id;

  @override
  String weaponName(String id) => _weapons[id] ?? id;

  @override
  bool get weaponChoicesGrantProficiency => true;
}
