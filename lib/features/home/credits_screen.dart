import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../data/datasources/srd/srd_pack_manifest.dart';
import '../../data/rulesets/ruleset_ids.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/responsive_layout.dart';

/// Credits and the license notices of the bundled SRD packs, read from each
/// pack's manifest.
class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final packs = [
      (l10n.creditsEdition2014, ref.watch(srdManifestForPackProvider(ContentPackId.srd51))),
      (l10n.creditsEdition2024, ref.watch(srdManifestForPackProvider(ContentPackId.srd521))),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.creditsTitle)),
      body: ResponsiveScaffoldBody(
        maxWidth: 720,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 32),
          children: [
            Text(l10n.creditsIntro, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            for (final (edition, manifest) in packs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: manifest.when(
                  data: (value) => _PackCredits(edition: edition, manifest: value),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Text(l10n.creditsUnavailable),
                ),
              ),
            const SizedBox(height: 4),
            Text(l10n.creditsNotAffiliated, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(l10n.creditsCopyright, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PackCredits extends StatelessWidget {
  const _PackCredits({required this.edition, required this.manifest});

  final String edition;
  final SrdPackManifest manifest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(manifest.title, style: theme.textTheme.titleMedium),
            Text(edition, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            SelectableText(manifest.attribution),
            const SizedBox(height: 12),
            SelectableText(
              '${l10n.creditsLicense(manifest.license)}\n${manifest.licenseUrl}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            SelectableText(
              '${l10n.creditsSource}\n${manifest.source}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
