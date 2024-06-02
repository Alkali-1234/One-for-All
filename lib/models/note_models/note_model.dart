import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import 'note_content.dart';
import 'note_contents.dart';

part 'note_model.freezed.dart';
// optional: Since our class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
part 'note_model.g.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String title,
    @NoteContentConverter() required List<NoteContent> content,
  }) = _Note;

  factory Note.fromJson(Map<String, Object?> json) => _$NoteFromJson(json);
}
