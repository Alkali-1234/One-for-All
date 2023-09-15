import 'package:oneforall/constants.dart';
import 'package:oneforall/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quizzes_models.dart';

class QuizzesFunctions {
  void refreshQuizzesFromLocal(AppState appState, bool? notifyListeners) async {
    appState.getQuizzes.clear();
    await SharedPreferences.getInstance().then((value) {
      if (value.containsKey("quizData")) {
        dynamic decodedObject = jsonDecode(value.getString("quizData")!);

        //* Convert the decoded `dynamic` object back to your desired Dart object structure
        List<QuizSet> quizzes = [];
        for (var quiz in decodedObject['quizzes']) {
          quizzes.add(
            QuizSet(
                title: quiz['title'],
                description: quiz['description'],
                questions: [
                  for (int i = 0; i < quiz["questions"].length; i++) QuizQuestion(id: i, question: quiz["questions"][i]["question"], answers: List<String>.from(quiz["questions"][i]["answers"] as List), correctAnswer: List<int>.from(quiz["questions"][i]["correctAnswer"] as List), type: quiz["questions"][i]["type"] != null ? quizTypes.values[quiz["questions"][i]["type"]] : quizTypes.multipleChoice),
                ],
                settings: quiz["settings"] ?? {}),
          );
        }

        //* Add the quizzes to the user data
        for (QuizSet quiz in quizzes) {
          appState.getQuizzes.add(quiz);
        }
        if (notifyListeners == true) appState.thisNotifyListeners();
      }
    });
  }
}
