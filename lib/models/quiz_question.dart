import '../constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'quiz_question.freezed.dart';
// optional: Since our class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
part 'quiz_question.g.dart';

@unfreezed
class QuizQuestion with _$QuizQuestion {
  factory QuizQuestion({
    required int id,
    required String question,
    required List<String> answers,
    required List<int> correctAnswer,
    required String? imagePath,
    QuizTypes? type,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, Object?> json) => _$QuizQuestionFromJson(json);
}

class QuizSet {
  //Constructor
  QuizSet({
    required this.title,
    required this.description,
    required this.questions,
    required this.settings,
  });
  String title;
  String description;
  List<QuizQuestion> questions;
  Map<String, dynamic> settings;
}
