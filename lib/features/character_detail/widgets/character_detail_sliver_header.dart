import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/character_avatar.dart';
import '../application/character_header_vm.dart';
import 'character_detail_tab_bar.dart';

class CharacterDetailSliverHeader extends StatelessWidget {
  const CharacterDetailSliverHeader({
    super.key,
    required this.header,
    required this.subtitle,
    required this.tabs,
    required this.innerBoxIsScrolled,
    required this.onBack,
    required this.onRollDice,
    required this.onLevelUp,
    required this.onResetLevels,
    required this.onRest,
    required this.onImageChanged,
  });

  final CharacterHeaderVm header;
  final String subtitle;
  final TabController tabs;
  final bool innerBoxIsScrolled;
  final VoidCallback onBack;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onResetLevels;
  final VoidCallback onRest;
  final ValueChanged<String?> onImageChanged;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 700;
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      toolbarHeight: 0,
      expandedHeight: isCompact ? 144 : 160,
      automaticallyImplyLeading: false,
      forceElevated: innerBoxIsScrolled,
      flexibleSpace: _CharacterDetailFlexibleHeader(
        header: header,
        subtitle: subtitle,
        onBack: onBack,
        onRollDice: onRollDice,
        onLevelUp: onLevelUp,
        onResetLevels: onResetLevels,
        onRest: onRest,
        onImageChanged: onImageChanged,
      ),
      bottom: CharacterDetailTabBar(controller: tabs),
    );
  }
}

enum _CharacterHeaderAction { rollDice, levelUp, resetLevels, rest }

class _CharacterDetailFlexibleHeader extends StatelessWidget {
  const _CharacterDetailFlexibleHeader({
    required this.header,
    required this.subtitle,
    required this.onBack,
    required this.onRollDice,
    required this.onLevelUp,
    required this.onResetLevels,
    required this.onRest,
    required this.onImageChanged,
  });

  final CharacterHeaderVm header;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onResetLevels;
  final VoidCallback onRest;
  final ValueChanged<String?> onImageChanged;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final current = settings?.currentExtent ?? 1;
    final min = settings?.minExtent ?? CharacterDetailTabBar.height;
    final max = settings?.maxExtent ?? current;
    final rawProgress = max == min ? 1.0 : (current - min) / (max - min);
    final progress = rawProgress.clamp(0.0, 1.0).toDouble();
    final verticalOffset = (1 - progress) * -12;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                scheme.primary.withValues(alpha: 0.20),
                scheme.surface,
              ),
              Color.alphaBlend(
                scheme.secondary.withValues(alpha: 0.10),
                scheme.surface,
              ),
              scheme.surface,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: CharacterDetailTabBar.height,
              height: 1,
              child: ColoredBox(color: scheme.primary.withValues(alpha: 0.28)),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: CharacterDetailTabBar.height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final topInset = MediaQuery.paddingOf(context).top;
                  final usableHeight = constraints.maxHeight - topInset - 8;
                  const minUsableHeaderContentHeight = 64.0;
                  if (usableHeight < minUsableHeaderContentHeight) {
                    return const SizedBox.shrink();
                  }

                  final heightProgress =
                      ((usableHeight - minUsableHeaderContentHeight) / 32)
                          .clamp(0.0, 1.0)
                          .toDouble();
                  final opacity = Curves.easeOutCubic.transform(
                    progress * heightProgress,
                  );

                  return ClipRect(
                    child: IgnorePointer(
                      ignoring: opacity < 0.05,
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, verticalOffset),
                          child: _ExpandedHeaderContent(
                            header: header,
                            subtitle: subtitle,
                            onBack: onBack,
                            onRollDice: onRollDice,
                            onLevelUp: onLevelUp,
                            onResetLevels: onResetLevels,
                            onRest: onRest,
                            onImageChanged: onImageChanged,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedHeaderContent extends StatelessWidget {
  const _ExpandedHeaderContent({
    required this.header,
    required this.subtitle,
    required this.onBack,
    required this.onRollDice,
    required this.onLevelUp,
    required this.onResetLevels,
    required this.onRest,
    required this.onImageChanged,
  });

  final CharacterHeaderVm header;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onResetLevels;
  final VoidCallback onRest;
  final ValueChanged<String?> onImageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.72),
                foregroundColor: theme.colorScheme.onSurface,
              ),
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
            _CharacterHeaderAvatar(
              header: header,
              onImageChanged: onImageChanged,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxHeight < 56) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 4),
            _CharacterActionMenu(
              xpTrackingEnabled: header.xpTrackingEnabled,
              onRollDice: onRollDice,
              onLevelUp: onLevelUp,
              onResetLevels: onResetLevels,
              onRest: onRest,
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterHeaderAvatar extends StatelessWidget {
  const _CharacterHeaderAvatar({
    required this.header,
    required this.onImageChanged,
  });

  final CharacterHeaderVm header;
  final ValueChanged<String?> onImageChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.16),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CharacterAvatar(
        name: header.name,
        imagePath: header.imagePath,
        radius: 22,
        heroTag: 'character_avatar_${header.id}',
        onImageChanged: onImageChanged,
      ),
    );
  }
}

class _CharacterActionMenu extends StatelessWidget {
  const _CharacterActionMenu({
    required this.xpTrackingEnabled,
    required this.onRollDice,
    required this.onLevelUp,
    required this.onResetLevels,
    required this.onRest,
  });

  final bool xpTrackingEnabled;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onResetLevels;
  final VoidCallback onRest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<_CharacterHeaderAction>(
      icon: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.42)),
        ),
        child: Icon(Icons.more_vert, color: scheme.primary),
      ),
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      onSelected: (action) {
        switch (action) {
          case _CharacterHeaderAction.rollDice:
            onRollDice();
            return;
          case _CharacterHeaderAction.levelUp:
            onLevelUp();
            return;
          case _CharacterHeaderAction.resetLevels:
            onResetLevels();
            return;
          case _CharacterHeaderAction.rest:
            onRest();
            return;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _CharacterHeaderAction.rollDice,
          child: _CharacterActionMenuItem(
            icon: Icons.casino_outlined,
            label: l10n.characterActionRollDice,
          ),
        ),
        const PopupMenuDivider(),
        if (!xpTrackingEnabled)
          PopupMenuItem(
            value: _CharacterHeaderAction.levelUp,
            child: _CharacterActionMenuItem(
              icon: Icons.keyboard_double_arrow_up,
              label: l10n.tooltipLevelUp,
            ),
          ),
        PopupMenuItem(
          value: _CharacterHeaderAction.rest,
          child: _CharacterActionMenuItem(
            icon: Icons.hotel_outlined,
            label: l10n.restPickerTitle,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _CharacterHeaderAction.resetLevels,
          child: _CharacterActionMenuItem(
            icon: Icons.restart_alt,
            label: l10n.characterActionResetLevels,
          ),
        ),
      ],
    );
  }
}

class _CharacterActionMenuItem extends StatelessWidget {
  const _CharacterActionMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
    );
  }
}
