# D&D content coverage by edition and language

Updated: 2026-11-28.

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
- [x] Regression tests and catalog validation: 672 Flutter tests passed;
  analysis of the changed Dart files reported no issues; both SRD pack
  validators passed their 18 base JSON integrity checks.

### Languages

The following status refers to the additions above and the 30 recently added
PHB spells. Existing translations of older content are retained.

| Language | Code | Status |
| --- | --- | --- |
| English | en | Listed additions implemented and validated; limitations below |
| German | de | Listed additions translated and validated |
| Spanish | es | Listed additions translated and validated |
| French | fr | Listed additions translated and validated |
| Italian | it | Listed additions translated and validated |
| Japanese | ja | Listed additions translated and validated |
| Korean | ko | Listed additions translated and validated |
| Portuguese | pt | Listed additions translated and validated |
| Russian | ru | Listed additions translated and validated |
| Turkish | tr | Listed additions translated and validated |
| Chinese | zh | Listed additions translated and validated |

### Outside this completion scope

The pre-release review's Tome choice and four Chain familiar catalog gaps
have been addressed above. The edition picker now labels 2024 as Beta and
discloses incomplete content before selection. The 3.0.2 announcement explains
2014 additions, the 2024 beta and remaining manual effects in all 11 UI languages.
A signed Android App Bundle for 3.0.2+37 has been built, and its JAR signature
has been verified against the new upload certificate. A smoke test on a
physical device remains unverified here.

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

All ten translation languages (Portuguese, Spanish, French, Italian, German,
Japanese, Korean, Russian, Turkish and Chinese) cover all 30 spell summaries,
65 choice options, expanded subclass descriptions and the 50-row Wild Magic
table, all 24 added creature stat blocks, 34 equipment entries, five background
variants and personality suggestions. The interface reads these localized
suggestions and indexes variant equipment in the selected language.

The listed additions are now covered in all 11 app languages, including the
English source. No language remains pending for this supplemental 2014 scope.
Shared interface labels are also present in all app languages. English remains
the source and fallback. This does not certify the accuracy of every older
translation or change the implementation limitations listed above.

Translation validation checks the 30 spells, all 65 option descriptions,
the 50 Wild Magic rows, background suggestions, equipment and creature
trait/action text through the runtime i18n service. Distance markers are
compared with the English source, including composed supplemental tables.
A changed translated surge distance is rejected. Both pack validators and
analysis of the changed Dart files pass.

An editorial spot review corrected awkward Portuguese/Spanish narrative
prompts and restored Unicode accents in the shared interface labels. The
translation checks are technical safeguards; terminology has not been
certified against every officially localized book or by a native editor.

Runtime translation tests cover all ten completed translation languages,
including all 50 Wild Magic outcomes, Elemental Attunement, the full discipline
list, the five background variants and their inherited personality suggestions.
They check the surge ranges, distance values and damage dice. This is not a
review of every older translation or an expansion of the 2024 scope.

German additions use informal player instructions, and Japanese additions
use the existing plain style. Damage-dice checks accept notation adjacent
to Japanese characters without requiring unnatural spaces in the text.
Korean additions handle particles after spell names; Russian additions retain
the grammatical endings needed by localized measurement markers. Turkish
additions use informal player instructions and retain Turkish dotted/dotless
letters; Chinese additions use simplified characters. All preserve the 2014
damage dice, distances and condition durations.

Reference sources:

