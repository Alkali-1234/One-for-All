import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_data.dart';
import '../data/community_data.dart';
import 'dart:math';

get getUserAuth => FirebaseAuth.instance;

login(String email, String password, bool saveCredentials) {
  FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password)
      .then((value) async {
    final prefs = await SharedPreferences.getInstance();
    if (saveCredentials) {
      prefs.setString("email", email);
      prefs.setString("password", password);
      prefs.setBool("hasOpenedBefore", true);
    }
  }).catchError((error) {
    return error;
  });
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
  //TODO get user data from database
  return true;
}
