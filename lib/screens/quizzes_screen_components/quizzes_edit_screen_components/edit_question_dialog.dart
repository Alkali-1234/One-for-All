import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:photo_view/photo_view.dart";
import "package:provider/provider.dart";

import "../../../components/quizzes_components/drag_and_drop_edit.dart";
import "../../../components/quizzes_components/drop_down_edit.dart";
import "../../../constants.dart";
import "../../../main.dart";
import "../../../models/quiz_question.dart";

import 'dart:math' as math;

///* Edit question modal
class EditQuestionModal extends StatefulWidget {
  const EditQuestionModal({super.key, required this.index, required this.question, required this.setQuizSet, required this.quizIndex, required this.onDone});
  final int index;
  final QuizQuestion question;
  final Function setQuizSet;
  final int quizIndex;
  final Function onDone;

  @override
  State<EditQuestionModal> createState() => EditQuestionModalState();
}

class EditQuestionModalState extends State<EditQuestionModal> {
  late QuizTypes questionType;
  late QuizQuestion question;
  final TextEditingController _questionController = TextEditingController();

  late List<TextEditingController> _textAnswerControllers;
  @override
  void initState() {
    super.initState();
    question = widget.question;
    questionType = question.type ?? QuizTypes.multipleChoice;
    if (questionType == QuizTypes.multipleChoice) _questionController.text = question.question;
    if (questionType == QuizTypes.multipleChoice) _textAnswerControllers = List.generate(question.answers.length, (index) => TextEditingController(text: question.answers[index]));
  }

  String error = "";

  //* Keys
  final dropDownEditKey = GlobalKey<DropDownEditState>();
  final reorderEditKey = GlobalKey<ReorderEditState>();

  //* Functions
  void validateDropdownQuestion(AppState appState) {
    if (dropDownEditKey.currentState == null) {
      throw Exception("Something went wrong. Please try again");
    }
    final dropDownEditState = dropDownEditKey.currentState;
    if (dropDownEditState!.dropdownSentence.isEmpty) {
      throw Exception("Sentence is empty");
    }
    if (dropDownEditState.dropdownAnswers.isEmpty || dropDownEditState.dropdownSentence.isEmpty) {
      throw Exception("There must be at least 1 answer and 1 sentence");
    }
    if (dropDownEditState.dropdownSentence.indexOf("<seperator />") > 0) {
      throw Exception("Illegal word: <seperator />");
    }

    QuizQuestion quizQuestion = QuizQuestion(
        imagePath: question.imagePath,
        id: widget.index,
        question: dropDownEditState.dropdownSentence.join("<seperator />"),
        answers: dropDownEditState.dropdownAnswers,
        correctAnswer: [
          for (var sentence in dropDownEditState.dropdownSentence)
            if (sentence.contains("<dropdown answer=")) int.parse(sentence.split("=")[1].split(" ")[0]),
        ],
        type: QuizTypes.dropdown);
    appState.getQuizzes[widget.quizIndex].questions[widget.index] = quizQuestion;
  }

  void validateReorderQuestion(AppState appState) {
    //* Check if there is atleast 1 drag item and 1 drop item
    if (reorderEditKey.currentState == null) {
      throw Exception("Something went wrong. Please try again");
    }
    if (reorderEditKey.currentState!.draggables.isEmpty || reorderEditKey.currentState!.correctOrder.isEmpty) {
      throw Exception("There must be at least 1 drag item and 1 drop item");
    }
    //* Check if there is no duplicate drag items
    for (var draggable in reorderEditKey.currentState!.draggables) {
      if (reorderEditKey.currentState!.draggables.where((element) => element == draggable).length > 1) {
        throw Exception("There cannot be duplicate drag items");
      }
    }
    QuizQuestion quizQuestion = QuizQuestion(imagePath: question.imagePath, id: widget.index, question: reorderEditKey.currentState!.question, answers: reorderEditKey.currentState!.draggables, correctAnswer: reorderEditKey.currentState!.correctOrder, type: QuizTypes.reorder);
    appState.getQuizzes[widget.quizIndex].questions[widget.index] = quizQuestion;
  }

