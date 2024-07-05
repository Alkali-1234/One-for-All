import "package:flutter/material.dart";
import "package:oneforall/components/main_container.dart";

import "../quizzes_play_screen.dart";

class EndScreen extends StatefulWidget {
  const EndScreen({super.key, required this.score, required this.correctAnswers, required this.totalQuestions, required this.redemptionAmount, required this.timeSpent, required this.highestStreak});
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int redemptionAmount;
  final Duration timeSpent;
  final int highestStreak;

  @override
  State<EndScreen> createState() => EndScreenState();
}

class EndScreenState extends State<EndScreen> with TickerProviderStateMixin {
  List<int> formatDurationToSeperateInts(Duration duration) {
    int minutes = (duration.inSeconds / 60).floor();
    int remainingSeconds = duration.inSeconds - (minutes * 60);
    return [
      minutes,
      remainingSeconds
    ];
  }

  bool continueButtonEnabled = false;

  void onAnimationFinished() async {
    await Future.delayed(const Duration(seconds: 10));
    setState(() {
      continueButtonEnabled = true;
    });
  }

  @override
  void initState() {
    super.initState();
    onAnimationFinished();
    //* Notify listeners after build
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: MainContainer(
          onClose: () => null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.primaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Time Spent", style: textTheme.displayMedium),
                        //* Score, number adding animation
                        Row(
                          children: [
                            NumberAddingAnimation(value: formatDurationToSeperateInts(widget.timeSpent)[0], context: context, index: 7),
                            Text(":", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                            NumberAddingAnimation(value: formatDurationToSeperateInts(widget.timeSpent)[1], context: context, index: 6),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: Center(
                        child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.primaryContainer,
                    disabledBackgroundColor: Colors.transparent,
                    foregroundColor: theme.onBackground,
                    disabledForegroundColor: theme.onBackground.withOpacity(0.5),
                    side: !continueButtonEnabled ? BorderSide(color: theme.onBackground.withOpacity(0.25)) : null,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  onPressed: continueButtonEnabled ? () => Navigator.of(context).pop() : null,
                  label: const Text("Back"),
                  icon: const Icon(Icons.arrow_back_rounded),
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
