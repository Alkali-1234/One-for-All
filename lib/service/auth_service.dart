import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//ignore: unused_import
import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/main.dart';
import 'package:oneforall/service/files_service.dart';
import 'package:oneforall/service/firebase_api.dart';
//ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_data.dart';
//ignore: unused_import
import '../models/quizzes_models.dart';
import 'community_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

get getUserAuth => FirebaseAuth.instance;

Future login(String email, String password, bool saveCredentials, AppState appState) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).catchError((error, stacktrace) {
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
  final assignedCommunity = await getValue("users", auth.currentUser!.uid, "assignedCommunity") ?? "";
  await getDocument("users", auth.currentUser!.uid).then((value) async {
    //set flashcard sets for setUserData
    //* Initialize an empty list of flashcard sets
    debugPrint(value.data()!["flashcardSets"].toString());
    List<FlashcardSet> flashcardSets = [];
    //! Temporarily unused
    // // if (value.data()!["flashcardSets"] != null) {
    // //   //* Add flashcard sets to the list
    // //   for (var i = 0; i < value.data()!["flashcardSets"].length; i++) {
    // //     flashcardSets.add(FlashcardSet(
    // //         id: i,
    // //         flashcards: [
    // //           for (var j = 0; j < value.data()!["flashcardSets"][i]["questions"].length; j++) Flashcard(image: null, id: j, question: value.data()!["flashcardSets"][i]["questions"][j]["question"], answer: value.data()!["flashcardSets"][i]["questions"][j]["answer"], hints: [])
    // //         ],
    // //         title: "${value.data()!["flashcardSets"][i]["title"]} (Cloud)",
    // //         description: value.data()!["flashcardSets"][i]["description"]));
    // //   }
    // // }

    List<String> incompleteData = [];
    //* Check if user data is incomplete
    if (value.data()!["exp"] == null) {
      incompleteData.add("exp");
    }
    if (value.data()!["streak"] == null) {
      incompleteData.add("streak");
    }
    if (value.data()!["posts"] == null) {
      incompleteData.add("posts");
    }
    if (value.data()!["sections"] == null) {
      incompleteData.add("sections");
    }
    //! Temporarily unused
    // if (value.data()!["flashcardSets"] == null) {
    //   incompleteData.add("flashcardSets");
    // }
    if (value.data()!["assignedCommunity"] == null) {
      incompleteData.add("assignedCommunity");
    }
    if (value.data()!["sections"] == null) {
      incompleteData.add("sections");
    }
    if (value.data()!["username"] == null) {
      incompleteData.add("username");
    }
    if (value.data()!["profilePicture"] == null) {
      incompleteData.add("profilePicture");
    }
    if (value.data()!["community"] == null) {
      incompleteData.add("community");
    }

    //* Set missing data
    if (incompleteData.isNotEmpty) {
      await FirebaseFirestore.instance.collection("users").doc(auth.currentUser!.uid).update({
        for (var data in incompleteData)
          data: data == "flashcardSets"
              ? []
              : data == "sections"
                  ? []
                  : data == "community"
                      ? assignedCommunity ?? ""
                      : data == "username"
                          ? auth.currentUser!.displayName
                          : data == "profilePicture"
                              ? auth.currentUser!.photoURL
                              : 0
      });
    }

    //* New Method
    appState.setCurrentUser(UserData(
      uid: int.tryParse(auth.currentUser!.uid) ?? 0,
      exp: value.data()!["exp"] ?? 0,
      streak: value.data()!["streak"] ?? 0,
      posts: value.data()!["posts"] ?? 0,
      flashCardSets: flashcardSets,
      username: auth.currentUser!.displayName ?? "Invalid Username!",
      email: auth.currentUser!.email ?? "Invalid Email!",
      profilePicture: auth.currentUser!.photoURL ?? "",
      assignedCommunity: (assignedCommunity.isEmpty || assignedCommunity == null) ? "0" : assignedCommunity,
      //! user may have multiple sections
      assignedSection: value.data()!["sections"].isEmpty ? "0" : value.data()!["sections"][0],
    ));

    print(appState.getCurrentUser);

    // //! Deprecated method
    // setUserData(UserData(
    //   uid: int.tryParse(auth.currentUser!.uid) ?? 0,
    //   exp: value.data()["exp"],
    //   streak: value.data()["streak"],
    //   posts: value.data()["posts"],
    //   flashCardSets: flashcardSets,
    //   username: auth.currentUser!.displayName ?? "Invalid Username!",
    //   email: auth.currentUser!.email ?? "Invalid Email!",
    //   profilePicture: auth.currentUser!.photoURL ?? "",
    //   assignedCommunity: assignedCommunity,
    //   assignedSection: value.data()!["sections"][0],
    // ));
  }).catchError((error, stackTrace) {
    debugPrint("err on auth service: getDocument");
    throw error;
  });
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
                for (int i = 0; i < quiz["questions"].length; i++) QuizQuestion(imagePath: quiz["questions"][i]["imagePath"] ?? "", id: i, question: quiz["questions"][i]["question"], answers: List<String>.from(quiz["questions"][i]["answers"] as List), correctAnswer: List<int>.from(quiz["questions"][i]["correctAnswer"] as List), type: quiz["questions"][i]["type"] != null ? QuizTypes.values[quiz["questions"][i]["type"]] : QuizTypes.multipleChoice),
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
          for (var flashcard in set['questions']) Flashcard(image: flashcard['image'], id: set['questions'].indexOf(flashcard), question: flashcard['question'], answer: flashcard['answer'], hints: flashcard['hints'])
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
  print(appState.getMabData?.posts);

  final assignedSection = appState.getCurrentUser.assignedSection != "0" ? appState.getCurrentUser.assignedSection![0] : "";

  //* Initialize FCM
  if (kIsWeb == false) await initializeFCM(assignedCommunity, assignedSection);
  //* hasOpenedBefore = true
  prefs.setBool("hasOpenedBefore", true);
  return true;
}

Future createAccount(String email, String password, String username, AppState appState) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).catchError((error, stacktrace) {
      throw error.toString();
    });
  } catch (e) {
    rethrow;
  }

  await FirebaseAuth.instance.currentUser!.updateDisplayName(username).onError((error, stackTrace) => throw stackTrace);
  await FirebaseAuth.instance.currentUser!.updatePhotoURL("https://api.dicebear.com/api/initials/$username.svg").onError((error, stackTrace) => throw stackTrace);
  //Create user data
  await createUserData(FirebaseAuth.instance.currentUser!.uid).catchError((error, stackTrace) {
    throw error;
  });
  await login(email, password, false, appState).catchError((error, stackTrace) {
    throw error;
  });
  //* First time load = false
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool("hasOpenedBefore", true);
  return true;
}

