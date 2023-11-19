import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_data.dart';

class FlashcardsEditScreen extends StatefulWidget {
  const FlashcardsEditScreen({super.key, required this.setIndex});
  final int setIndex;

  @override
  State<FlashcardsEditScreen> createState() => _FlashcardsEditScreenState();
}

class _FlashcardsEditScreenState extends State<FlashcardsEditScreen> {
  //! FIXME when you delete a flashcard, the list is not updated correctly
  Object questionQuery = {
    "queries": []
  };

  get getQuestionQuery => questionQuery;

  void initializeQueries(FlashcardSet set) {
    for (var i = 0; i < set.flashcards.length; i++) {
      getQuestionQuery["queries"].add({
        "id": set.flashcards[i].id,
        "question": set.flashcards[i].question,
        "answer": set.flashcards[i].answer
      });
    }
  }

  Future saveFlashcards(AppState appState) async {
    //* Determine wether flashcard is stored on cloud or locally
    //TODO implement

    //* In case of local storage
    //! Will always use the local storage method for now
    //* Set the flashcard set to the new flashcard set
    setState(() {
      appState.getCurrentUser.flashCardSets[widget.setIndex].flashcards = List<Flashcard>.empty(growable: true);
      for (var i in getQuestionQuery["queries"]) {
        appState.getCurrentUser.flashCardSets[widget.setIndex].flashcards.add(Flashcard(id: i["id"], question: i["question"], answer: i["answer"]));
      }
    });
    Object objectifiedFlashcardSets = {
      "sets": [
        for (var set in appState.getCurrentUser.flashCardSets)
          {
            "title": set.title,
            "description": set.description,
            "questions": [
              for (var flashcard in set.flashcards)
                {
                  "question": flashcard.question,
                  "answer": flashcard.answer
                }
            ]
          }
      ]
    };
    //* Save the flashcard set to the local storage
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("flashcardSets", jsonEncode(objectifiedFlashcardSets));
    Navigator.pop(context);
  }

  void addCard() {
    setState(() {
      getQuestionQuery["queries"].add({
        "id": getQuestionQuery["queries"].length,
        "question": "",
        "answer": ""
      });
      moreOptionsTweens.add(Tween<double>(begin: 0.8, end: 0.1));
      showMoreOptions.add(false);
    });
  }

  @override
  void initState() {
    super.initState();
    var set = context.read<AppState>().getCurrentUser.flashCardSets[widget.setIndex];
    initializeQueries(set);
    moreOptionsTweens = List.generate(set.flashcards.length, (index) => Tween<double>(begin: 0.8, end: 0.1));
    showMoreOptions = List.generate(set.flashcards.length, (index) => false);
  }

  late List<Tween<double>> moreOptionsTweens;
  late List<bool> showMoreOptions;

