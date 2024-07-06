import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../constants.dart';
import '../../../models/quiz_question.dart';

//* Multiple choice question
class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key, required this.question, required this.nextQuestionFunction, required this.doAnimationFunction, required this.toggleShowingAnswers, required this.currentCombo});
  final QuizQuestion question;
  final Function nextQuestionFunction;
  final Function doAnimationFunction;
  final Function toggleShowingAnswers;
  final int currentCombo;

  @override
  State<MultipleChoice> createState() => MultipleChoiceState();
}

class MultipleChoiceState extends State<MultipleChoice> {
  List<int> selectedAnswers = [];
  bool showAnswers = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  void validateAnswer() async {
    int correctAnswers = 0;
    for (var answer in selectedAnswers) {
      if (widget.question.correctAnswer.contains(answer)) {
        correctAnswers++;
      }
    }
    if (correctAnswers == widget.question.correctAnswer.length) {
      await audioPlayer.setAsset("assets/audio/successSound.mp3");
      audioPlayer.play();
    }
    widget.toggleShowingAnswers();
    setState(() {
      showAnswers = true;
    });
    //await Future.delayed(const Duration(milliseconds: 500));
    int calculatedScore = calculateScore(correctAnswers, widget.question.correctAnswer.length);
    widget.doAnimationFunction(calculatedScore);
    // await Future.delayed(const Duration(seconds: 2));
    widget.toggleShowingAnswers();
    widget.nextQuestionFunction(
      (correctAnswers == widget.question.correctAnswer.length),
      calculatedScore,
      widget.question,
    );
    final correct = correctAnswers == widget.question.correctAnswer.length;
    await Future.delayed(Duration(milliseconds: correct ? (1500 - (widget.currentCombo * 100).round()) : 3000));
    setState(() {
      showAnswers = false;
      selectedAnswers = [];
    });
  }

  int calculateScore(int correctAnswers, int answersLength) {
    int score = 0;
    if (correctAnswers == answersLength) {
      score = 100;
    } else if (correctAnswers == 0) {
      score = 0;
    } else {
      score = (correctAnswers / answersLength * 100).round();
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    // var textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        //* Question
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 50,
            ),
            Text("Multiple Choice - ${widget.question.correctAnswer.length > 1 ? "Multiple Answers" : "One Answer"}", style: Theme.of(context).textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(
              height: 10,
            ),
            //* Question
            Text(
              widget.question.question,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        //* Validate answer button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: selectedAnswers.isNotEmpty && !showAnswers ? primaryGradient : null,
            border: selectedAnswers.isEmpty || showAnswers ? Border.all(color: theme.onBackground.withOpacity(0.25)) : null,
          ),
          width: double.infinity,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.onBackground,
                disabledForegroundColor: theme.onBackground.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: selectedAnswers.isNotEmpty && !showAnswers ? () => validateAnswer() : null,
              icon: const Icon(Icons.check),
              label: const Text("Validate Answer")),
        ),
        const SizedBox(height: 10),
        //* Choices
        Expanded(
            child: Column(
          children: [
            for (var answer in widget.question.answers) ...[
              Flexible(
                flex: 1,
                child: SizedBox.expand(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      //* Change color based on answer
                      //* If question answer is correct, turn green
                      //* If user answers wrong, turn red
                      //* If answer is not selected, turn default color
                      backgroundColor: !showAnswers
                          ? theme.primaryContainer
                          : showAnswers && widget.question.correctAnswer.contains(widget.question.answers.indexOf(answer))
                              ? Colors.green
                              : showAnswers && !widget.question.correctAnswer.contains(widget.question.answers.indexOf(answer)) && selectedAnswers.contains(widget.question.answers.indexOf(answer))
                                  ? Colors.red
                                  : theme.primaryContainer,

                      foregroundColor: theme.onBackground,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: selectedAnswers.contains(widget.question.answers.indexOf(answer)) ? BorderSide(color: theme.onBackground, width: 2) : const BorderSide(color: Colors.transparent, width: 2),
                    ),
                    onPressed: showAnswers
                        ? () {}
                        : () => setState(() {
                              if (widget.question.correctAnswer.length > 1) {
                                if (selectedAnswers.contains(widget.question.answers.indexOf(answer))) {
                                  selectedAnswers.remove(widget.question.answers.indexOf(answer));
                                } else {
                                  selectedAnswers.add(widget.question.answers.indexOf(answer));
                                }
                              } else {
                                selectedAnswers = [
                                  widget.question.answers.indexOf(answer)
                                ];
                              }
                            }),
                    child: Text(answer),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ],
        )),
      ],
    );
  }
}
