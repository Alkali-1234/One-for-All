import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
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
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        elapsedTime++;
      });
    });
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
  int highestStreak = 0;
  int questionsDone = 0;
  int redemptionAmount = 0;
  DateTime startTime = DateTime.now();
  int elapsedTime = 0;
  late Timer timer;

  //* Animation
  Tween<double> scoreStatTween = Tween<double>(begin: 0, end: 0);
  Tween<double> scoreStatAddTween = Tween<double>(begin: 1, end: 1);
  int scoreBeingAdded = 0;

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
      redemptionSet = QuizSet(title: "Redemption", description: "Redemption", questions: []);
      redemptionAmount++;
    });
  }

  String formatSeconds(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds - (minutes * 60);
    String formattedMinutes = minutes.toString().padLeft(2, "0");
    String formattedSeconds = remainingSeconds.toString().padLeft(2, "0");
    return "$formattedMinutes:$formattedSeconds";
  }

  void doNextQuestionAnimations(int score, int scoreBeingAdded) async {
    setState(() {
      this.scoreBeingAdded = scoreBeingAdded;
    });
    await Future.delayed(const Duration(milliseconds: 250));
    setState(() {
      scoreStatAddTween = Tween<double>(begin: 1, end: 0);
    });
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      scoreStatTween = Tween<double>(begin: score.toDouble(), end: score.toDouble() + scoreBeingAdded);
    });
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      scoreStatAddTween = Tween<double>(begin: 0, end: 1);
    });
  }

  void nextQuestion(bool correct, int score, QuizQuestion question) {
    //* Check if quiz is finished
    if (quizSet.questions.indexOf(currentQuestion) + 1 > quizSet.questions.length - 1) {
      questionsDone++;
      if (correct) {
        correctAnswers++;
        correctStreak++;
        if (correctStreak > highestStreak) {
          highestStreak = correctStreak;
        }
        this.score += score * (correctStreak / 10.round() + 1).round();
      } else {
        correctStreak = 0;
        redemptionSet.questions.add(question);
      }
      if (redemptionSet.questions.isNotEmpty) {
        initializeRedemption();

        doNextQuestionAnimations(this.score, score);
        return;
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => InterstitialScreen(
                  onClosed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EndScreen(score: score, correctAnswers: correctAnswers, totalQuestions: questionsDone, redemptionAmount: redemptionAmount, timeSpent: DateTime.now().difference(startTime), highestStreak: highestStreak))),
                  onFailed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EndScreen(score: score, correctAnswers: correctAnswers, totalQuestions: questionsDone, redemptionAmount: redemptionAmount, timeSpent: DateTime.now().difference(startTime), highestStreak: highestStreak))),
                )));
        return;
      }
    }

    doNextQuestionAnimations(this.score, score);
    setState(() {
      questionsDone++;
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
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        //* Statistics
        Row(
          children: [
            //* Score
            Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder(
                  tween: scoreStatTween,
                  duration: const Duration(milliseconds: 250),
                  builder: (context, double value, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.yellow),
                        const SizedBox(width: 5),
                        Text(value.toInt().toString(), style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 2.5),
                        //* + <score add amount> Score animation. Shows when the score increases, goes from being faded from above, to being faded out to the bottom
                        TweenAnimationBuilder(
                          tween: scoreStatAddTween,
                          duration: const Duration(milliseconds: 250),
                          builder: (context, value, child) {
                            return Opacity(opacity: 1 - value, child: Transform.translate(offset: Offset(0, -value), child: child));
                          },
                          child: Text("+${scoreBeingAdded.toString()}", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                        )
                      ],
                    );
                  }),
            ),
            //* Time Elapsed
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_rounded, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(formatSeconds(elapsedTime), style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            //* Streak
            Align(
              alignment: Alignment.centerRight,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 5),
                AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Text(correctStreak.toString(), style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold))),
              ]),
            )
          ],
        ),
        Expanded(
          child: currentQuestion.type == quizTypes.multipleChoice || currentQuestion.type == null
              ? MultipleChoice(
                  question: currentQuestion,
                  nextQuestionFunction: nextQuestion,
                )
              : const Placeholder(),
        ),
      ],
    );
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
    setState(() {
      showAnswers = false;
      selectedAnswers = [];
    });
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

class EndScreen extends StatefulWidget {
  const EndScreen({super.key, required this.score, required this.correctAnswers, required this.totalQuestions, required this.redemptionAmount, required this.timeSpent, required this.highestStreak});
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int redemptionAmount;
  final Duration timeSpent;
  final int highestStreak;

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: MainContainer(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text("Quiz Finished", style: textTheme.displayLarge!.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(
              height: 50,
            ),
            statisticCard(title: "Score", value: widget.score, context: context, index: 1),
            const SizedBox(
              height: 10,
            ),
            statisticCard(title: "Total Questions", value: widget.totalQuestions, context: context, index: 2),
            const SizedBox(height: 10),
            statisticCard(title: "Correct Answers", value: widget.correctAnswers, context: context, index: 3),
            const SizedBox(height: 10),
            statisticCard(title: "Highest Streak", value: widget.highestStreak, context: context, index: 4),
            const SizedBox(height: 10),
            statisticCard(title: "Redemption Amount", value: widget.redemptionAmount, context: context, index: 5),
            const SizedBox(height: 10),
            statisticCard(title: "Time Spent", value: widget.timeSpent.inSeconds, context: context, index: 6),
            Expanded(
                child: Center(
                    child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: theme.primaryContainer,
                foregroundColor: theme.onBackground,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              onPressed: () => Navigator.of(context).pop(),
              label: const Text("Continue"),
              icon: const Icon(Icons.check),
            ))),
          ],
        ),
      )),
    );
  }

  Widget statisticCard({required String title, required int value, required BuildContext context, required int index}) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: textTheme.displayMedium),
            //* Score, number adding animation
            NumberAddingAnimation(value: value, context: context, index: index),
          ],
        ),
      ),
    );
  }
}

class NumberAddingAnimation extends StatefulWidget {
  const NumberAddingAnimation({super.key, required this.value, required this.context, required this.index});
  final int value;
  final BuildContext context;
  final int index;

  @override
  State<NumberAddingAnimation> createState() => _NumberAddingAnimationState();
}

class _NumberAddingAnimationState extends State<NumberAddingAnimation> {
  Tween<double> tween = Tween<double>(begin: 0, end: 0);

  void startAnimation() async {
    await Future.delayed(Duration(milliseconds: 1200 * widget.index));
    setState(() {
      tween = Tween<double>(begin: 0, end: widget.value.toDouble());
    });
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: tween,
      duration: const Duration(milliseconds: 1000),
      builder: (context, double value, child) {
        return Text(value.toInt().toString(), style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold));
      },
    );
  }
}
