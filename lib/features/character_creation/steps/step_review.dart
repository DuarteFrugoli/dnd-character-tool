import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:dnd_character_tool/l10n/ability_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/constants/armor_class.dart';
import '../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../data/datasources/srd/srd_models.dart';
import '../../../data/models/ability_scores.dart';
import '../../../shared/providers/providers.dart';
import '../../../core/units/unit_system_provider.dart';
import '../../../core/units/unit_formatter.dart';
import '../character_draft_provider.dart';
import '../widgets/review_equipment_preview.dart';
import '../widgets/review_equipment_widgets.dart';

class StepReview extends ConsumerStatefulWidget {
  const StepReview({super.key});

  @override
  ConsumerState<StepReview> createState() => StepReviewState();
}

class StepReviewState extends ConsumerState<StepReview> {
  final _scrollController = ScrollController();
  final _startingGoldKey = GlobalKey();
  final _languageChoicesKey = GlobalKey();
  final _toolChoicesKey = GlobalKey();
  final _startingEquipmentKey = GlobalKey();
  final _classEquipmentKey = GlobalKey();
  bool _showValidation = false;

  bool focusFirstPendingIssue() {
    final issue = firstCreationReviewIssue(ref.read(characterDraftProvider));
    setState(() => _showValidation = true);
    if (issue == null) return false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _keyForIssue(issue).currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
    return true;
  }

