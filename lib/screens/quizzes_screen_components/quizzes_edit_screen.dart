import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/functions/quizzes_functions.dart';
import 'package:oneforall/models/quiz_question.dart';
import 'package:oneforall/premium/quiz_gen/quiz_gen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

import '../../main.dart';

//* Import components
import 'quizzes_edit_screen_components/new_question_modal.dart';
import 'quizzes_edit_screen_components/query_list_item.dart';
import 'quizzes_edit_screen_components/quiz_settings_modal.dart';

class QuizzesEditScreen extends StatefulWidget {
  const QuizzesEditScreen({super.key, required this.index});
  final int index;

  @override
  State<QuizzesEditScreen> createState() => _QuizzesEditScreenState();
}

class _QuizzesEditScreenState extends State<QuizzesEditScreen> {
  late QuizSet quizSet;
  String searchQuery = "";

  //* Keys
  final settingsKey = GlobalKey<QuizSettingsModalState>();

  //* Controllers
  final listController = ScrollController();

  @override
  void initState() {
    super.initState();
    quizSet = context.read<AppState>().getQuizzes[widget.index];
    listItems = List.generate(
        quizSet.questions.length,
        (index) => QueryListItem(
            question: quizSet.questions[index],
            index: index,
            setQuizSet: setQuizSet,
            quizIndex: widget.index,
            duplicated: false,
            remveListItem: (i) => setState(() => listItems.removeAt(i)),
            addListItem: (QueryListItem item) async {
              final key = GlobalKey<QueryListItemState>();
              setState(() {
                listItems.insert(item.index + 1, QueryListItem(key: key, question: item.question, index: item.index + 1, setQuizSet: setQuizSet, quizIndex: item.quizIndex, duplicated: true, addListItem: item.addListItem, remveListItem: (i) => setState(() => listItems.removeAt(i))));
              });
              await Future.delayed(const Duration(milliseconds: 50));
              key.currentState!.doColorAnim();
            }));
  }

  void setQuizSet(QuizSet quizSet) {
    setState(() {
      this.quizSet = quizSet;
    });
  }

