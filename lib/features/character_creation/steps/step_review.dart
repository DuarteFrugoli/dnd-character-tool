import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../character_draft_provider.dart';

class StepReview extends ConsumerWidget {
  const StepReview({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(characterDraftProvider);
    final attrs = draft.finalAttributes;
    final con = attrs['Constitution'] ?? 10;
    final conMod = ((con - 10) / 2).floor();
    final dex = attrs['Dexterity'] ?? 10;
    final dexMod = ((dex - 10) / 2).floor();
    final hitDie = draft.selectedClass?.hitDie ?? 8;
    final maxHp = hitDie + conMod;
    final allItems = _resolveEquipmentItems(draft);
    final armorInfo = _findArmorAC(allItems, dexMod);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReviewSection(title: 'Identity', children: [
          _Row('Name', draft.name.isEmpty ? 'Unnamed Hero' : draft.name),
          if (draft.playerName.isNotEmpty)
            _Row('Player', draft.playerName),
        ]),
        _ReviewSection(title: 'Class', children: [
          _Row('Class', draft.selectedClass?.name ?? '—'),
          if (draft.selectedSubclass != null)
            _Row(
              draft.selectedClass?.subclassFeatureName ?? 'Subclass',
              draft.selectedSubclass!.name,
            ),
          _Row('Hit Die', 'd${draft.selectedClass?.hitDie ?? '—'}'),
          _Row(
            'Saving Throws',
            draft.selectedClass?.savingThrows.join(', ') ?? '—',
          ),
          if (draft.selectedClass != null)
            const _StartingGoldRow(),
        ]),
        _ReviewSection(title: 'Race', children: [
          _Row('Race', draft.selectedRace?.name ?? '—'),
          if (draft.selectedSubrace != null)
            _Row('Subrace', draft.selectedSubrace!.name),
          _Row('Speed', '${draft.selectedRace?.speed ?? 0} ft'),
          if (draft.fixedRaceLanguages.isNotEmpty)
            _Row('Languages', draft.fixedRaceLanguages.join(', ')),
        ]),
        _ReviewSection(title: 'Background', children: [
          _Row('Background', draft.selectedBackground?.name ?? '—'),
          _Row(
            'Feature',
            draft.selectedBackground?.feature.name ?? '—',
          ),
        ]),
        _ReviewSection(title: 'Skills', children: [
          _Row('From background', draft.grantedSkills.join(', ')),
          if (draft.chosenSkills.isNotEmpty)
            _Row('Class choices', draft.chosenSkills.join(', ')),
        ]),
        _ReviewSection(title: 'Attributes', children: [
          ...attrs.entries
              .map((e) => _Row(e.key, '${e.value} (${_mod(e.value)})')),
          _Row('Max HP', '$maxHp  (d$hitDie + $conMod CON)'),
          _Row('AC (Unarmored)', '${10 + dexMod}'),
          if (armorInfo != null)
            _Row('AC with ${armorInfo.$2}', '${armorInfo.$1}'),
          _Row('Proficiency Bonus', '+2'),
        ]),
        // ── Language Choices ────────────────────────────────────────────────────────
        if (draft.languageChoicesNeeded > 0)
          const _LanguageChoiceSection(),
        // ── Tool Proficiency Choices ─────────────────────────────────────────────────
        const _ToolProficiencySection(),
        // ── Starting Equipment ─────────────────────────────────────────────────────
        if (draft.selectedBackground != null &&
            draft.selectedBackground!.startingEquipment.isNotEmpty)
          const _StartingEquipmentSection(),        // ── Class Equipment ────────────────────────────────────────────────────
        if (draft.selectedClass?.startingEquipment != null)
          const _ClassEquipmentSection(),        const SizedBox(height: 16),
      ],
    );
  }

  String _mod(int score) {
    final m = ((score - 10) / 2).floor();
    return m >= 0 ? '+$m' : '$m';
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ── Starting Gold Roll ────────────────────────────────────────────────────────

/// Parses "NdSxM" and rolls N dice of S sides, multiplied by M.
/// Returns the total gp result.
int _rollGoldDice(String dice) {
  final match =
      RegExp(r'^(\d+)d(\d+)(?:[xX\u00d7](\d+))?$').firstMatch(dice);
  if (match == null) return 0;
  final n = int.parse(match.group(1)!);
  final s = int.parse(match.group(2)!);
  final mult = match.group(3) != null ? int.parse(match.group(3)!) : 1;
  final rng = Random();
  int total = 0;
  for (int i = 0; i < n; i++) {
    total += rng.nextInt(s) + 1;
  }
  return total * mult;
}

class _StartingGoldRow extends ConsumerStatefulWidget {
  const _StartingGoldRow();

  @override
  ConsumerState<_StartingGoldRow> createState() => _StartingGoldRowState();
}

class _StartingGoldRowState extends ConsumerState<_StartingGoldRow> {
  void _roll() {
    final dice = ref.read(characterDraftProvider).selectedClass!.startingGoldDice;
    final result = _rollGoldDice(dice);
    ref.read(characterDraftProvider.notifier).setRolledStartingGold(result);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(characterDraftProvider);
    final dice = draft.selectedClass!.startingGoldDice;
    final rolled = draft.rolledStartingGold;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              'Starting Gold',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: rolled != null
                ? Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '$rolled gp',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                      ),
                      TextSpan(
                        text: '  (${_formatStartingGold(dice)})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ]),
                  )
                : Text(
                    _formatStartingGold(dice),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(10),
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(40, 40),
            ),
            onPressed: _roll,
            child: const Icon(Icons.casino_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _StartingEquipmentSection extends ConsumerWidget {
  const _StartingEquipmentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(characterDraftProvider);
    final notifier = ref.read(characterDraftProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final bg = draft.selectedBackground!;

    final fixedItems =
        bg.startingEquipment.where((i) => !isEquipmentChoiceItem(i)).toList();
    final choiceItems =
        bg.startingEquipment.where(isEquipmentChoiceItem).toList();
    final selectedItems = draft.selectedStartingEquipment;
    final resolvedChoices = draft.resolvedEquipmentChoices;
    final allFixedSelected = fixedItems.every(selectedItems.contains);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Starting Equipment',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.primary),
                ),
                const Spacer(),
                if (fixedItems.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      if (allFixedSelected) {
                        for (final item in fixedItems) {
                          if (selectedItems.contains(item)) {
                            notifier.toggleStartingItem(item);
                          }
                        }
                      } else {
                        for (final item in fixedItems) {
                          if (!selectedItems.contains(item)) {
                            notifier.toggleStartingItem(item);
                          }
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      allFixedSelected ? 'Deselect all' : 'Select all',
                      style: TextStyle(fontSize: 12, color: scheme.primary),
                    ),
                  ),
              ],
            ),
            if (fixedItems.isNotEmpty) ...[  
              const SizedBox(height: 4),
              Text(
                "Uncheck items you don't want to add to your inventory.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              ...fixedItems.map((item) {
                final isSelected = selectedItems.contains(item);
                final isGold = RegExp(r'^\d+\s*gp$', caseSensitive: false)
                    .hasMatch(item.trim());
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isSelected,
                  onChanged: (_) => notifier.toggleStartingItem(item),
                  title: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  secondary: isGold
                      ? Icon(Icons.monetization_on_outlined,
                          size: 16, color: scheme.tertiary)
                      : null,
                );
              }),
            ],
            // ── Equipment choices (e.g. "Musical instrument") ───────────
            if (choiceItems.isNotEmpty) ...[  
              if (fixedItems.isNotEmpty) const Divider(height: 20),
              Text(
                'Equipment Choices',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.secondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick the specific item for each slot.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              ...choiceItems.map((item) {
                final options = _equipmentChoiceOptions(item) ?? [];
                final current = resolvedChoices[item];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<String>(
                    initialValue: current,
                    decoration: InputDecoration(
                      labelText: item,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    hint: const Text('Choose one'),
                    items: options
                        .map((o) =>
                            DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) notifier.setEquipmentChoice(item, v);
                    },
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Language Choice Section ───────────────────────────────────────────────────

const _kDndLanguages = [
  'Abyssal', 'Celestial', 'Common', 'Deep Speech', 'Draconic',
  'Dwarvish', 'Elvish', 'Giant', 'Gnomish', 'Goblin',
  'Halfling', 'Infernal', 'Orc', 'Primordial', 'Sylvan', 'Undercommon',
];

// ── Tool Proficiency constants ────────────────────────────────────────────────
// ── Weapon constants (used for "any X weapon" sub-choices) ─────────────────
const _kSimpleMeleeWeapons = [
  'Club', 'Dagger', 'Greatclub', 'Handaxe', 'Javelin',
  'Light hammer', 'Mace', 'Quarterstaff', 'Sickle', 'Spear',
];
const _kSimpleRangedWeapons = ['Dart', 'Light crossbow', 'Shortbow', 'Sling'];
const _kMartialMeleeWeapons = [
  'Battleaxe', 'Flail', 'Glaive', 'Greataxe', 'Greatsword', 'Halberd',
  'Lance', 'Longsword', 'Maul', 'Morningstar', 'Pike', 'Rapier',
  'Scimitar', 'Shortsword', 'Trident', 'War pick', 'Warhammer', 'Whip',
];
const _kMartialRangedWeapons = [
  'Blowgun', 'Hand crossbow', 'Heavy crossbow', 'Longbow', 'Net',
];

/// Returns the selectable list for an "any X" item, or null if not applicable.
List<String>? _anyItemOptions(String item) {
  final lower = item.toLowerCase();
  if (lower == 'any simple weapon') {
    return [..._kSimpleMeleeWeapons, ..._kSimpleRangedWeapons];
  }
  if (lower == 'any simple melee weapon') return _kSimpleMeleeWeapons;
  if (lower == 'any martial weapon') {
    return [..._kMartialMeleeWeapons, ..._kMartialRangedWeapons];
  }
  if (lower == 'any martial melee weapon') return _kMartialMeleeWeapons;
  if (lower == 'any musical instrument') return _kInstruments;
  return null;
}
const _kArtisanTools = [
  "Alchemist's supplies", "Brewer's supplies", "Calligrapher's supplies",
  "Carpenter's tools", "Cartographer's tools", "Cobbler's tools",
  "Cook's utensils", "Glassblower's tools", "Jeweler's tools",
  "Leatherworker's tools", "Mason's tools", "Painter's supplies",
  "Potter's tools", "Smith's tools", "Tinker's tools",
  "Weaver's tools", "Woodcarver's tools",
];

const _kGamingSets = [
  'Dice set', 'Dragonchess set', 'Playing card set', 'Three-Dragon Ante set',
];

const _kInstruments = [
  'Bagpipes', 'Drum', 'Dulcimer', 'Flute', 'Lute', 'Lyre',
  'Horn', 'Pan flute', 'Shawm', 'Viol',
];

const _kWordToInt = {
  'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
};

class _ToolSlot {
  final String source;
  final String label;
  final List<String> options;
  const _ToolSlot({required this.source, required this.label, required this.options});
}

List<String> _toolOptionsForEntry(String lower) {
  if (lower.contains('artisan') && lower.contains('musical')) {
    return [..._kArtisanTools, ..._kInstruments];
  } else if (lower.contains('artisan')) {
    return _kArtisanTools;
  } else if (lower.contains('gaming')) {
    return _kGamingSets;
  } else if (lower.contains('musical')) {
    return _kInstruments;
  }
  return [..._kArtisanTools, ..._kGamingSets, ..._kInstruments];
}

bool _isToolChoice(String tool) {
  final lower = tool.toLowerCase();
  return lower.contains('one type of') || lower.contains('of your choice');
}

/// Returns the list of options for a starting-equipment choice item,
/// or null if the item is not a choice item.
List<String>? _equipmentChoiceOptions(String item) {
  final lower = item.toLowerCase();
  if (lower.contains('musical instrument')) return _kInstruments;
  if (lower.contains("artisan's tools")) return _kArtisanTools;
  if (lower.contains('gaming set')) return _kGamingSets;
  if (lower.contains('tools of the con')) {
    return ["Disguise kit", "Forgery kit", "Poisoner's kit", "Thieves' tools"];
  }
  return null;
}

// ── Armor / AC helpers ────────────────────────────────────────────────────────

/// (pattern in item name, base AC, max dex bonus: -1=unlimited, 0=none, N=capped)
/// Ordered so more-specific patterns come before generic substrings.
const _kArmorPatterns = <(String, int, int)>[
  ('half plate', 15, 2),
  ('studded leather', 12, -1),
  ('chain mail', 16, 0),
  ('ring mail', 14, 0),
  ('scale mail', 14, 2),
  ('chain shirt', 13, 2),
  ('plate', 18, 0),
  ('splint', 17, 0),
  ('breastplate', 14, 2),
  ('hide', 12, 2),
  ('leather', 11, -1),
  ('padded', 11, -1),
];

/// Returns the AC an item provides given the character's Dex modifier,
/// or null if the item is not armor.
int? _calcArmorAC(String item, int dexMod) {
  final lower = item.toLowerCase();
  for (final (pattern, base, maxDex) in _kArmorPatterns) {
    if (lower.contains(pattern)) {
      if (maxDex == 0) return base;
      if (maxDex == -1) return base + dexMod;
      return base + (dexMod > maxDex ? maxDex : dexMod);
    }
  }
  return null;
}

/// Finds the highest-AC armor+shield combo in [items].
/// Returns (finalAC, displayLabel) or null if no armor or shield found.
(int, String)? _findArmorAC(List<String> items, int dexMod) {
  final hasShield =
      items.any((i) => i.toLowerCase().contains('shield'));

  String? bestName;
  int? bestAC;

  for (final item in items) {
    final ac = _calcArmorAC(item, dexMod);
    if (ac != null && (bestAC == null || ac > bestAC)) {
      bestAC = ac;
      bestName = item;
    }
  }

  if (bestAC == null && !hasShield) return null;
  if (bestAC == null) return (10 + dexMod + 2, 'Shield (Unarmored)');

  final totalAC = bestAC + (hasShield ? 2 : 0);
  final label = hasShield ? '$bestName + Shield' : bestName!;
  return (totalAC, label);
}

/// Resolves all equipment item names from background + class selections.
List<String> _resolveEquipmentItems(CharacterDraft draft) {
  final items = <String>[];

  // Background: checked fixed items + resolved generic choices
  items.addAll(draft.selectedStartingEquipment);
  items.addAll(draft.resolvedEquipmentChoices.values);

  // Class fixed items + chosen option items (with "any X" resolved)
  final equip = draft.selectedClass?.startingEquipment;
  if (equip != null) {
    items.addAll(equip.fixed);
    for (int g = 0; g < equip.choices.length; g++) {
      final optIdx = g < draft.classEquipmentChoices.length
          ? draft.classEquipmentChoices[g]
          : null;
      if (optIdx == null) continue;
      final option = equip.choices[g].options[optIdx];
      for (int i = 0; i < option.length; i++) {
        final item = option[i];
        if (item.toLowerCase().startsWith('any ')) {
          final specific = draft.classEquipmentSpecifics['$g:$i'];
          if (specific != null) items.add(specific);
        } else {
          items.add(item);
        }
      }
    }
  }

  return items;
}

/// Parses a starting-gold dice string like "5d4x10" or "5d4" into a display string.
String _formatStartingGold(String dice) {
  if (dice.isEmpty) return '—';
  final match =
      RegExp(r'^(\d+)d(\d+)(?:[xX×](\d+))?$').firstMatch(dice);
  if (match == null) return '$dice gp';
  final n = int.parse(match.group(1)!);
  final s = int.parse(match.group(2)!);
  final mult = match.group(3) != null ? int.parse(match.group(3)!) : 1;
  final avg = (n * (s + 1) / 2 * mult).round();
  final notation = mult > 1 ? '${n}d$s×$mult' : '${n}d$s';
  return '$notation gp  (avg. ~$avg gp)';
}

List<_ToolSlot> _buildToolSlots(CharacterDraft draft) {
  final slots = <_ToolSlot>[];

  // Race: "Tool Proficiency" trait → one artisan's tool
  final race = draft.selectedRace;
  if (race != null && race.traits.contains('Tool Proficiency')) {
    slots.add(_ToolSlot(
      source: race.name,
      label: "Artisan's tool",
      options: _kArtisanTools,
    ));
  }

  // Background tool choices
  final bg = draft.selectedBackground;
  if (bg != null) {
    for (final tool in bg.toolProficiencies) {
      if (_isToolChoice(tool)) {
        final lower = tool.toLowerCase();
        slots.add(_ToolSlot(
          source: bg.name,
          label: lower.contains('gaming')
              ? 'Gaming set'
              : lower.contains('musical')
                  ? 'Musical instrument'
                  : "Artisan's tool",
          options: _toolOptionsForEntry(lower),
        ));
      }
    }
  }

  // Class tool choices
  final cls = draft.selectedClass;
  if (cls != null) {
    for (final tool in cls.toolProficiencies) {
      if (_isToolChoice(tool)) {
        final lower = tool.toLowerCase();
        // Detect count word (e.g., "three musical instruments of your choice")
        final match = RegExp(r'(\w+) musical instrument').firstMatch(lower);
        final countWord = match?.group(1);
        final count = _kWordToInt[countWord] ?? 1;
        final options = _toolOptionsForEntry(lower);
        final label = lower.contains('artisan') && lower.contains('musical')
            ? "Artisan's tool or instrument"
            : 'Musical instrument';
        for (int i = 0; i < count; i++) {
          slots.add(_ToolSlot(source: cls.name, label: label, options: options));
        }
      }
    }
  }

  return slots;
}

List<String> _buildFixedTools(CharacterDraft draft) {
  final fixed = <String>[];

  final bg = draft.selectedBackground;
  if (bg != null) {
    for (final tool in bg.toolProficiencies) {
      if (!_isToolChoice(tool)) fixed.add('${bg.name}: $tool');
    }
  }

  final cls = draft.selectedClass;
  if (cls != null) {
    for (final tool in cls.toolProficiencies) {
      if (!_isToolChoice(tool)) fixed.add('${cls.name}: $tool');
    }
  }

  return fixed;
}

// ── Tool Proficiency Section ──────────────────────────────────────────────────

class _ToolProficiencySection extends ConsumerWidget {
  const _ToolProficiencySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(characterDraftProvider);
    final scheme = Theme.of(context).colorScheme;

    final slots = _buildToolSlots(draft);
    final fixed = _buildFixedTools(draft);

    if (slots.isEmpty && fixed.isEmpty) return const SizedBox.shrink();

    final chosen = draft.chosenToolProficiencies;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tool Proficiencies',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.primary),
            ),
            if (fixed.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...fixed.map(
                (t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.handyman_outlined,
                          size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(t,
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (slots.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Choose your tool proficiency:',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              ...slots.asMap().entries.map((entry) {
                final i = entry.key;
                final slot = entry.value;
                final currentVal =
                    i < chosen.length && chosen[i].isNotEmpty ? chosen[i] : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${slot.source} — ${slot.label}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: currentVal,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        hint: const Text('Select a tool…',
                            style: TextStyle(fontSize: 13)),
                        items: slot.options
                            .map((tool) => DropdownMenuItem(
                                  value: tool,
                                  child: Text(tool,
                                      style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          final updated = List<String>.from(chosen);
                          while (updated.length <= i) {
                            updated.add('');
                          }
                          updated[i] = val;
                          ref
                              .read(characterDraftProvider.notifier)
                              .setChosenToolProficiencies(updated);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Class Equipment Section ───────────────────────────────────────────────────

class _ClassEquipmentSection extends ConsumerWidget {
  const _ClassEquipmentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(characterDraftProvider);
    final notifier = ref.read(characterDraftProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final cls = draft.selectedClass!;
    final equip = cls.startingEquipment!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Equipment — ${cls.name}',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.primary),
            ),
            // ── Fixed items ──────────────────────────────────────────────
            if (equip.fixed.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Included:',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: equip.fixed
                    .map((item) => Chip(
                          label: Text(item,
                              style: Theme.of(context).textTheme.bodySmall),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                        ))
                    .toList(),
              ),
            ],
            // ── Choice groups ─────────────────────────────────────────────
            ...equip.choices.asMap().entries.map((groupEntry) {
              final g = groupEntry.key;
              final group = groupEntry.value;
              final selectedOptionIdx =
                  g < draft.classEquipmentChoices.length
                      ? draft.classEquipmentChoices[g]
                      : null;

              // Label for a package: items joined by " + "
              String optionLabel(List<String> items) =>
                  items.map((i) => i.startsWith('any ') ? i : i).join(' + ');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Choose one:',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: group.options.asMap().entries.map((optEntry) {
                      final optIdx = optEntry.key;
                      final option = optEntry.value;
                      final isSelected = selectedOptionIdx == optIdx;
                      return ChoiceChip(
                        label: Text(
                          optionLabel(option),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? scheme.onSecondaryContainer
                                : null,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) =>
                            notifier.setClassEquipmentChoice(g, optIdx),
                      );
                    }).toList(),
                  ),
                  // Sub-dropdowns for "any X" items in the selected option
                  if (selectedOptionIdx != null)
                    ...group.options[selectedOptionIdx]
                        .asMap()
                        .entries
                        .where((e) =>
                            e.value.toLowerCase().startsWith('any '))
                        .map((e) {
                      final i = e.key;
                      final anyItem = e.value;
                      final opts = _anyItemOptions(anyItem) ?? [];
                      final current =
                          draft.classEquipmentSpecifics['$g:$i'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: DropdownButtonFormField<String>(
                          initialValue: current,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: anyItem,
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          hint: const Text('Choose one',
                              style: TextStyle(fontSize: 13)),
                          items: opts
                              .map((o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(o,
                                        style: const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              notifier.setClassEquipmentSpecific('$g:$i', v);
                            }
                          },
                        ),
                      );
                    }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LanguageChoiceSection extends ConsumerStatefulWidget {
  const _LanguageChoiceSection();

  @override
  ConsumerState<_LanguageChoiceSection> createState() =>
      _LanguageChoiceSectionState();
}

class _LanguageChoiceSectionState
    extends ConsumerState<_LanguageChoiceSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(characterDraftProvider);
    final scheme = Theme.of(context).colorScheme;
    final needed = draft.languageChoicesNeeded;
    final chosen = draft.chosenLanguages;
    final canAdd = chosen.length < needed;

    void addLanguage(String lang) {
      final trimmed = lang.trim();
      if (trimmed.isEmpty || chosen.contains(trimmed)) return;
      if (chosen.length >= needed) return;
      ref
          .read(characterDraftProvider.notifier)
          .setChosenLanguages([...chosen, trimmed]);
    }

    void removeLanguage(String lang) {
      ref.read(characterDraftProvider.notifier).setChosenLanguages(
            chosen.where((l) => l != lang).toList(),
          );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Language Choices',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.primary),
                ),
                const Spacer(),
                Text(
                  '${chosen.length} / $needed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: chosen.length >= needed
                            ? scheme.primary
                            : scheme.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Choose $needed language(s) granted by your race or background.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (chosen.isNotEmpty) ...[const SizedBox(height: 8), Wrap(
              spacing: 4,
              runSpacing: 4,
              children: chosen
                  .map((lang) => Chip(
                        label: Text(lang),
                        labelStyle: const TextStyle(fontSize: 12),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        onDeleted: () => removeLanguage(lang),
                      ))
                  .toList(),
            )],
            if (canAdd) ...[const SizedBox(height: 8), Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Type a language…',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                    ),
                    onSubmitted: (v) {
                      addLanguage(v);
                      _ctrl.clear();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    addLanguage(_ctrl.text);
                    _ctrl.clear();
                  },
                ),
              ],
            ), const SizedBox(height: 8), Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _kDndLanguages
                  .where((l) =>
                      !chosen.contains(l) &&
                      !draft.fixedRaceLanguages.contains(l))
                  .map((lang) => ActionChip(
                        label: Text(lang),
                        labelStyle: const TextStyle(fontSize: 11),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 2),
                        onPressed: () => addLanguage(lang),
                      ))
                  .toList(),
            )],
          ],
        ),
      ),
    );
  }
}
