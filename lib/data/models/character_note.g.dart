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
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => CharacterNoteTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isPinned: readBool(json['isPinned']),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CharacterNoteToJson(CharacterNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
      'isPinned': instance.isPinned,
      'sortOrder': instance.sortOrder,
    };

CharacterNoteTag _$CharacterNoteTagFromJson(Map<String, dynamic> json) =>
    CharacterNoteTag(
      label: json['label'] as String? ?? '',
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF607D8B,
    );

Map<String, dynamic> _$CharacterNoteTagToJson(CharacterNoteTag instance) =>
    <String, dynamic>{
      'label': instance.label,
      'colorValue': instance.colorValue,
    };
