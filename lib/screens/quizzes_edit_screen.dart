import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/components/quizzes_components/drag_and_drop_edit.dart';
import 'package:oneforall/components/quizzes_components/drop_down_edit.dart';
import 'package:oneforall/functions/quizzes_functions.dart';
import 'package:oneforall/models/quizzes_models.dart';
import 'package:oneforall/screens/quizzes_screen.dart';
import 'package:oneforall/styles/styles.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

import '../main.dart';

class QuizzesEditScreen extends StatefulWidget {
  const QuizzesEditScreen({super.key, required this.index});
  final int index;

  @override
  State<QuizzesEditScreen> createState() => _QuizzesEditScreenState();
}

class _QuizzesEditScreenState extends State<QuizzesEditScreen> {
  late QuizSet quizSet;

  //* Keys
  final settingsKey = GlobalKey<_QuizSettingsModalState>();

  //* Controllers
  final listController = ScrollController();

  @override
  void initState() {
    super.initState();
    quizSet = context.read<AppState>().getQuizzes[widget.index];
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
                  "type": question.type?.index ?? quizTypes.multipleChoice.index
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
                  "type": question.type?.index ?? quizTypes.multipleChoice.index
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
    Navigator.pop(context);
  }

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
                                    backgroundColor: theme.primaryContainer,
                                    foregroundColor: theme.onBackground,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => {
                                        QuizzesFunctions().refreshQuizzesFromLocal(appState, true),
                                        Navigator.pop(context),
                                        Navigator.pop(context),
                                      },
                                  child: const Text("Confirm")),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryContainer,
                        foregroundColor: theme.onBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => showDialog(context: context, builder: (context) => NewQuestionModal(quizSet: quizSet, setQuizSet: setQuizSet, listController: listController)),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Question")),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    children: [
                      //* Queries
                      Flexible(
                          flex: 10,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            controller: listController,
                            itemBuilder: (context, index) {
                              return QueryListItem(question: quizSet.questions[index], index: index, setQuizSet: setQuizSet, quizIndex: widget.index);
                            },
                            itemCount: quizSet.questions.length,
                          )),
                      const SizedBox(height: 10),
                      Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryContainer,
                                    foregroundColor: theme.onBackground,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(Icons.save, color: theme.onBackground),
                                  onPressed: () => saveQuizSet(appState),
                                  label: const Text("Save & Quit")),
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryContainer,
                                    foregroundColor: theme.onBackground,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(Icons.save, color: theme.onBackground),
                                  onPressed: () async {
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
                                                  "type": question.type?.index ?? quizTypes.multipleChoice.index
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
                                    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Saved", style: TextStyle(color: Colors.white))));
                                  },
                                  label: const Text("Save")),
                            ],
                          )),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}

class QueryListItem extends StatefulWidget {
  const QueryListItem({super.key, required this.question, required this.index, required this.setQuizSet, required this.quizIndex});
  final QuizQuestion question;
  final int index;
  final Function setQuizSet;
  final int quizIndex;

  @override
  State<QueryListItem> createState() => _QueryListItemState();
}

class _QueryListItemState extends State<QueryListItem> {
  void duplicateQuestion(QuizQuestion question, AppState appState) {
    //* New Quizquestion in order to not point to the same object
    QuizQuestion newQuestion = QuizQuestion(id: appState.getQuizzes[widget.quizIndex].questions.length, question: question.question, answers: [], correctAnswer: [], type: question.type);
    for (String answer in question.answers) {
      newQuestion.answers.add(answer);
    }
    for (int correctAnswer in question.correctAnswer) {
      newQuestion.correctAnswer.add(correctAnswer);
    }

    appState.getQuizzes[widget.quizIndex].questions.insert(widget.index, newQuestion);
    widget.setQuizSet(appState.getQuizzes[widget.quizIndex]);
  }

