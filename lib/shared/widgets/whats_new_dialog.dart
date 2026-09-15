import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

Future<void> showWhatsNewDialog(
  BuildContext context, {
  required String version,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _WhatsNewDialog(version: version),
  );
}

class _WhatsNewDialog extends StatelessWidget {
  const _WhatsNewDialog({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final media = MediaQuery.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: media.size.height * 0.86,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primaryContainer,
                      Color.alphaBlend(
                        cs.tertiary.withValues(alpha: 0.28),
                        cs.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Icon(
                          Icons.campaign_outlined,
                          color: cs.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.whatsNewTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.whatsNewVersionSubtitle(version),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onPrimaryContainer.withValues(
                                  alpha: 0.78,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Text(
                  l10n.whatsNewIntro,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
              _WhatsNewItem(
                icon: Icons.casino_outlined,
                title: l10n.whatsNewContextualRollsTitle,
                body: l10n.whatsNewContextualRollsBody,
              ),
              _WhatsNewItem(
                icon: Icons.adjust_outlined,
                title: l10n.whatsNewCriticalsTitle,
                body: l10n.whatsNewCriticalsBody,
              ),
              _WhatsNewItem(
                icon: Icons.verified_user_outlined,
                title: l10n.whatsNewConfirmationsTitle,
                body: l10n.whatsNewConfirmationsBody,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.whatsNewDone),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhatsNewItem extends StatelessWidget {
  const _WhatsNewItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 21, color: cs.onSecondaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
