import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/banner_ad.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/models/quizzes_models.dart';
import 'package:oneforall/screens/interstitial_screen.dart';
import './flashcardsPlay_screen.dart';

class QuizzesPlayScreen extends StatefulWidget {
  const QuizzesPlayScreen({super.key, required this.quizSet});
  final QuizSet quizSet;

  @override
  State<QuizzesPlayScreen> createState() => _QuizzesPlayScreenState();
}

class _QuizzesPlayScreenState extends State<QuizzesPlayScreen> {
  bool reversed = false;
  int currentScreen = 0;
  void changeScreen(int screen) {
    setState(() {
      if (screen > currentScreen) {
        reversed = false;
      } else {
        reversed = true;
      }
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: MainContainer(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PageTransitionSwitcher(
                reverse: reversed,
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                ),
                child: currentScreen == 0
                    ? PlayScreenConfirmation(changeScreenFunction: changeScreen)
                    : currentScreen == 1
                        ? PlayScreen(quizSet: widget.quizSet)
                        : const Placeholder(),
              ))),
    );
  }
}

//* Play screen confirmation screen
class PlayScreenConfirmation extends StatelessWidget {
  const PlayScreenConfirmation({super.key, required this.changeScreenFunction});
  final Function changeScreenFunction;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, c) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Quizzes", style: textTheme.displayLarge!.copyWith(fontStyle: FontStyle.italic)),
          Text("Let's get started.", style: textTheme.displaySmall),
          const SizedBox(height: 100),
          Container(
            width: c.maxWidth * 0.7,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: primaryGradient,
            ),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                onPressed: () {
                  changeScreenFunction(1);
                },
                child: Text(
                  "Start Quiz",
                  style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                )),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: c.maxWidth * 0.7,
            height: 50,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: theme.primaryContainer,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Nevermind",
                  style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                )),
          )
        ],
      );
    });
  }
}

//* Play screen
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.quizSet});
  final QuizSet quizSet;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  void initState() {
    super.initState();
    initializeVariables();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(context: context, builder: (context) => const ThreeTwoOneGoRibbon(), barrierDismissible: false);
    });
  }

  //* Variables
  late QuizQuestion currentQuestion;
  late QuizSet quizSet;

  int score = 0;
  int correctAnswers = 0;
  int correctStreak = 0;

  //* Redemption
  QuizSet redemptionSet = QuizSet(title: "Redemption", description: "Redemption", questions: []);

  //* Functions
  void initializeVariables() {
    quizSet = widget.quizSet;
    currentQuestion = quizSet.questions[0];
  }

  void initializeRedemption() {
    setState(() {
      quizSet = redemptionSet;
      currentQuestion = quizSet.questions[0];
    });
  }

  void nextQuestion(bool correct, int score, QuizQuestion question) {
    //* Check if quiz is finished
    if (quizSet.questions.indexOf(currentQuestion) + 1 > quizSet.questions.length - 1) {
      if (correct) {
        correctAnswers++;
        correctStreak++;
        this.score += score;
      } else {
        correctStreak = 0;
        redemptionSet.questions.add(question);
      }
      if (redemptionSet.questions.isNotEmpty) {
        initializeRedemption();
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => InterstitialScreen(
                  onClosed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EndScreen(score: score, correctAnswers: correctAnswers, totalQuestions: quizSet.questions.length))),
                  onFailed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EndScreen(score: score, correctAnswers: correctAnswers, totalQuestions: quizSet.questions.length))),
                )));
        return;
      }
    }
    setState(() {
      currentQuestion = quizSet.questions[quizSet.questions.indexOf(currentQuestion) + 1];
      if (correct) {
        correctAnswers++;
        correctStreak++;
        this.score += score;
      } else {
        correctStreak = 0;
        redemptionSet.questions.add(question);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return currentQuestion.type == quizTypes.multipleChoice || currentQuestion.type == null
        ? MultipleChoice(
            question: currentQuestion,
            nextQuestionFunction: nextQuestion,
          )
        : const Placeholder();
  }
}

//* Multiple choice question
class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key, required this.question, required this.nextQuestionFunction});
  final QuizQuestion question;
  final Function nextQuestionFunction;

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  List<int> selectedAnswers = [];
  bool showAnswers = false;
  void validateAnswer() async {
    int correctAnswers = 0;
    for (var answer in selectedAnswers) {
      if (widget.question.correctAnswer.contains(answer)) {
        correctAnswers++;
      }
    }
    setState(() {
      showAnswers = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    widget.nextQuestionFunction(
      (correctAnswers == widget.question.correctAnswer.length),
      calculateScore(correctAnswers, widget.question.correctAnswer.length),
      widget.question,
    );
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
    return score + Random().nextInt(10);
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
            gradient: primaryGradient,
          ),
          width: double.infinity,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.onBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => selectedAnswers.isNotEmpty ? validateAnswer() : null,
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
                      backgroundColor: theme.primaryContainer,
                      foregroundColor: theme.onBackground,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: selectedAnswers.contains(widget.question.answers.indexOf(answer)) ? BorderSide(color: theme.onBackground, width: 2) : const BorderSide(color: Colors.transparent, width: 2),
                    ),
                    onPressed: () => setState(() {
                      if (widget.question.correctAnswer.length > 1) {
                        selectedAnswers.add(widget.question.answers.indexOf(answer));
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

class EndScreen extends StatelessWidget {
  const EndScreen({super.key, required this.score, required this.correctAnswers, required this.totalQuestions});
  final int score;
  final int correctAnswers;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
