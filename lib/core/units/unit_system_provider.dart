import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kUnitSystemKey = 'unit_system';

enum UnitSystem { imperial, metric, squares }

/// Returns the default [UnitSystem] based on the device locale.
/// English locale → Imperial; everything else → Metric.
UnitSystem defaultUnitSystem(Locale? locale) {
  final code = locale?.languageCode ??
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return code == 'en' ? UnitSystem.imperial : UnitSystem.metric;
}

class UnitSystemNotifier extends Notifier<UnitSystem> {
  UnitSystemNotifier([this._initial]);
  final UnitSystem? _initial;

  static UnitSystemNotifier withInitial(UnitSystem v) =>
      UnitSystemNotifier(v);

  @override
  UnitSystem build() =>
      _initial ??
      defaultUnitSystem(
        WidgetsBinding.instance.platformDispatcher.locale,
      );

  Future<void> setUnitSystem(UnitSystem v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUnitSystemKey, v.name);
  }
}

final unitSystemProvider =
    NotifierProvider<UnitSystemNotifier, UnitSystem>(UnitSystemNotifier.new);
