import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import '../data/user_data.dart';

class FlashcardsPlayScreen extends StatefulWidget {
  const FlashcardsPlayScreen({super.key, required this.flashcardsSet});
  final FlashcardSet flashcardsSet;

  @override
  State<FlashcardsPlayScreen> createState() => _FlashcardsPlayScreen();
}

class _FlashcardsPlayScreen extends State<FlashcardsPlayScreen> {
  int selectedScreen = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    FlashcardSet set = widget.flashcardsSet;

    // 0 = Select Mode
    // 1 = Infinity Mode
    // 2 = Normal Mode UNAVAILABLE
    // 3 Play
    void changeScreen(int screen) {
      setState(() {
        selectedScreen = screen;
      });
    }

    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/purpwallpaper 2.png'),
                fit: BoxFit.cover)),
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    //App Bar
                    selectedScreen != 3
                        ? Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: theme.onPrimary,
                                    ),
                                  ),
                                  Text(
                                    set.title,
                                    style: textTheme.displayMedium,
                                  ),
                                  Container(),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    //End of App Bar
                    //Body
                    selectedScreen == 0
                        ? SelectModeScreen(
                            textTheme: textTheme,
                            theme: theme,
                            set: set,
                            changeScreenFunction: changeScreen)
                        : selectedScreen == 1
                            ? StartScreen(
                                textTheme: textTheme,
                                theme: theme,
                                set: set,
                                changeScreenFunction: changeScreen)
                            : selectedScreen == 2
                                ? const Placeholder()
                                : selectedScreen == 3
                                    ? PlayScreen(set: set)
                                    : const Placeholder(),
                  ],
                ))));
  }
}

class SelectModeScreen extends StatelessWidget {
  const SelectModeScreen({
    super.key,
    required this.textTheme,
    required this.theme,
    required this.set,
    required this.changeScreenFunction,
  });

  final TextTheme textTheme;
  final ColorScheme theme;
  final FlashcardSet set;
  final Function changeScreenFunction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text("Flashcards",
            style: textTheme.displayLarge!
                .copyWith(fontStyle: FontStyle.italic, fontSize: 48)),
        Text("Let's get started.", style: textTheme.displayMedium),
        const SizedBox(height: 60),
        Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.onPrimary)),
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Text(
              set.title,
              style: textTheme.displayMedium,
            ),
          ),
        ),
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: primaryGradient),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {changeScreenFunction(1)},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: theme.onPrimary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
              child: Text(
                "Infinity Mode",
                style: textTheme.displaySmall!.copyWith(
                    color: theme.onPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondary,
              borderRadius: BorderRadius.circular(100),
            ),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {
                showDialog(
                    context: context,
                    builder: (_) => const UnavailableItemDialog()),
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: theme.onPrimary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
              child: Text(
                "Normal Mode",
                style: textTheme.displaySmall!.copyWith(
                    color: theme.onPrimary, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({
    super.key,
    required this.textTheme,
    required this.theme,
    required this.set,
    required this.changeScreenFunction,
  });

  final TextTheme textTheme;
  final ColorScheme theme;
  final FlashcardSet set;
  final Function changeScreenFunction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text("Infinity Mode",
            style: textTheme.displayLarge!
                .copyWith(fontStyle: FontStyle.italic, fontSize: 48)),
        Text("Repeats until you stop it.", style: textTheme.displayMedium),
        const SizedBox(height: 60),
        Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.onPrimary)),
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Text(
              set.title,
              style: textTheme.displayMedium,
            ),
          ),
        ),
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: primaryGradient),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {changeScreenFunction(3)},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: theme.onPrimary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
              child: Text(
                "Start",
                style: textTheme.displaySmall!.copyWith(
                    color: theme.onPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondary,
              borderRadius: BorderRadius.circular(100),
            ),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {
                changeScreenFunction(0),
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: theme.onPrimary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
              child: Text(
                "Nevermind",
                style: textTheme.displaySmall!.copyWith(
                    color: theme.onPrimary, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.set});
  final FlashcardSet set;
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  Flashcard currentCard = Flashcard(
      id: 0,
      question: "Why did the chicken cross the road?",
      answer: "To get to the other side");
  Object flashcardWeights = {"weights": []};
  get getFlashcardWeights => flashcardWeights;
  int questionNumber = 1;
  bool flipped = false;
  void initializeWeights() {
    for (var i = 0; i < widget.set.flashcards.length; i++) {
      getFlashcardWeights["weights"].add({
        "card": widget.set.flashcards[i],
        "weight": 500,
      });
    }
  }

  void changeWeights(int index, int weight) {
    setState(() {
      getFlashcardWeights["weights"][index]["weight"] = weight;
    });
  }

  void changeCurrentCard(Flashcard card) {
    setState(() {
      currentCard = card;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeWeights();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Top (nothign)
            Container(),
            //Main Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Question $questionNumber",
                    style: textTheme.displayMedium),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          flipped = !flipped;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.secondary.withOpacity(0.115),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.transparent,
                        // height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox.shrink(),
                            Text(
                              !flipped
                                  ? currentCard.question
                                  : currentCard.answer,
                              style: textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            Icon(Icons.rotate_left, color: theme.onBackground),
                          ],
                        ),
                      )),
                ),
                const SizedBox(height: 10),
                Text("How well did you know this?",
                    style: textTheme.displaySmall),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: primaryGradient),
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: theme.onPrimary),
                          child: const Text("100% Knew it!")),
                    ),
                  ],
                )
              ],
            ),
            //Bottom
            ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondary,
                  shadowColor: Colors.transparent,
                  // height: MediaQuery.of(context).size.height * 0.25,
                ),
                child: Text(
                  "Finish",
                  style: textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    );
  }
}

class UnavailableItemDialog extends StatelessWidget {
  const UnavailableItemDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("This item is not available yet",
                  style: Theme.of(context).textTheme.displayMedium),
              FloatingActionButton.small(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Ok",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
