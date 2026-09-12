import 'package:dnd_character_tool/core/dice/contextual_roll_preferences_provider.dart';
import 'package:dnd_character_tool/data/dice/dice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contextualCriticalModeFromPrefs', () {
    test('uses double dice as the default critical rule', () {
      expect(
        contextualCriticalModeFromPrefs(null),
        ContextualCriticalMode.doubleDice,
      );
      expect(
        contextualCriticalModeFromPrefs('unknown'),
        ContextualCriticalMode.doubleDice,
      );
      expect(
        contextualCriticalModeFromPrefs(ContextualCriticalMode.none.name),
        ContextualCriticalMode.doubleDice,
      );
    });

    test('loads saved critical rules', () {
      expect(
        contextualCriticalModeFromPrefs(ContextualCriticalMode.doubleDice.name),
        ContextualCriticalMode.doubleDice,
      );
      expect(
        contextualCriticalModeFromPrefs(ContextualCriticalMode.doubleTotal.name),
        ContextualCriticalMode.doubleTotal,
      );
    });
  });
}
