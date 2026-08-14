import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../json_helpers.dart';

part 'character_note.g.dart';

const _uuid = Uuid();

@JsonSerializable()
class CharacterNote {
  @JsonKey(fromJson: _idFromJson)
  final String id;

  final String title;
  final String content;
  final DateTime createdAt;
  final List<CharacterNoteTag> tags;
  @JsonKey(fromJson: readBool)
  final bool isPinned;
  final int sortOrder;

  CharacterNote({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.tags = const [],
    this.isPinned = false,
    this.sortOrder = 0,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now();

  CharacterNote copyWith({
    String? title,
    String? content,
    List<CharacterNoteTag>? tags,
    bool? isPinned,
    int? sortOrder,
  }) {
    return CharacterNote(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory CharacterNote.fromJson(Map<String, dynamic> json) =>
      _$CharacterNoteFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterNoteToJson(this);
}

@JsonSerializable()
class CharacterNoteTag {
  final String label;
  final int colorValue;

  const CharacterNoteTag({required this.label, required this.colorValue});

  CharacterNoteTag copyWith({String? label, int? colorValue}) {
    return CharacterNoteTag(
      label: label ?? this.label,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  factory CharacterNoteTag.fromJson(Map<String, dynamic> json) =>
      _$CharacterNoteTagFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterNoteTagToJson(this);
}

String _idFromJson(dynamic v) => (v is String && v.isNotEmpty) ? v : _uuid.v4();
