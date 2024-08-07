import 'package:flutter/material.dart';
// import 'package:introduction_screen/introduction_screen.dart';
import 'package:oneforall/models/quiz_question.dart';
import 'package:oneforall/styles/styles.dart';

class ReorderEdit extends StatefulWidget {
  const ReorderEdit({required super.key, this.question});
  final QuizQuestion? question;

  @override
  State<ReorderEdit> createState() => ReorderEditState();
}

class ReorderEditState extends State<ReorderEdit> {
  String question = "Order the words to make a sentence!"; //Question
  List<String> draggables = [
    "This",
    "is a",
    "reorder",
    "question!",
  ]; //Answers
  List<int> correctOrder = [
    -1,
    -1,
    -1,
    -1,
  ]; //Correct answer

  //* Controllers
  late TextEditingController questionController;
  late TextEditingController currentlyEditingController;

  int currentlyEditing = -1;
  bool dragging = false;

  @override
  void initState() {
    super.initState();
    //* Initialize variables if question is not null
    if (widget.question != null) {
      question = widget.question!.question;
      draggables = widget.question!.answers;
      correctOrder = widget.question!.correctAnswer;
    }
    questionController = TextEditingController(text: question);
    currentlyEditingController = TextEditingController(text: currentlyEditing != -1 ? draggables[currentlyEditing] : "");
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //* Question
        TextField(
          cursorColor: theme.onBackground,
          style: textTheme.displaySmall,
          controller: questionController,
          decoration: TextInputStyle(theme: theme, textTheme: textTheme).getTextInputStyle().copyWith(
                hintText: "Question",
              ),
          onChanged: (value) => question = value,
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondary,
                foregroundColor: theme.onBackground,
                side: BorderSide(color: theme.tertiary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  draggables.add("New Option");
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add option")),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondary,
                foregroundColor: theme.onBackground,
                side: BorderSide(color: theme.tertiary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  correctOrder.add(-1);
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add order")),
        ),
        const SizedBox(height: 5),
        //* Drag and Drops
        Row(
          children: [
            Text(
              "Options: (Double tap the text to change it)",
              style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              //* Draggable widgets
              children: [
                for (int i = 0; i < draggables.length; i++) ...[
                  SizedBox(
                    height: 50,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Draggable<int>(
                          onDragStarted: () => setState(() {
                                dragging = true;
                              }),
                          onDragEnd: (details) => setState(() {
                                dragging = false;
                              }),
                          data: i,
                          feedback: Container(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(color: theme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text(draggables[i], style: textTheme.displaySmall),
                            ),
                          ),
                          childWhenDragging: Container(
                            decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(color: theme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(10),
                                child: Center(
                                  child: GestureDetector(
                                      onDoubleTap: () {
                                        setState(() {
                                          currentlyEditing = i;
                                          currentlyEditingController.text = draggables[i];
                                          currentlyEditingController.selection = TextSelection(baseOffset: 0, extentOffset: currentlyEditingController.text.length);
                                        });
                                      },
                                      child: currentlyEditing == i
                                          ? IntrinsicWidth(
                                              child: TextField(
                                                autofocus: true,
                                                cursorColor: theme.onBackground,
                                                style: textTheme.displaySmall,
                                                controller: currentlyEditingController,
                                                // onTap: () {
                                                //   currentlyEditingController.selection = TextSelection(baseOffset: 0, extentOffset: currentlyEditingController.text.length);
                                                // },
                                                decoration: TextInputStyle(theme: theme, textTheme: textTheme).getTextInputStyle().copyWith(hintText: "Option", contentPadding: const EdgeInsets.only(left: 5)),
                                                onChanged: (value) => draggables[i] = value,
                                                onEditingComplete: () => setState(() {
                                                  currentlyEditing = -1;
                                                }),
                                                onTapOutside: (event) => setState(() {
                                                  currentlyEditing = -1;
                                                }),
                                              ),
                                            )
                                          : Text(draggables[i], style: textTheme.displaySmall)),
                                ),
                              ),
//* Delete button
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, padding: const EdgeInsets.all(2.5)),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      draggables.removeAt(i);
                                    });
                                  },
                                ),
                              )
                            ],
                          ));
                    }),
                  ),
                  const SizedBox(height: 15)
                ]
              ],
            ),
          ),
        ),
        Row(
          children: [
            Text(
              "Correct Order: ",
              style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              //* Draggable widgets
              children: [
                for (int i = 0; i < correctOrder.length; i++) ...[
                  SizedBox(
                    height: 55,
                    child: DragTarget<int>(
                      onAcceptWithDetails: (data) {
                        correctOrder[i] = data.data;
                        setState(() {});
                      },
                      builder: (context, List<int?> candidateData, rejectedData) {
                        // if (correctOrder.length >= i && correctOrder[i] != -1) {
                        //   return Container(
                        //     decoration: BoxDecoration(color: theme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                        //     child: Center(
                        //       child: Text(draggables[correctOrder[i]], style: textTheme.displaySmall),
                        //     ),
                        //   );
                        // }
                        return Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: dragging ? const EdgeInsets.all(4) : const EdgeInsets.all(5),
                              decoration: BoxDecoration(border: dragging ? Border.all(color: theme.onBackground.withOpacity(0.5)) : null, color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                decoration: BoxDecoration(color: (correctOrder.length >= i && correctOrder[i] != -1) ? theme.primaryContainer : theme.primary, borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: (correctOrder.length >= i && correctOrder[i] != -1)
                                      ? Text(
                                          draggables[correctOrder[i]],
                                          style: textTheme.displaySmall,
                                        )
                                      : Text("Order #${i + 1}", style: textTheme.displaySmall),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, padding: const EdgeInsets.all(2.5)),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                onPressed: () {
                                  setState(() {
                                    correctOrder.removeAt(i);
                                  });
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}
