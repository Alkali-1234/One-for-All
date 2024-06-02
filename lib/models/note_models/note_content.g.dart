// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteContentImpl<T> _$$NoteContentImplFromJson<T extends BaseContentTypes>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    _$NoteContentImpl<T>(
      fromJsonT(json['content']),
    );

Map<String, dynamic> _$$NoteContentImplToJson<T extends BaseContentTypes>(
  _$NoteContentImpl<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'content': toJsonT(instance.content),
    };
