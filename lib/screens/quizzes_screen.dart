import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/components/styled_components/container.dart';
import 'package:oneforall/components/styled_components/filled_elevated_button.dart';
import 'package:oneforall/components/styled_components/primary_elevated_button.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:oneforall/components/styled_components/touchable_container.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/functions/quizzes_functions.dart';
import 'package:oneforall/styles/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/main_container.dart';
import 'package:oneforall/main.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../components/styled_components/text_field.dart';
import '../models/quiz_question.dart';
import 'quizzes_screen_components/quizzes_edit_screen.dart';
import 'quizzes_play_screen/quizzes_play_screen.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  String _searchText = "";
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);
    return Scaffold(
      backgroundColor: theme.background,
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: StyledTouchableContainer(
            onPressed: () {
              showDialog(context: context, builder: (context) => const NewSetOptions());
            },
            theme: ctheme,
            child: Icon(Icons.add, color: theme.onBackground)),
      ),
      // bottomNavigationBar: const BannerAdWidget(),
      body: MainContainer(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //* Search bar
            StyledTextField(
              onChanged: (value) => setState(() => _searchText = value),
              theme: ctheme,
              hint: "Search",
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Icon(Icons.library_books, color: theme.onBackground, size: 50),
                const SizedBox(
                  width: 10,
                ),
                Text("Library", style: textTheme.displayLarge),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            appState.getQuizzes.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("You don't have any Quizzes", style: textTheme.displayMedium),
                          const SizedBox(
                            height: 10,
                          ),
                          StyledTouchableContainer(
                            theme: getThemeFromTheme(theme),
                            onPressed: () {
                              showDialog(context: context, builder: (context) => const NewSetOptions());
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Create Quiz",
                                    style: textTheme.displaySmall,
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Icon(Icons.add, color: theme.onBackground)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (!appState.getQuizzes[index].title.toLowerCase().contains(_searchText.toLowerCase()) && !appState.getQuizzes[index].description.toLowerCase().contains(_searchText.toLowerCase())) return const SizedBox.shrink();
                          return ListItem(
                            title: appState.getQuizzes[index].title,
                            index: index,
                          );
                        },
                        itemCount: appState.getQuizzes.length)),
          ],
        ),
      )),
    );
  }
}

