part of '../../character_detail_screen.dart';

class _SpellcastingBanner extends StatelessWidget {
  const _SpellcastingBanner({
    required this.engine,
    this.preparedCount,
    this.maxPrepared,
    this.knownCount,
    this.maxKnown,
    required this.cantripCount,
  });

  final SpellcastingEngine engine;
  final int? preparedCount;
  final int? maxPrepared;
  final int? knownCount;
  final int? maxKnown;
  final int cantripCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final ability = switch (engine.spellcastingAbility.toUpperCase()) {
      'INT' => l10n.abilityInt,
      'WIS' => l10n.abilityWis,
      'CHA' => l10n.abilityCha,
      _ => engine.spellcastingAbility.toUpperCase(),
    };
    final modStr = engine.abilityModifier >= 0
        ? '+${engine.abilityModifier}'
        : '${engine.abilityModifier}';

    return Card(
      color: scheme.primaryContainer.withAlpha(80),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.spellsSpellcasting} · $ability ($modStr)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _BannerStat(l10n.spellsAttack, engine.spellAttackFormatted),
                _BannerStat(l10n.spellsSaveDC, '${engine.saveDC}'),
                if (engine.maxCantrips > 0)
                  _BannerStat(
                    l10n.spellsCantrips,
                    '$cantripCount / ${engine.maxCantrips}',
                    warning: cantripCount > engine.maxCantrips,
                  ),
                if (preparedCount != null && maxPrepared != null)
                  _BannerStat(
                    l10n.spellsPrepared,
                    '$preparedCount / $maxPrepared',
                    warning: preparedCount! > maxPrepared!,
                  )
                else if (knownCount != null)
                  _BannerStat(
                    l10n.spellsKnown,
                    maxKnown != null
                        ? '$knownCount / $maxKnown'
                        : '$knownCount',
                    warning: maxKnown != null && knownCount! > maxKnown!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  const _BannerStat(this.label, this.value, {this.warning = false});
  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: warning ? scheme.error : null,
          ),
        ),
      ],
    );
  }
}

// ── Spell Level Header ────────────────────────────────────────────────────────

