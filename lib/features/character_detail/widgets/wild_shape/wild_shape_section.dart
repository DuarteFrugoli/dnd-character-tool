import 'package:collection/collection.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/units/unit_system_provider.dart';
import '../../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../../data/datasources/srd/srd_monster.dart';
import '../../../../data/dice/contextual_roll.dart';
import '../../../../data/feature_usage_engine.dart';
import '../../../../data/models/models.dart';
import '../../../../data/rulesets/srd_content_pack.dart';
import '../../../../data/rulesets/wild_shape_rules.dart';
import '../../../../data/wild_shape/wild_shape_engine.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/widgets/monster_stat_block.dart';
import '../../character_detail_provider.dart';
import '../detail_widgets.dart';
import '../dice/contextual_roll_sheet.dart';

/// Whether the sheet shows Wild Shape: a Druid of level 2+ or an active form.
bool showsWildShape(Character character) =>
    character.wildShape != null ||
    WildShapeRules.forCharacter(character).limitsFor(character) != null;

/// Druid Wild Shape: uses, the Beast Shapes limits, assuming and leaving a
/// form, and the active form's statistics and attacks.
class WildShapeSection extends ConsumerWidget {
  const WildShapeSection({
    super.key,
    required this.characterId,
    required this.character,
  });

  final String characterId;
  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final packId = character.contentPackId;
    final monsters = ref.watch(srdMonstersForPackProvider(packId)).valueOrNull;
    final usages = ref.watch(srdFeatureUsagesForPackProvider(packId)).valueOrNull;
    if (monsters == null || usages == null) return const SizedBox.shrink();
    final i18n = ref.watch(srdI18nForPackProvider(packId)).valueOrNull ??
        SrdI18nService.englishForPack(SrdContentPackRegistry.forId(packId));
    final uses = WildShapeEngine.usage(character, usages);
    final active = character.wildShape;
    final form = active == null
        ? null
        : monsters.firstWhereOrNull((monster) => monster.id == active.monsterId);
    return DetailSection(
      title: l10n.wildShapeTitle,
      icon: Icons.pets,
      subtitle: _usesLabel(l10n, uses),
      child: form == null
          ? _IdleWildShape(
              characterId: characterId,
              character: character,
              monsters: monsters,
              uses: uses,
              i18n: i18n,
            )
          : _ActiveWildShape(
              characterId: characterId,
              character: character,
              form: form,
              i18n: i18n,
            ),
    );
  }

  static String? _usesLabel(AppLocalizations l10n, FeatureUsageView? uses) {
    if (uses == null) return null;
    if (uses.isUnlimited) return l10n.wildShapeUsesUnlimited;
    return l10n.wildShapeUses(uses.current ?? 0, uses.max ?? 0);
  }
}

class _IdleWildShape extends ConsumerWidget {
  const _IdleWildShape({
    required this.characterId,
    required this.character,
    required this.monsters,
    required this.uses,
    required this.i18n,
  });

  final String characterId;
  final Character character;
  final List<SrdMonster> monsters;
  final FeatureUsageView? uses;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final rules = WildShapeRules.forCharacter(character);
    final limits = rules.limitsFor(character);
    final available = WildShapeEngine.availableForms(character, monsters);
    final hasUses = uses != null && (uses!.isUnlimited || uses!.canSpend);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (limits != null) Text(_limitsText(l10n, limits), style: theme.textTheme.bodyMedium),
        if (limits?.knownForms != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.wildShapeKnownForms(available.length, limits!.knownForms!),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          if (available.isEmpty)
            Text(l10n.wildShapeChooseForms, style: theme.textTheme.bodySmall)
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final form in available)
                  ActionChip(
                    label: Text(i18n.monsterName(form.name)),
                    onPressed: () => showMonsterStatBlockSheet(context, form, i18n),
                  ),
              ],
            ),
        ],
        if (!hasUses && uses != null) ...[
          const SizedBox(height: 8),
          Text(l10n.wildShapeNoUsesLeft, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: hasUses && available.isNotEmpty
              ? () => _pickForm(context, ref, available)
              : null,
          icon: const Icon(Icons.pets),
          label: Text(l10n.wildShapeAssume),
        ),
      ],
    );
  }

  Future<void> _pickForm(
    BuildContext context,
    WidgetRef ref,
    List<SrdMonster> available,
  ) async {
    final form = await showModalBottomSheet<SrdMonster>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _FormPicker(
        character: character,
        forms: available,
        i18n: i18n,
      ),
    );
    if (form == null || !context.mounted) return;
    await confirmAndAssumeWildShape(
      context,
      ref,
      characterId: characterId,
      character: character,
      form: form,
      uses: uses!,
      i18n: i18n,
    );
  }
}

