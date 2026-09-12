import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/dice/dice.dart';

const contextualRollAskBeforeRollingPrefsKey =
    'contextual_roll_ask_before_rolling';
const contextualRollCriticalModePrefsKey = 'contextual_roll_critical_mode';

class ContextualRollPreferences {
  const ContextualRollPreferences({
    this.askBeforeRolling = true,
    this.criticalMode = ContextualCriticalMode.doubleDice,
  });

  final bool askBeforeRolling;
  final ContextualCriticalMode criticalMode;

  ContextualRollPreferences copyWith({
    bool? askBeforeRolling,
    ContextualCriticalMode? criticalMode,
  }) {
    return ContextualRollPreferences(
      askBeforeRolling: askBeforeRolling ?? this.askBeforeRolling,
      criticalMode: criticalMode ?? this.criticalMode,
    );
  }
}

final contextualRollPreferencesProvider =
    NotifierProvider<
      ContextualRollPreferencesNotifier,
      ContextualRollPreferences
    >(ContextualRollPreferencesNotifier.new);

class ContextualRollPreferencesNotifier
    extends Notifier<ContextualRollPreferences> {
  ContextualRollPreferencesNotifier([this._initial]);

  final ContextualRollPreferences? _initial;

  static ContextualRollPreferencesNotifier withInitial(
    ContextualRollPreferences preferences,
  ) => ContextualRollPreferencesNotifier(preferences);

  @override
  ContextualRollPreferences build() =>
      _initial ?? const ContextualRollPreferences();

  Future<void> setAskBeforeRolling(bool value) async {
    state = state.copyWith(askBeforeRolling: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(contextualRollAskBeforeRollingPrefsKey, value);
  }

  Future<void> setCriticalMode(ContextualCriticalMode mode) async {
    if (mode == ContextualCriticalMode.none) return;
    state = state.copyWith(criticalMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(contextualRollCriticalModePrefsKey, mode.name);
  }
}

ContextualCriticalMode contextualCriticalModeFromPrefs(String? value) {
  return ContextualCriticalMode.values.firstWhere(
    (mode) => mode.name == value && mode != ContextualCriticalMode.none,
    orElse: () => ContextualCriticalMode.doubleDice,
  );
}
