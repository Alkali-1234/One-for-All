import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import 'note_contents.dart';

part 'note_content.freezed.dart';
// optional: Since our class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
part 'note_content.g.dart';

@Freezed(genericArgumentFactories: true)
class NoteContent<T extends BaseContentTypes> with _$NoteContent<T> {
  const factory NoteContent(T content) = _NoteContent;

  factory NoteContent.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) => _$NoteContentFromJson(json, fromJsonT);
}

class NoteContentConverter extends JsonConverter<NoteContent<BaseContentTypes>, Map<String, dynamic>> {
  const NoteContentConverter();

  @override
  NoteContent<BaseContentTypes> fromJson(Map<String, dynamic> json) {
    return NoteContent(const ContentTypesConverter().fromJson(json['content']));
  }

  @override
  Map<String, dynamic> toJson(NoteContent object) {
    return {
      "content": const ContentTypesConverter().toJson(object.content),
    };
  }
}

class ContentTypesConverter extends JsonConverter<BaseContentTypes, Map<String, dynamic>> {
  const ContentTypesConverter();

  @override
  BaseContentTypes fromJson(Map<String, dynamic> json) {
    if (json.containsKey('text')) {
      return TextContent(text: json['text'] as String);
    }
    if (json.containsKey('image')) {
      return ImageContent(type: ImageContentTypes.values[json['type']], image: json['image']);
    }
    throw Exception('Unknown content type whilst converting json to content types');
  }

  @override
  Map<String, dynamic> toJson(BaseContentTypes object) {
    if (object is TextContent) {
      return {
        'text': object.text
      };
    }
    if (object is ImageContent) {
      return {
        'type': object.type.index,
        'image': object.image
      };
    }
    throw Exception('Unknown content type whilst converting content to json');
  }
}

enum ContentTypes {
  text,
  image,
  file,
  link,
  list,
}

// * "skibidi" -Emir Yahya, 2024