  bool expandedView = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = context.watch<AppState>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //* New design
        Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: theme.onBackground.withOpacity(0.125), width: 0.5)),
          ),
          child: ListTile(
              splashColor: theme.onBackground.withOpacity(0.125),
              onTap: () => setState(() {
                    expandedView = !expandedView;
                  }),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.flip(flipY: expandedView, child: Icon(Icons.arrow_drop_down, color: theme.onBackground)),
                ],
              ),
              title: Text(widget.question.question, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //* Add button
                  IconButton(
                      onPressed: () {
                        appState.getQuizzes[widget.quizIndex].questions.insert(
                            widget.index,
                            QuizQuestion(id: appState.getQuizzes[widget.quizIndex].questions.length + 1, question: "Question", answers: [
                              "Answer 1",
                              "Answer 2"
                            ], correctAnswer: [
                              0
                            ]));
                        widget.setQuizSet(appState.getQuizzes[widget.quizIndex]);
                      },
                      icon: const Icon(Icons.add, color: Colors.green)),
                  //* Duplicate button
                  IconButton(onPressed: () => duplicateQuestion(widget.question, appState), icon: Icon(Icons.copy, color: theme.onBackground)),
                  //* Delete button
                  IconButton(
                      onPressed: () {
                        appState.getQuizzes[widget.quizIndex].questions.removeAt(widget.index);
                        widget.setQuizSet(appState.getQuizzes[widget.quizIndex]);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red)),
                ],
              )),
        ),
        if (expandedView) Padding(padding: const EdgeInsets.only(left: 16.0), child: EditQuestionModal(index: widget.index, question: widget.question, setQuizSet: widget.setQuizSet, quizIndex: widget.quizIndex)),
        //! Old design
        // ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        //       backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //     ),
        //     onPressed: () => showDialog(context: context, builder: (context) => EditQuestionModal(question: question, index: index, setQuizSet: setQuizSet, quizIndex: quizIndex), barrierDismissible: false),
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Text("Question ${index + 1}", style: textTheme.displaySmall),
        //             Text("${question.answers.length.toString()} Answers", style: textTheme.displaySmall),
        //           ],
        //         ),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Flexible(
        //               flex: 2,
        //               child: Text(
        //                 question.question,
        //                 style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
        //                 overflow: TextOverflow.ellipsis,
        //                 maxLines: 1,
        //                 softWrap: true,
        //               ),
        //             ),
        //             Flexible(flex: 1, child: FittedBox(child: Text("${question.correctAnswer.length.toString()} Correct Answers", style: textTheme.displaySmall))),
        //           ],
        //         )
        //       ],
        //     )),
        // const SizedBox(height: 5),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     ElevatedButton.icon(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: theme.primaryContainer,
        //           foregroundColor: theme.onBackground,
        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //         ),
        //         onPressed: () {
        //           appState.getQuizzes[quizIndex].questions.insert(
        //               index,
        //               QuizQuestion(id: appState.getQuizzes[quizIndex].questions.length + 1, question: "Question", answers: [
        //                 "Answer 1"
        //               ], correctAnswer: []));
        //           setQuizSet(appState.getQuizzes[quizIndex]);
        //         },
        //         icon: const Icon(Icons.add),
        //         label: const Text("Add")),
        //     ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: theme.primaryContainer, foregroundColor: theme.onBackground, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => duplicateQuestion(question, appState), icon: const Icon(Icons.copy), label: const Text("Duplicate")),
        //     ElevatedButton.icon(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: theme.primaryContainer,
        //           foregroundColor: theme.onBackground,
        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //         ),
        //         onPressed: () {
        //           appState.getQuizzes[quizIndex].questions.removeAt(index);
        //           setQuizSet(appState.getQuizzes[quizIndex]);
        //         },
        //         icon: const Icon(Icons.delete),
        //         label: const Text("Delete")),
        //   ],
        // )
      ],
    );
  }
}

///New quesetion modal
class NewQuestionModal extends StatefulWidget {
  const NewQuestionModal({super.key, required this.quizSet, required this.setQuizSet, required this.listController});
  final QuizSet quizSet;
  final Function setQuizSet;
  final ScrollController listController;

  @override
  State<NewQuestionModal> createState() => _NewQuestionModalState();
}

