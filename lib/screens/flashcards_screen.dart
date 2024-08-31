import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/components/styled_components/container.dart';
import 'package:oneforall/components/styled_components/filled_elevated_button.dart';
import 'package:oneforall/components/styled_components/primary_elevated_button.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:oneforall/components/styled_components/text_field.dart';
import 'package:oneforall/components/styled_components/touchable_container.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/functions/flashcards_functions.dart';
import 'package:oneforall/main.dart';
import 'package:provider/provider.dart';
import '../data/user_data.dart';
import 'flashcards_play_screen.dart';
import 'flashcards_edit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  String searchQuery = "";
  bool isItemValid(String title) {
    if (title.toLowerCase().contains(searchQuery.toLowerCase())) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = Provider.of<AppState>(context);
    var ctheme = getThemeFromTheme(theme);
    return Scaffold(
        floatingActionButton: SizedBox(
          height: 60,
          width: 60,
          child: StyledTouchableContainer(
              theme: ctheme,
              onPressed: () => showDialog(context: context, builder: (context) => const NewSetOptions()),
              child: Icon(
                Icons.add_rounded,
                color: theme.onBackground,
              )),
        ),
        // bottomNavigationBar: const BannerAdWidget(),
        resizeToAvoidBottomInset: false,
        body: MainContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                StyledTextField(
                  theme: ctheme,
                  onChanged: (value) => setState(() {
                    searchQuery = value;
                  }),
                  hint: "Search",
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.library_books, color: theme.onBackground, size: 50),
                          const SizedBox(width: 10),
                          Text("Library", style: textTheme.displayLarge),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (appState.getCurrentUser.flashCardSets.isEmpty)
                        Expanded(
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("You don't have any Flashcards", style: textTheme.displayMedium),
                              const SizedBox(height: 10),
                              StyledTouchableContainer(
                                theme: getThemeFromTheme(theme),
                                onPressed: () {
                                  showDialog(context: context, builder: (context) => const NewSetOptions());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Create Flashcard",
                                        style: textTheme.displaySmall,
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Icon(Icons.add, color: theme.onBackground)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ),
                      if (appState.getCurrentUser.flashCardSets.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              itemCount: appState.getCurrentUser.flashCardSets.length,
                              itemBuilder: (context, index) {
                                return isItemValid(appState.getCurrentUser.flashCardSets[index].title)
                                    ? Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: StyledTouchableContainer(
                                            theme: ctheme,
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => SelectedSetModal(
                                                        flashcardSet: appState.getCurrentUser.flashCardSets.length - 1 >= index ? appState.getCurrentUser.flashCardSets[index] : FlashcardSet(id: 0, flashcards: [], title: "", description: ""),
                                                        index: index,
                                                      ));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(32.0),
                                              child: Text(
                                                appState.getCurrentUser.flashCardSets[index].title,
                                                style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            )),
                                      )
                                    : Container();
                              }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class ImportSetModal extends StatefulWidget {
  const ImportSetModal({super.key});

  @override
  State<ImportSetModal> createState() => _ImportSetModalState();
}

class _ImportSetModalState extends State<ImportSetModal> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    // var appState = Provider.of<AppState>(context);
    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: theme.background,
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Import from JSON string", style: textTheme.displayMedium),
            const SizedBox(height: 10),
            //Text Field
            TextField(
              onChanged: (value) => setState(() {
                // titleQuery = value;
              }),
              keyboardAppearance: Brightness.dark,
              cursorColor: theme.onPrimary,
              style: textTheme.displaySmall!.copyWith(color: theme.onPrimary, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  filled: true,
                  fillColor: theme.primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 2,
                      color: theme.onBackground,
                    ),
                  ),
                  hintText: 'JSON String',
                  hintStyle: textTheme.displaySmall!.copyWith(color: theme.onPrimary.withOpacity(0.25), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            //Buttons: Create and Cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondary,
                      foregroundColor: theme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Import")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondary,
                      foregroundColor: theme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
              ],
            ),
            const SizedBox(height: 10),
            Text("Import from ZIP file", style: textTheme.displayMedium),
            const SizedBox(height: 10),
            // Button
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondary,
                  foregroundColor: theme.onBackground,
                ),
                onPressed: () async {
                  FilePickerResult? file = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      'zip'
                    ],
                  );
                  if (file == null) return;
                  if (!context.mounted) return;
                  FlashcardsFunctions().importFlashcardFromZip(File(file.files.first.path!), context, context.read<AppState>());
                },
                icon: const Icon(Icons.download),
                label: const Text("Import")),
          ])),
    );
  }
}

