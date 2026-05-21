import 'package:json_annotation/json_annotation.dart';

part 'ability_scores.g.dart';

@JsonSerializable()
class AbilityScores {
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  const AbilityScores({
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
  });

  int get strengthModifier => _modifier(strength);
  int get dexterityModifier => _modifier(dexterity);
  int get constitutionModifier => _modifier(constitution);
  int get intelligenceModifier => _modifier(intelligence);
  int get wisdomModifier => _modifier(wisdom);
  int get charismaModifier => _modifier(charisma);

  int _modifier(int score) => ((score - 10) / 2).floor();

  int operator [](String ability) {
    switch (ability.toLowerCase()) {
      case 'strength':
        return strength;
      case 'dexterity':
        return dexterity;
      case 'constitution':
        return constitution;
      case 'intelligence':
        return intelligence;
      case 'wisdom':
        return wisdom;
      case 'charisma':
        return charisma;
      default:
        throw ArgumentError('Unknown ability: $ability');
    }
  }

  AbilityScores copyWith({
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
  }) {
    return AbilityScores(
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
    );
  }

  /// Returns a new [AbilityScores] with [attribute] increased by [delta],
  /// clamped to [1, 20]. [attribute] must be the lowercase full name
  /// (e.g. 'strength', 'dexterity'). Unknown attributes return `this`.
  AbilityScores increment(String attribute, int delta) {
    switch (attribute.toLowerCase()) {
      case 'strength':
        return copyWith(strength: (strength + delta).clamp(1, 20));
      case 'dexterity':
        return copyWith(dexterity: (dexterity + delta).clamp(1, 20));
      case 'constitution':
        return copyWith(constitution: (constitution + delta).clamp(1, 20));
      case 'intelligence':
        return copyWith(intelligence: (intelligence + delta).clamp(1, 20));
      case 'wisdom':
        return copyWith(wisdom: (wisdom + delta).clamp(1, 20));
      case 'charisma':
        return copyWith(charisma: (charisma + delta).clamp(1, 20));
      default:
        return this;
    }
  }

  factory AbilityScores.fromJson(Map<String, dynamic> json) =>
      _$AbilityScoresFromJson(json);

  Map<String, dynamic> toJson() => _$AbilityScoresToJson(this);
}
