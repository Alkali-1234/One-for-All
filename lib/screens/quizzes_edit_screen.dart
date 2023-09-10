import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/models/quizzes_models.dart';
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

  void saveQuizSet(AppState appState) {
    setState(() async {
      appState.getQuizzes[widget.index] = quizSet;
      // Save to prefs

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
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Editing ${quizSet.title}", style: textTheme.displayMedium),
                Text("${quizSet.questions.length.toString()} Questions", style: textTheme.displayMedium)
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
                  onPressed: () => showDialog(context: context, builder: (context) => NewQuestionModal(quizSet: quizSet, setQuizSet: setQuizSet)),
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
                              label: const Text("Save")),
                          // ElevatedButton.icon(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: theme.primaryContainer,
                          //       foregroundColor: theme.onBackground,
                          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          //     ),
                          //     icon: Icon(Icons.close, color: theme.onBackground),
                          //     onPressed: () => Navigator.pop(context),
                          //     label: const Text("Cancel")),
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

class QueryListItem extends StatelessWidget {
  const QueryListItem({super.key, required this.question, required this.index, required this.setQuizSet, required this.quizIndex});
  final QuizQuestion question;
  final int index;
  final Function setQuizSet;
  final int quizIndex;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = context.watch<AppState>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => showDialog(context: context, builder: (context) => EditQuestionModal(question: question, index: index, setQuizSet: setQuizSet)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Question ${index + 1}", style: textTheme.displaySmall),
                    Text("${question.answers.length.toString()} Answers", style: textTheme.displaySmall),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(question.question, style: textTheme.displayMedium),
                    Text("${question.correctAnswer.length.toString()} Correct Answers", style: textTheme.displaySmall),
                  ],
                )
              ],
            )),
        const SizedBox(height: 5),
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
                  appState.getQuizzes[quizIndex].questions.insert(
                      index,
                      QuizQuestion(question: "Question", answers: [
                        "Answer 1"
                      ], correctAnswer: []));
                  setQuizSet(appState.getQuizzes[quizIndex]);
                },
                icon: const Icon(Icons.add),
                label: const Text("Add")),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryContainer,
                  foregroundColor: theme.onBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  appState.getQuizzes[quizIndex].questions.removeAt(index);
                  setQuizSet(appState.getQuizzes[quizIndex]);
                },
                icon: const Icon(Icons.delete),
                label: const Text("Delete")),
          ],
        )
      ],
    );
  }
}

///New quesetion modal
class NewQuestionModal extends StatefulWidget {
  const NewQuestionModal({super.key, required this.quizSet, required this.setQuizSet});
  final QuizSet quizSet;
  final Function setQuizSet;

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
                      widget.quizSet.questions.add(QuizQuestion(
                        question: "Question",
                        answers: [
                          "Answer 1"
                        ],
                        correctAnswer: [
                          1
                        ],
                      )),
                      widget.setQuizSet(widget.quizSet)
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
  const EditQuestionModal({super.key, required this.index, required this.question, required this.setQuizSet});
  final int index;
  final QuizQuestion question;
  final Function setQuizSet;

  @override
  State<EditQuestionModal> createState() => _EditQuestionModalState();
}

class _EditQuestionModalState extends State<EditQuestionModal> {
  quizTypes questionType = quizTypes.multipleChoice;
  late QuizQuestion question;
  final TextEditingController _questionController = TextEditingController();

  late List<TextEditingController> _textAnswerControllers;
  @override
  void initState() {
    super.initState();
    question = widget.question;
    if (questionType == quizTypes.multipleChoice) _questionController.text = question.question;
    if (questionType == quizTypes.multipleChoice) _textAnswerControllers = List.generate(question.answers.length, (index) => TextEditingController(text: question.answers[index]));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = context.watch<AppState>();
    return Dialog(
        child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Edit Question ${widget.index + 1}", style: textTheme.displayMedium),
                const SizedBox(height: 10),
                //* Question type (Multiple Choices) more will be added Soon™
                DropdownButton(
                    style: textTheme.displaySmall,
                    items: [
                      DropdownMenuItem(
                          value: questionType,
                          child: Text(
                            "Multiple Choice",
                            style: textTheme.displaySmall,
                          )),
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
                                        question.answers.add("Answer ${question.answers.length + 1}");
                                        question.correctAnswer.add(question.answers.length + 1);
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
                                    SizedBox(
                                      width: 200,
                                      child: TextField(
                                        controller: _textAnswerControllers[index],
                                        style: textTheme.displaySmall,
                                        cursorColor: theme.onBackground,
                                        decoration: InputDecoration(
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
                                    Checkbox(
                                        value: question.correctAnswer.contains(index),
                                        onChanged: (value) => setState(() {
                                              if (value == null) return;
                                              if (value) question.correctAnswer[index] = index;
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
                    : Text(
                        "how tf (frick) did you get here",
                        style: textTheme.displaySmall,
                      ),
                const SizedBox(height: 10),
                //* Done and Cancel
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
                          Navigator.pop(context);
                          widget.setQuizSet(appState.getQuizzes[widget.index]);
                        },
                        icon: const Icon(Icons.done),
                        label: const Text("Done")),
                  ],
                )
              ],
            )));
  }
}
