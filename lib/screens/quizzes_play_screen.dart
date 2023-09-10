import 'package:flutter/material.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/models/quizzes_models.dart';
import '../main.dart';
import 'package:provider/provider.dart';

class QuizzesPlayScreen extends StatefulWidget {
  const QuizzesPlayScreen({super.key, required this.quizSet});
  final QuizSet quizSet;

  @override
  State<QuizzesPlayScreen> createState() => _QuizzesPlayScreenState();
}

class _QuizzesPlayScreenState extends State<QuizzesPlayScreen> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: MainContainer(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("WIP - Quizzes Play Screen", style: textTheme.displayMedium),
          ],
        ),
      )),
    );
  }
}