  bool validateQuestions(AppState appState) {
    {
      if (questionType == QuizTypes.multipleChoice) {
        if (question.question == "") {
          setState(() {
            error = "Question cannot be empty";
          });
          return false;
        }
        if (question.answers.length < 2) {
          setState(() {
            error = "There must be at least 2 answers";
          });
          return false;
        }
        if (question.correctAnswer.isEmpty) {
          setState(() {
            error = "There must be at least 1 correct answer";
          });
          return false;
        }
        //* check for duplicates
        for (var answer in question.answers) {
          if (question.answers.where((element) => element == answer).length > 1) {
            setState(() {
              error = "There cannot be duplicate answers";
            });
            return false;
          }
        }
      }
      if (questionType == QuizTypes.dropdown) {
        try {
          validateDropdownQuestion(appState);
        } on Exception catch (e) {
          setState(() {
            error = e.toString();
          });
          return false;
        }
      }
      if (questionType == QuizTypes.reorder) {
        try {
          validateReorderQuestion(appState);
        } on Exception catch (e) {
          setState(() {
            error = e.toString();
          });
          return false;
        }
      }
      widget.setQuizSet(appState.getQuizzes[widget.quizIndex]);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = context.watch<AppState>();
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.primaryContainer,
          border: Border.all(color: theme.secondary, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //* Question type (Multiple Choices, Dropdown, Drag an Drop) more will be added Soon™
              SizedBox(
                width: double.infinity,
                child: DropdownButton(
                    isExpanded: true,
                    value: questionType,
                    style: textTheme.displaySmall,
                    items: [
                      DropdownMenuItem(
                          value: QuizTypes.multipleChoice,
                          child: Text(
                            "Multiple Choice",
                            style: textTheme.displaySmall,
                          )),
                      DropdownMenuItem(value: QuizTypes.dropdown, child: Text("Dropdown", style: textTheme.displaySmall)),
                      DropdownMenuItem(value: QuizTypes.reorder, child: Text("Reorder", style: textTheme.displaySmall)),
                    ],
                    onChanged: (value) => setState(() {
                          questionType = value as QuizTypes;
                        })),
              ),
              const SizedBox(height: 10),
              //* Add Image
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.primaryContainer,
                        foregroundColor: theme.onBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        Directory docsDir = await getApplicationDocumentsDirectory();
                        late bool previouslyHasImage = false;
                        String previousImagePath = "";
                        if (question.imagePath != null && question.imagePath!.isNotEmpty) {
                          previouslyHasImage = true;
                          previousImagePath = question.imagePath!;
                        }
                        final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (image == null) return;
                        int imageID = math.Random().nextInt(999999);
                        //* Check if directory exists
                        await Directory("${docsDir.path}/quizzesAssets/${appState.getQuizzes[widget.quizIndex].title}").exists().then((value) async {
                          if (value == false) {
                            await Directory("${docsDir.path}/quizzesAssets/${appState.getQuizzes[widget.quizIndex].title}").create(recursive: true);
                          }
                        });
                        File newImage = await File(image.path).copy("${docsDir.path}/quizzesAssets/${appState.getQuizzes[widget.quizIndex].title}/quizImage${image.name}_$imageID.png");
                        setState(() {
                          question.imagePath = newImage.path;
                        });
                        //! Previously has image not tested
                        if (previouslyHasImage) {
                          //* Check if any other question has the same image
                          for (var question in appState.getQuizzes[widget.quizIndex].questions) {
                            if (question.imagePath == previousImagePath) {
                              return;
                            }
                          }
                          await File.fromUri(Uri.file(previousImagePath)).delete();
                        }
                      },
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text("Add Image")),
                  if (question.imagePath != null && question.imagePath?.isNotEmpty == true)
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: theme.primaryContainer,
                          foregroundColor: theme.onBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          await File.fromUri(Uri.file(question.imagePath!)).delete();
                          //Remove the image path for any other question that has the same one
                          for (var question in appState.getQuizzes[widget.quizIndex].questions) {
                            if (question.imagePath == this.question.imagePath) {
                              question.imagePath = "";
                            }
                          }
                          appState.thisNotifyListeners();
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text("Remove Image")),
                ],
              ),
              const SizedBox(height: 10),
              //* Image if there is one
              question.imagePath != null && question.imagePath!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.onBackground, width: 2),
                          ),
                          height: 200,
                          child: InkWell(
                              splashColor: theme.onBackground.withOpacity(0.25),
                              onTap: () => showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      surfaceTintColor: Colors.transparent,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 300,
                                            child: PhotoView(
                                              backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                                              maxScale: PhotoViewComputedScale.covered * 2,
                                              minScale: PhotoViewComputedScale.contained * 0.8,
                                              imageProvider: FileImage(File(question.imagePath!)),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              TextButton(onPressed: () => Clipboard.setData(ClipboardData(text: question.imagePath!)), child: Text("Copy Image Path", style: textTheme.displaySmall)),
                                            ],
                                          )
                                        ],
                                      ))),
                              child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Hero(tag: "image", child: Image.file(File(question.imagePath!))))),
                        ),
                      ],
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: theme.primary),
                      child: Center(
                        child: Text(
                          "No Image",
                          style: textTheme.displaySmall,
                        ),
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
              //* Question
              questionType == QuizTypes.multipleChoice
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _questionController,
                          style: textTheme.displaySmall,
                          cursorColor: theme.onBackground,
                          decoration: InputDecoration(
                            fillColor: theme.primary,
                            filled: true,
                            hintText: "Question",
                            hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.onBackground, width: 1), borderRadius: BorderRadius.circular(10)),
                          ),
                          onChanged: (value) => setState(() {
                            question.question = value;
                          }),

                          //* Answers | Checklist (Answer)
                        ),
                        const SizedBox(height: 20),
                        //* Add answer
                        Row(
                          children: [
                            IconButton(
                                onPressed: () => setState(() {
                                      _textAnswerControllers.add(TextEditingController(text: "Answer ${question.answers.length + 1}"));
                                      question.answers.add("Answer ${question.answers.length + 1}");
                                    }),
                                icon: const Icon(Icons.add, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: TextField(
                                          onTap: () => _textAnswerControllers[index].selection = TextSelection(baseOffset: 0, extentOffset: _textAnswerControllers[index].text.length),
                                          controller: _textAnswerControllers[index],
                                          style: textTheme.displaySmall,
                                          cursorColor: theme.onBackground,
                                          decoration: InputDecoration(
                                            fillColor: theme.primary,
                                            filled: true,
                                            hintText: "Answer ${index + 1}",
                                            hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold),
                                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.onBackground, width: 1), borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              question.answers[index] = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            checkColor: theme.onBackground,
                                            value: question.correctAnswer.contains(index),
                                            onChanged: (value) => setState(() {
                                                  if (value == null) return;
                                                  if (value) question.correctAnswer.add(index);
                                                  if (!value) question.correctAnswer.remove(index);
                                                  setState(() {});
                                                })),
                                        IconButton(
                                            onPressed: () => setState(() {
                                                  _textAnswerControllers.removeAt(index);
                                                  question.answers.removeAt(index);
                                                  question.correctAnswer.remove(index);
                                                }),
                                            icon: const Icon(Icons.delete, color: Colors.red)),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                            itemCount: question.answers.length,
                          ),
                        ),
                      ],
                    )
                  : questionType == QuizTypes.dropdown
                      ? DropDownEdit(
                          key: dropDownEditKey,
                          question: question,
                        )
                      : questionType == QuizTypes.reorder
                          ? ReorderEdit(key: reorderEditKey, question: widget.question.type == QuizTypes.reorder ? question : null)
                          : Text(
                              "how tf (frick) did you get here",
                              style: textTheme.displaySmall,
                            ),
              const SizedBox(height: 10),
              //* Done
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     ElevatedButton.icon(
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: theme.primaryContainer,
              //           foregroundColor: theme.onBackground,
              //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              //         ),
              //         onPressed: () {
              //           if (questionType == quizTypes.multipleChoice) {
              //             if (question.question == "") {
              //               setState(() {
              //                 error = "Question cannot be empty";
              //               });
              //               return;
              //             }
              //             if (question.answers.length < 2) {
              //               setState(() {
              //                 error = "There must be at least 2 answers";
              //               });
              //               return;
              //             }
              //             if (question.correctAnswer.isEmpty) {
              //               setState(() {
              //                 error = "There must be at least 1 correct answer";
              //               });
              //               return;
              //             }
              //             //* check for duplicates
              //             for (var answer in question.answers) {
              //               if (question.answers.where((element) => element == answer).length > 1) {
              //                 setState(() {
              //                   error = "There cannot be duplicate answers";
              //                 });
              //                 return;
              //               }
              //             }
              //           }
              //           if (questionType == quizTypes.dropdown) {
              //             try {
              //               validateDropdownQuestion(appState);
              //             } on Exception catch (e) {
              //               setState(() {
              //                 error = e.toString();
              //               });
              //               return;
              //             }
              //           }
              //           if (questionType == quizTypes.reorder) {
              //             try {
              //               validateReorderQuestion(appState);
              //             } on Exception catch (e) {
              //               setState(() {
              //                 error = e.toString();
              //               });
              //               return;
              //             }
              //           }
              //           widget.setQuizSet(appState.getQuizzes[widget.quizIndex]);
              //           widget.onDone();
              //         },
              //         icon: const Icon(Icons.done),
              //         label: const Text("Done")),
              //   ],
              // ),

              error != "" ? Text(error, style: textTheme.displaySmall!.copyWith(color: theme.error)) : const SizedBox(),
            ],
          ),
        ));
  }
}
