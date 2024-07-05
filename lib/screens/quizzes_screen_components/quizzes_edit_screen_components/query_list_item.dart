import "package:flutter/material.dart";
import "package:oneforall/main.dart";
import "package:provider/provider.dart";

import "../../../models/quizzes_models.dart";
import "dart:math" as math;

import "edit_question_dialog.dart";

class QueryListItem extends StatefulWidget {
  const QueryListItem({super.key, required this.question, required this.index, required this.setQuizSet, required this.quizIndex, required this.duplicated, required this.addListItem, required this.remveListItem});
  final QuizQuestion question;
  final int index;
  final Function setQuizSet;
  final int quizIndex;
  final bool duplicated;
  final Function addListItem;
  final Function remveListItem;

  @override
  State<QueryListItem> createState() => QueryListItemState();
}

class QueryListItemState extends State<QueryListItem> {
  void duplicateQuestion(QuizQuestion question, AppState appState) {
    //* New Quizquestion in order to not point to the same object
    QuizQuestion newQuestion = QuizQuestion(imagePath: question.imagePath, id: appState.getQuizzes[widget.quizIndex].questions.length, question: question.question, answers: [], correctAnswer: [], type: question.type);
    for (String answer in question.answers) {
      newQuestion.answers.add(answer);
    }
    for (int correctAnswer in question.correctAnswer) {
      newQuestion.correctAnswer.add(correctAnswer);
    }

    appState.getQuizzes[widget.quizIndex].questions.insert(widget.index, newQuestion);
    widget.addListItem(QueryListItem(
      question: newQuestion,
      index: widget.index,
      setQuizSet: widget.setQuizSet,
      quizIndex: widget.quizIndex,
      duplicated: true,
      addListItem: widget.addListItem,
      remveListItem: widget.remveListItem,
    ));
  }

  bool expandedView = false;
  Tween<double> tween = Tween<double>(begin: 0, end: 1);
  Tween<double> colorAnim = Tween<double>(begin: 0, end: 1);

  void doColorAnim() async {
    setState(() {
      colorAnim = Tween<double>(begin: 0, end: 1);
    });
    await Future.delayed(const Duration(milliseconds: 250));
    setState(() {
      colorAnim = Tween<double>(begin: 1, end: 0);
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.duplicated) {
      doColorAnim();
    } else {
      colorAnim = Tween<double>(begin: 0, end: 0);
    }
  }

  final key = GlobalKey<EditQuestionModalState>();

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
          child: TweenAnimationBuilder(
              tween: colorAnim,
              duration: const Duration(milliseconds: 250),
              builder: (context, value, child) {
                return ListTile(
                    tileColor: theme.onBackground.withOpacity(0.25 * value),
                    splashColor: theme.onBackground.withOpacity(0.25),
                    onTap: () async {
                      if (expandedView) {
                        if (key.currentState!.validateQuestions(context.read<AppState>()) == false) return;
                        setState(() {
                          tween = Tween<double>(begin: 0, end: 1);
                        });
                        await Future.delayed(const Duration(milliseconds: 250));
                        setState(() {
                          expandedView = false;
                        });
                        return;
                      } else {
                        setState(() {
                          tween = Tween<double>(begin: 1, end: 0);
                        });
                      }
                      await Future.delayed(const Duration(milliseconds: 250));
                      setState(() {
                        expandedView = !expandedView;
                      });
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder(duration: const Duration(milliseconds: 150), tween: tween, builder: (context, value, child) => Transform.rotate(angle: math.pi * -value, child: Icon(Icons.arrow_drop_down, color: theme.onBackground))),
                      ],
                    ),
                    title: Text(
                      widget.question.question,
                      style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //* Add button
                        IconButton(
                            onPressed: () {
                              appState.getQuizzes[widget.quizIndex].questions.insert(
                                  widget.index,
                                  QuizQuestion(imagePath: null, id: appState.getQuizzes[widget.quizIndex].questions.length + 1, question: "Question", answers: [
                                    "Answer 1",
                                    "Answer 2"
                                  ], correctAnswer: [
                                    0
                                  ]));
                              widget.setQuizSet(appState.getQuizzes[widget.quizIndex]);
                              widget.addListItem(QueryListItem(
                                question: appState.getQuizzes[widget.quizIndex].questions[widget.index],
                                index: widget.index,
                                setQuizSet: widget.setQuizSet,
                                quizIndex: widget.quizIndex,
                                duplicated: true,
                                addListItem: widget.addListItem,
                                remveListItem: widget.remveListItem,
                              ));
                            },
                            icon: const Icon(Icons.add, color: Colors.green)),
                        //* Duplicate button
                        IconButton(onPressed: () => duplicateQuestion(widget.question, appState), icon: Icon(Icons.copy, color: theme.onBackground)),
                        //* Delete button
                        IconButton(
                            onPressed: () {
                              appState.getQuizzes[widget.quizIndex].questions.removeAt(widget.index);
                              widget.setQuizSet(appState.getQuizzes[widget.quizIndex]);
                              widget.remveListItem(widget.index);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red)),
                      ],
                    ));
              }),
        ),
        if (expandedView)
          TweenAnimationBuilder(
            tween: tween,
            duration: const Duration(milliseconds: 250),
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, 10 * -value),
              child: child,
            ),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: EditQuestionModal(
                  key: key,
                  index: widget.index,
                  question: widget.question,
                  setQuizSet: widget.setQuizSet,
                  quizIndex: widget.quizIndex,
                  onDone: () async {
                    setState(() {
                      tween = Tween<double>(begin: 1, end: 0);
                    });
                    await Future.delayed(const Duration(milliseconds: 250));
                    setState(() {
                      expandedView = false;
                    });
                  },
                )),
          ),
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