String _limitsText(AppLocalizations l10n, WildShapeLimits limits) => [
  l10n.wildShapeLimits(limits.maxChallengeRating),
  if (!limits.allowsFly) l10n.wildShapeNoFly,
  if (!limits.allowsSwim) l10n.wildShapeNoSwim,
].join(' · ');

/// Says what assuming [form] changes before spending the use.
Future<void> confirmAndAssumeWildShape(
  BuildContext context,
  WidgetRef ref, {
  required String characterId,
  required Character character,
  required SrdMonster form,
  required FeatureUsageView uses,
  required SrdI18nService i18n,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final rules = WildShapeRules.forCharacter(character);
  final druidLevel = character.classLevel(WildShapeRules.druid);
  final temporary = rules.temporaryHitPointsOnAssume(druidLevel);
  final current = character.hitPoints.temporary;
  final name = i18n.monsterName(form.name);
  final lines = [
    if (uses.isUnlimited)
      l10n.wildShapeConfirmUnlimited
    else
      l10n.wildShapeConfirmUse(uses.current!, uses.current! - 1, uses.max!),
    if (character.wildShape != null) l10n.wildShapeConfirmReplace,
    if (rules.usesBeastHitPoints)
      l10n.wildShapeConfirmFormHp(form.hitPoints)
    else if (temporary > current)
      l10n.wildShapeConfirmTempHp(temporary)
    else
      l10n.wildShapeConfirmTempHpKept(current, temporary),
    l10n.wildShapeConfirmDuration(rules.durationHours(druidLevel)),
    rules.usesBeastHitPoints ? l10n.wildShapeConfirmKeeps2014 : l10n.wildShapeConfirmKeeps2024,
  ];
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.wildShapeConfirmTitle(name)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $line'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.wildShapeConfirm),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await ref.read(characterDetailProvider(characterId).notifier).assumeWildShape(form);
  } on StateError {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wildShapeNoUsesLeft)),
      );
    }
  }
}

class _FormPicker extends ConsumerStatefulWidget {
  const _FormPicker({
    required this.character,
    required this.forms,
    required this.i18n,
  });

  final Character character;
  final List<SrdMonster> forms;
  final SrdI18nService i18n;

  @override
  ConsumerState<_FormPicker> createState() => _FormPickerState();
}

