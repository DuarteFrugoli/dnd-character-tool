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
    this.onConvert2024,
    required this.onRest,
    required this.onImageChanged,
  });

  final CharacterHeaderVm header;
  final String subtitle;
  final TabController tabs;
  final List<Widget> children;
  final VoidCallback onBack;
  final VoidCallback onRollDice;
  final VoidCallback? onLevelUp;
  final VoidCallback? onResetLevels;

  /// Converts a 2014 sheet into a new 2024 sheet.
  final VoidCallback? onConvert2024;
  final VoidCallback? onRest;
  final ValueChanged<String?> onImageChanged;

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
            onConvert2024: onConvert2024,
            onRest: onRest,
            onImageChanged: onImageChanged,
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
