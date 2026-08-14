import 'package:flutter/material.dart';

import '../../../shared/widgets/responsive_layout.dart';
import '../application/character_header_vm.dart';
import 'character_detail_sliver_header.dart';

class CharacterDetailShell extends StatelessWidget {
  const CharacterDetailShell({
    super.key,
    required this.header,
    required this.subtitle,
    required this.tabs,
    required this.children,
    required this.onBack,
    required this.onRollDice,
    required this.onLevelUp,
    required this.onResetLevels,
    required this.onRest,
  });

  final CharacterHeaderVm header;
  final String subtitle;
  final TabController tabs;
  final List<Widget> children;
  final VoidCallback onBack;
  final VoidCallback onRollDice;
  final VoidCallback onLevelUp;
  final VoidCallback onResetLevels;
  final VoidCallback onRest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CharacterDetailSliverHeader(
            header: header,
            subtitle: subtitle,
            tabs: tabs,
            innerBoxIsScrolled: innerBoxIsScrolled,
            onBack: onBack,
            onRollDice: onRollDice,
            onLevelUp: onLevelUp,
            onResetLevels: onResetLevels,
            onRest: onRest,
          ),
        ],
        body: ResponsiveScaffoldBody(
          maxWidth: 1280,
          child: TabBarView(controller: tabs, children: children),
        ),
      ),
    );
  }
}
