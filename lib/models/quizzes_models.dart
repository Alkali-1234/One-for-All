import '../constants.dart';

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

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    this.type,
  });
  int id;
  String question;
  List<String> answers;
  //Between 0 to length of answers
  List<int> correctAnswer;
  quizTypes? type;
}
