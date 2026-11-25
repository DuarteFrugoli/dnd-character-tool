# D&D content coverage by edition and language

Updated: 2026-11-25.

This tracks the gaps identified in the bundled catalogs, not every published
D&D supplement. English is the source catalog. Translations are separate work:
an English fallback in the app does not mean a language is complete.

## D&D 2014

Scope: Player's Handbook 2014 character options and the supporting creatures
and equipment needed for those options. This does not certify every rule,
Dungeon Master's Guide item, Monster Manual entry, or later supplement.

### Existing option coverage

- 12 PHB classes and 40 PHB subclasses registered.
- 9 PHB races, their subraces, and Variant Human registered.
- 42 PHB feats and 13 base backgrounds registered.
- All 361 PHB spells represented (362 total, including Whirlwind).
- 37 weapons, 12 armors and a shield, and 39 tool/vehicle proficiency entries.

### English implementation checklist

- [x] PHB Eldritch Invocations: 32 descriptions, prerequisites, level choices
  and at most one replacement per level. Agonizing Blast applies to its 2014
  Eldritch Blast damage roll.
- [x] Pact of the Tome: three guided cantrip choices from any class list,
  with Warlock provenance and removal when the pact or its choices are undone.
  Uses the dependent-choice mechanism already present in 2024, with 2014 rules.
- [x] Pact of the Chain: Imp, Pseudodragon, Quasit and Sprite stat blocks,
  including the Imp's nonmagical, non-silvered attack resistance condition.
  These are catalog entries; familiar summoning/control is not automated.
- [x] Circle of the Land: bonus cantrip, eight terrain choices and all circle
  spell tables; grants follow druid levels and are refreshed on terrain edits.
- [x] Way of the Four Elements: 16 selectable disciplines plus the initially
  known Elemental Attunement, ki costs, level restrictions and corrected text.
- [x] Wild Magic: 50 outcome summaries covering every d100 result, visible in
  the feature description; includes the Tides of Chaos recharge explanation.
- [x] Totem Warrior: independent animal choices at levels 3, 6, and 14.
- [x] Circle of the Moon: 16 additional beasts and four elementals; 90 beasts
  through CR 6 plus four elementals in total. Moon limits, two-use elemental
  transformations, and nonmagical-only physical resistance are represented.
- [x] Five selectable background variants, including Retainers and Bad
  Reputation; Guild Merchant uses a supported navigator-tool equipment option.
- [x] Background personality suggestions: eight traits, six ideals, six bonds
  and six flaws per base background, inherited by variants. These are
  **original English roleplaying prompts**, not the published PHB tables.
- [x] Five arcane focuses and 29 mount/tack/transport entries in the inventory.
- [x] Regression tests and catalog validation: 594 Flutter tests passed;
  analysis of the changed Dart files reported no issues; both SRD pack
  validators passed their 18 base JSON integrity checks.

### Languages

The following status refers to the additions above and the 30 recently added
PHB spells. Existing translations of older content are retained.

| Language | Code | Status |
| --- | --- | --- |
| English | en | Listed additions implemented and validated; limitations below |
| German | de | Pending translation and review |
| Spanish | es | Listed additions translated and validated |
| French | fr | Pending translation and review |
| Italian | it | Pending translation and review |
| Japanese | ja | Pending translation and review |
| Korean | ko | Pending translation and review |
| Portuguese | pt | Listed additions translated and validated |
| Russian | ru | Pending translation and review |
| Turkish | tr | Pending translation and review |
| Chinese | zh | Pending translation and review |

### Outside this completion scope

The pre-release review's Tome choice and four Chain familiar catalog gaps
have been addressed above. The edition picker now labels 2024 as Beta and
discloses incomplete content before selection. The 3.0.2 announcement explains
2014 additions, the 2024 beta and remaining manual effects in all 11 UI languages.
A signed release build and smoke test on a physical device remain unverified.

- Later 2014-compatible books, including Artificer and additional subclasses,
  races, feats, backgrounds, spells, and optional class features.
- Full Monster Manual and Dungeon Master's Guide catalogs, including missing
  artifacts. Current magic item catalog has 262 entries.
- Automated application of every combat feature; some options remain usable
  through descriptions, saved choices, and resource tracking.
- A line-by-line accuracy and translation audit of all pre-existing text.
- Verbatim PHB personality tables: the app supplies original suggestions.
- Automatic application of surge effects, discipline casting/ki spending,
  every invocation's spell limits and combat effects.
- Full replacement management for the initially known Elemental Attunement;
  its text is available, while the choice editor manages the other disciplines.
- Alternative Guild Merchant tool/language/equipment combinations and an
  unrestricted Gladiator weapon picker; use a custom background or edit gear
  for those allowed variants. The supplied variants use valid fixed options.

### Files and translation work

English supplemental catalogs:

- `assets/data/2014/phb_spells.json`: 30 spell summaries.
- `assets/data/2014/phb_options.json`: invocations, disciplines, terrains,
  totems and Wild Magic outcomes.
- `assets/data/2014/phb_backgrounds.json`: variants and personality prompts.
- `assets/data/srd/5.1/monsters.json`: 24 added SRD creature stat blocks
  (16 beasts, four elementals and four special familiars).
- `assets/data/2014/phb_equipment.json`: 34 added equipment entries, merged
  into the gear browser and inventory index only for 2014.

Portuguese and Spanish cover all 30 spell summaries, 65 choice options,
the expanded subclass descriptions and 50-row Wild Magic table, all 24 added
creature stat blocks, 34 equipment entries, five background variants and the
personality suggestions. The interface reads these localized suggestions
and indexes variant equipment in the selected language.

Each of the eight pending content languages still needs names, descriptions,
new choice options, creature traits/actions, background prompts and expanded
feature tables. Their older feature summaries may still appear until revised.
Shared interface labels are present in all app languages. English remains
the source and fallback. This does not certify the accuracy of every older
translation or change the implementation limitations listed above.

Translation validation checks the 30 spells, all 65 option descriptions,
the 50 Wild Magic rows, background suggestions, equipment and creature
trait/action text through the runtime i18n service. Distance markers are
compared with the English source, including composed supplemental tables;
the validator continues to accept the older base summaries in languages
whose full tables are still pending. A changed translated surge distance
is rejected. Both pack validators and analysis of the changed Dart files pass.

An editorial spot review corrected awkward Portuguese/Spanish narrative
prompts and restored Unicode accents in the shared interface labels. The
translation checks are technical safeguards; terminology has not been
certified against every officially localized book or by a native editor.

Reference sources:

- [Official SRD 5.1](https://media.wizards.com/2023/downloads/dnd/SRD_CC_v5.1.pdf)
- [PHB 2014 spell checklist](https://media.wizards.com/2015/downloads/dnd/DnD_SpellLists_1.01.pdf)
- [Four Elements discipline reference](https://dnd5e.wikidot.com/monk:four-elements:disciplines)
- [Wild Magic reference](https://dnd5e.wikidot.com/sorcerer:wild-magic)

## D&D 2024

Placeholder only. Detailed content and language audit to be filled in later.

| Language | Code | Status |
| --- | --- | --- |
| English | en | Placeholder — not audited here |
| German | de | Placeholder |
| Spanish | es | Placeholder |
| French | fr | Placeholder |
| Italian | it | Placeholder |
| Japanese | ja | Placeholder |
| Korean | ko | Placeholder |
| Portuguese | pt | Placeholder |
| Russian | ru | Placeholder |
| Turkish | tr | Placeholder |
| Chinese | zh | Placeholder |
