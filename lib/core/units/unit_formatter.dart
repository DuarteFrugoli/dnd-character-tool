import 'unit_system_provider.dart';

/// Converts and formats distances stored internally as feet.
String formatDistance(int feet, UnitSystem system) {
  final value = feetToDisplayDistance(feet, system);
  switch (system) {
    case UnitSystem.imperial:
      return '$value ft';
    case UnitSystem.metric:
      return '$value m';
    case UnitSystem.squares:
      return '$value sq';
  }
}

/// The distance suffix label for input fields (e.g. 'ft', 'm' or 'sq').
String distanceSuffix(UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      return 'ft';
    case UnitSystem.metric:
      return 'm';
    case UnitSystem.squares:
      return 'sq';
  }
}

/// Converts an internally stored feet value to the current system's input unit.
int feetToDisplayDistance(int feet, UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      return feet;
    case UnitSystem.metric:
      return (feet * 0.3048).round();
    case UnitSystem.squares:
      return (feet / 5).round();
  }
}

/// Converts a user-entered distance value to the internal storage unit (feet).
int displayDistanceToFeet(int value, UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      return value;
    case UnitSystem.metric:
      return (value / 0.3048).round();
    case UnitSystem.squares:
      return value * 5;
  }
}

/// Converts and formats weights stored internally as pounds (lb).
String formatWeight(double lb, UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      final display = lb % 1 == 0
          ? lb.toInt().toString()
          : lb.toStringAsFixed(2);
      return '$display lb';
    case UnitSystem.metric:
    case UnitSystem.squares:
      final kg = lb * 0.453592;
      final display = kg % 1 == 0
          ? kg.round().toString()
          : kg.toStringAsFixed(2);
      return '$display kg';
  }
}

/// The weight suffix label for input fields (e.g. 'lb' or 'kg').
String weightSuffix(UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      return 'lb';
    case UnitSystem.metric:
    case UnitSystem.squares:
      return 'kg';
  }
}

/// Converts a user-entered weight value (in the current system's unit) to
/// the internal storage unit (lb).
double weightToLb(double value, UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      return value;
    case UnitSystem.metric:
    case UnitSystem.squares:
      return value / 0.453592;
  }
}

/// Converts an internally stored lb value to the current system's display unit.
double lbToDisplay(double lb, UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      return lb;
    case UnitSystem.metric:
    case UnitSystem.squares:
      return lb * 0.453592;
  }
}
