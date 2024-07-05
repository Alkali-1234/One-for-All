import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../functions/quizzes_functions.dart';
import '../../../main.dart';

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
                  QuizzesFunctions().refreshQuizzesFromLocal(context.read<AppState>(), false);
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
