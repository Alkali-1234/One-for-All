import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'openai_message_model.freezed.dart';
// optional: Since our class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
// part 'openai_message_model.g.dart';

@freezed
class OpenAIMessageModel with _$OpenAIMessageModel {
  const factory OpenAIMessageModel({
    required String message,
    required OpenAIMessageRoles role,
    List<String>? imageURLs,
    List<String>? imageFileIDs,
  }) = _OpenAIMessageModel;

  // factory OpenAIMessageModel.fromJson(Map<String, Object?> json) => _$OpenAIMessageModelFromJson(json);
}

enum OpenAIMessageRoles {
  user,
  assistant,
  system,
}