class NewSetOptions extends StatefulWidget {
  const NewSetOptions({super.key});

  @override
  State<NewSetOptions> createState() => _NewSetOptionsState();
}

class _NewSetOptionsState extends State<NewSetOptions> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    // var appState = Provider.of<AppState>(context);
    var ctheme = getThemeFromTheme(theme);
    return Dialog(
        backgroundColor: theme.background,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: StyledTouchableContainer(
                      theme: ctheme,
                      onPressed: () => {
                        Navigator.pop(context),
                        showDialog(context: context, builder: (context) => const NewSetModal())
                      },
                      child: Icon(Icons.add, color: theme.onBackground, size: 24),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Create",
                    style: textTheme.displaySmall,
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: StyledTouchableContainer(
                      theme: ctheme,
                      onPressed: () => {},
                      child: Icon(Icons.smart_toy, color: theme.onBackground, size: 24),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Generate",
                    style: textTheme.displaySmall,
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: StyledTouchableContainer(
                      theme: ctheme,
                      onPressed: () => {
                        Navigator.pop(context),
                        showDialog(context: context, builder: (context) => const ImportSetModal())
                      },
                      child: Icon(Icons.download, color: theme.onBackground, size: 24),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Import",
                    style: textTheme.displaySmall,
                  )
                ],
              )
            ],
          ),
        ));
  }
}

class GenerateFlashcardsModal extends StatefulWidget {
  const GenerateFlashcardsModal({super.key});

  @override
  State<GenerateFlashcardsModal> createState() => _GenerateFlashcardsModalState();
}

class _GenerateFlashcardsModalState extends State<GenerateFlashcardsModal> {
  int? selectedQuiz;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);
    return Dialog(
      child: Container(
        decoration: BoxDecoration(color: theme.background, borderRadius: const BorderRadius.all(Radius.circular(20.0))),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Generate Flashcards", style: textTheme.displayMedium),
            const SizedBox(height: 5),
            Text(
              "Generate from quiz: ",
              style: textTheme.displaySmall,
            ),
            Row(
              children: [
                Text("Select quiz : ", style: textTheme.displaySmall),
                const SizedBox(width: 5),
                DropdownButton<int>(
                    value: selectedQuiz,
                    hint: Text(
                      "Select Quiz",
                      style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    items: [
                      for (int i = 0; i < appState.getQuizzes.length; i++) ...[
                        DropdownMenuItem(value: i, child: Text(appState.getQuizzes[i].title, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)))
                      ]
                    ],
                    onChanged: (value) => setState(() {
                          selectedQuiz = value;
                        })),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            StyledPrimaryElevatedButton(
                theme: ctheme,
                onPressed: () {
                  if (selectedQuiz == null) return;
                  appState.getCurrentUser.flashCardSets.add(FlashcardSet(id: appState.getCurrentUser.flashCardSets.length + 1, title: appState.getQuizzes[selectedQuiz!].title, description: appState.getQuizzes[selectedQuiz!].description, flashcards: [
                    for (int i = 0; i < appState.getQuizzes[selectedQuiz!].questions.length; i++) ...[
                      Flashcard(hints: [], id: i, image: appState.getQuizzes[selectedQuiz!].questions[i].imagePath, question: appState.getQuizzes[selectedQuiz!].questions[i].type == QuizTypes.multipleChoice ? appState.getQuizzes[selectedQuiz!].questions[i].question : "not supported", answer: appState.getQuizzes[selectedQuiz!].questions[i].type == QuizTypes.multipleChoice ? List<String>.generate(appState.getQuizzes[selectedQuiz!].questions[i].correctAnswer.length, (index) => appState.getQuizzes[selectedQuiz!].questions[i].answers[index]).join(", ") : "not supported")
                    ]
                  ]));
                },
                child: Text("Generate", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)))
          ],
        ),
      ),
    );
  }
}

