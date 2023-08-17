import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

ThemeData passedUserTheme = defaultBlueTheme;

class UserData {
  UserData(
      {required this.uid,
      required this.exp,
      required this.streak,
      required this.posts,
      required this.flashCardSets,
      required this.username,
      required this.email,
      required this.profilePicture,
      required this.assignedCommunity,
      required this.assignedSection});

  final int uid;
  int exp;
  int streak;
  int posts;
  String username;
  String email;
  String profilePicture;
  List<FlashcardSet> flashCardSets;
  String? assignedCommunity;
  String? assignedSection;

  set setExp(int exp) => this.exp = exp;
  set setStreak(int streak) => this.streak = streak;
  set setPosts(int posts) => this.posts = posts;
  set setUsername(String username) => this.username = username;
  set setEmail(String email) => this.email = email;
  set setProfilePicture(String profilePicture) =>
      this.profilePicture = profilePicture;
  set setFlashCardSets(List<FlashcardSet> flashCardSets) =>
      this.flashCardSets = flashCardSets;
  set addFlashCardSet(FlashcardSet flashCardSet) =>
      flashCardSets.add(flashCardSet);
}

UserData? userData;

@Deprecated("Use stream builder and provider instead")
void setUserData(UserData data) => userData = data;

@Deprecated("Use stream builder and provider instead")
get getUserData => userData!;

class FlashcardSet {
  FlashcardSet(
      {required this.id,
      required this.title,
      required this.description,
      required this.flashcards});

  final int id;
  String title;
  String description;
  List<Flashcard> flashcards;
}

class Flashcard {
  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
  });

  final int id;
  String question;
  String answer;
}

//! check if this still throws an error
@Deprecated("No longer used")
Future reloadFlashcards() async {
  //* Get flashcard sets from shared preferences
  await SharedPreferences.getInstance().then((value) {
    if (value.containsKey("flashcardSets")) {
      dynamic decodedObject = jsonDecode(value.getString("flashcardSets")!);

      //* Convert the decoded `dynamic` object back to your desired Dart object structure
      List<FlashcardSet> flashcardSets = [];
      for (var set in decodedObject['sets']) {
        flashcardSets.add(FlashcardSet(
            id: decodedObject['sets'].indexOf(set),
            title: set["title"],
            description: "description_unavailable",
            flashcards: [
              for (var flashcard in set['questions'])
                Flashcard(
                    id: set['questions'].indexOf(flashcard),
                    question: flashcard['question'],
                    answer: flashcard['answer'])
            ]));
      }

      //* Empty the flashcard sets
      getUserData.flashCardSets = List<FlashcardSet>.empty(growable: true);

      //* Add the flashcard sets to the user data
      for (FlashcardSet set in flashcardSets) {
        getUserData.flashCardSets.add(set);
      }
    }
  });
}
