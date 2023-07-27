import 'package:firebase_auth/firebase_auth.dart';
//ignore: unused_import
import 'package:flutter/material.dart';
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
  if(saveCredentials) {
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
                flashcardSets.add(FlashcardSet(id: i, flashcards: [
                    for (var j = 0; j < value.data()!["flashcardSets"][i]["questions"].length; j++)
                        Flashcard(id: j, question: value.data()!["flashcardSets"][i]["questions"][j]["question"], answer: value.data()!["flashcardSets"][i]["questions"][j]["answer"])
                ], title: value.data()!["flashcardSets"][i]["title"], description: value.data()!["flashcardSets"][i]["description"]));
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

  
    //Set community data
  await getValue("users", auth.currentUser!.uid, "assignedCommunity").then((value) async {
    if (value != null) {
        debugPrint("Assigned community: $value");
     await getCommunityData(value); 
    } else { throw Exception("User not assigned to community"); }
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
        flashCardSets: value["flashCardSets"] == [] ? [] : value["flashCardSets"],
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
