import 'package:cloud_firestore/cloud_firestore.dart';
//ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../data/community_data.dart';
import 'auth_service.dart';

//! TODO FUNCTION NOT TESTED
Future getValue(String collection, String document, String field) async {
    //* Get the collection
  CollectionReference communityCollection =

      FirebaseFirestore.instance.collection(collection);
  var val;
  try {
    await communityCollection.doc(document).get().then((value) {
      if (value.data() == null) {
        throw Exception("Community does not exist");
      } else {
        debugPrint(value.data().toString());
        val = value[field];
      }
    }).catchError((error, stackTrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  return val;
}

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
  //* Check if user is authenticated
  if (getUserAuth == null) {
    throw Exception("User is not authenticated");
  }
  FirebaseFirestore.instance
      .collection("communities")
      .doc(communityID)
      //TODO UID should be proper
      .update({
    "members": FieldValue.arrayUnion([getUserAuth.uid])
  });

  //* Save data to community_data.dart
  setCommunityData(communityDocument);
  setMabData(
      //! data is not complete in community document
      MabData(uid: 0, posts: [
    for (var post in communityDocument["MAB"])
      MabPost(
          uid: 0,
          title: post["title"],
          description: post["description"],
          date: DateTime.parse(post["date"].toDate().toString()),
          authorUID: 0,
          image: post["image"],
          fileAttatchments: post["files"],
          dueDate: DateTime.parse(post["date"].toDate().toString()),
          type: 0,
          subject: 1)
  ]));
  return communityDocument;
}

Future getCommunityData(String communityID) async {
  //* Get the community document
  CollectionReference communityCollection =
      FirebaseFirestore.instance.collection("communities");
  var document;
  try {
    await communityCollection.doc(communityID).get().then((value) {
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

  //* Save data to community_data.dart
  setCommunityData(document);
  setMabData(
      //! data is not complete in community document
      MabData(uid: 0, posts: [
    for (var post in document["MAB"])
      MabPost(
          uid: 0,
          title: post["title"],
          description: post["description"],
          date: DateTime.parse(post["date"].toDate().toString()),
          authorUID: 0,
          image: post["image"],
          fileAttatchments: post["files"],
          dueDate: DateTime.parse(post["date"].toDate().toString()),
          type: 0,
          subject: 1)
  ]));
  //* If the user is in a section, get the section data
  //TODO
  return document;
}
