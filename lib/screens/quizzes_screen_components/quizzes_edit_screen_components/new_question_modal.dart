import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../models/quizzes_models.dart';

///New quesetion modal
class NewQuestionModal extends StatefulWidget {
  const NewQuestionModal({super.key, required this.quizSet, required this.setQuizSet, required this.listController, required this.addQuestion});
  final QuizSet quizSet;
  final Function setQuizSet;
  final ScrollController listController;
  final Function addQuestion;

  @override
  State<NewQuestionModal> createState() => _NewQuestionModalState();
}

class _NewQuestionModalState extends State<NewQuestionModal> {
  QuizTypes questionType = QuizTypes.multipleChoice;
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
                        value: QuizTypes.multipleChoice,
                        child: Text(
                          "Multiple Choice",
                          style: textTheme.displaySmall,
                        )),
                    DropdownMenuItem(value: QuizTypes.reorder, child: Text("Reorder", style: textTheme.displaySmall)),
                    DropdownMenuItem(value: QuizTypes.dropdown, child: Text("Dropdown", style: textTheme.displaySmall)),
                  ],
                  onChanged: (value) => setState(() {
                        questionType = value as QuizTypes;
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
                        QuizTypes.multipleChoice => widget.quizSet.questions.add(QuizQuestion(imagePath: "", id: widget.quizSet.questions.length + 1, question: "Question", answers: [
                            "Answer 1",
                            "Answer 2"
                          ], correctAnswer: [
                            0
                          ])),
                        QuizTypes.reorder => widget.quizSet.questions.add(QuizQuestion(
                            imagePath: "",
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
                            type: QuizTypes.reorder)),
                        QuizTypes.dropdown => widget.quizSet.questions.add(QuizQuestion(
                            imagePath: "",
                            id: widget.quizSet.questions.length + 1,
                            question: "Question <dropdown answer=0 />",
                            answers: [
                              "Answer 1"
                            ],
                            correctAnswer: [
                              0
                            ],
                            type: QuizTypes.dropdown)),
                        _ => null,
                      },
                      widget.setQuizSet(widget.quizSet),
                      widget.addQuestion(widget.quizSet.questions.last),
                      //! fake
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
