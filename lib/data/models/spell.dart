import 'package:json_annotation/json_annotation.dart';

part 'spell.g.dart';

/// Spell slots per spell level (index 0 = level 1, index 8 = level 9)
@JsonSerializable()
class SpellSlots {
  final List<int> total;
  final List<int> used;

  const SpellSlots({
    this.total = const [0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.used = const [0, 0, 0, 0, 0, 0, 0, 0, 0],
  });

  int remaining(int level) => total[level - 1] - used[level - 1];

  SpellSlots copyWith({List<int>? total, List<int>? used}) {
    return SpellSlots(
      total: total ?? List.from(this.total),
      used: used ?? List.from(this.used),
    );
  }

  factory SpellSlots.fromJson(Map<String, dynamic> json) {
    final raw = _$SpellSlotsFromJson(json);
    return SpellSlots._normalized(raw.total, raw.used);
  }

  /// Garante exatamente 9 posições, valores não-negativos e used <= total.
  factory SpellSlots._normalized(List<int> total, List<int> used) {
    const size = 9;
    final t = List<int>.generate(size, (i) => i < total.length ? total[i].clamp(0, 9999) : 0);
    final u = List<int>.generate(size, (i) {
      final usedVal = i < used.length ? used[i].clamp(0, 9999) : 0;
      return usedVal.clamp(0, t[i]);
    });
    return SpellSlots(total: t, used: u);
  }

  Map<String, dynamic> toJson() => _$SpellSlotsToJson(this);
}

@JsonSerializable()
class KnownSpell {
  final String name;
  final int level;
  final bool isPrepared;
  final bool isAlwaysPrepared;

  const KnownSpell({
    required this.name,
    required this.level,
    this.isPrepared = false,
    this.isAlwaysPrepared = false,
  });

  KnownSpell copyWith({
    String? name,
    int? level,
    bool? isPrepared,
    bool? isAlwaysPrepared,
  }) {
    return KnownSpell(
      name: name ?? this.name,
      level: level ?? this.level,
      isPrepared: isPrepared ?? this.isPrepared,
      isAlwaysPrepared: isAlwaysPrepared ?? this.isAlwaysPrepared,
    );
  }

  factory KnownSpell.fromJson(Map<String, dynamic> json) =>
      _$KnownSpellFromJson(json);

  Map<String, dynamic> toJson() => _$KnownSpellToJson(this);
}

/// A racial innate spell (e.g. Tiefling Hellish Rebuke, Drow Dancing Lights).
/// [usesPerDay] == null means the spell is at-will.
class InnateSpell {
  final String name;
  final int? usesPerDay;
  final int usedToday;

  const InnateSpell({
    required this.name,
    this.usesPerDay,
    this.usedToday = 0,
  });

  bool get isAtWill => usesPerDay == null;
  bool get canUse => isAtWill || usedToday < usesPerDay!;
  int get remaining =>
      usesPerDay == null ? -1 : (usesPerDay! - usedToday).clamp(0, usesPerDay!);

  InnateSpell copyWith({int? usedToday}) => InnateSpell(
        name: name,
        usesPerDay: usesPerDay,
        usedToday: usedToday ?? this.usedToday,
      );

  factory InnateSpell.fromJson(Map<String, dynamic> json) => InnateSpell(
        name: json['name'] as String,
        usesPerDay: (json['usesPerDay'] as num?)?.toInt(),
        usedToday: (json['usedToday'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        if (usesPerDay != null) 'usesPerDay': usesPerDay,
        'usedToday': usedToday,
      };
}
