import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kUnitSystemKey = 'unit_system';

enum UnitSystem { imperial, metric, squares }

/// Languages whose official D&D books measure in meters. Spanish, Japanese,
/// Korean, Russian, Turkish and Chinese books keep feet, like English.
const _metricLanguages = {'pt', 'fr', 'de', 'it'};

/// The system the official books of [languageCode] use.
UnitSystem officialUnitSystem(String languageCode) =>
    _metricLanguages.contains(languageCode) ? UnitSystem.metric : UnitSystem.imperial;

/// Returns the default [UnitSystem] for the device locale: the one its
/// official books use.
UnitSystem defaultUnitSystem(Locale? locale) => officialUnitSystem(
  locale?.languageCode ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode,
);

class UnitSystemNotifier extends Notifier<UnitSystem> {
  UnitSystemNotifier([this._initial]);
  final UnitSystem? _initial;

  static UnitSystemNotifier withInitial(UnitSystem v) => UnitSystemNotifier(v);

  @override
  UnitSystem build() =>
      _initial ??
      defaultUnitSystem(WidgetsBinding.instance.platformDispatcher.locale);

  Future<void> setUnitSystem(UnitSystem v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUnitSystemKey, v.name);
  }
}

final unitSystemProvider = NotifierProvider<UnitSystemNotifier, UnitSystem>(
  UnitSystemNotifier.new,
);
