import 'package:flutter/material.dart';
import '../components/main_container.dart';
import 'package:oneforall/main.dart';
import 'package:provider/provider.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return MainContainer(
        child: Column(
      children: [
        Text("Quizzes", style: Theme.of(context).textTheme.displayLarge),
        Text("Coming soon!", style: Theme.of(context).textTheme.displayLarge),
      ],
    ));
  }
}
