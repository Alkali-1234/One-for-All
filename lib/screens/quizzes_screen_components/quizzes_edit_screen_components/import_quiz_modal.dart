import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../constants.dart";
import "../../../main.dart";
import "../../../models/quizzes_models.dart";
import "../../../styles/styles.dart";

class ImportQuizModal extends StatefulWidget {
  const ImportQuizModal({super.key});

  @override
  State<ImportQuizModal> createState() => _ImportQuizModalState();
}

class _ImportQuizModalState extends State<ImportQuizModal> {
  String error = "";

  String jsonString = "";

  void validateJSON(AppState appState) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      dynamic decodedObject = jsonDecode(jsonString);

      //* Convert the decoded `dynamic` object back to your desired Dart object structure
      List<QuizSet> quizzes = [];
      for (var quiz in decodedObject['quizzes']) {
        quizzes.add(
          QuizSet(
              title: quiz['title'],
              description: quiz['description'],
              questions: [
                for (int i = 0; i < quiz["questions"].length; i++) QuizQuestion(imagePath: quiz["questions"][i]["imagePath"], id: i, question: quiz["questions"][i]["question"], answers: List<String>.from(quiz["questions"][i]["answers"] as List), correctAnswer: List<int>.from(quiz["questions"][i]["correctAnswer"] as List), type: quiz["questions"][i]["type"] != null ? QuizTypes.values[quiz["questions"][i]["type"]] : QuizTypes.multipleChoice),
              ],
              settings: quiz["settings"] ?? {}),
        );
      }

      //* Add the quizzes to the user data
      for (QuizSet quiz in quizzes) {
        appState.getQuizzes.add(quiz);
      }
    } catch (e) {
      setState(() {
        error = "String not formatted correctly? ${e.toString()}";
      });
    }
    appState.thisNotifyListeners();
    //Convert to Object
    Object quizData = {
      "quizzes": [
        for (var quiz in appState.getQuizzes)
          {
            "title": quiz.title,
            "description": quiz.description,
            "questions": [
              for (var question in quiz.questions)
                {
                  "question": question.question,
                  "answers": question.answers,
                  "correctAnswer": question.correctAnswer,
                  "type": question.type?.index ?? QuizTypes.multipleChoice.index,
                  "imagePath": question.imagePath
                }
            ],
            "settings": quiz.settings
          }
      ]
    };
    //Save to prefs
    await prefs.setString("quizData", jsonEncode(quizData));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return Dialog(
        child: Container(
            decoration: BoxDecoration(color: theme.background),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text("Import from JSON String", style: textTheme.displaySmall),
                  ],
                ),
                const SizedBox(height: 5),
                TextField(
                  style: textTheme.displaySmall,
                  cursorColor: theme.onBackground,
                  decoration: TextInputStyle(theme: theme, textTheme: textTheme).getTextInputStyle().copyWith(hintText: "JSON String", hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold)),
                  onChanged: (value) => setState(() {
                    jsonString = value;
                  }),
                ),
                const SizedBox(height: 5),
                error != "" ? Text(error, style: textTheme.displaySmall!.copyWith(color: theme.error)) : const SizedBox(),
              ],
            )));
  }
}
