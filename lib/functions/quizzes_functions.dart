import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quizzes_models.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

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
                  for (int i = 0; i < quiz["questions"].length; i++) QuizQuestion(imagePath: quiz["questions"][i]["imagePath"], id: i, question: quiz["questions"][i]["question"], answers: List<String>.from(quiz["questions"][i]["answers"] as List), correctAnswer: List<int>.from(quiz["questions"][i]["correctAnswer"] as List), type: quiz["questions"][i]["type"] != null ? QuizTypes.values[quiz["questions"][i]["type"]] : QuizTypes.multipleChoice),
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

  Future<void> exportQuizzesToDownloads(QuizSet quiz, BuildContext context) async {
    //* Convert the quizzes to a JSON string
    Object quizData = {
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
    };

    //* Save the JSON string to the device's downloads folder
    Archive archive = Archive();
    archive.addFile(ArchiveFile('quiz.json', jsonEncode(quizData).length, utf8.encode(jsonEncode(quizData))));
    //* Add images to the archive
    for (var question in quiz.questions) {
      if (question.imagePath != null && question.imagePath!.isNotEmpty) {
        archive.addFile(ArchiveFile('images/${question.imagePath!.split("/").last}', File(question.imagePath!).readAsBytesSync().length, File(question.imagePath!).readAsBytesSync()));
      }
    }
    Directory? downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory == null) return;
    final File zipFile = await File('${downloadsDirectory.path}/quiz.zip').create();
    zipFile.writeAsBytesSync(ZipEncoder().encode(archive)!);
    print("Saved to ${zipFile.path}");
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Saved to ${zipFile.path}"),
      backgroundColor: Colors.green,
    ));
    // var encoder = ZipFileEncoder();
    // encoder.zipDirectory(Directory('${downloadsDirectory.path}/quizzesExports'), filename: 'quiz.zip');
    // encoder.close();
    archive.clear();
    // print("Saved to ${downloadsDirectory.path}/quizzesExports/quiz.zip");
  }

  Future<void> importQuizFromZip(File file, AppState appState, BuildContext context) async {
    String quizName = "";
    QuizSet? quiz;
    if (file.path.endsWith(".zip")) {
      Archive archive = ZipDecoder().decodeBytes(file.readAsBytesSync());
      for (var file in archive) {
        if (file.isFile && file.name.endsWith(".json")) {
          //* Convert the decoded `dynamic` object back to your desired Dart object structure
          dynamic decodedObject = jsonDecode(utf8.decode(file.content as List<int>));
          quizName = decodedObject['title'];
          List<QuizSet> quizzes = [];
          quizzes.add(
            QuizSet(
                title: decodedObject['title'],
                description: decodedObject['description'],
                questions: [
                  for (int i = 0; i < decodedObject["questions"].length; i++) QuizQuestion(imagePath: decodedObject["questions"][i]["imagePath"], id: i, question: decodedObject["questions"][i]["question"], answers: List<String>.from(decodedObject["questions"][i]["answers"] as List), correctAnswer: List<int>.from(decodedObject["questions"][i]["correctAnswer"] as List), type: decodedObject["questions"][i]["type"] != null ? QuizTypes.values[decodedObject["questions"][i]["type"]] : QuizTypes.multipleChoice),
                ],
                settings: decodedObject["settings"] ?? {}),
          );
          quiz = quizzes[0];
          appState.thisNotifyListeners();
        } else if (file.isFile && file.name.startsWith("images/")) {
          //* Save the image to the device's downloads folder
          Directory documentsDirectory = await getApplicationDocumentsDirectory();
          File image = await File('${documentsDirectory.path}/quizAssets/$quizName/${file.name.split('/').last}').create(recursive: true);
          image.writeAsBytesSync(file.content as List<int>);
          //* Redirect any images in the quiz to the new location
          for (var element in quiz!.questions.where((element) => element.imagePath?.contains(image.path.split('/').last) ?? false)) {
            element.imagePath = image.path;
          }
        }
      }
      //* Save to app state
      appState.getQuizzes.add(quiz!);
      //* Save to shared preferences
      refreshQuizesFromAppState(appState);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Imported ${file.path}"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 10),
      ));
    }
  }

  Future<void> refreshQuizesFromAppState(AppState appState) async {
    var prefs = await SharedPreferences.getInstance();
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
}
