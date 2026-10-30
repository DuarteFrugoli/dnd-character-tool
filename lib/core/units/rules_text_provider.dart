import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locale/locale_provider.dart';
import 'distance_markup.dart';
import 'unit_system_provider.dart';

/// Renders the distance markers of rules text (SRD descriptions, their
/// translations and the copies saved on sheets) for the app language and
/// the unit preference.
final rulesTextProvider = Provider<String Function(String)>((ref) {
  final system = ref.watch(unitSystemProvider);
  final languageCode =
      ref.watch(localeProvider)?.languageCode ??
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return (text) => DistanceMarkup.render(text, languageCode: languageCode, system: system);
});
