import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
//ignore: unused_import
import 'package:flutter/material.dart';
import 'package:oneforall/service/files_service.dart';
//ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_data.dart';
//ignore: unused_import
import 'community_service.dart';

get getUserAuth => FirebaseAuth.instance;

Future login(String email, String password, bool saveCredentials) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((error, stacktrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  //* Save credentials
  if (saveCredentials) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", email);
    prefs.setString("password", password);
  }

  var auth = FirebaseAuth.instance;
  //Set user data
  await getDocument("users", auth.currentUser!.uid).then((value) {
    //set flashcard sets for setUserData
    //* Initialize an empty list of flashcard sets
    debugPrint(value.data()!["flashcardSets"].toString());
    List<FlashcardSet> flashcardSets = [];
    if (value.data()!["flashcardSets"] != null) {
      //* Add flashcard sets to the list
      for (var i = 0; i < value.data()!["flashcardSets"].length; i++) {
        flashcardSets.add(FlashcardSet(
            id: i,
            flashcards: [
              for (var j = 0;
                  j < value.data()!["flashcardSets"][i]["questions"].length;
                  j++)
                Flashcard(
                    id: j,
                    question: value.data()!["flashcardSets"][i]["questions"][j]
                        ["question"],
                    answer: value.data()!["flashcardSets"][i]["questions"][j]
                        ["answer"])
            ],
            title: value.data()!["flashcardSets"][i]["title"],
            description: value.data()!["flashcardSets"][i]["description"]));
      }
    }

    setUserData(UserData(
        uid: int.tryParse(auth.currentUser!.uid) ?? 0,
        exp: value.data()["exp"],
        streak: value.data()["streak"],
        posts: value.data()["posts"],
        flashCardSets: flashcardSets,
        username: auth.currentUser!.displayName ?? "Invalid Username!",
        email: auth.currentUser!.email ?? "Invalid Email!",
        profilePicture: auth.currentUser!.photoURL ?? ""));
  }).catchError((error, stackTrace) {
    debugPrint("err on auth service: getDocument");
    throw error;
  });

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

      //* Add the flashcard sets to the user data
      for (FlashcardSet set in flashcardSets) {
        getUserData.flashCardSets.add(set);
      }
    }
  });

  //* Set community data
  await getValue("users", auth.currentUser!.uid, "assignedCommunity")
      .then((value) async {
    if (value != null) {
      debugPrint("Assigned community: $value");
      await getCommunityData(value);
    } else {
      throw Exception("User not assigned to community");
    }
  }).catchError((error, stackTrace) {
    debugPrint("err on auth service: getValue");
    throw error;
  });
  //* hasOpenedBefore = true
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool("hasOpenedBefore", true);
  return true;
}

Future createAccount(String email, String password, String username) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .catchError((error, stacktrace) {
      throw error.toString();
    });
  } catch (e) {
    rethrow;
  }

  await FirebaseAuth.instance.currentUser!
      .updateDisplayName(username)
      .onError((error, stackTrace) => throw stackTrace);
  await FirebaseAuth.instance.currentUser!
      .updatePhotoURL("https://api.dicebear.com/api/initials/$username.svg")
      .onError((error, stackTrace) => throw stackTrace);
  //Create user data
  await createUserData(FirebaseAuth.instance.currentUser!.uid)
      .catchError((error, stackTrace) {
    throw error;
  });
  var auth = FirebaseAuth.instance;
  //Set user data
  await getDocument("users", auth.currentUser!.uid).then((value) {
    setUserData(UserData(
        uid: int.tryParse(auth.currentUser!.uid) ?? 0,
        exp: value["exp"] ?? -1,
        streak: value["streak"] ?? -1,
        posts: value["posts"] ?? -1,
        flashCardSets:
            value["flashCardSets"] == [] ? [] : value["flashCardSets"],
        username: auth.currentUser!.displayName ?? "Invalid Username!",
        email: auth.currentUser!.email ?? "Invalid Email!",
        profilePicture: auth.currentUser!.photoURL ?? ""));
  }).catchError((error, stackTrace) {
    throw error;
  });
  //* First time load = false
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool("hasOpenedBefore", true);
  return true;
}

Future changeUserName(String username) async {
  try {
    await FirebaseAuth.instance.currentUser!
        .updateDisplayName(username)
        .catchError((error, stacktrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  return true;
}

Future changeUserProfilePicture(
    File file, String? previousProfilePicture) async {
  String url = "";
  //* Upload new profile picture to firebase storage
  try {
    url = await uploadUserPP(
        file, "profile_picture_${FirebaseAuth.instance.currentUser!.uid}");
  } catch (e) {
    rethrow;
  }

  try {
    await FirebaseAuth.instance.currentUser!
        .updatePhotoURL(url)
        .catchError((error, stacktrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  if (previousProfilePicture != null) {
    //* Delete previous profile picture from firebase storage
    //TODO implement
  }
  return url;
}

Future changeUserEmail(String email) async {
  try {
    await FirebaseAuth.instance.currentUser!
        .updateEmail(email)
        .catchError((error, stacktrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  return true;
}

Future logout() async {
  try {
    await FirebaseAuth.instance.signOut().catchError((error, stacktrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  return true;
}
