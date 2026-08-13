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
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [
        Tab(text: l10n.detailTabIdentity),
        Tab(text: l10n.detailTabStats),
        Tab(text: l10n.detailTabSkills),
        Tab(text: l10n.detailTabFeatures),
        Tab(text: l10n.detailTabSpells),
        Tab(text: l10n.detailTabInventory),
        Tab(text: l10n.detailTabNotes),
      ],
    );
  }
}
