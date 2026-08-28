import 'package:collection/collection.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/feature_choice_engine.dart';
import '../../../shared/providers/providers.dart';
import '../../character_detail/widgets/feature_choice_editor.dart';
import '../creation_feature_choice_loader.dart';
import '../character_draft_provider.dart';

class StepFeatureChoices extends ConsumerStatefulWidget {
  const StepFeatureChoices({super.key});

  @override
  ConsumerState<StepFeatureChoices> createState() => _StepFeatureChoicesState();
}

class _StepFeatureChoicesState extends ConsumerState<StepFeatureChoices> {
  String? _loadKey;
  Future<CreationFeatureChoiceData>? _future;

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(characterDraftProvider);
    _ensureFuture(draft);

    return FutureBuilder<CreationFeatureChoiceData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(AppLocalizations.of(context)!.featuresLoadError),
          );
        }

        final data = snapshot.data!;
        final i18n = ref.watch(srdI18nProvider).valueOrNull ?? data.i18n;
        _syncRequests(draft, data.requests);

        if (data.requests.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.featureChoicesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(l10n.detailNone),
            ],
          );
        }

        return FeatureChoiceEditor(
          requests: data.requests,
          initialChoices: draft.featureChoices,
          catalog: data.catalog,
          character: data.previewCharacter,
          i18n: i18n,
          skills: data.skills,
          tools: data.tools,
          spells: data.spells,
          languages: data.languages,
          weapons: data.weapons,
          feats: data.feats,
          featureLabelBuilder: (request) =>
              creationFeatureChoiceRequestFeatureLabel(request, i18n),
          onChanged: (choices) {
            ref
                .read(characterDraftProvider.notifier)
                .setFeatureChoices(choices);
          },
        );
      },
    );
  }

  void _ensureFuture(CharacterDraft draft) {
    final key = creationFeatureChoiceDraftKey(draft);
    if (_loadKey == key && _future != null) return;
    _loadKey = key;
    _future = loadCreationFeatureChoiceData(ref, draft);
  }

  void _syncRequests(
    CharacterDraft draft,
    List<FeatureChoiceRequest> requests,
  ) {
    final currentKeys = draft.featureChoiceRequests.map((r) => r.key).toList();
    final nextKeys = requests.map((r) => r.key).toList();
    final sameRequests = const ListEquality<String>().equals(
      currentKeys,
      nextKeys,
    );
    if (draft.featureChoicesLoaded && sameRequests) return;

    final key = _loadKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || key != _loadKey) return;
      ref
          .read(characterDraftProvider.notifier)
          .setFeatureChoiceRequests(requests);
    });
  }
}
