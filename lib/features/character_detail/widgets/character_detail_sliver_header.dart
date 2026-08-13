import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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
    required this.onRest,
  });

  final CharacterHeaderVm header;
  final String subtitle;
  final TabController tabs;
  final bool innerBoxIsScrolled;
  final VoidCallback onBack;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onRest;

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
        onRest: onRest,
      ),
      bottom: CharacterDetailTabBar(controller: tabs),
    );
  }
}

enum _CharacterHeaderAction { rollDice, levelUp, rest }

class _CharacterDetailFlexibleHeader extends StatelessWidget {
  const _CharacterDetailFlexibleHeader({
    required this.header,
    required this.subtitle,
    required this.onBack,
    required this.onRollDice,
    required this.onLevelUp,
    required this.onRest,
  });

  final CharacterHeaderVm header;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onRest;

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

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
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
                          onRest: onRest,
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
    required this.onRest,
  });

  final CharacterHeaderVm header;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onRest;

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
              onPressed: onBack,
            ),
            const SizedBox(width: 4),
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
              onRest: onRest,
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterActionMenu extends StatelessWidget {
  const _CharacterActionMenu({
    required this.xpTrackingEnabled,
    required this.onRollDice,
    required this.onLevelUp,
    required this.onRest,
  });

  final bool xpTrackingEnabled;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onRest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<_CharacterHeaderAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      onSelected: (action) {
        switch (action) {
          case _CharacterHeaderAction.rollDice:
            onRollDice();
            return;
          case _CharacterHeaderAction.levelUp:
            onLevelUp();
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