- [Official SRD 5.1](https://media.wizards.com/2023/downloads/dnd/SRD_CC_v5.1.pdf)
- [PHB 2014 spell checklist](https://media.wizards.com/2015/downloads/dnd/DnD_SpellLists_1.01.pdf)
- [Four Elements discipline reference](https://dnd5e.wikidot.com/monk:four-elements:disciplines)
- [Wild Magic reference](https://dnd5e.wikidot.com/sorcerer:wild-magic)

## D&D 2024

Scope: Player's Handbook 2024 character options. Monster Manual 2025 and
Dungeon Master's Guide 2024 material comes later with the GM area.

### Current catalog (2026-11-28)

- SRD 5.2.1: 12 classes, 12 subclasses, 9 species, 4 backgrounds, 17 feats
  (4 origin, 2 general, 4 fighting style, 7 epic boons), 339 spells,
  270 magic items, 88 creatures (mostly Wild Shape beasts).
- `assets/data/2024/phb_subclasses.json`: the other 36 PHB subclasses and
  13 spells they need, as original English summaries. No translations yet.
- `assets/data/2024/phb_origins.json`: the other 12 PHB backgrounds, 6 Origin
  feats and the Aasimar, as original English summaries with P1 translations
  in all 10 translation languages. The pack validator checks it merged with
  the SRD catalogs.
- `assets/data/2024/phb_feats.json`: the other 6 Fighting Style feats, added
  to the three class style lists, as original English summaries with P2
  translations in all 10 translation languages. Later general feats and
  Epic Boons go here too.
- `assets/data/2024/phb_spells.json`: the other 39 PHB spells, as original
  English summaries with attack and damage rolls where a single formula
  applies. With the SRD and subclass spells, the 2024 catalog has 391 spells.
  Translated in all 11 app languages.

### Prioritized gaps

Order follows how early a player meets the gap: creation first, then low
levels, then high levels. Entries outside the SRD are written as original
English summaries, like the existing supplemental catalogs.

**P1 - Origin (every new character)** - implemented and translated

Backgrounds depend on their origin feats, so both ship together.

- [x] 6 origin feats: Crafter, Healer, Lucky, Musician, Tavern Brawler, Tough.
  Tough adds 2 HP per level, retroactively when taken at a feat level and
  through level resets; Lucky tracks Luck Points; Crafter and Musician ask for
  three tools. Healer, Tavern Brawler, the Crafter discount and Musician's
  Heroic Inspiration for allies are descriptive.
- [x] 12 backgrounds: Artisan, Charlatan, Entertainer, Farmer, Guard, Guide,
  Hermit, Merchant, Noble, Sailor, Scribe, Wayfarer, with their equipment
  packages (option A is worth 50 GP, like option B). The 2014 conversion maps Guild
  Artisan to Artisan and Guild Merchant to Merchant.
- [x] Species: Aasimar, with the Light cantrip, Healing Hands and Celestial
  Revelation uses. Resistances and the transformation are descriptive.
- [x] P1 translations in all 10 translation languages: names of the 12
  backgrounds; names and descriptions of the 6 Origin feats and 4 new Aasimar
  traits; Aasimar's name, 18 tool/instrument choices, 3 tracked resource names
  and missing generic equipment labels. Runtime tests check every language,
  distance markers, damage dice and the localized inventory names. Existing
  tool, skill and Light cantrip translations are reused. This is not a native
  editorial audit or completion of the other 2024 priorities.

**P2 - Fighting Style feats (Fighter, Paladin, Ranger at levels 1-2)** - implemented and translated

- [x] Blind Fighting, Dueling, Interception, Protection, Thrown Weapon
  Fighting, Unarmed Fighting: in the Fighter, Paladin and Ranger Fighting
  Style lists, the Champion's Additional Fighting Style and as level feats.
  A style the sheet already has, from a Fighting Style feature or a feat, is
  not offered again (also for the 2014 Champion). Weapon rolls apply Archery
  (+2 attack with Ranged weapons), Dueling (+2 one-handed Melee damage while
  no other Melee weapon is equipped) and Thrown Weapon Fighting (+2 damage,
  with a thrown option for Melee Thrown weapons) in both editions where the
  style exists; Defense changes AC. The other styles are descriptive.
- [x] P2 translations in all 10 translation languages: full names and
  descriptions of the 6 feats and summaries in the Fighter, Paladin and
  Ranger choice lists, also used by the Champion. Dueling and Thrown Weapon
  Fighting share their names with the existing weapon-roll notes. Runtime
  tests check every language, all 18 list entries, distances, dice and +2
  damage bonuses. Protection retains its 2024 duration and proximity
  condition; Unarmed Fighting retains its damage dice and start-of-turn effect.

**P3 - Spells** - done in English

Checked against a public 2024 spell index (each page's source line read as
"Player's Handbook"): every SRD and subclass spell already in the app is on
it at the same level, and these 39 were missing. Branding Smite (replaced by
Shining Smite), Whirlwind (not a PHB spell) and Shadow Blade are not in the
2024 book; Feeblemind is Befuddlement.

- [x] Cantrips: Blade Ward, Friends, Thorn Whip, Thunderclap, Toll the Dead,
  Word of Radiance.
- [x] Paladin: Compelled Duel, Thunderous Smite, Wrathful Smite, Blinding
  Smite, Aura of Vitality, Aura of Purity, Staggering Smite, Banishing Smite,
  Circle of Power, Destructive Wave.
- [x] Ranger: Hail of Thorns, Cordon of Arrows, Conjure Barrage, Lightning
  Arrow, Elemental Weapon, Grasping Vine, Conjure Volley, Swift Quiver.
- [x] Others: Armor of Agathys, Witch Bolt, Arcane Vigor, Cloud of Daggers,
  Crown of Madness, Feign Death, Summon Undead, Summon Elemental, Jallarzi's
  Storm of Radiance, Synaptic Static, Arcane Gate, Summon Fiend, Tasha's
  Bubbling Cauldron, Power Word Fortify, Telepathy.
- [x] Rolls: attack and damage with slot or cantrip scaling for the damage
  spells, except Toll the Dead (two damage dice by target state), Witch Bolt's
  later 1d12 and Lightning Arrow's 2d8 burst, which stay in the description.
- [x] Translations of P3 in the 10 translation languages: name,
  description, higher-level text, material, casting time, range, duration and
  roll labels. The 28 spells that also exist in 2014 keep their 2014 names in
  each language. Dice and measures match the English source (pack validator
  and `supplemental_2024_spells_i18n_test.dart`), and no new name repeats
  another spell's name in the same language.

**P4 - General feats (level 4 and later)**

About 41 missing (verify against the PHB 2024 list): Actor, Athlete, Charger,
Chef, Crossbow Expert, Crusher, Defensive Duelist, Dual Wielder, Durable,
Elemental Adept, Fey Touched, Great Weapon Master, Heavily Armored, Heavy
Armor Master, Inspiring Leader, Keen Mind, Lightly Armored, Mage Slayer,
Martial Weapon Training, Medium Armor Master, Moderately Armored, Mounted
Combatant, Observant, Piercer, Poisoner, Polearm Master, Resilient, Ritual
Caster, Sentinel, Shadow Touched, Sharpshooter, Shield Master, Skill Expert,
Skulker, Slasher, Speedy, Spell Sniper, Telekinetic, Telepathic, War Caster,
Weapon Master.

- [ ] Armor, weapon and ability feats that change calculated values first
  (Heavily/Moderately/Lightly Armored, Resilient, Durable, Martial Weapon
  Training, Skill Expert), then the rest.

**P5 - Epic Boons (level 19)**

- [ ] Energy Resistance, Fortitude, Recovery, Skill, Speed.

**P6 - Translations**

- [ ] The 36 non-SRD subclasses and their 13 spells in the 10 translation
  languages.
- [ ] Each P1-P5 batch translated before or with its release.
- [ ] Audit of the existing SRD 5.2.1 overlays.

**P7 - Leave Beta**

- [ ] Remove the 2024 Beta label once P1-P6 are done.

### Languages

| Language | Code | Status |
| --- | --- | --- |
| English | en | P1/P2 implemented; remaining checklist pending |
| German | de | P1/P2 translated and validated; remaining 2024 content pending |
| Spanish | es | P1/P2 translated and validated; remaining 2024 content pending |
| French | fr | P1/P2 translated and validated; remaining 2024 content pending |
| Italian | it | P1/P2 translated and validated; remaining 2024 content pending |
| Japanese | ja | P1/P2 translated and validated; remaining 2024 content pending |
| Korean | ko | P1/P2 translated and validated; remaining 2024 content pending |
| Portuguese | pt | P1/P2 translated and validated; remaining 2024 content pending |
| Russian | ru | P1/P2 translated and validated; remaining 2024 content pending |
| Turkish | tr | P1/P2 translated and validated; remaining 2024 content pending |
| Chinese | zh | P1/P2 translated and validated; remaining 2024 content pending |
