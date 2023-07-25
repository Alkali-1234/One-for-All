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
  setUserData(UserData(
      uid: int.tryParse(auth.currentUser!.uid) ?? 0,
      exp: 0,
      streak: 0,
      posts: 0,
      flashCardSets: [],
      username: auth.currentUser!.displayName ?? "Invalid Username!",
      email: auth.currentUser!.email ?? "Invalid Email!",
      profilePicture: auth.currentUser!.photoURL ?? ""));

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
  var auth = FirebaseAuth.instance;
  //TODO user data from firestore
  //Set user data
  setUserData(UserData(
      uid: int.tryParse(auth.currentUser!.uid) ?? 0,
      exp: 0,
      streak: 0,
      posts: 0,
      flashCardSets: [],
      username: auth.currentUser!.displayName ?? "Invalid Username!",
      email: auth.currentUser!.email ?? "Invalid Email!",
      profilePicture: auth.currentUser!.photoURL ?? ""));
  return true;
}
