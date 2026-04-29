import 'package:json_annotation/json_annotation.dart';

part 'character_personality.g.dart';

@JsonSerializable()
class CharacterPersonality {
  final String traits;
  final String ideals;
  final String bonds;
  final String flaws;

  const CharacterPersonality({
    this.traits = '',
    this.ideals = '',
    this.bonds = '',
    this.flaws = '',
  });

  CharacterPersonality copyWith({
    String? traits,
    String? ideals,
    String? bonds,
    String? flaws,
  }) {
    return CharacterPersonality(
      traits: traits ?? this.traits,
      ideals: ideals ?? this.ideals,
      bonds: bonds ?? this.bonds,
      flaws: flaws ?? this.flaws,
    );
  }

  factory CharacterPersonality.fromJson(Map<String, dynamic> json) =>
      _$CharacterPersonalityFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterPersonalityToJson(this);
}
