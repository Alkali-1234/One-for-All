import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../data/community_data.dart';
import 'auth_service.dart';

Future getCommunity(String communityID) async {
  //* Get the community document
  CollectionReference communityCollection =
      FirebaseFirestore.instance.collection("communities");
  Object? document;
  try {
    await communityCollection.doc(communityID).get().then((value) {
      // debugPrint(value.toString());
      // debugPrint(value.data().toString());
      // debugPrint(value.exists.toString());
      // if (communityID == "P3xcmRih8YYxkOqsuV7u") {
      //   debugPrint("Community should exists");
      // }
      if (value.data() == null) {
        throw Exception("Community does not exist");
      } else {
        debugPrint(value.data().toString());
        document = value.data();
      }
    }).catchError((error, stackTrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  return document;
}

Future joinCommunity(String communityID, String password) async {
  //* Attempt to join community
  var communityDocument;
  //* Get the community document
  try {
    communityDocument = await getCommunity(communityID);
  } catch (e) {
    rethrow;
  }
  //* Check for any errors
  if (communityDocument == null) {
    throw Exception("Community does not exist");
  }
  if (communityDocument["password"] != password) {
    throw Exception("Incorrect password");
  }
  //* Add user to community at document["members"]
  FirebaseFirestore.instance
      .collection("communities")
      .doc(communityID)
      //TODO UID should be proper
      .update({
    "members": FieldValue.arrayUnion([12345])
  });

  //* Save data to community_data.dart
  setCommunityData(communityDocument);
  setMabData(
      //TODO: UId should be 0
      MabData(uid: 0, posts: [
    for (var post in communityDocument["MAB"])
      MabPost(
          uid: 0,
          title: post["title"],
          description: post["description"],
          //! Date is not a DateTime object
          date: post["date"],
          authorUID: 0,
          image: post["image"],
          fileAttatchments: post["files"],
          //! Due date is hardcoded
          dueDate: DateTime(2023, 10, 1),
          type: 0,
          subject: 1)
  ]));
  return communityDocument;
}
