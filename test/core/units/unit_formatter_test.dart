import 'package:dnd_character_tool/core/units/unit_formatter.dart';
import 'package:dnd_character_tool/core/units/unit_system_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('defaultUnitSystem', () {
    test('uses imperial for English locales and metric otherwise', () {
      expect(defaultUnitSystem(const Locale('en')), UnitSystem.imperial);
      expect(defaultUnitSystem(const Locale('en', 'US')), UnitSystem.imperial);
      expect(defaultUnitSystem(const Locale('pt', 'BR')), UnitSystem.metric);
      expect(defaultUnitSystem(const Locale('es')), UnitSystem.metric);
    });
  });

  group('distance formatting', () {
    test('keeps feet as the internal storage unit', () {
      expect(formatDistance(30, UnitSystem.imperial), '30 ft');
      expect(formatDistance(30, UnitSystem.metric), '9 m');
      expect(formatDistance(30, UnitSystem.squares), '6 sq');
    });

    test('converts display input back to stored feet', () {
      expect(displayDistanceToFeet(30, UnitSystem.imperial), 30);
      expect(displayDistanceToFeet(9, UnitSystem.metric), 30);
      expect(displayDistanceToFeet(6, UnitSystem.squares), 30);
    });

    test('uses the selected system suffix for input fields', () {
      expect(distanceSuffix(UnitSystem.imperial), 'ft');
      expect(distanceSuffix(UnitSystem.metric), 'm');
      expect(distanceSuffix(UnitSystem.squares), 'sq');
    });
  });

  group('weight formatting', () {
    test('keeps pounds as the internal storage unit', () {
      expect(formatWeight(10, UnitSystem.imperial), '10 lb');
      expect(formatWeight(10, UnitSystem.metric), '4.54 kg');
    });

    test('converts metric display input back to stored pounds', () {
      expect(weightToLb(10, UnitSystem.imperial), 10);
      expect(weightToLb(10, UnitSystem.metric), closeTo(22.046, 0.001));
      expect(lbToDisplay(22.046, UnitSystem.metric), closeTo(10, 0.001));
    });

    test('uses kg for metric and squares weight inputs', () {
      expect(weightSuffix(UnitSystem.imperial), 'lb');
      expect(weightSuffix(UnitSystem.metric), 'kg');
      expect(weightSuffix(UnitSystem.squares), 'kg');
    });
  });
}