class _SpellLevelHeader extends StatelessWidget {
  const _SpellLevelHeader({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        level == 0
            ? AppLocalizations.of(context)!.spellsCantrips
            : AppLocalizations.of(context)!.spellsLevelN(level),
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Spell Row ─────────────────────────────────────────────────────────────────

class _SpellRow extends ConsumerWidget {
  const _SpellRow({
    required this.spell,
    required this.srdSpell,
    required this.showPrepareToggle,
    required this.onTogglePrepared,
    required this.onTap,
    this.isDisabled = false,
    this.onLongPress,
    this.characterId,
    this.concentrationSpell,
    required this.i18n,
  });

  final KnownSpell spell;
  final SrdSpell? srdSpell;
  final bool showPrepareToggle;
  final VoidCallback onTogglePrepared;
  final VoidCallback onTap;
  final bool isDisabled;
  final VoidCallback? onLongPress;

  /// Passed when concentration tracking is enabled (non-null characterId).
  final String? characterId;

  /// The currently active concentration spell name (from character state).
  final String? concentrationSpell;
  final SrdI18nService i18n;

  static Color _schoolColor(String school) {
    switch (school.toLowerCase()) {
      case 'evocation':
        return Colors.deepOrange;
      case 'abjuration':
        return Colors.blue;
      case 'conjuration':
        return Colors.amber;
      case 'divination':
        return Colors.cyan;
      case 'enchantment':
        return Colors.purple;
      case 'illusion':
        return Colors.indigo;
      case 'necromancy':
        return Colors.green;
      case 'transmutation':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  static String _schoolAbbr(String school) {
    switch (school.toLowerCase()) {
      case 'evocation':
        return 'Evoc';
      case 'abjuration':
        return 'Abj';
      case 'conjuration':
        return 'Conj';
      case 'divination':
        return 'Div';
      case 'enchantment':
        return 'Ench';
      case 'illusion':
        return 'Illu';
      case 'necromancy':
        return 'Necro';
      case 'transmutation':
        return 'Trans';
      default:
        return school;
    }
  }

  static IconData _castingTimeIcon(String type) {
    switch (type) {
      case 'bonus_action':
        return Icons.flash_on;
      case 'reaction':
        return Icons.rotate_left;
      case 'minute':
      case 'hour':
      case 'special':
        return Icons.timer_outlined;
      default:
        return Icons.bolt;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final srd = srdSpell;
    final isPrepared = spell.isPrepared || spell.isAlwaysPrepared;
    // Dimmed: DM-disabled always, or not-prepared in a prepare class
    final dimmed = isDisabled || (showPrepareToggle && !isPrepared);

    Widget card = Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Prepare toggle or always-prepared icon
              if (showPrepareToggle) ...[
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onTogglePrepared,
                    child: Icon(
                      spell.isPrepared
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: spell.isPrepared
                          ? scheme.primary
                          : scheme.outlineVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (spell.isAlwaysPrepared) ...[
                Icon(Icons.auto_fix_high, size: 18, color: scheme.tertiary),
                const SizedBox(width: 8),
              ],

              // Name
              Expanded(
                child: Text(
                  i18n.spellName(spell.name),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: dimmed ? scheme.onSurfaceVariant : null,
                  ),
                ),
              ),

              // School badge
              if (srd != null) ...[
                const SizedBox(width: 4),
                _SchoolBadge(
                  label: _schoolAbbr(srd.school),
                  color: _schoolColor(srd.school),
                ),
              ],

              // Casting time icon
              if (srd != null) ...[
                const SizedBox(width: 6),
                Icon(
                  _castingTimeIcon(srd.castingTimeType),
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ],

              // Concentration badge + icon
              if (srd?.concentration == true) ...[
                const SizedBox(width: 4),
                _SmallBadge('C', scheme.secondary),
                if (characterId != null) ...[
                  const SizedBox(width: 2),
                  Builder(builder: (ctx) {
                    final isActive = concentrationSpell == spell.name;
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _onConcentrationTap(
                          ctx,
                          ref,
                          spell.name,
                          concentrationSpell,
                          characterId!,
                          i18n,
                        ),
                        child: Tooltip(
                          message: AppLocalizations.of(
                            ctx,
                          )!.concentrationTooltip,
                          child: Icon(
                            isActive ? Icons.gps_fixed : Icons.gps_not_fixed,
                            size: 16,
                            color: isActive
                                ? scheme.primary
                                : scheme.outlineVariant,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],

              // Ritual badge
              if (srd?.ritual == true) ...[
                const SizedBox(width: 4),
                _SmallBadge('R', scheme.tertiary),
              ],
            ],
          ),
        ),
      ),
    );

    if (isDisabled) {
      card = Opacity(opacity: 0.35, child: card);
    }

    return card;
  }
}

class _SchoolBadge extends StatelessWidget {
  const _SchoolBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      border: Border.all(color: color.withAlpha(100)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withAlpha(40),
      border: Border.all(color: color.withAlpha(150)),
    ),
    child: Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ),
  );
}

// ── Concentration helpers ─────────────────────────────────────────────────────

Future<void> _onConcentrationTap(
  BuildContext context,
  WidgetRef ref,
  String spellName,
  String? currentConcentration,
  String characterId,
  SrdI18nService i18n,
) async {
  final notifier = ref.read(characterDetailProvider(characterId).notifier);
  if (currentConcentration == spellName) {
    // Toggle off — already concentrating on this spell
    await notifier.setConcentration(null);
    return;
  }
  if (currentConcentration == null) {
    // No active concentration — set directly
    await notifier.setConcentration(spellName);
    return;
  }
  // Already concentrating on a different spell — confirm switch
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.concentrationReplaceTitle),
      content: Text(
        l10n.concentrationReplaceBody(
          i18n.spellName(currentConcentration),
          i18n.spellName(spellName),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.concentrationReplaceConfirm),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await notifier.setConcentration(spellName);
  }
}

// ── Concentration Banner ──────────────────────────────────────────────────────

class _ConcentrationBanner extends StatelessWidget {
  const _ConcentrationBanner({
    required this.spellName,
    required this.i18n,
    required this.onBreak,
  });

  final String spellName;
  final SrdI18nService i18n;
  final VoidCallback onBreak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.gps_fixed, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.concentrationBannerLabel} ${i18n.spellName(spellName)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: onBreak,
              style: TextButton.styleFrom(
                foregroundColor: scheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.concentrationBreakButton),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Innate Spell Row ──────────────────────────────────────────────────────────

class _InnateSpellRow extends StatelessWidget {
  const _InnateSpellRow({
    required this.spell,
    required this.i18n,
    required this.onUse,
    this.onTap,
  });

  final InnateSpell spell;
  final SrdI18nService i18n;
  final VoidCallback? onUse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.auto_fix_high_outlined, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                i18n.spellName(spell.name),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (spell.isAtWill)
              Chip(
                label: Text(AppLocalizations.of(context)!.spellsAtWill),
                side: BorderSide.none,
                backgroundColor: scheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: scheme.onSecondaryContainer,
                  fontSize: 11,
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            else ...[
              Text(
                '${spell.remaining}/${spell.usesPerDay}/dia',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(width: 6),
              ...List.generate(spell.usesPerDay!, (i) {
                final isUsed = i >= spell.remaining;
                return MouseRegion(
                  cursor: isUsed ? MouseCursor.defer : SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: isUsed ? null : onUse,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUsed ? null : scheme.primaryContainer,
                        border: Border.all(
                          color: isUsed ? scheme.outlineVariant : scheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
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

// ── Spell Slot Row ────────────────────────────────────────────────────────────

class _SpellSlotRow extends StatelessWidget {
  const _SpellSlotRow({
    required this.level,
    required this.total,
    required this.used,
    required this.onUse,
    required this.onRestore,
  });

  final int level;
  final int total;
  final int used;
  final VoidCallback onUse;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final remaining = total - used;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              l10n.spellsSlotLevel(level),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 4,
              children: List.generate(total, (i) {
                final isUsed = i >= remaining;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: isUsed ? onRestore : onUse,
                    child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUsed ? null : scheme.primaryContainer,
                      border: Border.all(
                        color: isUsed ? scheme.outlineVariant : scheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  ),
                );
              }),
            ),
          ),
          Text(
            '$remaining/$total',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