//* Quiz List Item
class ListItem extends StatelessWidget {
  const ListItem({super.key, required this.title, required this.index});
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: StyledTouchableContainer(
        theme: ctheme,
        onPressed: () => showDialog(context: context, builder: (context) => SelectedQuizModal(quiz: context.read<AppState>().getQuizzes[index], index: index)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Text(title, style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

//* Selected Quiz Modal
class SelectedQuizModal extends StatelessWidget {
  const SelectedQuizModal({super.key, required this.quiz, required this.index});
  final QuizSet quiz;
  final int index;

  String getSetJson() {
    dynamic quizData = {
      "quizzes": [
        {
          "title": quiz.title,
          "description": quiz.description,
          "questions": [
            for (var question in quiz.questions)
              {
                "question": question.question,
                "answers": question.answers,
                "correctAnswer": question.correctAnswer,
                "type": question.type?.index ?? QuizTypes.multipleChoice.index
              }
          ],
          "settings": quiz.settings
        }
      ]
    };
    return jsonEncode(quizData);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);
    return Dialog(
        backgroundColor: theme.background,
        child: Container(
          decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(quiz.title, style: textTheme.displayLarge)),
                    //* Options button
                    PopupMenuButton(
                        color: theme.background,
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(child: Text("Export", style: textTheme.displaySmall), onTap: () => QuizzesFunctions().exportQuizzesToDownloads(quiz, context)),
                            PopupMenuItem(
                                child: Text("Edit", style: textTheme.displaySmall),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuizzesEditScreen(index: index)));
                                }),
                            PopupMenuItem(
                                child: Text("Delete", style: textTheme.displaySmall),
                                onTap: () async {
                                  Navigator.pop(context);
                                  context.read<AppState>().getQuizzes.removeAt(index);
                                  final prefs = await SharedPreferences.getInstance();
                                  //Convert to Object
                                  Object quizData = {
                                    "quizzes": [
                                      // ignore: use_build_context_synchronously
                                      for (var quiz in context.read<AppState>().getQuizzes)
                                        {
                                          "title": quiz.title,
                                          "description": quiz.description,
                                          "questions": [
                                            for (var question in quiz.questions)
                                              {
                                                "question": question.question,
                                                "answers": question.answers,
                                                "correctAnswer": question.correctAnswer,
                                                "type": question.type?.index ?? QuizTypes.multipleChoice.index
                                              }
                                          ],
                                          "settings": quiz.settings
                                        }
                                    ]
                                  };
                                  //Save to prefs
                                  await prefs.setString("quizData", jsonEncode(quizData));
                                  if (!context.mounted) return;
                                  context.read<AppState>().thisNotifyListeners();
                                }),
                          ];
                        },
                        child: Icon(Icons.more_vert, color: theme.onBackground))
                  ],
                ),
                const SizedBox(height: 10),
                Text(quiz.description, style: textTheme.displayMedium),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                //Some information
                StyledContainer(
                  theme: ctheme,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Questions", style: textTheme.displaySmall),
                        Text(quiz.questions.length.toString(), style: textTheme.displaySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("JSON Encoded quiz set. Copy this for importing quiz sets.", style: textTheme.displaySmall),
                const SizedBox(height: 10),
                SelectableText(getSetJson(), style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold), maxLines: 5),
                const SizedBox(
                  height: 32,
                ),
                //Open, Edit, and Close
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledElevatedButton(
                        color: Colors.green,
                        onPressed: () {
                          Navigator.pop(context);
                          QuizSet modifiedQuiz = QuizSet(
                              title: quiz.title,
                              description: quiz.description,
                              questions: [],
                              settings: quiz.settings.isNotEmpty
                                  ? quiz.settings
                                  : {
                                      "shuffleQuestions": false,
                                      "shuffleAnswers": false
                                    });
                          if (quiz.questions.isEmpty) return;
                          if (quiz.settings["shuffleQuestions"] != null && quiz.settings["shuffleQuestions"] == true) {
                            modifiedQuiz.questions = quiz.questions.toList()..shuffle();
                          } else {
                            modifiedQuiz.questions = quiz.questions.toList();
                          }
                          if (quiz.settings["shuffleAnswers"] != null && quiz.settings["shuffleAnswers"] == true) {
                            for (var question in modifiedQuiz.questions.where((element) => element.type == QuizTypes.multipleChoice || element.type == QuizTypes.reorder)) {
                              List<String> tempAns = question.answers.toList();
                              question.answers.shuffle();
                              question.correctAnswer = question.correctAnswer.map((e) => question.answers.indexOf(tempAns[e])).toList();
                            }
                            for (var question in modifiedQuiz.questions.where((element) => element.type == QuizTypes.dropdown)) {
                              List<String> tempAns = question.answers.toList();
                              question.answers.shuffle();
                              question.correctAnswer = question.correctAnswer.map((e) => question.answers.indexOf(tempAns[e])).toList();
                              //* Change the correct answer in sentence
                              List<String> sentence = question.question.split("<seperator />");
                              int dropdownIndex = 0;
                              for (var i = 0; i < sentence.length; i++) {
                                if (sentence[i].contains("<dropdown ")) {
                                  sentence[i] = "<dropdown answer=${question.correctAnswer[dropdownIndex]} />";
                                  dropdownIndex++;
                                }
                              }
                            }
                          }
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuizzesPlayScreen(quizSet: modifiedQuiz)));
                        },
                        child: Text("Open", style: textTheme.displaySmall)),
                    const SizedBox(
                      height: 16,
                    ),
                    FilledElevatedButton(
                        color: Colors.blue,
                        onPressed: () => {
                              Navigator.pop(context),
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuizzesEditScreen(index: index))),
                            },
                        child: Text("Edit", style: textTheme.displaySmall)),
                    const SizedBox(
                      height: 16,
                    ),
                    FilledElevatedButton(color: Colors.red, onPressed: () => Navigator.pop(context), child: Text("Close", style: textTheme.displaySmall)),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

//* New Quiz Modal
class NewQuizModal extends StatefulWidget {
  const NewQuizModal({super.key});

  @override
  State<NewQuizModal> createState() => _NewQuizModalState();
}

class _NewQuizModalState extends State<NewQuizModal> {
  String _title = "";
  String _description = "";
  String _error = "";

