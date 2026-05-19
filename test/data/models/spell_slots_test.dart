import 'package:dnd_character_tool/data/models/spell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpellSlots._normalized', () {
    test('pads short lists to 9 elements', () {
      final slots = SpellSlots.fromJson({
        'total': [2, 3],
        'used': [1],
      });
      expect(slots.total.length, 9);
      expect(slots.used.length, 9);
      expect(slots.total[0], 2);
      expect(slots.total[1], 3);
      expect(slots.total[2], 0);
    });

    test('truncates lists longer than 9 elements', () {
      final slots = SpellSlots.fromJson({
        'total': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        'used': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      });
      expect(slots.total.length, 9);
      expect(slots.used.length, 9);
    });

    test('clamps negative values to 0', () {
      final slots = SpellSlots.fromJson({
        'total': [-5, 3],
        'used': [-1, 2],
      });
      expect(slots.total[0], 0);
      expect(slots.used[0], 0);
      expect(slots.used[1], 2);
    });

    test('clamps used > total to total', () {
      final slots = SpellSlots.fromJson({
        'total': [2, 1],
        'used': [5, 3],
      });
      expect(slots.used[0], 2);
      expect(slots.used[1], 1);
    });

    test('accepts valid data unchanged', () {
      final slots = SpellSlots.fromJson({
        'total': [4, 3, 2, 1, 0, 0, 0, 0, 0],
        'used': [2, 1, 0, 0, 0, 0, 0, 0, 0],
      });
      expect(slots.total[0], 4);
      expect(slots.used[0], 2);
    });

    test('handles empty lists', () {
      final slots = SpellSlots.fromJson({
        'total': <int>[],
        'used': <int>[],
      });
      expect(slots.total.length, 9);
      expect(slots.total.every((v) => v == 0), true);
    });
  });

  group('SpellSlots.copyWith', () {
    test('creates new instance with updated values', () {
      const original = SpellSlots(
        total: [4, 3, 0, 0, 0, 0, 0, 0, 0],
        used: [0, 0, 0, 0, 0, 0, 0, 0, 0],
      );
      final copy = original.copyWith(used: [1, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(copy.total[0], 4);
      expect(copy.used[0], 1);
      expect(original.used[0], 0); // original not mutated
    });
  });
}
