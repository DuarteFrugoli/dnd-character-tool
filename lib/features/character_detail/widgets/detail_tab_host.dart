import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';

class CharacterTabHost<T> extends ConsumerWidget {
  const CharacterTabHost({
    super.key,
    required this.provider,
    required this.builder,
  });

  final ProviderListenable<AsyncValue<T>> provider;
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppLocalizations.of(context)!.detailErrorLoading(error.toString()),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (value) => builder(context, value),
    );
  }
}