  void addQuiz(AppState appState) async {
    if (_title.isEmpty || _description.isEmpty) {
      setState(() {
        _error = "Please fill in all fields";
      });
      return;
    }
    Navigator.pop(context);
    appState.getQuizzes.add(QuizSet(title: _title, description: _description, questions: [], settings: {}));
    final prefs = await SharedPreferences.getInstance();
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
                  "correctAnswer": question.correctAnswer
                }
            ]
          }
      ]
    };
    //Save to prefs
    await prefs.setString("quizData", jsonEncode(quizData));
    setState(() {});
    appState.thisNotifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);
    return Dialog(
        backgroundColor: theme.background,
        child: Container(
          decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Create Quiz", style: textTheme.displayLarge),
                const SizedBox(
                  height: 15,
                ),
                StyledTextField(hint: "Title", onChanged: (value) => setState(() => _title = value), style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold), theme: ctheme),
                const SizedBox(
                  height: 16,
                ),
                StyledTextField(
                  hint: "Description",
                  onChanged: (value) => setState(() => _description = value),
                  style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                  theme: ctheme,
                ),
                _error.isNotEmpty ? Text(_error, style: textTheme.displaySmall!.copyWith(color: theme.error)) : const SizedBox.shrink(),
                const SizedBox(
                  height: 32,
                ),

                //Add and Cancel buttons
                StyledPrimaryElevatedButton(theme: ctheme, onPressed: () => addQuiz(appState), child: Text("Add", style: textTheme.displaySmall)),
                const SizedBox(
                  height: 16,
                ),
                FilledElevatedButton(color: Colors.red, onPressed: () => Navigator.pop(context), child: Text("Cancel", style: textTheme.displaySmall))
              ],
            ),
          ),
        ));
  }
}

class NewSetOptions extends StatefulWidget {
  const NewSetOptions({super.key});

  @override
  State<NewSetOptions> createState() => _NewSetOptionsState();
}

class _NewSetOptionsState extends State<NewSetOptions> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    // var appState = Provider.of<AppState>(context);
    var ctheme = getThemeFromTheme(theme);
    return Dialog(
        backgroundColor: theme.background,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: StyledTouchableContainer(
                      theme: ctheme,
                      onPressed: () => {
                        Navigator.pop(context),
                        showDialog(context: context, builder: (context) => const NewQuizModal())
                      },
                      child: Icon(Icons.add, color: theme.onBackground, size: 24),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Create",
                    style: textTheme.displaySmall,
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: StyledTouchableContainer(
                      theme: ctheme,
                      onPressed: () => {},
                      child: Icon(Icons.smart_toy, color: theme.onBackground, size: 24),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Generate",
                    style: textTheme.displaySmall,
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: StyledTouchableContainer(
                      theme: ctheme,
                      onPressed: () => {
                        Navigator.pop(context),
                        showDialog(context: context, builder: (context) => const ImportQuizModal())
                      },
                      child: Icon(Icons.download, color: theme.onBackground, size: 24),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Import",
                    style: textTheme.displaySmall,
                  )
                ],
              )
            ],
          ),
        ));
  }
}

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
      return;
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
                  "type": question.type?.index ?? QuizTypes.multipleChoice.index
                }
            ],
            "settings": quiz.settings
          }
      ]
    };
    //Save to prefs
    await prefs.setString("quizData", jsonEncode(quizData));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return Dialog(
        child: Container(
            decoration: BoxDecoration(color: theme.background, borderRadius: const BorderRadius.all(Radius.circular(20.0))),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Import from JSON String", style: textTheme.displayMedium),
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
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: theme.secondary,
                          foregroundColor: theme.onBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                        ),
                        onPressed: () => validateJSON(context.read<AppState>()),
                        child: const Text("Import")),
                    ElevatedButton(style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: theme.secondary, foregroundColor: theme.onBackground, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none)), onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel"))
                  ],
                ),
                const SizedBox(height: 10),
                //* Import from zip file
                Text("Import from zip file", style: textTheme.displayMedium),
                const SizedBox(height: 5),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.secondary,
                      foregroundColor: theme.onBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                    ),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: [
                        'zip'
                      ]);
                      if (result == null) return;
                      if (!context.mounted) return;
                      QuizzesFunctions().importQuizFromZip(File(result.files.single.path!), context.read<AppState>(), context);
                    },
                    child: const Text("Select File")),
              ],
            )));
  }
}
