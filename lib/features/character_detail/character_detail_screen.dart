import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/spellcasting_engine.dart';
import '../../data/constants/level_up_rules.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import 'spell_browser_sheet.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/models/models.dart';
import '../../data/models/domain_constants.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/character_avatar.dart';
import 'character_detail_provider.dart';

part 'tabs/identity_tab.dart';
part 'tabs/stats_tab.dart';
part 'tabs/skills_tab.dart';
part 'tabs/features_tab.dart';
part 'tabs/spells_tab.dart';
part 'tabs/notes_tab.dart';
part 'tabs/inventory_tab.dart';
part 'widgets/detail_widgets.dart';
part 'level_up_wizard.dart';

// â”€â”€ Skill â†’ Ability mapping â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

String _mod(int score) {
  final m = ((score - 10) / 2).floor();
  return m >= 0 ? '+$m' : '$m';
}

String _sign(int n) => n >= 0 ? '+$n' : '$n';

// â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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
                icon: const Icon(Icons.upgrade),
                tooltip: AppLocalizations.of(context)!.tooltipLevelUp,
                onPressed: () => _openLevelUpWizardSheet(
                  context,
                  character,
                  widget.characterId,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.single_bed),
              tooltip: AppLocalizations.of(context)!.detailTooltipLongRest,
              onPressed: () => _confirmLongRest(),
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
            ),
            _StatsTab(
              character: character,
              characterId: widget.characterId,
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