class NewSetModal extends StatefulWidget {
  const NewSetModal({super.key});

  @override
  State<NewSetModal> createState() => _NewSetModalState();
}

class _NewSetModalState extends State<NewSetModal> {
  String titleQuery = "";
  bool isLoading = false;
  bool success = false;

  Future createSet(AppState appState) async {
    //* Spam prevention
    if (isLoading || success) {
      return;
    }
    //* Check if the title is empty
    if (titleQuery == "") {
      return;
    }
    //* Set loading to true
    setState(() {
      isLoading = true;
    });
    //* Create the set and add it to shared preferences
    List<FlashcardSet> flashcardSets = [];
    //* Get the flashcard sets from shared prefs
    await SharedPreferences.getInstance().then((value) {
      if (value.containsKey("flashcardSets")) {
        dynamic decodedObject = jsonDecode(value.getString("flashcardSets")!);

        //* Convert the decoded `dynamic` object back to your desired Dart object structure
        for (var set in decodedObject['sets']) {
          flashcardSets.add(FlashcardSet(id: decodedObject['sets'].indexOf(set), title: set["title"], description: "description_unavailable", flashcards: [
            for (var flashcard in set['questions']) Flashcard(id: set['questions'].indexOf(flashcard), question: flashcard['question'], answer: flashcard['answer'], image: flashcard['image'], hints: flashcard['hints'] ?? [])
          ]));
        }
      }
    });
    flashcardSets.add(FlashcardSet(id: flashcardSets.length, flashcards: [], title: titleQuery, description: ""));
    //* Convert flashcard sets to json
    Object flashcardSetsObject = {
      "sets": [
        for (FlashcardSet set in flashcardSets)
          {
            "title": set.title,
            "description": set.description,
            "questions": [
              for (Flashcard flashcard in set.flashcards)
                {
                  "question": flashcard.question,
                  "answer": flashcard.answer,
                  "image": flashcard.image,
                  "hints": flashcard.hints
                }
            ]
          }
      ],
    };

    //* Save the data to shared prefs by converting it to json
    await SharedPreferences.getInstance().then((value) async {
      await value.setString("flashcardSets", jsonEncode(flashcardSetsObject));
    });

    //* Add the set to the current user
    appState.addFlashcardSet(FlashcardSet(id: flashcardSets.length, flashcards: [], title: titleQuery, description: ""));

    //* Rebuild
    setState(() {});

    //* Set loading to false
    setState(() {
      isLoading = false;
      success = true;
    });
    //ignore: user_build_context_synchronously, use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);
    return Dialog(
        child: Container(
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text("Create Set", style: textTheme.displayLarge),
                  const Divider(),
                  const SizedBox(height: 10),
                  //Title Text Field
                  StyledTextField(
                    onChanged: (value) => setState(() {
                      titleQuery = value;
                    }),
                    theme: ctheme,
                    hint: "Title",
                  ),
                  const SizedBox(height: 10),
                  //How to use
                  Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: theme.onPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text("How to use", style: textTheme.displaySmall),
                    ],
                  ),
                  const SizedBox(height: 10),
                  //How to use text
                  Text("You may put as much question as you will, each flashcard set are stored locally (CACHED!). Each set represents one collection of cards. For each card you encounter you must think of the answer in your head, and then flip the card by tapping it, revealing the answer. You then must choose the following buttons depending on your performance on the question (The buttons mentioned are the 100% knew it, 50% some, 0% didn’t know). Each question has a weight, depending on your performance on the question, the weight can go down and up. In which if it goes up it will show more frequently per as if it goes down it will show less frequently. For more information, look at the *docs*", style: textTheme.displaySmall),
                  const SizedBox(height: 10),
                  //Buttons: Create and Cancel
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StyledPrimaryElevatedButton(
                          theme: ctheme,
                          onPressed: () {
                            createSet(context.read<AppState>());
                          },
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : success
                                  ? Icon(
                                      Icons.check,
                                      color: theme.onBackground,
                                    )
                                  : Text(
                                      "Create",
                                      style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                                    )),
                      const SizedBox(
                        height: 16,
                      ),
                      FilledElevatedButton(
                          color: Colors.red,
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: textTheme.displaySmall,
                          )),
                    ],
                  )
                ]),
              ),
            )));
  }
}

