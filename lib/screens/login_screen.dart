//
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oneforall/components/styled_components/elevated_button.dart';
import 'package:oneforall/components/styled_components/primary_elevated_button.dart';
import 'package:oneforall/components/styled_components/text_field.dart';
import 'package:oneforall/data/user_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../constants.dart';
import '../models/quiz_question.dart';
import '../service/auth_service.dart';
import '../main.dart';
import 'package:email_validator/email_validator.dart';
import './get_started.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String emailQuery = "";
  String passwordQuery = "";
  String error = "";
  bool saveCredentials = false;
  bool isLoading = false;

  void pushToPage(Widget page) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => page));
    return;
  }

  void attemptLogin(AppState appState) async {
    setState(() {
      isLoading = true;
    });
    //Check if email and password are filled
    if (emailQuery == "" || passwordQuery == "") {
      setState(() {
        isLoading = false;
        error = "Please fill in all fields";
      });
      return;
    }
    //Validate email
    if (!EmailValidator.validate(emailQuery)) {
      setState(() {
        isLoading = false;
        error = "Please enter a valid email";
      });
      return;
    }

    var prefs = await SharedPreferences.getInstance();
    bool hasOpenedBefore = prefs.getBool("hasOpenedBefore") ?? false;

    //Attempt to login
    await login(emailQuery, passwordQuery, saveCredentials, appState)
        .then((value) => pushToPage(ShowCaseWidget(
              builder: Builder(builder: (context) {
                return HomePage(
                  doShowcase: !hasOpenedBefore,
                );
              }),
            )))
        .onError((error, stackTrace) => setState(() {
              isLoading = false;
              this.error = error.toString();
            }));
  }

  void loginAsGuest(AppState appState) async {
    appState.setCurrentUser(UserData(uid: 0, exp: 0, streak: 0, posts: 0, flashCardSets: [], username: "Guest", email: "guest@guest.com", profilePicture: "https://picsum.photos/200", assignedCommunity: "0", assignedSection: "0", roles: []));
    appState.setQuizzes([]);
    //* Get quizzes data from shared preferences
    await SharedPreferences.getInstance().then((value) {
      if (value.containsKey("quizData")) {
        appState.setQuizzes([]);
        dynamic decodedObject = jsonDecode(value.getString("quizData")!);

        //* Convert the decoded `dynamic` object back to your desired Dart object structure
        List<QuizSet> quizzes = [];
        for (var quiz in decodedObject['quizzes']) {
          quizzes.add(
            QuizSet(
                title: quiz['title'],
                description: quiz['description'],
                questions: [
                  for (int i = 0; i < quiz["questions"].length; i++) QuizQuestion(imagePath: quiz["questions"][i]["imagePath"], id: i, question: quiz["questions"][i]["question"], answers: List<String>.from(quiz["questions"][i]["answers"] as List), correctAnswer: List<int>.from(quiz["questions"][i]["correctAnswer"] as List), type: quiz["questions"][i]["type"] != null ? QuizTypes.values[quiz["questions"][i]["type"]] : QuizTypes.multipleChoice),
                ],
                settings: quiz["settings"] ?? {}),
          );
        }

        //* Add the quizzes to the user data
        for (QuizSet quiz in quizzes) {
          appState.getQuizzes.add(quiz);
        }
      }
    });

    //* Get flashcard sets from shared preferences
    await SharedPreferences.getInstance().then((value) {
      if (value.containsKey("flashcardSets")) {
        dynamic decodedObject = jsonDecode(value.getString("flashcardSets")!);

        //* Convert the decoded `dynamic` object back to your desired Dart object structure
        List<FlashcardSet> flashcardSets = [];
        for (var set in decodedObject['sets']) {
          flashcardSets.add(FlashcardSet(id: decodedObject['sets'].indexOf(set), title: "${set["title"]}", description: "description_unavailable", flashcards: [
            for (var flashcard in set['questions']) Flashcard(image: flashcard['image'], id: set['questions'].indexOf(flashcard), question: flashcard['question'], answer: flashcard['answer'], hints: flashcard['hints'] ?? [])
          ]));
        }

        //* Add the flashcard sets to the user data
        for (FlashcardSet set in flashcardSets) {
          // getUserData.flashCardSets.add(set);
          appState.getCurrentUser.flashCardSets.add(set);
        }
      }
    });

    //* Set community data
    // ! No longer needed
    // if (assignedCommunity != null) {
    //   await getCommunityData(assignedCommunity).then((value) {
    //     return;
    //   }).catchError((error, stackTrace) {
    //     throw error;
    //   });
    // } else {
    //   throw Exception("user_not_assigned_to_community");
    // }

    // if (assignedCommunity is! String) {
    //   throw Exception("assigned_community_not_string");
    // }

    //* Notifications
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("setting_notifications_MAB")) {
      prefs.setBool("setting_notifications_MAB", true);
    }
    if (!prefs.containsKey("setting_notifications_LAC")) {
      prefs.setBool("setting_notifications_LAC", true);
    }
    if (!prefs.containsKey("setting_notifications_RecentActivity")) {
      prefs.setBool("setting_notifications_RecentActivity", true);
    }

    //if my hypothesis is correct, this should be null
    // print(appState.getMabData?.posts);

    // final assignedSection = appState.getCurrentUser.assignedSection != "0" ? appState.getCurrentUser.assignedSection![0] : "";

    //* initialize FCM
    // await initializeFCM(assignedCommunity, assignedSection);
    bool hasOpenedBefore = prefs.getBool("hasOpenedBefore") ?? false;
    //* hasOpenedBefore = true
    prefs.setBool("hasOpenedBefore", true);
    pushToPage(ShowCaseWidget(
      builder: Builder(builder: (context) {
        return HomePage(
          doShowcase: !hasOpenedBefore,
        );
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = context.watch<AppState>();
    var ctheme = appState.getCurrentTheme(context);
    return Scaffold(
        body: SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Text(
                "Log In",
                style: textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              StyledTextField(
                theme: ctheme,
                onChanged: (value) => setState(() {
                  emailQuery = value;
                }),
                hint: "Email",
              ),
              const SizedBox(height: 10),
              StyledTextField(
                onChanged: (value) => setState(() {
                  passwordQuery = value;
                }),
                theme: ctheme,
                hint: "Password",
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                          side: BorderSide(color: Theme.of(context).colorScheme.onBackground),
                          value: saveCredentials,
                          onChanged: (value) {
                            setState(() {
                              saveCredentials = value!;
                            });
                          }),
                      Text("Remember me", style: textTheme.displaySmall)
                    ],
                  ),
                  Text("", style: textTheme.displaySmall)
                ],
              ),
              const SizedBox(height: 20),
              StyledPrimaryElevatedButton(
                  theme: ctheme,
                  onPressed: () {
                    if (isLoading == false) {
                      attemptLogin(context.read<AppState>());
                    }
                  },
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: theme.onBackground),
                        )
                      : Text("Log In", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              error != "" ? Text(error, style: textTheme.displaySmall!.copyWith(color: theme.error)) : Container(),
              const SizedBox(
                height: 10,
              ),
              StyledElevatedButton(
                  theme: ctheme,
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GetStartedScreen()));
                  },
                  child: Text("Create a new account", style: textTheme.displaySmall)),
              const SizedBox(height: 20),

              // Login as Guest
              StyledElevatedButton(theme: ctheme, onPressed: () => loginAsGuest(context.read<AppState>()), child: Text("Login as Guest", style: textTheme.displaySmall))
            ],
          ),
        ),
      ),
    ));
  }
}