  GlobalKey _keyForIssue(CreationReviewIssue issue) {
    return switch (issue) {
      CreationReviewIssue.startingGold => _startingGoldKey,
      CreationReviewIssue.languages => _languageChoicesKey,
      CreationReviewIssue.tools => _toolChoicesKey,
      CreationReviewIssue.backgroundEquipment => _startingEquipmentKey,
      CreationReviewIssue.classEquipment => _classEquipmentKey,
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final draft = ref.watch(characterDraftProvider);
    final attrs = draft.finalAttributes;
    final abilityScores = AbilityScores(
      strength: attrs['Strength'] ?? 10,
      dexterity: attrs['Dexterity'] ?? 10,
      constitution: attrs['Constitution'] ?? 10,
      intelligence: attrs['Intelligence'] ?? 10,
      wisdom: attrs['Wisdom'] ?? 10,
      charisma: attrs['Charisma'] ?? 10,
    );
    final con = attrs['Constitution'] ?? 10;
    final conMod = ((con - 10) / 2).floor();
    final dex = attrs['Dexterity'] ?? 10;
    final dexMod = ((dex - 10) / 2).floor();
    final hitDie = draft.selectedClass?.hitDie ?? 8;
    final maxHp = hitDie + conMod;
    final className = draft.selectedClass?.name ?? '';
    final unarmoredAc = calcUnarmoredArmorClass(
      characterClass: className,
      abilityScores: abilityScores,
    );
    final shieldOnlyAc = calcUnarmoredArmorClass(
      characterClass: className,
      abilityScores: abilityScores,
      shieldBonus: 2,
    );
    final allItems = _resolveEquipmentItems(draft);
    final armorInfo = _findArmorAC(
      allItems,
      dexMod,
      shieldOnlyAc: shieldOnlyAc,
    );

    final clsName = draft.selectedClass != null
        ? i18n.className(draft.selectedClass!.name)
        : null;
    final subclassFeature = draft.selectedClass != null
        ? (i18n.classSubclassFeatureName(draft.selectedClass!.name) ??
              draft.selectedClass!.subclassFeatureName)
        : l10n.reviewRowSubclass;
    final subclassName =
        draft.selectedSubclass != null && draft.selectedClass != null
        ? i18n.subclassName(
            draft.selectedClass!.name,
            draft.selectedSubclass!.name,
          )
        : null;
    final raceName = draft.selectedRace != null
        ? i18n.raceName(draft.selectedRace!.name)
        : null;
    final subraceName = draft.selectedSubrace != null
        ? i18n.subraceName(draft.selectedSubrace!.name)
        : null;
    final bgName = draft.selectedBackground != null
        ? i18n.backgroundName(draft.selectedBackground!.name)
        : null;
    final bgFeatureName = draft.selectedBackground != null
        ? (i18n.backgroundFeatureName(draft.selectedBackground!.name) ??
              draft.selectedBackground!.feature.name)
        : null;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        _ReviewSection(
          title: l10n.sectionIdentity,
          children: [
            _Row(
              l10n.reviewRowName,
              draft.name.isEmpty ? l10n.reviewUnnamedHero : draft.name,
            ),
            if (draft.playerName.isNotEmpty)
              _Row(l10n.reviewRowPlayer, draft.playerName),
          ],
        ),
        _ReviewSection(
          title: l10n.creationStepClass,
          children: [
            _Row(l10n.creationStepClass, clsName ?? '—'),
            if (subclassName != null) _Row(subclassFeature, subclassName),
            _Row(
              l10n.reviewRowHitDie,
              'd${draft.selectedClass?.hitDie ?? '—'}',
            ),
            _Row(
              l10n.reviewRowSavingThrows,
              draft.selectedClass?.savingThrows
                      .map((s) => abilityName(l10n, s))
                      .join(', ') ??
                  '—',
            ),
          ],
        ),
        if (draft.selectedClass != null)
          _StartingGoldSection(
            key: _startingGoldKey,
            showValidation: _showValidation,
          ),
        _ReviewSection(
          title: l10n.creationStepRace,
          children: [
            _Row(l10n.creationStepRace, raceName ?? '—'),
            if (subraceName != null) _Row(l10n.reviewRowSubrace, subraceName),
            _Row(
              l10n.reviewRowSpeed,
              formatDistance(
                draft.selectedRace?.speed ?? 0,
                ref.watch(unitSystemProvider),
              ),
            ),
            if (draft.fixedRaceLanguages.isNotEmpty)
              _Row(
                l10n.reviewRowLanguages,
                draft.fixedRaceLanguages.map(i18n.languageName).join(', '),
              ),
          ],
        ),
        _ReviewSection(
          title: l10n.creationStepBackground,
          children: [
            _Row(l10n.creationStepBackground, bgName ?? '—'),
            _Row(l10n.reviewRowFeature, bgFeatureName ?? '—'),
          ],
        ),
        _ReviewSection(
          title: l10n.creationStepSkills,
          children: [
            _Row(
              l10n.reviewRowFromBackground,
              draft.grantedSkills.map(i18n.skillName).join(', '),
            ),
            if (draft.chosenSkills.isNotEmpty)
              _Row(
                l10n.reviewRowClassChoices,
                draft.chosenSkills.map(i18n.skillName).join(', '),
              ),
          ],
        ),
        _ReviewSection(
          title: l10n.creationStepAttributes,
          children: [
            ...attrs.entries.map(
              (e) => _Row(e.key, '${e.value} (${_mod(e.value)})'),
            ),
            _Row(l10n.reviewRowMaxHp, '$maxHp  (d$hitDie + $conMod CON)'),
            _Row(l10n.reviewRowAcUnarmored, '$unarmoredAc'),
            if (armorInfo != null)
              _Row(l10n.reviewRowAcWith(armorInfo.$2), '${armorInfo.$1}'),
            _Row(l10n.reviewRowProficiencyBonus, '+2'),
          ],
        ),
        // ── Language Choices ────────────────────────────────────────────────────────
        if (draft.languageChoicesNeeded > 0)
          _LanguageChoiceSection(
            key: _languageChoicesKey,
            showValidation: _showValidation,
          ),
        // ── Tool Proficiency Choices ─────────────────────────────────────────────────
        _ToolProficiencySection(
          key: _toolChoicesKey,
          showValidation: _showValidation,
        ),
        // ── Starting Equipment ─────────────────────────────────────────────────────
        if (draft.selectedBackground != null &&
            draft.selectedBackground!.startingEquipment.isNotEmpty)
          _StartingEquipmentSection(
            key: _startingEquipmentKey,
            showValidation: _showValidation,
          ), // ── Class Equipment ────────────────────────────────────────────────────
        if (draft.selectedClass?.startingEquipment != null)
          _ClassEquipmentSection(
            key: _classEquipmentKey,
            showValidation: _showValidation,
          ),
        const SizedBox(height: 16),
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
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
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
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// Starting gold helpers
/// Parses "NdSxM" and rolls N dice of S sides, multiplied by M.
/// Returns the total gp result.
int _rollGoldDice(String dice) {
  final match = RegExp(r'^(\d+)d(\d+)(?:[xX\u00d7](\d+))?$').firstMatch(dice);
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

class _StartingGoldSection extends ConsumerWidget {
  const _StartingGoldSection({super.key, required this.showValidation});

  final bool showValidation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void roll() {
      final dice = ref
          .read(characterDraftProvider)
          .selectedClass!
          .startingGoldDice;
      final result = _rollGoldDice(dice);
      ref.read(characterDraftProvider.notifier).setRolledStartingGold(result);
    }

    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(characterDraftProvider);
    final dice = draft.selectedClass!.startingGoldDice;
    final rolled = draft.rolledStartingGold;
    final scheme = Theme.of(context).colorScheme;
    final isMissing = rolled == null;
    final showError = showValidation && isMissing;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: _reviewCardShape(context, showError),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reviewStartingGold,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: showError ? scheme.error : scheme.primary,
                    ),
                  ),
                ),
                if (showError)
                  _PendingReviewChip(label: l10n.featureChoicesPending),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              rolled == null ? _formatStartingGold(dice) : '$rolled gp',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: rolled == null ? scheme.onSurface : scheme.primary,
              ),
            ),
            if (rolled != null) ...[
              const SizedBox(height: 2),
              Text(
                _formatStartingGold(dice),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: roll,
                icon: const Icon(Icons.casino_outlined, size: 18),
                label: Text(
                  rolled == null ? l10n.diceRollButton : l10n.diceRerollButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ShapeBorder? _reviewCardShape(BuildContext context, bool showError) {
  if (!showError) return null;
  final scheme = Theme.of(context).colorScheme;
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: scheme.error, width: 1.2),
  );
}

class _PendingReviewChip extends StatelessWidget {
  const _PendingReviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 14, color: scheme.onErrorContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartingEquipmentSection extends ConsumerWidget {
  const _StartingEquipmentSection({super.key, required this.showValidation});

  final bool showValidation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(characterDraftProvider);
    final notifier = ref.read(characterDraftProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final itemsByName =
        ref.watch(srdItemsProvider).valueOrNull ??
        const <String, SrdItemData>{};
    final bg = draft.selectedBackground!;

    final fixedItems = bg.startingEquipment
        .where((i) => !isEquipmentChoiceItem(i))
        .toList();
    final choiceItems = bg.startingEquipment
        .where(isEquipmentChoiceItem)
        .toList();
    final selectedItems = draft.selectedStartingEquipment;
    final resolvedChoices = draft.resolvedEquipmentChoices;
    final allFixedSelected = fixedItems.every(selectedItems.contains);
    final showError =
        showValidation && !creationBackgroundEquipmentChoicesComplete(draft);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: _reviewCardShape(context, showError),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.reviewStartingEquipment,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: showError ? scheme.error : scheme.primary,
                  ),
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
                      allFixedSelected
                          ? l10n.reviewDeselectAll
                          : l10n.reviewSelectAll,
                      style: TextStyle(fontSize: 12, color: scheme.primary),
                    ),
                  ),
              ],
            ),
            if (showError) ...[
              const SizedBox(height: 8),
              _PendingReviewChip(label: l10n.featureChoicesPending),
            ],
            if (fixedItems.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l10n.reviewUncheckHint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              ...fixedItems.map((item) {
                final isSelected = selectedItems.contains(item);
                final preview = equipmentPreviewFor(
                  rawName: item,
                  itemsByName: itemsByName,
                  i18n: i18n,
                  l10n: l10n,
                );
                final detailsPreview = preview?.hasDetails == true
                    ? preview
                    : null;
                return ReviewEquipmentCheckboxTile(
                  rawName: item,
                  preview: preview,
                  i18n: i18n,
                  isSelected: isSelected,
                  onChanged: (_) => notifier.toggleStartingItem(item),
                  onDetails: detailsPreview == null
                      ? null
                      : () => showEquipmentPreviewDetails(
                          context,
                          ref,
                          detailsPreview,
                        ),
                );
              }),
            ],
            // ── Equipment choices (e.g. "Musical instrument") ───────────
            if (choiceItems.isNotEmpty) ...[
              if (fixedItems.isNotEmpty) const Divider(height: 20),
              Text(
                l10n.reviewEquipmentChoices,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: scheme.secondary),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.reviewEquipmentChoicesHint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              ...choiceItems.map((item) {
                final options = _equipmentChoiceOptions(item) ?? [];
                final current = resolvedChoices[item];
                final currentPreview = current == null
                    ? null
                    : equipmentPreviewFor(
                        rawName: current,
                        itemsByName: itemsByName,
                        i18n: i18n,
                        l10n: l10n,
                      );
                final currentDetailsPreview = currentPreview?.hasDetails == true
                    ? currentPreview
                    : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<String>(
                    initialValue: current,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: i18n.backgroundEquipmentName(item),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: currentDetailsPreview == null
                          ? null
                          : EquipmentInfoButton(
                              onPressed: () => showEquipmentPreviewDetails(
                                context,
                                ref,
                                currentDetailsPreview,
                              ),
                            ),
                    ),
                    hint: Text(l10n.stepChooseOne),
                    selectedItemBuilder: (context) => options.map((o) {
                      final label = equipmentPreviewLabel(
                        rawName: o,
                        itemsByName: itemsByName,
                        i18n: i18n,
                        l10n: l10n,
                      );
                      return Text(label, overflow: TextOverflow.ellipsis);
                    }).toList(),
                    items: options.map((o) {
                      final preview = equipmentPreviewFor(
                        rawName: o,
                        itemsByName: itemsByName,
                        i18n: i18n,
                        l10n: l10n,
                      );
                      return DropdownMenuItem(
                        value: o,
                        child: EquipmentDropdownOption(
                          preview: preview,
                          label: i18n.backgroundEquipmentName(o),
                          i18n: i18n,
                        ),
                      );
                    }).toList(),
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
  'Abyssal',
  'Celestial',
  'Common',
  'Deep Speech',
  'Draconic',
  'Dwarvish',
  'Elvish',
  'Giant',
  'Gnomish',
  'Goblin',
  'Halfling',
  'Infernal',
  'Orc',
  'Primordial',
  'Sylvan',
  'Undercommon',
];

// ── Tool Proficiency constants ────────────────────────────────────────────────
// ── Weapon constants (used for "any X weapon" sub-choices) ─────────────────
const _kSimpleMeleeWeapons = [
  'Club',
  'Dagger',
  'Greatclub',
  'Handaxe',
  'Javelin',
  'Light hammer',
  'Mace',
  'Quarterstaff',
  'Sickle',
  'Spear',
];
const _kSimpleRangedWeapons = ['Dart', 'Light crossbow', 'Shortbow', 'Sling'];
const _kMartialMeleeWeapons = [
  'Battleaxe',
  'Flail',
  'Glaive',
  'Greataxe',
  'Greatsword',
  'Halberd',
  'Lance',
  'Longsword',
  'Maul',
  'Morningstar',
  'Pike',
  'Rapier',
  'Scimitar',
  'Shortsword',
  'Trident',
  'War pick',
  'Warhammer',
  'Whip',
];
const _kMartialRangedWeapons = [
  'Blowgun',
  'Hand crossbow',
  'Heavy crossbow',
  'Longbow',
  'Net',
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
  "Alchemist's supplies",
  "Brewer's supplies",
  "Calligrapher's supplies",
  "Carpenter's tools",
  "Cartographer's tools",
  "Cobbler's tools",
  "Cook's utensils",
  "Glassblower's tools",
  "Jeweler's tools",
  "Leatherworker's tools",
  "Mason's tools",
  "Painter's supplies",
  "Potter's tools",
  "Smith's tools",
  "Tinker's tools",
  "Weaver's tools",
  "Woodcarver's tools",
];

const _kGamingSets = [
  'Dice set',
  'Dragonchess set',
  'Playing card set',
  'Three-Dragon Ante set',
];

const _kInstruments = [
  'Bagpipes',
  'Drum',
  'Dulcimer',
  'Flute',
  'Lute',
  'Lyre',
  'Horn',
  'Pan flute',
  'Shawm',
  'Viol',
];

const _kWordToInt = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5};

class _ToolSlot {
  final String source;
  final String label;
  final List<String> options;
  const _ToolSlot({
    required this.source,
    required this.label,
    required this.options,
  });
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
(int, String)? _findArmorAC(
  List<String> items,
  int dexMod, {
  required int shieldOnlyAc,
}) {
  final hasShield = items.any((i) => i.toLowerCase().contains('shield'));

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
  if (bestAC == null) return (shieldOnlyAc, 'Shield (Unarmored)');

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
  final match = RegExp(r'^(\d+)d(\d+)(?:[xX×](\d+))?$').firstMatch(dice);
  if (match == null) return '$dice gp';
  final n = int.parse(match.group(1)!);
  final s = int.parse(match.group(2)!);
  final mult = match.group(3) != null ? int.parse(match.group(3)!) : 1;
  final avg = (n * (s + 1) / 2 * mult).round();
  final notation = mult > 1 ? '${n}d$s×$mult' : '${n}d$s';
  return '$notation gp  (avg. ~$avg gp)';
}

List<_ToolSlot> _buildToolSlots(
  CharacterDraft draft,
  SrdI18nService i18n,
  AppLocalizations l10n,
) {
  final slots = <_ToolSlot>[];

  // Race: "Tool Proficiency" trait → one artisan's tool
  final race = draft.selectedRace;
  if (race != null && race.traits.contains('Tool Proficiency')) {
    slots.add(
      _ToolSlot(
        source: i18n.raceName(race.name),
        label: l10n.stepToolCategoryArtisanTool,
        options: _kArtisanTools,
      ),
    );
  }

  // Background tool choices
  final bg = draft.selectedBackground;
  if (bg != null) {
    for (final tool in bg.toolProficiencies) {
      if (_isToolChoice(tool)) {
        final lower = tool.toLowerCase();
        final label = lower.contains('gaming')
            ? l10n.stepToolCategoryGamingSet
            : lower.contains('musical')
            ? l10n.stepToolCategoryInstrument
            : l10n.stepToolCategoryArtisanTool;
        slots.add(
          _ToolSlot(
            source: i18n.backgroundName(bg.name),
            label: label,
            options: _toolOptionsForEntry(lower),
          ),
        );
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
            ? l10n.stepToolCategoryArtisanOrInstrument
            : l10n.stepToolCategoryInstrument;
        for (int i = 0; i < count; i++) {
          slots.add(
            _ToolSlot(
              source: i18n.className(cls.name),
              label: label,
              options: options,
            ),
          );
        }
      }
    }
  }

  return slots;
}

List<String> _buildFixedTools(CharacterDraft draft, SrdI18nService i18n) {
  final fixed = <String>[];

  final bg = draft.selectedBackground;
  if (bg != null) {
    for (final tool in bg.toolProficiencies) {
      if (!_isToolChoice(tool)) {
        fixed.add('${i18n.backgroundName(bg.name)}: ${i18n.toolName(tool)}');
      }
    }
  }

  final cls = draft.selectedClass;
  if (cls != null) {
    for (final tool in cls.toolProficiencies) {
      if (!_isToolChoice(tool)) {
        fixed.add('${i18n.className(cls.name)}: ${i18n.toolName(tool)}');
      }
    }
  }

  return fixed;
}

// ── Tool Proficiency Section ──────────────────────────────────────────────────

class _ToolProficiencySection extends ConsumerWidget {
  const _ToolProficiencySection({super.key, required this.showValidation});

  final bool showValidation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(characterDraftProvider);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;

    final slots = _buildToolSlots(draft, i18n, l10n);
    final fixed = _buildFixedTools(draft, i18n);

    if (slots.isEmpty && fixed.isEmpty) return const SizedBox.shrink();

    final chosen = draft.chosenToolProficiencies;
    final showError = showValidation && !creationToolChoicesComplete(draft);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: _reviewCardShape(context, showError),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.reviewToolProficiencies,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: showError ? scheme.error : scheme.primary,
              ),
            ),
            if (showError) ...[
              const SizedBox(height: 8),
              _PendingReviewChip(label: l10n.featureChoicesPending),
            ],
            if (fixed.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...fixed.map(
                (t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.handyman_outlined,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          t,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (slots.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.reviewChooseToolProficiency,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              ...slots.asMap().entries.map((entry) {
                final i = entry.key;
                final slot = entry.value;
                final currentVal = i < chosen.length && chosen[i].isNotEmpty
                    ? chosen[i]
                    : null;

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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        hint: Text(
                          AppLocalizations.of(context)!.stepSelectTool,
                          style: const TextStyle(fontSize: 13),
                        ),
                        items: slot.options
                            .map(
                              (tool) => DropdownMenuItem(
                                value: tool,
                                child: Text(
                                  i18n.toolName(tool),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
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
  const _ClassEquipmentSection({super.key, required this.showValidation});

  final bool showValidation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(characterDraftProvider);
    final notifier = ref.read(characterDraftProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    final itemsByName =
        ref.watch(srdItemsProvider).valueOrNull ??
        const <String, SrdItemData>{};
    final cls = draft.selectedClass!;
    final equip = cls.startingEquipment!;
    final showError = showValidation && !draft.classEquipmentComplete;

    ReviewEquipmentPreview? previewFor(String rawName) {
      return equipmentPreviewFor(
        rawName: rawName,
        itemsByName: itemsByName,
        i18n: i18n,
        l10n: l10n,
      );
    }

    String optionLabel(List<String> items) {
      return items
          .map((item) {
            final preview = previewFor(item);
            return preview == null
                ? i18n.backgroundEquipmentName(item)
                : equipmentPreviewTitle(preview);
          })
          .join(' + ');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: _reviewCardShape(context, showError),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviewClassEquipmentTitle(i18n.className(cls.name)),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: showError ? scheme.error : scheme.primary,
              ),
            ),
            if (showError) ...[
              const SizedBox(height: 8),
              _PendingReviewChip(label: l10n.featureChoicesPending),
            ],
            // ── Fixed items ──────────────────────────────────────────────
            if (equip.fixed.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.reviewEquipmentIncluded,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: equip.fixed.map((item) {
                  final preview = previewFor(item);
                  final detailsPreview = preview?.hasDetails == true
                      ? preview
                      : null;
                  return ReviewEquipmentChip(
                    rawName: item,
                    preview: preview,
                    i18n: i18n,
                    onDetails: detailsPreview == null
                        ? null
                        : () => showEquipmentPreviewDetails(
                            context,
                            ref,
                            detailsPreview,
                          ),
                  );
                }).toList(),
              ),
            ],
            // ── Choice groups ─────────────────────────────────────────────
            ...equip.choices.asMap().entries.map((groupEntry) {
              final g = groupEntry.key;
              final group = groupEntry.value;
              final selectedOptionIdx = g < draft.classEquipmentChoices.length
                  ? draft.classEquipmentChoices[g]
                  : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.reviewChooseOne,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    children: group.options.asMap().entries.map((optEntry) {
                      final optIdx = optEntry.key;
                      final option = optEntry.value;
                      final isSelected = selectedOptionIdx == optIdx;
                      final label = optionLabel(option);
                      final previews = option
                          .map(previewFor)
                          .whereType<ReviewEquipmentPreview>()
                          .toList();
                      final hasDetails = previews.any(
                        (preview) => preview.hasDetails,
                      );
                      return ClassEquipmentOptionTile(
                        label: label,
                        previews: previews,
                        i18n: i18n,
                        selected: isSelected,
                        onSelected: () =>
                            notifier.setClassEquipmentChoice(g, optIdx),
                        onDetails: hasDetails
                            ? () => showEquipmentPackageDetails(
                                context,
                                ref,
                                previews,
                                label,
                                i18n,
                              )
                            : null,
                      );
                    }).toList(),
                  ),
                  // Sub-dropdowns for "any X" items in the selected option
                  if (selectedOptionIdx != null)
                    ...group.options[selectedOptionIdx]
                        .asMap()
                        .entries
                        .where((e) => e.value.toLowerCase().startsWith('any '))
                        .map((e) {
                          final i = e.key;
                          final anyItem = e.value;
                          final opts = _anyItemOptions(anyItem) ?? [];
                          final current =
                              draft.classEquipmentSpecifics['$g:$i'];
                          final currentPreview = current == null
                              ? null
                              : previewFor(current);
                          final currentDetailsPreview =
                              currentPreview?.hasDetails == true
                              ? currentPreview
                              : null;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: DropdownButtonFormField<String>(
                              initialValue: current,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: i18n.backgroundEquipmentName(
                                  anyItem,
                                ),
                                border: const OutlineInputBorder(),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                suffixIcon: currentDetailsPreview == null
                                    ? null
                                    : EquipmentInfoButton(
                                        onPressed: () =>
                                            showEquipmentPreviewDetails(
                                              context,
                                              ref,
                                              currentDetailsPreview,
                                            ),
                                      ),
                              ),
                              hint: Text(
                                l10n.stepChooseOne,
                                style: const TextStyle(fontSize: 13),
                              ),
                              selectedItemBuilder: (context) => opts.map((o) {
                                final label = equipmentPreviewLabel(
                                  rawName: o,
                                  itemsByName: itemsByName,
                                  i18n: i18n,
                                  l10n: l10n,
                                );
                                return Text(
                                  label,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                );
                              }).toList(),
                              items: opts.map((o) {
                                final preview = previewFor(o);
                                return DropdownMenuItem(
                                  value: o,
                                  child: EquipmentDropdownOption(
                                    preview: preview,
                                    label: i18n.backgroundEquipmentName(o),
                                    i18n: i18n,
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  notifier.setClassEquipmentSpecific(
                                    '$g:$i',
                                    v,
                                  );
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
  const _LanguageChoiceSection({super.key, required this.showValidation});

  final bool showValidation;

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
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(characterDraftProvider);
    final scheme = Theme.of(context).colorScheme;
    final needed = draft.languageChoicesNeeded;
    final chosen = draft.chosenLanguages;
    final canAdd = chosen.length < needed;
    final showError =
        widget.showValidation && !creationLanguageChoicesComplete(draft);

    void addLanguage(String lang) {
      final trimmed = lang.trim();
      if (trimmed.isEmpty || chosen.contains(trimmed)) return;
      if (chosen.length >= needed) return;
      ref.read(characterDraftProvider.notifier).setChosenLanguages([
        ...chosen,
        trimmed,
      ]);
    }

    void removeLanguage(String lang) {
      ref
          .read(characterDraftProvider.notifier)
          .setChosenLanguages(chosen.where((l) => l != lang).toList());
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: _reviewCardShape(context, showError),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.reviewLanguageChoices,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: showError ? scheme.error : scheme.primary,
                  ),
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
            if (showError) ...[
              const SizedBox(height: 8),
              _PendingReviewChip(label: l10n.featureChoicesPending),
            ],
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.reviewChooseLanguages(needed),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (chosen.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: chosen
                    .map(
                      (lang) => Chip(
                        label: Text(lang),
                        labelStyle: const TextStyle(fontSize: 12),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onDeleted: () => removeLanguage(lang),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (canAdd) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: l10n.reviewLanguageTypeHint,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
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
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _kDndLanguages
                    .where(
                      (l) =>
                          !chosen.contains(l) &&
                          !draft.fixedRaceLanguages.contains(l),
                    )
                    .map(
                      (lang) => ActionChip(
                        label: Text(lang),
                        labelStyle: const TextStyle(fontSize: 11),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        onPressed: () => addLanguage(lang),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