  @override
  Widget build(BuildContext context) {
    var theme = passedUserTheme.colorScheme;
    var textTheme = passedUserTheme.textTheme;
    var appState = context.watch<AppState>();
    return Container(
        decoration: passedUserTheme == defaultBlueTheme ? const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/purpwallpaper 2.png'), fit: BoxFit.cover)) : BoxDecoration(color: passedUserTheme.colorScheme.background),
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    //App Bar
                    Container(
                      color: theme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.arrow_back,
                                color: theme.onPrimary,
                              ),
                            ),
                            Text(appState.getCurrentUser.username, style: textTheme.displaySmall),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: theme.onPrimary,
                                borderRadius: BorderRadius.circular(20),
                                gradient: getPrimaryGradient,
                              ),
                              child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(15)), child: Image.network(appState.getCurrentUser.profilePicture, fit: BoxFit.cover)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //End of App Bar
                    //Body
                    const SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Edit Set", style: textTheme.displayMedium),
                                Text("${getQuestionQuery["queries"].length} Questions", style: textTheme.displayMedium)
                              ],
                            ),
                            const SizedBox(height: 10),
                            //New Question button
                            ElevatedButton(
                                onPressed: () => addCard(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.secondary,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  side: BorderSide(color: theme.tertiary, width: 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: theme.onPrimary),
                                    const SizedBox(width: 10),
                                    Text(
                                      "New Question",
                                      style: textTheme.displaySmall,
                                    ),
                                  ],
                                )),
                            Expanded(
                              child: ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                  itemCount: getQuestionQuery["queries"].length,
                                  itemBuilder: (context, index) {
                                    return LayoutBuilder(builder: (context, consntraints) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: index % 2 == 0 ? theme.primary : theme.secondary,
                                        ),
                                        child: Row(
                                          children: [
                                            TweenAnimationBuilder<double>(
                                              tween: moreOptionsTweens[index],
                                              duration: const Duration(milliseconds: 500),
                                              builder: (context, value, child) => SizedBox(
                                                width: consntraints.maxWidth * value,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const SizedBox(width: 10),
                                                    AnimatedOpacity(
                                                      duration: const Duration(milliseconds: 500),
                                                      opacity: moreOptionsTweens[index].end == 1 ? 1 : 0,
                                                      child: showMoreOptions[index]
                                                          ? Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                ElevatedButton.icon(
                                                                    label: Text("Delete", style: textTheme.displaySmall),
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: theme.secondary,
                                                                      shadowColor: Colors.transparent,
                                                                      elevation: 0,
                                                                      side: BorderSide(color: theme.tertiary, width: 1),
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                    ),
                                                                    onPressed: () => {
                                                                          setState(
                                                                            () {
                                                                              getQuestionQuery["queries"].removeAt(index);
                                                                              moreOptionsTweens.removeAt(index);
                                                                              showMoreOptions.removeAt(index);
                                                                            },
                                                                          ),
                                                                        },
                                                                    icon: const Icon(Icons.delete, color: Colors.red)),
                                                              ],
                                                            )
                                                          : const SizedBox.shrink(),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          moreOptionsTweens[index].end == 0.1 ? moreOptionsTweens[index] = Tween<double>(begin: 0.1, end: 1) : moreOptionsTweens[index] = Tween<double>(begin: 1, end: 0.1);
                                                        });
                                                        if (showMoreOptions[index] == true) {
                                                          await Future.delayed(const Duration(milliseconds: 500));
                                                          setState(() {
                                                            showMoreOptions[index] = false;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            showMoreOptions[index] = true;
                                                          });
                                                        }
                                                      },
                                                      child: Transform.flip(flipX: showMoreOptions[index], child: Icon(Icons.chevron_right, color: theme.onBackground)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextFormField(
                                                    cursorColor: theme.onPrimary,
                                                    textAlign: TextAlign.center,
                                                    initialValue: getQuestionQuery["queries"][index]["question"],
                                                    decoration: InputDecoration(
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.zero,
                                                        borderSide: BorderSide(color: theme.onBackground, width: 1),
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.zero,
                                                        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                                      ),
                                                      contentPadding: const EdgeInsets.all(0),
                                                      hintText: "Question ${index + 1}",
                                                      hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                                                      // filled: true,
                                                    ),
                                                    style: textTheme.displaySmall,
                                                    onChanged: (value) {
                                                      getQuestionQuery["queries"][index]["question"] = value;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    cursorColor: theme.onPrimary,
                                                    textAlign: TextAlign.center,
                                                    initialValue: getQuestionQuery["queries"][index]["answer"],
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.zero,
                                                        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.zero,
                                                        borderSide: BorderSide(color: theme.onBackground, width: 1),
                                                      ),
                                                      contentPadding: const EdgeInsets.all(0),
                                                      hintText: "Answer ${index + 1}",
                                                      hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                                                      // fillColor: theme.primary,
                                                      // filled: true,
                                                    ),
                                                    style: textTheme.displaySmall,
                                                    onChanged: (value) {
                                                      getQuestionQuery["queries"][index]["answer"] = value;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  }),
                            ),
                            const Divider(),
                            //Save and Cancel Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      saveFlashcards(context.read<AppState>());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.secondary,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      side: BorderSide(color: theme.tertiary, width: 1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save, color: theme.onPrimary),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Save",
                                          style: textTheme.displaySmall,
                                        ),
                                      ],
                                    )),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.secondary,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      side: BorderSide(color: theme.tertiary, width: 1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cancel, color: theme.onPrimary),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Cancel",
                                          style: textTheme.displaySmall,
                                        ),
                                      ],
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ))));
  }
}
