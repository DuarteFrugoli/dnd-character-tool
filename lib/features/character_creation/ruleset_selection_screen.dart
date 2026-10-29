import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RulesetSelectionScreen extends StatelessWidget {
  const RulesetSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.creationRulesetTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(l10n.creationRuleset2014),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/create/2014'),
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories_outlined),
            title: Text(l10n.creationRuleset2024),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/create/2024'),
          ),
        ],
      ),
    );
  }
}
