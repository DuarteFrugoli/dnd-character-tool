import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class CharacterDetailTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CharacterDetailTabBar({super.key, required this.controller});

  static const height = kTextTabBarHeight;

  final TabController controller;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final tabBarBackground = Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.07),
      scheme.surface,
    );
    final indicatorColor = Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.22),
      scheme.surfaceContainerHighest,
    );

    return Material(
      color: tabBarBackground,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: scheme.primary.withValues(alpha: 0.16)),
            bottom: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: SizedBox(
          height: height,
          child: TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            labelColor: scheme.onSurface,
            unselectedLabelColor: scheme.onSurfaceVariant,
            labelStyle: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            unselectedLabelStyle: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            labelPadding: const EdgeInsets.symmetric(horizontal: 14),
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 7,
            ),
            indicator: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.38)),
            ),
            overlayColor: WidgetStatePropertyAll(
              scheme.primary.withValues(alpha: 0.08),
            ),
            tabs: [
              Tab(text: l10n.detailTabIdentity),
              Tab(text: l10n.detailTabStats),
              Tab(text: l10n.detailTabSkills),
              Tab(text: l10n.detailTabFeatures),
              Tab(text: l10n.detailTabSpells),
              Tab(text: l10n.detailTabInventory),
              Tab(text: l10n.detailTabNotes),
            ],
          ),
        ),
      ),
    );
  }
}
