import 'package:json_annotation/json_annotation.dart';

part 'character_appearance.g.dart';

@JsonSerializable()
class CharacterAppearance {
  final String? age;
  final String height;
  final String weight;
  final String eyes;
  final String skin;
  final String hair;

  const CharacterAppearance({
    this.age,
    this.height = '',
    this.weight = '',
    this.eyes = '',
    this.skin = '',
    this.hair = '',
  });

  CharacterAppearance copyWith({
    String? age,
    String? height,
    String? weight,
    String? eyes,
    String? skin,
    String? hair,
  }) {
    return CharacterAppearance(
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      eyes: eyes ?? this.eyes,
      skin: skin ?? this.skin,
      hair: hair ?? this.hair,
    );
  }

  factory CharacterAppearance.fromJson(Map<String, dynamic> json) =>
      _$CharacterAppearanceFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterAppearanceToJson(this);
}
