import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_data.dart';

class FCQuery {
  FCQuery({required this.question, required this.answer, this.image, this.hints});
  String question;
  String answer;
  String? image;
  List<dynamic>? hints;
}

class FlashcardsEditScreen extends StatefulWidget {
  const FlashcardsEditScreen({super.key, required this.setIndex});
  final int setIndex;

  @override
  State<FlashcardsEditScreen> createState() => _FlashcardsEditScreenState();
}

class _FlashcardsEditScreenState extends State<FlashcardsEditScreen> {
  List<FCQuery> questionQuery = [];

  void initializeQueries(FlashcardSet set) {
    for (var i = 0; i < set.flashcards.length; i++) {
      questionQuery.add(FCQuery(question: set.flashcards[i].question, answer: set.flashcards[i].answer, image: set.flashcards[i].image, hints: set.flashcards[i].hints));
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
      for (var i in questionQuery) {
        appState.getCurrentUser.flashCardSets[widget.setIndex].flashcards.add(Flashcard(image: i.image, id: 0, question: i.question, answer: i.answer, hints: i.hints ?? []));
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
                  "image": flashcard.image,
                  "hints": flashcard.hints
                }
            ]
          }
      ]
    };
    //* Save the flashcard set to the local storage
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("flashcardSets", jsonEncode(objectifiedFlashcardSets));
    if (!mounted) return;
    Navigator.pop(context);
  }

  void addCard() {
    setState(() {
      questionQuery.add(
        FCQuery(question: "", answer: "", image: null, hints: []),
      );
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
    return Scaffold(
      body: MainContainer(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: RichText(
                        text: TextSpan(text: "Editing", style: textTheme.displayMedium, children: [
                          TextSpan(text: " ${appState.getCurrentUser.flashCardSets[widget.setIndex].title}", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                Text("${questionQuery.length} Questions", style: textTheme.displayMedium)
              ],
            ),
          ),
          const SizedBox(height: 10),
          //New Question button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
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
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: ListView(
                  key: Key(questionQuery.length.toString()),
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  // itemCount: questionQuery.length,
                  children: [
                    for (int index = 0; index < questionQuery.length; index++) ...{
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LayoutBuilder(builder: (context, consntraints) {
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
                                                    ? Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          ElevatedButton.icon(
                                                              style: ElevatedButton.styleFrom(
                                                                foregroundColor: theme.onBackground,
                                                                backgroundColor: theme.secondary,
                                                                shadowColor: Colors.transparent,
                                                                elevation: 0,
                                                                side: BorderSide(color: theme.tertiary, width: 1),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                              ),
                                                              onPressed: () => showDialog(
                                                                  context: context,
                                                                  builder: (context) => HintsDialog(
                                                                        questionQuery: questionQuery[index],
                                                                      )),
                                                              icon: const Icon(Icons.edit),
                                                              label: const Text("Hints")),
                                                          const SizedBox(width: 10),
                                                          ElevatedButton.icon(
                                                              label: Text("Delete", style: textTheme.displaySmall),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: theme.secondary,
                                                                shadowColor: Colors.transparent,
                                                                elevation: 0,
                                                                side: BorderSide(color: theme.tertiary, width: 1),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                              ),
                                                              onPressed: () => setState(() {
                                                                    questionQuery.removeAt(index);
                                                                  }),
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
                                              initialValue: questionQuery[index].question,
                                              decoration: InputDecoration(
                                                border: const OutlineInputBorder(
                                                  borderRadius: BorderRadius.zero,
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                                ),
                                                contentPadding: const EdgeInsets.all(0),
                                                hintText: "Question ${index + 1}",
                                                hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                                                // filled: true,
                                              ),
                                              style: textTheme.displaySmall,
                                              onChanged: (value) {
                                                questionQuery[index].question = value;
                                              },
                                            ),
                                            TextFormField(
                                              cursorColor: theme.onPrimary,
                                              textAlign: TextAlign.center,
                                              initialValue: questionQuery[index].answer,
                                              decoration: InputDecoration(
                                                border: const OutlineInputBorder(
                                                  borderRadius: BorderRadius.zero,
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                                ),

                                                contentPadding: const EdgeInsets.all(0),
                                                hintText: "Answer ${index + 1}",
                                                hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                                                // fillColor: theme.primary,
                                                // filled: true,
                                              ),
                                              style: textTheme.displaySmall,
                                              onChanged: (value) {
                                                questionQuery[index].question = value;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  //* image
                                  ImageSelector(
                                      image: questionQuery[index].image,
                                      onImageSelected: (image) {
                                        setState(() {
                                          questionQuery[index].image = image;
                                        });
                                      }),
                                ],
                              ),
                            );
                          }),
                        ),
                      )
                    }
                  ]),
            ),
          ),
          //Save and Cancel Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
            ),
          )
        ],
      )),
    );
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
        InkWell(
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.flip(flipY: expanded, child: RotatedBox(quarterTurns: 1, child: Icon(Icons.chevron_left, color: theme.onBackground))),
                const SizedBox(width: 5),
                Text("Image", style: textTheme.displaySmall),
              ],
            ),
          ),
        ),
        if (expanded)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () => addImage(), icon: Icon(Icons.add_a_photo, color: theme.onBackground)),
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
                    child: InkWell(
                      onTap: widget.image != null
                          ? () => showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 300,
                                        child: PhotoView(
                                          imageProvider: FileImage(File(widget.image!)),
                                          maxScale: PhotoViewComputedScale.covered * 2.0,
                                          minScale: PhotoViewComputedScale.contained * 0.8,
                                          initialScale: PhotoViewComputedScale.contained * 1.0,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextButton(
                                          onPressed: () => Clipboard.setData(ClipboardData(text: widget.image!)),
                                          child: Text(
                                            "Copy Image Path",
                                            style: textTheme.displaySmall,
                                          )),
                                    ],
                                  )))
                          : null,
                      child: widget.image != null
                          ? Image.file(
                              File(widget.image!),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                "No image",
                                style: textTheme.displaySmall,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }
}

class HintsDialog extends StatefulWidget {
  const HintsDialog({super.key, required this.questionQuery});

  final FCQuery questionQuery;

  @override
  State<HintsDialog> createState() => _HintsDialogState();
}

class _HintsDialogState extends State<HintsDialog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: theme.background,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text("Hints for ${widget.questionQuery.question}", style: textTheme.displayMedium),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                key: Key(widget.questionQuery.hints?.length.toString() ?? "0"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int index = 0; index < (widget.questionQuery.hints?.length ?? 0); index++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              cursorColor: theme.onPrimary,
                              textAlign: TextAlign.center,
                              initialValue: widget.questionQuery.hints?[index] ?? [],
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: theme.onBackground, width: 0.5),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                                ),
                                contentPadding: EdgeInsets.zero,
                                hintText: "Hint ${index + 1}",
                                hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                                filled: true,
                                fillColor: theme.primary,
                              ),
                              style: textTheme.displaySmall,
                              onChanged: (value) {
                                widget.questionQuery.hints?[index] = value;
                              },
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.questionQuery.hints?.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red))
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      widget.questionQuery.hints?.add("");
                    });
                  },
                  icon: const Icon(Icons.add),
                  color: theme.onBackground,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.done,
                      color: Colors.green,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