class SelectedSetModal extends StatelessWidget {
  const SelectedSetModal({super.key, required this.flashcardSet, required this.index});
  final FlashcardSet flashcardSet;
  final int index;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Top
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(flashcardSet.title, style: textTheme.displayLarge)),
                      //* More options
                      PopupMenuButton(
                          color: theme.background,
                          itemBuilder: (context) => <PopupMenuEntry>[
                                PopupMenuItem(
                                  child: Text(
                                    "Export",
                                    style: textTheme.displaySmall,
                                  ),
                                  onTap: () {
                                    FlashcardsFunctions().exportFlashcardsToDownloads(flashcardSet, context);
                                  },
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    "Delete",
                                    style: textTheme.displaySmall,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.read<AppState>().getCurrentUser.flashCardSets.removeAt(index);
                                    context.read<AppState>().thisNotifyListeners();
                                    //* Delete images
                                    for (var flashcard in flashcardSet.flashcards.where((element) => element.image != null)) {
                                      //* Delete the image
                                      File(flashcard.image!).delete();
                                    }
                                    //* Convert flashcard sets to json
                                    List<FlashcardSet> flashcardSets = context.read<AppState>().getCurrentUser.flashCardSets;
                                    Object flashcardSetsObject = {
                                      "sets": [
                                        for (FlashcardSet set in flashcardSets)
                                          {
                                            "title": set.title,
                                            "description": set.description,
                                            "questions": [
                                              for (Flashcard flashcard in set.flashcards)
                                                {
                                                  "question": flashcard.question,
                                                  "answer": flashcard.answer,
                                                  "image": flashcard.image
                                                }
                                            ]
                                          }
                                      ],
                                    };
                                    SharedPreferences.getInstance().then((value) async {
                                      await value.setString("flashcardSets", jsonEncode(flashcardSetsObject));
                                    });
                                  },
                                ),
                              ],
                          icon: Icon(Icons.more_vert, color: theme.onBackground),
                          onSelected: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  //Middle
                  StyledContainer(
                    theme: ctheme,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Number of questions", style: textTheme.displaySmall),
                        Text(flashcardSet.flashcards.length.toString(), style: textTheme.displaySmall)
                      ]),
                    ),
                  ),
                ],
              ),
              //Bottom
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledElevatedButton(
                      color: Colors.green,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return FlashcardsPlayScreen(flashcardsSet: flashcardSet);
                        }));
                      },
                      child: Text(
                        "Open",
                        style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    height: 16,
                  ),
                  FilledElevatedButton(
                      color: Colors.blue,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return FlashcardsEditScreen(
                                //Index is the index of the set in the user list of sets
                                setIndex: index);
                          })),
                      child: Text(
                        "Edit",
                        style: textTheme.displaySmall,
                      )),
                  const SizedBox(
                    height: 16,
                  ),
                  FilledElevatedButton(
                      color: Colors.red,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: textTheme.displaySmall,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
