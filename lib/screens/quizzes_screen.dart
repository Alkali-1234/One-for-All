import 'package:flutter/material.dart';
import 'package:oneforall/banner_ad.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/styles/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/main_container.dart';
import 'package:oneforall/main.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/quizzes_models.dart';
import 'quizzes_edit_screen.dart';
import 'quizzes_play_screen.dart';

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
    return Scaffold(
      backgroundColor: theme.background,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(context: context, builder: (context) => const NewSetOptions());
          },
          backgroundColor: theme.secondary,
          child: Icon(Icons.add, color: theme.onBackground)),
      bottomNavigationBar: const BannerAdWidget(),
      body: MainContainer(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            //* Search bar
            TextField(
                onChanged: (value) => setState(() => _searchText = value),
                style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                cursorColor: theme.onBackground,
                decoration: InputDecoration(
                  hintStyle: textTheme.displayMedium!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: theme.primary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  hintText: "Search",
                  suffixIcon: Icon(Icons.search, color: theme.onBackground, size: 50),
                )),
            const SizedBox(
              height: 10,
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
              height: 5,
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
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryContainer,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                showDialog(context: context, builder: (context) => const NewSetOptions());
                              },
                              icon: Icon(
                                Icons.add,
                                color: theme.onBackground,
                              ),
                              label: Text("Create Quiz", style: textTheme.displaySmall)),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: theme.tertiary)),
        ),
        onPressed: () => showDialog(context: context, builder: (context) => SelectedQuizModal(quiz: context.read<AppState>().getQuizzes[index], index: index)),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Text(title, style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
        )),
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
                "type": question.type?.index ?? quizTypes.multipleChoice.index
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
    return Dialog(
        backgroundColor: theme.background,
        child: Container(
          decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(quiz.title, style: textTheme.displayLarge),
                const SizedBox(height: 10),
                Text(quiz.description, style: textTheme.displayMedium),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                //Some information
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Questions", style: textTheme.displaySmall),
                      Text(quiz.questions.length.toString(), style: textTheme.displaySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text("JSON Encoded quiz set. Copy this for importing quiz sets.", style: textTheme.displaySmall),
                const SizedBox(height: 10),
                SelectableText(getSetJson(), style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold), maxLines: 5),
                const SizedBox(
                  height: 10,
                ),
                //Open, Edit, and Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                        ),
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
                            for (var question in modifiedQuiz.questions.where((element) => element.type == quizTypes.multipleChoice || element.type == quizTypes.reorder)) {
                              List<String> tempAns = question.answers.toList();
                              question.answers.shuffle();
                              question.correctAnswer = question.correctAnswer.map((e) => question.answers.indexOf(tempAns[e])).toList();
                            }
                            for (var question in modifiedQuiz.questions.where((element) => element.type == quizTypes.dropdown)) {
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
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                        ),
                        onPressed: () => {
                              Navigator.pop(context),
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuizzesEditScreen(index: index))),
                            },
                        child: Text("Edit", style: textTheme.displaySmall)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("Close", style: textTheme.displaySmall)),
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
    return Dialog(
        backgroundColor: theme.background,
        child: Container(
          decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("New Quiz", style: textTheme.displayLarge),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    onChanged: (value) => setState(() => _title = value),
                    style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                    cursorColor: theme.onBackground,
                    decoration: InputDecoration(
                      hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: theme.primary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      hintText: "Title",
                    )),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    onChanged: (value) => setState(() => _description = value),
                    style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                    cursorColor: theme.onBackground,
                    decoration: InputDecoration(
                      hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: theme.primary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      hintText: "Description",
                    )),
                _error.isNotEmpty ? Text(_error, style: textTheme.displaySmall!.copyWith(color: theme.error)) : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),

                //Add and Cancel buttons
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                        ),
                        onPressed: () => addQuiz(appState),
                        child: Text("Add", style: textTheme.displaySmall)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: textTheme.displaySmall)),
                  ]),
                )
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
    return Dialog(
      backgroundColor: theme.background,
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            //* Create New
            //Button style: Basically a square with an icon inside, and a text below it
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: theme.primary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(context: context, builder: (context) => const NewQuizModal());
                    },
                    icon: Icon(Icons.add, color: theme.onBackground),
                    label: Text("Create New", style: textTheme.displaySmall!.copyWith(color: theme.onBackground))),
              ],
            ),
            const SizedBox(height: 16),
            //* Import
            //Button style: Basically a square with an icon inside, and a text below it
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: theme.primary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(context: context, builder: (context) => const ImportQuizModal());
                    },
                    icon: Icon(Icons.file_copy, color: theme.onBackground),
                    label: Text("Import", style: textTheme.displaySmall!.copyWith(color: theme.onBackground))),
              ],
            ),
            const SizedBox(height: 16),
            //* Generate
            //Button style: Basically a square with an icon inside, and a text below it
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: theme.primary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.smart_toy, color: theme.onBackground),
                    label: Text("Generate", style: textTheme.displaySmall!.copyWith(color: theme.onBackground))),
              ],
            ),
          ])),
    );
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
                for (int i = 0; i < quiz["questions"].length; i++) QuizQuestion(id: i, question: quiz["questions"][i]["question"], answers: List<String>.from(quiz["questions"][i]["answers"] as List), correctAnswer: List<int>.from(quiz["questions"][i]["correctAnswer"] as List), type: quiz["questions"][i]["type"] != null ? quizTypes.values[quiz["questions"][i]["type"]] : quizTypes.multipleChoice),
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
                  "type": question.type?.index ?? quizTypes.multipleChoice.index
                }
            ],
            "settings": quiz.settings
          }
      ]
    };
    //Save to prefs
    await prefs.setString("quizData", jsonEncode(quizData));
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
                const SizedBox(height: 5),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryContainer,
                      foregroundColor: theme.onBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                    ),
                    onPressed: () => validateJSON(context.read<AppState>()),
                    icon: const Icon(Icons.add),
                    label: const Text("Import"))
              ],
            )));
  }
}
