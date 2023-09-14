import 'package:flutter/material.dart';
import 'package:oneforall/models/quizzes_models.dart';

class DropDownEdit extends StatefulWidget {
  const DropDownEdit({super.key, this.question});
  final QuizQuestion? question;

  @override
  State<DropDownEdit> createState() => DropDownEditState();
}

class DropDownEditState extends State<DropDownEdit> {
  List<String> dropdownAnswers = [
    "This",
    "dropdown"
  ];
  List<String> dropdownSentence = [
    "<dropdown answer=0 />",
    "is a",
    "<dropdown answer=1 />"
  ];

  List<TextEditingController> sentenceTextControllers = [];
  List<TextEditingController> answerTextControllers = [];

  @override
  void initState() {
    super.initState();
    //* If the question is not null, we set the sentence and answers
    if (widget.question != null) {
      dropdownAnswers = widget.question!.answers;
      dropdownSentence = widget.question!.question.split('<seperator />');
    }
    sentenceTextControllers = List.generate(dropdownSentence.length, (index) => TextEditingController(text: dropdownSentence[index]));
    answerTextControllers = List.generate(dropdownAnswers.length, (index) => TextEditingController(text: dropdownAnswers[index]));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              "Answers:",
              style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        for (int i = 0; i < dropdownAnswers.length; i++) ...{
          Row(
            children: [
              Flexible(
                flex: 8,
                child: TextField(
                  controller: answerTextControllers[i],
                  cursorColor: theme.onBackground,
                  style: textTheme.displaySmall,
                  decoration: InputDecoration(
                    fillColor: theme.primary,
                    filled: true,
                    border: null,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primary),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      dropdownAnswers[i] = value;
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                  flex: 2,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: theme.secondary,
                          foregroundColor: theme.onBackground,
                        ),
                        onPressed: () {
                          if (dropdownAnswers.length == 1) return;
                          setState(() {
                            //* Update the dropdowns
                            for (int j = 0; j < dropdownSentence.length; j++) {
                              if (dropdownSentence[j].contains("answer=$i")) {
                                dropdownSentence[j] = "<dropdown answer=0 />";
                              } else if (dropdownSentence[j].contains("answer=${dropdownAnswers.length - 1}")) {
                                dropdownSentence[j] = "<dropdown answer=${dropdownAnswers.length - 2} />";
                              }
                            }
                            dropdownAnswers.removeAt(i);
                            answerTextControllers.removeAt(i);
                          });
                        },
                        child: const Icon(Icons.close_rounded)),
                  )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        },
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: theme.secondary,
            foregroundColor: theme.onBackground,
          ),
          onPressed: () {
            setState(() {
              dropdownAnswers.add("");
              answerTextControllers.add(TextEditingController());
            });
          },
          child: const Icon(Icons.add_rounded),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Text("Sentence: ", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          runSpacing: 10,
          children: [
            //* Loops through the sentence and checks if it contains a dropdown
            for (var i = 0; i < dropdownSentence.length; i++)
              if (dropdownSentence[i].contains("<dropdown"))
                //* If it does, we add a dropdown button
                //* The value of the dropdown button is the answer at the index of the answer in the sentence
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<int>(
                      style: textTheme.displaySmall,
                      value: int.parse(dropdownSentence[i].split("=")[1].split(" ")[0]),
                      onChanged: (newValue) {
                        setState(() {
                          dropdownSentence[i] = "<dropdown answer=${newValue.toString()} />";
                        });
                      },
                      items: [
                        for (int i = 0; i < dropdownAnswers.length; i++)
                          DropdownMenuItem(
                            value: i,
                            child: Text(dropdownAnswers[i]),
                          )
                      ],
                    ),
                    const SizedBox(width: 5),
                    //* Delete button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.secondary,
                        foregroundColor: theme.onBackground,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.all(7),
                      ),
                      onPressed: () {
                        setState(() {
                          dropdownSentence.removeAt(i);
                          sentenceTextControllers.removeAt(i);
                        });
                      },
                      child: const Icon(Icons.close_rounded),
                    ),
                    const SizedBox(width: 5),
                  ],
                )
              else
                //* If it isn't, we just add the text as a textField
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: sentenceTextControllers[i],
                        cursorColor: theme.onBackground,
                        style: textTheme.displaySmall,
                        decoration: InputDecoration(
                          fillColor: theme.primary,
                          filled: true,
                          border: null,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.primary),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            dropdownSentence[i] = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: theme.secondary,
                          foregroundColor: theme.onBackground,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.all(7)),
                      onPressed: () {
                        setState(() {
                          dropdownSentence.removeAt(i);
                          sentenceTextControllers.removeAt(i);
                        });
                      },
                      child: const Icon(Icons.close_rounded),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: theme.secondary,
            foregroundColor: theme.onBackground,
          ),
          onPressed: () {
            setState(() {
              dropdownSentence.add("");
              sentenceTextControllers.add(TextEditingController());
            });
          },
          icon: const Icon(Icons.text_fields_rounded),
          label: const Text("Add Text"),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: theme.secondary,
              foregroundColor: theme.onBackground,
            ),
            onPressed: () {
              setState(() {
                dropdownSentence.add("<dropdown answer=0 />");
                sentenceTextControllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.question_mark_rounded),
            label: const Text("Add Dropdown")),
      ],
    );
  }
}

// class CustomDropdown extends StatelessWidget {
//   const CustomDropdown({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
