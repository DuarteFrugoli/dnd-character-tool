import 'unit_system_provider.dart';

/// Converts and formats distances stored internally as feet.
String formatDistance(int feet, UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      return '$feet ft';
    case UnitSystem.metric:
      final meters = (feet * 0.3048).round();
      return '$meters m';
    case UnitSystem.squares:
      final squares = (feet / 5).round();
      return '$squares sq';
  }
}

/// Converts and formats weights stored internally as pounds (lb).
String formatWeight(double lb, UnitSystem system) {
  switch (system) {
    case UnitSystem.imperial:
      final display = lb % 1 == 0 ? lb.toInt().toString() : lb.toStringAsFixed(2);
      return '$display lb';
    case UnitSystem.metric:
    case UnitSystem.squares:
      final kg = lb * 0.453592;
      final display = kg % 1 == 0 ? kg.round().toString() : kg.toStringAsFixed(2);
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

/// Converts a spell range string from the SRD JSON (e.g. "60 feet",
/// "Self (30-foot cone)") to the target unit system.
/// Non-distance strings ("Self", "Touch", "Sight", etc.) are returned as-is.
String formatSpellRange(String range, UnitSystem system) {
  if (system == UnitSystem.imperial) return range;

  // "N feet"
  final feetMatch = RegExp(r'^(\d+)\s+feet$').firstMatch(range);
  if (feetMatch != null) {
    return formatDistance(int.parse(feetMatch.group(1)!), system);
  }

  // "Self (N-foot shape)"
  final selfMatch = RegExp(r'^(\S+) \((\d+)-foot (.+)\)$').firstMatch(range);
  if (selfMatch != null) {
    final dist = formatDistance(int.parse(selfMatch.group(2)!), system);
    return '${selfMatch.group(1)!} ($dist ${selfMatch.group(3)!})';
  }

  return range;
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
