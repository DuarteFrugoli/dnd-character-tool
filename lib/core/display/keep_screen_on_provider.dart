import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const keepScreenOnCharacterSheetPrefsKey =
    'keep_screen_on_character_sheet';

final keepScreenOnCharacterSheetProvider =
    NotifierProvider<KeepScreenOnCharacterSheetNotifier, bool>(
      KeepScreenOnCharacterSheetNotifier.new,
    );

class KeepScreenOnCharacterSheetNotifier extends Notifier<bool> {
  KeepScreenOnCharacterSheetNotifier([this._initial]);

  final bool? _initial;

  static KeepScreenOnCharacterSheetNotifier withInitial(bool enabled) =>
      KeepScreenOnCharacterSheetNotifier(enabled);

  @override
  bool build() => _initial ?? false;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keepScreenOnCharacterSheetPrefsKey, enabled);
  }
}
