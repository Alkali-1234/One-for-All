import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";

import "../../../constants.dart";
import "../../../models/quizzes_models.dart";

//* Reorder Question
class ReorderQuestion extends StatefulWidget {
  const ReorderQuestion({super.key, required this.question, required this.nextQuestionFunction, required this.doAnimationFunction, required this.toggleShowingAnswers, required this.currentCombo});
  final QuizQuestion question;
  final Function nextQuestionFunction;
  final Function doAnimationFunction;
  final Function toggleShowingAnswers;
  final int currentCombo;

  @override
  State<ReorderQuestion> createState() => ReorderQuestionState();
}

class ReorderQuestionState extends State<ReorderQuestion> {
  List<int> selectedAnswers = [];
  bool showAnswers = false;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.generate(widget.question.correctAnswer.length, (index) => -1);
  }

  void validateAnswers() async {
    widget.toggleShowingAnswers();
    setState(() {
      showAnswers = true;
    });
    int correctAnswers = 0;
    for (int i = 0; i < selectedAnswers.length; i++) {
      if (selectedAnswers.length > i && selectedAnswers[i] == widget.question.correctAnswer[i]) {
        correctAnswers++;
      }
    }
    await audioPlayer.setAsset("assets/audio/successSound.mp3");
    audioPlayer.play();
    widget.doAnimationFunction(100 * correctAnswers);
    // Future.delayed(const Duration(seconds: 2), () {
    //   widget.toggleShowingAnswers();
    //   setState(() {
    //     showAnswers = false;
    //   });
    widget.nextQuestionFunction((correctAnswers == widget.question.correctAnswer.length), 100 * correctAnswers, widget.question);
    // });
    await Future.delayed(Duration(milliseconds: correctAnswers == widget.question.correctAnswer.length ? (1500 - (widget.currentCombo * 100).round()) : 3000));
    setState(() {
      showAnswers = false;
      selectedAnswers = [];
    });
  }

  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Text("Reorder", style: textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(
          height: 10,
        ),
        Text(
          widget.question.question,
          style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        //* Validate Answer
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: selectedAnswers.isNotEmpty && !showAnswers ? primaryGradient : null,
            border: selectedAnswers.isEmpty || showAnswers ? Border.all(color: theme.onBackground.withOpacity(0.25)) : null,
          ),
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.onBackground,
                disabledForegroundColor: theme.onBackground.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: showAnswers || selectedAnswers.contains(-1) ? null : () => validateAnswers(),
              icon: const Icon(Icons.check),
              label: const Text("Validate Answers")),
        ),
        //* Gridvew of answers
        Expanded(
          flex: 1,
          child: Center(
            child: Wrap(
              runSpacing: 10,
              spacing: 10,
              children: [
                for (var answer in widget.question.answers) ...[
                  Draggable<int>(
                    onDragStarted: () => setState(() {
                      dragging = true;
                    }),
                    onDragEnd: (details) => setState(() {
                      dragging = false;
                    }),
                    data: widget.question.answers.indexOf(answer),
                    feedback: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.primaryContainer,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text(answer, style: textTheme.displaySmall),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.primaryContainer,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text(answer, style: textTheme.displaySmall),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Wrap(
              runSpacing: 10,
              spacing: 10,
              children: [
                for (int i = 0; i < widget.question.correctAnswer.length; i++) ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      showAnswers
                          ? Text(
                              widget.question.answers[widget.question.correctAnswer[i]],
                              style: textTheme.displaySmall!.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 10),
                      DragTarget<int>(
                        builder: (context, candidateData, rejectedData) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: dragging ? const EdgeInsets.all(4) : const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent,
                              border: dragging ? Border.all(color: theme.onBackground.withOpacity(0.25), width: 1) : null,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: !showAnswers
                                    ? theme.primaryContainer
                                    : widget.question.correctAnswer[i] == selectedAnswers[i]
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: selectedAnswers.length > i && selectedAnswers[i] != -1
                                    ? Text(
                                        widget.question.answers[selectedAnswers[i]],
                                        style: textTheme.displaySmall,
                                      )
                                    : Text("Order #${i + 1}", style: textTheme.displaySmall),
                              ),
                            ),
                          );
                        },
                        onAcceptWithDetails: (data) {
                          for (var i = 0; i < widget.question.correctAnswer.length - selectedAnswers.length; i++) {
                            //Add missing answers
                            //fuck state
                            selectedAnswers.add(-1);
                          }

                          setState(() {
                            selectedAnswers[i] = data.data;
                          });
                        },
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}
