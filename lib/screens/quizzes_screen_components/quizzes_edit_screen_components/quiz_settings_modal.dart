import "package:flutter/material.dart";

import "../../../styles/styles.dart";

class QuizSettingsModal extends StatefulWidget {
  const QuizSettingsModal({super.key, required this.settings, required this.quizTitle, required this.onClose});
  final Map<String, dynamic> settings;
  final String quizTitle;
  final Function onClose;

  @override
  State<QuizSettingsModal> createState() => QuizSettingsModalState();
}

class QuizSettingsModalState extends State<QuizSettingsModal> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Settings for ${widget.quizTitle}", style: textTheme.displayMedium),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Shuffle Questions", style: textTheme.displaySmall),
                  Switch(
                      activeColor: Colors.green,
                      activeTrackColor: Colors.white,
                      inactiveThumbColor: Colors.red,
                      value: widget.settings["shuffleQuestions"] ?? false,
                      onChanged: (value) => setState(() {
                            widget.settings["shuffleQuestions"] = value;
                          }))
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Shuffle Answers", style: textTheme.displaySmall),
                  Switch(
                      activeColor: Colors.green,
                      activeTrackColor: Colors.white,
                      inactiveThumbColor: Colors.red,
                      value: widget.settings["shuffleAnswers"] ?? false,
                      onChanged: (value) => setState(() {
                            widget.settings["shuffleAnswers"] = value;
                          }))
                ],
              ),
              const SizedBox(height: 2),
              //* Redemption amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Redemption Amounts", style: textTheme.displaySmall),
                  IntrinsicWidth(
                    child: TextField(
                      controller: TextEditingController(text: widget.settings["redemptionAmounts"] != null ? widget.settings["redemptionAmounts"].toString() : ""),
                      keyboardType: TextInputType.number,
                      style: textTheme.displaySmall,
                      cursorColor: theme.onBackground,
                      decoration: TextInputStyle(theme: theme, textTheme: textTheme).getTextInputStyle().copyWith(hintText: "Amount", hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25), fontWeight: FontWeight.bold)),
                      onChanged: (value) => setState(() {
                        widget.settings["redemptionAmounts"] = value;
                      }),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryContainer,
                    foregroundColor: theme.onBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => widget.onClose(),
                  icon: const Icon(Icons.check),
                  label: const Text("Done"))
            ],
          ),
        ),
      ),
    );
  }
}
