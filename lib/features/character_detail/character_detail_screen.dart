import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';

import '../../data/spellcasting_engine.dart';
import '../../data/feature_choice_engine.dart';
import '../../data/feature_choice_option_resolver.dart';
import '../../data/feature_usage_engine.dart';
import '../../data/constants/armor_class.dart';
import '../../data/constants/level_up_rules.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import 'spell_browser_sheet.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/models/models.dart';
import '../../data/models/domain_constants.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/character_avatar.dart';
import '../../core/units/unit_system_provider.dart';
import '../../core/units/unit_formatter.dart';
import 'character_detail_provider.dart';
import 'widgets/feature_choice_editor.dart';

part 'tabs/identity_tab.dart';
part 'tabs/stats_tab.dart';
part 'tabs/skills_tab.dart';
part 'tabs/features_tab.dart';
part 'tabs/spells_tab.dart';
part 'tabs/notes_tab.dart';
part 'tabs/inventory_tab.dart';
part 'widgets/detail_widgets.dart';
part 'level_up_wizard.dart';

// ── Skill → Ability mapping ───────────────────────────────────────────────────

const _skillAbility = <String, String>{
  'Acrobatics': 'Dexterity',
  'Animal Handling': 'Wisdom',
  'Arcana': 'Intelligence',
  'Athletics': 'Strength',
  'Deception': 'Charisma',
  'History': 'Intelligence',
  'Insight': 'Wisdom',
  'Intimidation': 'Charisma',
  'Investigation': 'Intelligence',
  'Medicine': 'Wisdom',
  'Nature': 'Intelligence',
  'Perception': 'Wisdom',
  'Performance': 'Charisma',
  'Persuasion': 'Charisma',
  'Religion': 'Intelligence',
  'Sleight of Hand': 'Dexterity',
  'Stealth': 'Dexterity',
  'Survival': 'Wisdom',
};

// ── Helpers ───────────────────────────────────────────────────────────────────

String _mod(int score) {
  final m = ((score - 10) / 2).floor();
  return m >= 0 ? '+$m' : '$m';
}

String _sign(int n) => n >= 0 ? '+$n' : '$n';

// ── Edit Guard ─────────────────────────────────────────────────────────────────
// Shared object that lets the tab screen know when a child tab is in edit mode
// and request a discard-confirmation before allowing the tab to change.

class _EditGuard {
  /// True when any tab is in edit mode.
  bool get isEditing => _discardFn != null;

  /// Registered by the tab that enters edit mode. Called only after confirmation.
  Future<void> Function()? _discardFn;

  void register(Future<void> Function() discardFn) {
    _discardFn = discardFn;
  }

  void unregister() {
    _discardFn = null;
  }