class _NewQuestionModalState extends State<NewQuestionModal> {
  quizTypes questionType = quizTypes.multipleChoice;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
        backgroundColor: theme.background,
        child: Container(
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("New Question", style: textTheme.displayMedium),
              //* Question type
              DropdownButton(
                  value: questionType,
                  style: textTheme.displaySmall,
                  items: [
                    DropdownMenuItem(
                        value: quizTypes.multipleChoice,
                        child: Text(
                          "Multiple Choice",
                          style: textTheme.displaySmall,
                        )),
                    DropdownMenuItem(value: quizTypes.reorder, child: Text("Reorder", style: textTheme.displaySmall)),
                    DropdownMenuItem(value: quizTypes.dropdown, child: Text("Dropdown", style: textTheme.displaySmall)),
                  ],
                  onChanged: (value) => setState(() {
                        questionType = value as quizTypes;
                      })),
              const SizedBox(height: 10),
              //* Create and Cancel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryContainer,
                      foregroundColor: theme.onBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => {
                      switch (questionType) {
                        quizTypes.multipleChoice => widget.quizSet.questions.add(QuizQuestion(id: widget.quizSet.questions.length + 1, question: "Question", answers: [
                            "Answer 1"
                          ], correctAnswer: [
                            0
                          ])),
                        quizTypes.reorder => widget.quizSet.questions.add(QuizQuestion(
                            id: widget.quizSet.questions.length + 1,
                            question: "Question",
                            answers: [
                              "Answer 1",
                              "Answer 2"
                            ],
                            correctAnswer: [
                              0,
                              1
                            ],
                            type: quizTypes.reorder)),
                        quizTypes.dropdown => widget.quizSet.questions.add(QuizQuestion(
                            id: widget.quizSet.questions.length + 1,
                            question: "Question <dropdown answer=0 />",
                            answers: [
                              "Answer 1"
                            ],
                            correctAnswer: [
                              0
                            ],
                            type: quizTypes.dropdown)),
                        _ => null,
                      },
                      widget.setQuizSet(widget.quizSet),
                      //! FIXME fake
                      //** ------------ Update --------------- **
                      //* Should be real this time */
                      widget.listController.animateTo(widget.listController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.decelerate)
                    },
                    child: const Text("Create"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryContainer,
                      foregroundColor: theme.onBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

///* Edit question modal
class EditQuestionModal extends StatefulWidget {
  const EditQuestionModal({super.key, required this.index, required this.question, required this.setQuizSet, required this.quizIndex});
  final int index;
  final QuizQuestion question;
  final Function setQuizSet;
  final int quizIndex;

  @override
  State<EditQuestionModal> createState() => _EditQuestionModalState();
}

class _EditQuestionModalState extends State<EditQuestionModal> {
  late quizTypes questionType;
  late QuizQuestion question;
  final TextEditingController _questionController = TextEditingController();

  late List<TextEditingController> _textAnswerControllers;
  @override
  void initState() {
    super.initState();
    question = widget.question;
    questionType = question.type ?? quizTypes.multipleChoice;
    if (questionType == quizTypes.multipleChoice) _questionController.text = question.question;
    if (questionType == quizTypes.multipleChoice) _textAnswerControllers = List.generate(question.answers.length, (index) => TextEditingController(text: question.answers[index]));
  }

  String error = "";

  //* Keys
  final dropDownEditKey = GlobalKey<DropDownEditState>();
  final reorderEditKey = GlobalKey<ReorderEditState>();

  //* Functions
  void validateDropdownQuestion(AppState appState) {
    if (dropDownEditKey.currentState == null) {
      throw Exception("Something went wrong. Please try again");
    }
    final dropDownEditState = dropDownEditKey.currentState;
    if (dropDownEditState!.dropdownSentence.isEmpty) {
      throw Exception("Sentence is empty");
    }
    if (dropDownEditState.dropdownAnswers.isEmpty || dropDownEditState.dropdownSentence.isEmpty) {
      throw Exception("There must be at least 1 answer and 1 sentence");
    }
    if (dropDownEditState.dropdownSentence.indexOf("<seperator />") > 0) {
      throw Exception("Illegal word: <seperator />");
    }

    QuizQuestion quizQuestion = QuizQuestion(
        id: widget.index,
        question: dropDownEditState.dropdownSentence.join("<seperator />"),
        answers: dropDownEditState.dropdownAnswers,
        correctAnswer: [
          for (var sentence in dropDownEditState.dropdownSentence)
            if (sentence.contains("<dropdown answer=")) int.parse(sentence.split("=")[1].split(" ")[0]),
        ],
        type: quizTypes.dropdown);
    appState.getQuizzes[widget.quizIndex].questions[widget.index] = quizQuestion;
  }

  void validateReorderQuestion(AppState appState) {
    //* Check if there is atleast 1 drag item and 1 drop item
    if (reorderEditKey.currentState == null) {
      throw Exception("Something went wrong. Please try again");
    }
    if (reorderEditKey.currentState!.draggables.isEmpty || reorderEditKey.currentState!.correctOrder.isEmpty) {
      throw Exception("There must be at least 1 drag item and 1 drop item");
    }
    //* Check if there is no duplicate drag items
    for (var draggable in reorderEditKey.currentState!.draggables) {
      if (reorderEditKey.currentState!.draggables.where((element) => element == draggable).length > 1) {
        throw Exception("There cannot be duplicate drag items");
      }
    }
    QuizQuestion quizQuestion = QuizQuestion(id: widget.index, question: reorderEditKey.currentState!.question, answers: reorderEditKey.currentState!.draggables, correctAnswer: reorderEditKey.currentState!.correctOrder, type: quizTypes.reorder);
    appState.getQuizzes[widget.quizIndex].questions[widget.index] = quizQuestion;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = context.watch<AppState>();
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Question ${widget.index + 1}", style: textTheme.displayMedium),
              const SizedBox(height: 10),
              //* Question type (Multiple Choices, Dropdown, Drag an Drop) more will be added Soon™
              DropdownButton(
                  value: questionType,
                  style: textTheme.displaySmall,
                  items: [
                    DropdownMenuItem(
                        value: quizTypes.multipleChoice,
                        child: Text(
                          "Multiple Choice",
                          style: textTheme.displaySmall,
                        )),
                    DropdownMenuItem(value: quizTypes.dropdown, child: Text("Dropdown", style: textTheme.displaySmall)),
                    DropdownMenuItem(value: quizTypes.reorder, child: Text("Reorder", style: textTheme.displaySmall)),
                  ],
                  onChanged: (value) => setState(() {
                        questionType = value as quizTypes;
                      })),
              const SizedBox(height: 10),
              //* Question
              questionType == quizTypes.multipleChoice
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _questionController,
                          style: textTheme.displaySmall,
                          cursorColor: theme.onBackground,
                          decoration: InputDecoration(
                            fillColor: theme.primary,
                            filled: true,
                            hintText: "Question",
                            hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.onBackground, width: 1), borderRadius: BorderRadius.circular(10)),
                          ),
                          onChanged: (value) => setState(() {
                            question.question = value;
                          }),

                          //* Answers | Checklist (Answer)
                        ),
                        const SizedBox(height: 10),
                        //* Add answer
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryContainer,
                                  foregroundColor: theme.onBackground,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => setState(() {
                                      _textAnswerControllers.add(TextEditingController(text: "Answer ${question.answers.length + 1}"));
                                      question.answers.add("Answer ${question.answers.length + 1}");
                                    }),
                                icon: const Icon(Icons.add),
                                label: const Text("Add Answer")),
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryContainer,
                                  foregroundColor: theme.onBackground,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => setState(() {
                                      question.answers.removeLast();
                                      question.correctAnswer.removeLast();
                                    }),
                                icon: const Icon(Icons.delete),
                                label: const Text("Delete Answer")),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: SizedBox(
                                      width: 200,
                                      child: TextField(
                                        onTap: () => _textAnswerControllers[index].selection = TextSelection(baseOffset: 0, extentOffset: _textAnswerControllers[index].text.length),
                                        controller: _textAnswerControllers[index],
                                        style: textTheme.displaySmall,
                                        cursorColor: theme.onBackground,
                                        decoration: InputDecoration(
                                          fillColor: theme.primary,
                                          filled: true,
                                          hintText: "Answer ${index + 1}",
                                          hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold),
                                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.onBackground, width: 1), borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            question.answers[index] = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Checkbox(
                                      checkColor: theme.onBackground,
                                      value: question.correctAnswer.contains(index),
                                      onChanged: (value) => setState(() {
                                            if (value == null) return;
                                            if (value) question.correctAnswer.add(index);
                                            if (!value) question.correctAnswer.remove(index);
                                            setState(() {});
                                          }))
                                ],
                              );
                            },
                            itemCount: question.answers.length,
                          ),
                        ),
                      ],
                    )
                  : questionType == quizTypes.dropdown
                      ? DropDownEdit(
                          key: dropDownEditKey,
                          question: question,
                        )
                      : questionType == quizTypes.reorder
                          ? ReorderEdit(key: reorderEditKey, question: widget.question.type == quizTypes.reorder ? question : null)
                          : Text(
                              "how tf (frick) did you get here",
                              style: textTheme.displaySmall,
                            ),
              const SizedBox(height: 10),
              //* Done
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryContainer,
                        foregroundColor: theme.onBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (questionType == quizTypes.multipleChoice) {
                          if (question.question == "") {
                            setState(() {
                              error = "Question cannot be empty";
                            });
                            return;
                          }
                          if (question.answers.length < 2) {
                            setState(() {
                              error = "There must be at least 2 answers";
                            });
                            return;
                          }
                          if (question.correctAnswer.isEmpty) {
                            setState(() {
                              error = "There must be at least 1 correct answer";
                            });
                            return;
                          }
                          //* check for duplicates
                          for (var answer in question.answers) {
                            if (question.answers.where((element) => element == answer).length > 1) {
                              setState(() {
                                error = "There cannot be duplicate answers";
                              });
                              return;
                            }
                          }
                        }
                        if (questionType == quizTypes.dropdown) {
                          try {
                            validateDropdownQuestion(appState);
                          } on Exception catch (e) {
                            setState(() {
                              error = e.toString();
                            });
                            return;
                          }
                        }
                        if (questionType == quizTypes.reorder) {
                          try {
                            validateReorderQuestion(appState);
                          } on Exception catch (e) {
                            setState(() {
                              error = e.toString();
                            });
                          }
                        }
                        Navigator.pop(context);
                        widget.setQuizSet(appState.getQuizzes[widget.quizIndex]);
                      },
                      icon: const Icon(Icons.done),
                      label: const Text("Done")),
                ],
              ),

              error != "" ? Text(error, style: textTheme.displaySmall!.copyWith(color: theme.error)) : const SizedBox(),
            ],
          ),
        ));
  }
}

