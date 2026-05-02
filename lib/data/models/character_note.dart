import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'character_note.g.dart';

const _uuid = Uuid();

@JsonSerializable()
class CharacterNote {
  @JsonKey(fromJson: _idFromJson)
  final String id;

  final String title;
  final String content;
  final DateTime createdAt;

  CharacterNote({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  CharacterNote copyWith({
    String? title,
    String? content,
  }) {
    return CharacterNote(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }

  factory CharacterNote.fromJson(Map<String, dynamic> json) =>
      _$CharacterNoteFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterNoteToJson(this);
}

String _idFromJson(dynamic v) =>
    (v is String && v.isNotEmpty) ? v : _uuid.v4();