class _FormPickerState extends ConsumerState<_FormPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = ref.watch(unitSystemProvider);
    final i18n = widget.i18n;
    final hasKnownForms =
        WildShapeRules.forCharacter(widget.character) is WildShape2024Rules;
    final query = _query.trim().toLowerCase();
    final forms = [
      for (final form in widget.forms)
        if (query.isEmpty ||
            i18n.monsterName(form.name).toLowerCase().contains(query) ||
            form.name.toLowerCase().contains(query))
          form,
    ]..sort((a, b) => i18n.monsterName(a.name).compareTo(i18n.monsterName(b.name)));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 1,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.wildShapeAssume, style: Theme.of(context).textTheme.titleLarge),
                if (!hasKnownForms) ...[
                  const SizedBox(height: 4),
                  Text(l10n.wildShapeSeenNote),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.wildShapeSearch,
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: forms.length,
              itemBuilder: (context, index) {
                final form = forms[index];
                return ListTile(
                  title: Text(i18n.monsterName(form.name)),
                  subtitle: Text(
                    '${l10n.wildShapeChallengeRating(form.challengeRating)} · '
                    '${l10n.statSpeed} ${monsterSpeedLine(l10n, form.speed, units)}',
                  ),
                  trailing: IconButton(
                    tooltip: l10n.wildShapeStatBlock,
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => showMonsterStatBlockSheet(context, form, i18n),
                  ),
                  onTap: () => Navigator.of(context).pop(form),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveWildShape extends ConsumerWidget {
  const _ActiveWildShape({
    required this.characterId,
    required this.character,
    required this.form,
    required this.i18n,
  });

  final String characterId;
  final Character character;
  final SrdMonster form;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final units = ref.watch(unitSystemProvider);
    final active = character.wildShape!;
    final name = i18n.monsterName(form.name);
    final scores = character.abilityScores;
    // The form replaces Strength, Dexterity and Constitution; the Druid keeps
    // Intelligence, Wisdom and Charisma.
    final abilities = <(String, int)>[
      ('strength', form.score('strength')),
      ('dexterity', form.score('dexterity')),
      ('constitution', form.score('constitution')),
      ('intelligence', scores.intelligence),
      ('wisdom', scores.wisdom),
      ('charisma', scores.charisma),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.wildShapeActive(name), style: theme.textTheme.titleMedium),
                  Text(
                    '${monsterSizeTypeLine(l10n, form)} · '
                    '${l10n.wildShapeChallengeRating(form.challengeRating)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.wildShapeStatBlock,
              icon: const Icon(Icons.menu_book_outlined),
              onPressed: () => showMonsterStatBlockSheet(context, form, i18n),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(label: Text('${l10n.statAC} ${form.armorClass}')),
            if (active.hitPoints != null)
              Chip(
                label: Text(
                  l10n.wildShapeFormHp(active.hitPoints!, active.maxHitPoints ?? active.hitPoints!),
                ),
              ),
            Chip(label: Text('${l10n.statSpeed} ${monsterSpeedLine(l10n, form.speed, units)}')),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          abilities
              .map((a) => '${monsterAbilityShort(l10n, a.$1)} ${a.$2} (${_signed(((a.$2 - 10) / 2).floor())})')
              .join('  '),
          style: theme.textTheme.bodyMedium,
        ),
        Text(l10n.wildShapeScoresNote, style: theme.textTheme.bodySmall),
        if (form.attacks.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(l10n.wildShapeAttacks, style: theme.textTheme.labelLarge),
          for (final attack in form.attacks)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.casino_outlined),
              title: Text(monsterEntryName(i18n, form, _sectionOf(attack), attack)),
              subtitle: Text(_attackSummary(l10n, attack)),
              onTap: () => openContextualRollSheet(
                context,
                characterId: characterId,
                request: _attackRoll(l10n, name, attack),
              ),
            ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _confirmLeave(context, ref, name),
          icon: const Icon(Icons.undo),
          label: Text(l10n.wildShapeLeave),
        ),
      ],
    );
  }

  String _sectionOf(SrdMonsterEntry entry) =>
      form.bonusActions.contains(entry) ? 'bonusActions' : 'actions';

  String _attackSummary(AppLocalizations l10n, SrdMonsterEntry entry) {
    final attack = entry.attack!;
    return [
      _signed(attack.bonus),
      for (final damage in entry.damage)
        '${damage.formula} ${i18n.damageType(damage.type)}',
    ].join(' · ');
  }

  ContextualRollRequest _attackRoll(
    AppLocalizations l10n,
    String formName,
    SrdMonsterEntry entry,
  ) {
    final title = monsterEntryName(i18n, form, _sectionOf(entry), entry);
    return ContextualRollRequest(
      key: 'wild-shape-${form.id}-${entry.id}',
      title: title,
      subtitle: formName,
      parts: [
        ContextualRollPart.d20(label: l10n.wildShapeAttackRoll, d20Modifier: entry.attack!.bonus),
        for (final (index, damage) in entry.damage.indexed)
          ContextualRollPart.expression(
            id: 'damage-$index',
            label: i18n.damageType(damage.type),
            expression: damage.formula,
            critical: true,
          ),
      ],
    );
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref, String name) async {
    final l10n = AppLocalizations.of(context)!;
    final usesBeastHitPoints = character.wildShape?.hitPoints != null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.wildShapeLeaveTitle(name)),
        content: Text(
          usesBeastHitPoints ? l10n.wildShapeLeaveBody2014 : l10n.wildShapeLeaveBody2024,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.wildShapeLeave),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(characterDetailProvider(characterId).notifier).leaveWildShape();
    }
  }
}

String _signed(int value) => value >= 0 ? '+$value' : '$value';