  /// Shows a discard-confirmation dialog, then calls the tab's discard function.
  /// Returns true if the user confirmed (tab exited edit mode), false otherwise.
  Future<bool> requestCancel(BuildContext context, AppLocalizations l10n) async {
    final fn = _discardFn;
    if (fn == null) return true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.detailCancelEditTitle),
        content: Text(l10n.detailCancelEditContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.dialogDiscard),
          ),
        ],
      ),
    );
    if (confirm != true) return false;
    await fn();
    return true;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CharacterDetailScreen extends ConsumerStatefulWidget {
  const CharacterDetailScreen({super.key, required this.characterId});
  final String characterId;

  @override
  ConsumerState<CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _editGuard = _EditGuard();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    _tabs.addListener(_onTabChanging);
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanging);
    _tabs.dispose();
    super.dispose();
  }

  int _lastTabIndex = 0;
  bool _isIntercepting = false;

  void _onTabChanging() {
    // Only act when the tab index actually changes (not animation updates).
    if (!_tabs.indexIsChanging) return;
    // Prevent re-entry: animateTo(_lastTabIndex) below re-triggers this listener.
    if (_isIntercepting) return;
    if (!_editGuard.isEditing) {
      _lastTabIndex = _tabs.index;
      return;
    }
    // A tab is in edit mode — intercept the change.
    final targetIndex = _tabs.index;
    _isIntercepting = true;
    // Jump back to the editing tab immediately (before the animation settles).
    _tabs.animateTo(_lastTabIndex);
    // Then ask the tab to confirm discard asynchronously.
    final l10n = AppLocalizations.of(context)!;
    _editGuard.requestCancel(context, l10n).then((discarded) {
      _isIntercepting = false;
      if (discarded && mounted) {
        _lastTabIndex = targetIndex;
        _tabs.animateTo(targetIndex);
      }
    });
  }

  void _goBack() => context.canPop() ? context.pop() : context.go('/');

  Future<void> _handleBack() async {
    _goBack();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterDetailProvider(widget.characterId));
    return state.when(
      loading: () => Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: _handleBack)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _handleBack),
          title: const Text('Character'),
        ),
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.detailErrorLoading(e.toString()),
          ),
        ),
      ),
      data: _buildLoaded,
    );
  }

  Widget _buildLoaded(Character character) {
    final i18n =
        ref.watch(srdI18nProvider).valueOrNull ?? SrdI18nService.english;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          leading: BackButton(onPressed: _handleBack),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                character.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${i18n.className(character.characterClass)}${character.subclass != null ? ' (${i18n.subclassName(character.characterClass, character.subclass!)})' : ''}  ·  ${i18n.raceName(character.race)}'
                '${character.subrace != null ? ' (${i18n.subraceName(character.subrace!)})' : ''}'
                '  ·  Lv ${character.level}',
                maxLines: 2,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            if (!character.xpTrackingEnabled)
              IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_up),
                tooltip: AppLocalizations.of(context)!.tooltipLevelUp,
                onPressed: () => _openLevelUpWizardSheet(
                  context,
                  character,
                  widget.characterId,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.hotel_outlined),
              tooltip: AppLocalizations.of(context)!.restPickerTitle,
              onPressed: () => _showRestPicker(character),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.detailTabIdentity),
              Tab(text: AppLocalizations.of(context)!.detailTabStats),
              Tab(text: AppLocalizations.of(context)!.detailTabSkills),
              Tab(text: AppLocalizations.of(context)!.detailTabFeatures),
              Tab(text: AppLocalizations.of(context)!.detailTabSpells),
              Tab(text: AppLocalizations.of(context)!.detailTabInventory),
              Tab(text: AppLocalizations.of(context)!.detailTabNotes),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _IdentityTab(
              character: character,
              characterId: widget.characterId,
              editGuard: _editGuard,
            ),
            _StatsTab(
              character: character,
              characterId: widget.characterId,
              editGuard: _editGuard,
            ),
            _SkillsTab(
              character: character,
              characterId: widget.characterId,
            ),
            _FeaturesTab(
              character: character,
              characterId: widget.characterId,
            ),
            _SpellsTab(character: character, characterId: widget.characterId),
            _InventoryTab(
              character: character,
              characterId: widget.characterId,
            ),
            _NotesTab(character: character, characterId: widget.characterId),
          ],
        ),
    );
  }

  void _showRestPicker(Character character) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.restPickerTitle,
                  style: Theme.of(ctx).textTheme.titleMedium),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: Text(l10n.restPickerShort),
              subtitle: Text(l10n.restPickerShortCaption),
              onTap: () {
                Navigator.pop(ctx);
                _showShortRestDialog(character);
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel_outlined),
              title: Text(l10n.restPickerLong),
              subtitle: Text(l10n.restPickerLongCaption),
              onTap: () {
                Navigator.pop(ctx);
                _confirmLongRest();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showShortRestDialog(Character character) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(characterDetailProvider(widget.characterId).notifier);

    // Fetch hit die from SRD
    final classes = await ref.read(srdDataSourceProvider).getClasses();
    final srdClass = classes.firstWhereOrNull((c) => c.name == character.characterClass);
    final hitDie = srdClass?.hitDie ?? 8;
    final conMod = (character.abilityScores.constitution - 10) ~/ 2;
    final available = character.level - character.hitPoints.hitDiceUsed;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => _ShortRestDialog(
        l10n: l10n,
        hitDie: hitDie,
        conMod: conMod,
        availableHd: available,
        maxHp: character.hitPoints.maximum,
        currentHp: character.hitPoints.current,
        onConfirm: (hdSpent, hpGained) async {
          await notifier.shortRest(hdSpent: hdSpent, hpGained: hpGained);
        },
      ),
    );
  }

  Future<void> _confirmLongRest() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.longRestTitle),
        content: Text(l10n.longRestContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.longRestButton),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(characterDetailProvider(widget.characterId).notifier)
          .longRest();
    }
  }
}

// ── Short Rest Dialog ─────────────────────────────────────────────────────────

class _ShortRestDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final int hitDie;
  final int conMod;
  final int availableHd;
  final int maxHp;
  final int currentHp;
  final Future<void> Function(int hdSpent, int hpGained) onConfirm;

  const _ShortRestDialog({
    required this.l10n,
    required this.hitDie,
    required this.conMod,
    required this.availableHd,
    required this.maxHp,
    required this.currentHp,
    required this.onConfirm,
  });

  @override
  State<_ShortRestDialog> createState() => _ShortRestDialogState();
}

class _ShortRestDialogState extends State<_ShortRestDialog> {
  int _hdToSpend = 1;
  int _rolledHp = 0;
  bool _hasRolled = false;

  void _roll() {
    final rng = math.Random();
    int total = 0;
    for (int i = 0; i < _hdToSpend; i++) {
      total += rng.nextInt(widget.hitDie) + 1;
    }
    total += widget.conMod * _hdToSpend;
    setState(() {
      _rolledHp = total.clamp(0, widget.maxHp - widget.currentHp);
      _hasRolled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final scheme = Theme.of(context).colorScheme;
    final noDice = widget.availableHd <= 0;

    return AlertDialog(
      title: Text(l10n.shortRestTitle),
      content: noDice
          ? Text(l10n.shortRestNoDice)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.shortRestAvailableDice}: ${widget.availableHd} d${widget.hitDie}'
                  '${widget.conMod >= 0 ? ' (+${widget.conMod} CON)' : ' (${widget.conMod} CON)'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Stepper
                Row(
                  children: [
                    Text('${l10n.shortRestSpend}: '),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _hdToSpend > 1
                          ? () => setState(() {
                                _hdToSpend--;
                                _hasRolled = false;
                              })
                          : null,
                    ),
                    Text('$_hdToSpend',
                        style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _hdToSpend < widget.availableHd
                          ? () => setState(() {
                                _hdToSpend++;
                                _hasRolled = false;
                              })
                          : null,
                    ),
                  ],
                ),
                if (_hasRolled) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.shortRestRolled}: +$_rolledHp HP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.primary),
                  ),
                ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogCancel),
        ),
        if (!noDice && !_hasRolled)
          FilledButton(
            onPressed: _roll,
            child: Text(l10n.shortRestRollButton),
          ),
        if (!noDice && _hasRolled)
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.onConfirm(_hdToSpend, _rolledHp);
            },
            child: Text(l10n.shortRestButton),
          ),
        ],
    );
  }
}
