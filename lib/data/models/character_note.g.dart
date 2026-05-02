// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterNote _$CharacterNoteFromJson(Map<String, dynamic> json) =>
    CharacterNote(
      id: _idFromJson(json['id']),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CharacterNoteToJson(CharacterNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