Future saveFCMToken(String token) async {
  //* Check if user is logged in
  if (FirebaseAuth.instance.currentUser == null) {
    throw Exception("user_not_logged_in");
  }
  //* Check if user has already saved the token with shared prefs
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("fcmToken")) {
    if (prefs.getString("fcmToken") == token) {
      return true;
    }
  }
  try {
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "fcmToken": token
    });
  } catch (e) {
    rethrow;
  }
  prefs.setString("fcmToken", token);
  return true;
}

Future changeUserName(String username) async {
  try {
    await FirebaseAuth.instance.currentUser!.updateDisplayName(username).catchError((error, stacktrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  return true;
}

Future changeUserProfilePicture(File file, String? previousProfilePicture) async {
  String url = "";
  //* Upload new profile picture to firebase storage
  try {
    url = await uploadUserPP(file, "profile_picture_${FirebaseAuth.instance.currentUser!.uid}");
  } catch (e) {
    rethrow;
  }

  try {
    await FirebaseAuth.instance.currentUser!.updatePhotoURL(url).catchError((error, stacktrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  try {
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "profilePicture": url
    });
  } catch (e) {
    rethrow;
  }
  // if (previousProfilePicture != null) {
  //   //* Delete previous profile picture from firebase storage
  //   try {
  //     await FirebaseStorage.instance.refFromURL(previousProfilePicture).delete();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  return url;
}

Future changeUserEmail(String email) async {
  try {
    await FirebaseAuth.instance.currentUser!.updateEmail(email).catchError((error, stacktrace) {
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
