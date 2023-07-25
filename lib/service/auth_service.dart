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

  var auth = FirebaseAuth.instance;
  //Set user data
    await getDocument("users", auth.currentUser!.uid).then((value) {
        setUserData(UserData(
            uid: int.tryParse(auth.currentUser!.uid) ?? 0,
            exp: value["exp"] ?? -1,
            streak: value["streak"] ?? -1,
            posts: value["posts"] ?? -1,
            flashCardSets: value["flashCardSets"] ?? [],
            username: auth.currentUser!.displayName ?? "Invalid Username!",
            email: auth.currentUser!.email ?? "Invalid Email!",
            profilePicture: auth.currentUser!.photoURL ?? ""));
    }).catchError((error, stackTrace) {
        throw error;
    });

  
    //Set community data
  await getValue("users", auth.currentUser!.uid, "assignedCommunity").then((value) async {
    if (value != null) {
     await getCommunityData(value); 
    } else { throw Exception("User not assigned to community"); }
    }).catchError((error, stackTrace) {
      throw error;
    });
  
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
        flashCardSets: value["flashCardSets"] ?? [],
        username: auth.currentUser!.displayName ?? "Invalid Username!",
        email: auth.currentUser!.email ?? "Invalid Email!",
        profilePicture: auth.currentUser!.photoURL ?? ""));
  }).catchError((error, stackTrace) {
    throw error;
  });
  return true;
}
