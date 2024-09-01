import 'package:flutter/material.dart';
import 'package:oneforall/components/styled_components/primary_elevated_button.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:provider/provider.dart';

import '../../../components/styled_components/elevated_button.dart';
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
    var ctheme = getThemeFromTheme(theme);
    return LayoutBuilder(builder: (context, c) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Quizzes", style: textTheme.displayLarge!.copyWith(fontStyle: FontStyle.italic)),
          Text("Let's get started.", style: textTheme.displaySmall),
          const SizedBox(height: 100),
          SizedBox(
            width: c.maxWidth * 0.7,
            child: StyledPrimaryElevatedButton(
                theme: ctheme,
                onPressed: () {
                  changeScreenFunction(1);
                },
                child: Text(
                  "Start Quiz",
                  style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                )),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: c.maxWidth * 0.7,
            child: StyledElevatedButton(
                theme: ctheme,
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
