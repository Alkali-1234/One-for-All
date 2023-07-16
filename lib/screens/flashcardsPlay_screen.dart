import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import '../data/user_data.dart';
import 'dart:math';

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
  DateTime startingTime = DateTime.now();
  Flashcard currentCard = Flashcard(
      id: 0,
      question: "If this card shows up, something went wrong.",
      answer: "If this card shows up, something went wrong. (backside)");
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
    //Initialize first card
    changeCurrentCard(getFlashcardWeights["weights"][0]["card"]);
  }

  void nextQuestion(int weightDifference) {
    setState(() {
      questionNumber++;
      flipped = false;
    });
    //Change the weight of the current card
    //Look for the card in the weights list
    int index = getFlashcardWeights["weights"]
        .indexWhere((element) => element["card"] == currentCard);
    debugPrint("Index: $index");
    //Change the weight of the card
    changeWeights(index,
        getFlashcardWeights["weights"][index]["weight"] + weightDifference);
    //Get the next card
    //Get the total weight
    int totalWeight = 0;
    for (var i = 0; i < getFlashcardWeights["weights"].length; i++) {
      //Null check
      if (getFlashcardWeights["weights"][i]["weight"] == null) {
        getFlashcardWeights["weights"][i]["weight"] = 500;
      }
      totalWeight += getFlashcardWeights["weights"][i]["weight"] as int;
    }
    debugPrint("Total Weight: $totalWeight");
    //Get a random number between 0 and totalWeight
    int randomNumber = Random().nextInt(totalWeight);
    debugPrint("Random Number: $randomNumber");
    //Get the card that corresponds to the random number
    int currentWeight = 0;
    for (var i = 0; i < getFlashcardWeights["weights"].length; i++) {
      currentWeight += getFlashcardWeights["weights"][i]["weight"] as int;
      if (currentWeight >= randomNumber) {
        changeCurrentCard(getFlashcardWeights["weights"][i]["card"]);
        break;
      }
    }
    //Add 10 to the weight of each card
    for (var i = 0; i < getFlashcardWeights["weights"].length; i++) {
      changeWeights(i, getFlashcardWeights["weights"][i]["weight"] + 10);
    }
    debugPrint("Weights: $getFlashcardWeights");
  }

  void finishPlaying() {
    //Calculate score
    //Score is difference between starting total weight and current total weight
    int totalWeight = 0;
    //Calculate total weight
    for (var i = 0; i < getFlashcardWeights["weights"].length; i++) {
      totalWeight += getFlashcardWeights["weights"][i]["weight"] as int;
    }
    int score =
        totalWeight - (500 * getFlashcardWeights["weights"].length as int);
    //Calculate accuracy
    //Accuracy is starting total weight over current total weight
    double accuracy =
        (500 * getFlashcardWeights["weights"].length as int) / totalWeight;
    //Calculate time spent
    DateTime currentTime = DateTime.now();
    Duration timeSpent = startingTime.difference(currentTime);
    //Replace current screen with finished screen
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FinishedScreen(
                  set: widget.set,
                  score: score,
                  accuracy: accuracy,
                  timeSpent: timeSpent,
                  questionsDone: questionNumber,
                  weights: getFlashcardWeights,
                )));
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: primaryGradient),
                      child: ElevatedButton(
                          onPressed: () {
                            nextQuestion(-100);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: theme.onPrimary),
                          child: const Text("100% Knew it!")),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          nextQuestion(25);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.secondary,
                            shadowColor: Colors.transparent,
                            foregroundColor: theme.onPrimary),
                        child: const Text("50% Some")),
                    ElevatedButton(
                        onPressed: () {
                          nextQuestion(75);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.secondary,
                            shadowColor: Colors.transparent,
                            foregroundColor: theme.onPrimary),
                        child: const Text("0% None")),
                  ],
                )
              ],
            ),
            //Bottom
            ElevatedButton(
                onPressed: () {
                  debugPrint("Finish");
                  finishPlaying();
                },
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

class FinishedScreen extends StatelessWidget {
  const FinishedScreen(
      {super.key,
      required this.set,
      required this.score,
      required this.accuracy,
      required this.timeSpent,
      required this.questionsDone,
      required this.weights});
  final FlashcardSet set;
  final int score;
  final double accuracy;
  final Duration timeSpent;
  final int questionsDone;
  final Object weights;

  get getFlashcardSet => set;
  get getWeights => weights;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
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
                    Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.arrow_back,
                                color: theme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //End of App Bar
                    //Body
                    //Title
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text("Finished",
                              style: textTheme.displayLarge!
                                  .copyWith(fontStyle: FontStyle.italic)),
                          const SizedBox(height: 24),
                          //Card
                          Container(
                            decoration: BoxDecoration(
                              color: theme.primary,
                              border: Border.all(color: theme.secondary),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            child: Image.network(
                                              "https://picsum.photos/50",
                                              height: 35,
                                              width: 35,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text("Alkaline",
                                              style: textTheme.displayMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                          "Finished flashcards with an accuracy of:",
                                          style: textTheme.displaySmall),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${(accuracy * 100).round()}%",
                                        style: textTheme.displayLarge,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          //End of Card
                          const SizedBox(height: 24),
                          Container(
                              decoration: BoxDecoration(
                                color: theme.primaryContainer,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Score",
                                      style: textTheme.displayMedium,
                                    ),
                                    Text(score.toString(),
                                        style: textTheme.displayMedium)
                                  ],
                                ),
                              )),
                          const SizedBox(height: 10),
                          //Questions done
                          Container(
                              decoration: BoxDecoration(
                                color: theme.primaryContainer,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Questions done",
                                      style: textTheme.displayMedium,
                                    ),
                                    Text(questionsDone.toString(),
                                        style: textTheme.displayMedium)
                                  ],
                                ),
                              )),
                          const SizedBox(height: 10),
                          Container(
                              decoration: BoxDecoration(
                                color: theme.primaryContainer,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Time spent",
                                      style: textTheme.displayMedium,
                                    ),
                                    Text("${timeSpent.abs()} H",
                                        style: textTheme.displayMedium)
                                  ],
                                ),
                              )),

                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Text("Questions - ${set.flashcards.length}",
                                  style: textTheme.displayMedium),
                            ],
                          ),
                          const Divider(),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: ((context) => QuestionModal(
                                              card: set.flashcards[index],
                                              weightOfCard:
                                                  getWeights["weights"][index]
                                                      ["weight"])));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.secondary,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      side: BorderSide(color: theme.tertiary),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              set.flashcards[index].question,
                                              style: textTheme.displaySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              set.flashcards[index].answer,
                                              style: textTheme.displaySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: set.flashcards.length,
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    )
                  ],
                ))));
  }
}

class QuestionModal extends StatelessWidget {
  const QuestionModal(
      {super.key, required this.card, required this.weightOfCard});
  final Flashcard card;
  final int weightOfCard;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.secondary),
          borderRadius: BorderRadius.circular(10),
          color: theme.background,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.onBackground,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      card.question,
                      style: textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Answer",
                        style: textTheme.displayMedium,
                      ),
                      Text(
                        card.answer,
                        style: textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Weight",
                        style: textTheme.displayMedium,
                      ),
                      Text(
                        weightOfCard.toString(),
                        style: textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
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