  void refreshQuizLocalSave(AppState appState) async {
    final prefs = await SharedPreferences.getInstance();
// Save to prefs

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
                  "imagePath": question.imagePath,
                }
            ],
            "settings": quiz.settings
          }
      ]
    };
    //Save to prefs
    await prefs.setString("quizData", jsonEncode(quizData));
  }

  void saveQuizSet(AppState appState) async {
    final prefs = await SharedPreferences.getInstance();
// Save to prefs

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
                  "imagePath": question.imagePath,
                }
            ],
            "settings": quiz.settings
          }
      ]
    };
    //Save to prefs
    await prefs.setString("quizData", jsonEncode(quizData));
    setState(() {
      appState.getQuizzes[widget.index] = quizSet;
    });
    if (!mounted) return;
    Navigator.pop(context);
  }

  List<QueryListItem> listItems = [];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: MainContainer(
          onClose: () => showDialog(
              context: context,
              builder: (c) => Dialog(
                  child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Are you sure you want to exit? All unsaved changes will be lost!", style: textTheme.displayMedium),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => {
                                        QuizzesFunctions().refreshQuizzesFromLocal(appState, true),
                                        Navigator.pop(context),
                                        Navigator.pop(context),
                                      },
                                  child: const Text("Yes, exit.")),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryContainer,
                                    foregroundColor: theme.onBackground,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"))
                            ],
                          ),
                        ],
                      )))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                  cursorColor: theme.onBackground,
                  decoration: InputDecoration(hintStyle: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold, color: theme.onBackground.withOpacity(0.25)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), fillColor: theme.primary, filled: true, hintText: "Search", suffixIcon: Icon(Icons.search, size: 48, color: theme.onBackground), prefixIconColor: theme.onBackground),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Text(
                        "Editing ${quizSet.title}",
                        style: textTheme.displayMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //* Settings
                          IconButton(
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (c) => QuizSettingsModal(
                                        key: settingsKey,
                                        settings: quizSet.settings,
                                        quizTitle: quizSet.title,
                                        onClose: () => Navigator.pop(c),
                                      )),
                              icon: Icon(Icons.settings, color: theme.onBackground)),

                          const SizedBox(
                            width: 2.5,
                          ),
                          //* Delete
                          IconButton(
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (c) => DeleteConfirmationModal(onConfirm: () {
                                        Navigator.pop(c);
                                        Navigator.pop(context);
                                        appState.getQuizzes.removeAt(widget.index);
                                        appState.thisNotifyListeners();
                                        refreshQuizLocalSave(appState);
                                      })),
                              icon: const Icon(Icons.delete, color: Colors.red))
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: theme.primaryContainer,
                            foregroundColor: theme.onBackground,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) => NewQuestionModal(
                                  quizSet: quizSet,
                                  setQuizSet: setQuizSet,
                                  listController: listController,
                                  addQuestion: (question) async {
                                    final key = GlobalKey<QueryListItemState>();
                                    setState(() {
                                      listItems.add(QueryListItem(
                                          key: key,
                                          question: question,
                                          index: listItems.length,
                                          setQuizSet: setQuizSet,
                                          quizIndex: widget.index,
                                          duplicated: true,
                                          remveListItem: (i) => setState(() => listItems.removeAt(i)),
                                          addListItem: (QueryListItem item) async {
                                            final key = GlobalKey<QueryListItemState>();
                                            setState(() {
                                              listItems.insert(item.index + 1, QueryListItem(key: key, question: item.question, index: item.index + 1, setQuizSet: setQuizSet, quizIndex: item.quizIndex, duplicated: true, addListItem: item.addListItem, remveListItem: (i) => setState(() => listItems.removeAt(i))));
                                            });
                                            await Future.delayed(const Duration(milliseconds: 50));
                                            key.currentState!.doColorAnim();
                                          }));
                                    });
                                    await Future.delayed(const Duration(milliseconds: 50));
                                    await listController.animateTo(listController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.decelerate);
                                    key.currentState!.doColorAnim();
                                  })),
                          icon: const Icon(Icons.add),
                          label: const Text("Add Question")),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: theme.primaryContainer,
                              foregroundColor: theme.onBackground,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => showDialog(
                                context: context,
                                builder: (c) => QuizGenDialog(onInsertQuestions: (List<QuizQuestion> questions) {
                                      for (var question in questions) {
                                        quizSet.questions.add(question);
                                        listItems.add(QueryListItem(
                                            question: question,
                                            index: listItems.length,
                                            setQuizSet: setQuizSet,
                                            quizIndex: widget.index,
                                            duplicated: true,
                                            remveListItem: (i) => setState(() => listItems.removeAt(i)),
                                            addListItem: (QueryListItem item) async {
                                              final key = GlobalKey<QueryListItemState>();
                                              setState(() {
                                                listItems.insert(item.index + 1, QueryListItem(key: key, question: item.question, index: item.index + 1, setQuizSet: setQuizSet, quizIndex: item.quizIndex, duplicated: true, addListItem: item.addListItem, remveListItem: (i) => setState(() => listItems.removeAt(i))));
                                              });
                                              await Future.delayed(const Duration(milliseconds: 50));
                                              key.currentState!.doColorAnim();
                                            }));
                                      }
                                      setState(() {});
                                    })),
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text("Generate"))),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    controller: listController,
                    children: [
                      for (int index = 0; index < listItems.length; index++) ...[
                        if (searchQuery.isEmpty || listItems[index].question.question.toLowerCase().contains(searchQuery.toLowerCase())) listItems[index]
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                //* Save and discard
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => saveQuizSet(appState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Save", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (c) => Dialog(
                                child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: theme.background,
                                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Are you sure you want to exit? All unsaved changes will be lost!", style: textTheme.displayMedium),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                onPressed: () => {
                                                      QuizzesFunctions().refreshQuizzesFromLocal(appState, true),
                                                      Navigator.pop(context),
                                                      Navigator.pop(context),
                                                    },
                                                child: const Text("Yes, exit")),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: theme.primaryContainer,
                                                  foregroundColor: theme.onBackground,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("Cancel"))
                                          ],
                                        ),
                                      ],
                                    )))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Discard", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class DeleteConfirmationModal extends StatelessWidget {
  const DeleteConfirmationModal({super.key, required this.onConfirm});
  final Function onConfirm;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: Container(
          decoration: BoxDecoration(color: theme.background, borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Are you sure you want to delete this quiz?", style: textTheme.displayMedium),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => onConfirm(),
                        child: const Text("Yes, delete")),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryContainer,
                          foregroundColor: theme.onBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"))
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
