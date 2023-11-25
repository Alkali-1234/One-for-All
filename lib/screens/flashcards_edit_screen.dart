import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/main.dart';
import 'package:path_provider/path_provider.dart';
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
  Map<String, dynamic> questionQuery = {
    "queries": []
  };

  void initializeQueries(FlashcardSet set) {
    for (var i = 0; i < set.flashcards.length; i++) {
      questionQuery["queries"].add({
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
      for (var i in questionQuery["queries"]) {
        appState.getCurrentUser.flashCardSets[widget.setIndex].flashcards.add(Flashcard(image: i['image'], id: i["id"], question: i["question"], answer: i["answer"]));
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
                  "answer": flashcard.answer,
                  "image": flashcard.image
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
      questionQuery["queries"].add({
        "id": questionQuery["queries"].length,
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
  Future<void> removeQuestion(int index) async {
    Map<String, dynamic> newQuestionQuery = {
      "queries": [
        for (var i = 0; i < questionQuery["queries"].length; i++)
          if (i != index) questionQuery["queries"][i]
      ]
    };
    setState(() {
      questionQuery.clear();
    });
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      questionQuery = newQuestionQuery;
      moreOptionsTweens.removeAt(index);
      showMoreOptions.removeAt(index);
    });
  }

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
                                Text("${questionQuery["queries"]?.length ?? 0} Questions", style: textTheme.displayMedium)
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
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 100),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                    itemCount: questionQuery["queries"]?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      return LayoutBuilder(builder: (context, consntraints) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0 ? theme.primary : theme.secondary,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  TweenAnimationBuilder<double>(
                                                    curve: Curves.easeIn,
                                                    tween: moreOptionsTweens[index],
                                                    duration: const Duration(milliseconds: 200),
                                                    builder: (context, value, child) => SizedBox(
                                                      width: consntraints.maxWidth * value,
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const SizedBox(width: 10),
                                                          AnimatedOpacity(
                                                            duration: const Duration(milliseconds: 200),
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
                                                                          onPressed: () => removeQuestion(index),
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
                                                                await Future.delayed(const Duration(milliseconds: 200));
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
                                                          initialValue: questionQuery["queries"][index]["question"],
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
                                                            questionQuery["queries"][index]["question"] = value;
                                                          },
                                                        ),
                                                        TextFormField(
                                                          cursorColor: theme.onPrimary,
                                                          textAlign: TextAlign.center,
                                                          initialValue: questionQuery["queries"][index]["answer"],
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
                                                            questionQuery["queries"][index]["answer"] = value;
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              //* image
                                              ImageSelector(
                                                  image: questionQuery["queries"][index]["image"],
                                                  onImageSelected: (image) {
                                                    questionQuery["queries"][index]["image"] = image;
                                                  }),
                                            ],
                                          ),
                                        );
                                      });
                                    }),
                              ),
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

class ImageSelector extends StatefulWidget {
  const ImageSelector({super.key, required this.onImageSelected, this.image});
  final Function(String?) onImageSelected;
  final String? image;

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  bool expanded = false;

  Future<void> addImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    Directory documentsDir = await getApplicationDocumentsDirectory();
    if (Directory("${documentsDir.path}/flashcardImages").existsSync() == false) {
      await Directory("${documentsDir.path}/flashcardImages").create();
    }
    String newPath = "${documentsDir.path}/flashcardImages/${DateTime.now().millisecondsSinceEpoch}${image.name}.png";
    File copiedPath = await File(image.path).copy(newPath);
    widget.onImageSelected(copiedPath.path);
  }

  Future<void> removeImage() async {
    if (widget.image == null) return;
    await File(widget.image!).delete();
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        IconButton(
            onPressed: () => setState(() {
                  expanded = !expanded;
                }),
            icon: RotatedBox(quarterTurns: 1, child: Icon(Icons.chevron_left, color: theme.onBackground))),
        if (expanded)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () => addImage(), icon: Icon(Icons.add_a_photo, color: theme.onBackground)),
              const SizedBox(width: 10),
              IconButton(onPressed: () => removeImage(), icon: const Icon(Icons.delete, color: Colors.red)),
              const SizedBox(width: 10),
              //* Image preview
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.image != null
                        ? Image.file(
                            File(widget.image!),
                            fit: BoxFit.cover,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }
}
