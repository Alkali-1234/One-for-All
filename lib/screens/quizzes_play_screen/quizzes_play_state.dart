import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:oneforall/models/quiz_question.dart";

class CurrentQuestion extends Notifier<QuizQuestion> {
  void updateQuestion(QuizQuestion question) {
    state = question;
  }

  @override
  QuizQuestion build() {
    return QuizQuestion(id: 0, question: "", answers: [], correctAnswer: [], imagePath: null);
  }
}

final currentQuestionProvider = NotifierProvider<CurrentQuestion, QuizQuestion>(CurrentQuestion.new);

class QuizPlaying extends Notifier<QuizSet> {
  void updateQuiz(QuizSet quiz) {
    state = quiz;
  }

  QuizSet shuffleQuestions() {
    final shuffledQuestions = state.questions..shuffle();
    final newQuiz = state..questions = shuffledQuestions;
    state = newQuiz;
    return newQuiz;
  }

  @override
  QuizSet build() {
    return QuizSet(title: "", description: "", questions: [], settings: {});
  }
}

final quizPlayingProvider = NotifierProvider<QuizPlaying, QuizSet>(QuizPlaying.new);
