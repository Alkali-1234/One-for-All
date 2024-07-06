import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";

import "../../../constants.dart";
import "../../../models/quiz_question.dart";

//* Dropdown Question
class DropdownQuestion extends StatefulWidget {
  const DropdownQuestion({super.key, required this.question, required this.nextQuestionFunction, required this.doAnimationFunction, required this.toggleShowingAnswers});
  final QuizQuestion question;
  final Function nextQuestionFunction;
  final Function doAnimationFunction;
  final Function toggleShowingAnswers;

  @override
  State<DropdownQuestion> createState() => DropdownQuestionState();
}

class DropdownQuestionState extends State<DropdownQuestion> {
  //* Variables
  List<int> selectedAnswers = [];
  List<String> answers = [];
  List<String> sentence = [];
  bool showAnswers = false;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    //* Initialize variables
    answers = widget.question.answers;
    sentence = widget.question.question.split("<seperator />");
    // ignore: unused_local_variable
    for (var i in widget.question.correctAnswer) {
      selectedAnswers.add(0);
    }
  }

  void validateAnswer() async {
    widget.toggleShowingAnswers();
    setState(() {
      showAnswers = true;
    });
    int correctAmount = 0;
    for (int i = 0; i < selectedAnswers.length; i++) {
      if (widget.question.correctAnswer[i] == selectedAnswers[i]) {
        correctAmount++;
      }
    }
    await audioPlayer.setAsset("assets/audio/successSound.mp3");
    audioPlayer.play();
    widget.doAnimationFunction(correctAmount * 100 ~/ widget.question.correctAnswer.length);

    widget.nextQuestionFunction((correctAmount == widget.question.correctAnswer.length), correctAmount * 100 ~/ widget.question.correctAnswer.length, widget.question);
  }

  int indexOfDropDown(int pos) {
    int index = 0;
    for (int i = 0; i < sentence.length; i++) {
      if (i == pos) return index;
      if (sentence[i].contains("<dropdown answer=")) {
        index++;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Dropdown", style: textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 20),
        //* Sentence
        Wrap(
          runSpacing: 5,
          spacing: 10,
          children: [
            for (int i = 0; i < sentence.length; i++) ...[
              if (sentence[i].contains("<dropdown answer="))
                //* Dropdown
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    showAnswers ? Text(widget.question.answers[widget.question.correctAnswer[indexOfDropDown(i)]], style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.green)) : const SizedBox(),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: showAnswers ? (widget.question.correctAnswer[indexOfDropDown(i)] == selectedAnswers[indexOfDropDown(i)] ? Colors.green : Colors.red) : theme.primaryContainer,
                      ),
                      child: DropdownButton<int>(
                        value: selectedAnswers[indexOfDropDown(i)],
                        onChanged: showAnswers
                            ? null
                            : (int? value) {
                                setState(() {
                                  selectedAnswers[indexOfDropDown(i)] = value!;
                                });
                              },
                        items: [
                          for (int i = 0; i < widget.question.answers.length; i++) ...[
                            DropdownMenuItem(
                              value: i,
                              child: Text(widget.question.answers[i], style: textTheme.displaySmall),
                            )
                          ]
                        ],
                      ),
                    ),
                  ],
                )
              else
                Text(
                  sentence[i],
                  style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
            ]
          ],
        ),
        const SizedBox(height: 20),
        //* Validate answer button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: selectedAnswers.isNotEmpty && !showAnswers ? primaryGradient : null,
            border: selectedAnswers.isEmpty || showAnswers ? Border.all(color: theme.onBackground.withOpacity(0.25)) : null,
          ),
          height: 40,
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
      ],
    );
  }
}