class QuizSettingsModal extends StatefulWidget {
  const QuizSettingsModal({super.key, required this.settings, required this.quizTitle, required this.onClose});
  final Map<String, dynamic> settings;
  final String quizTitle;
  final Function onClose;

  @override
  State<QuizSettingsModal> createState() => _QuizSettingsModalState();
}

class _QuizSettingsModalState extends State<QuizSettingsModal> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Settings for ${widget.quizTitle}", style: textTheme.displayMedium),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Shuffle Questions", style: textTheme.displaySmall),
                  Switch(
                      activeColor: Colors.green,
                      activeTrackColor: Colors.white,
                      inactiveThumbColor: Colors.red,
                      value: widget.settings["shuffleQuestions"] ?? false,
                      onChanged: (value) => setState(() {
                            widget.settings["shuffleQuestions"] = value;
                          }))
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Shuffle Answers", style: textTheme.displaySmall),
                  Switch(
                      activeColor: Colors.green,
                      activeTrackColor: Colors.white,
                      inactiveThumbColor: Colors.red,
                      value: widget.settings["shuffleAnswers"] ?? false,
                      onChanged: (value) => setState(() {
                            widget.settings["shuffleAnswers"] = value;
                          }))
                ],
              ),
              const SizedBox(height: 2),
              //* Redemption amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Redemption Amounts", style: textTheme.displaySmall),
                  IntrinsicWidth(
                    child: TextField(
                      controller: TextEditingController(text: widget.settings["redemptionAmounts"] != null ? widget.settings["redemptionAmounts"].toString() : ""),
                      keyboardType: TextInputType.number,
                      style: textTheme.displaySmall,
                      cursorColor: theme.onBackground,
                      decoration: TextInputStyle(theme: theme, textTheme: textTheme).getTextInputStyle().copyWith(hintText: "Amount", hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold)),
                      onChanged: (value) => setState(() {
                        widget.settings["redemptionAmounts"] = value;
                      }),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryContainer,
                    foregroundColor: theme.onBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => widget.onClose(),
                  icon: const Icon(Icons.check),
                  label: const Text("Done"))
            ],
          ),
        ),
      ),
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
                          backgroundColor: theme.primaryContainer,
                          foregroundColor: theme.onBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => onConfirm(),
                        child: const Text("Confirm")),
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
