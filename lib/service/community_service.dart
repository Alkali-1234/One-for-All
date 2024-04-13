import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oneforall/functions/community_functions.dart';
import '../data/community_data.dart';
import '../main.dart';
import 'auth_service.dart';
import 'dart:io';
import 'files_service.dart';

Future addNewMABEvent(String title, String description, int type, int subject, Timestamp dueDate, List<File> attatchements, File? image, AppState appState) async {
  if (appState.getCurrentUser.assignedCommunity == "0") {
    throw Exception("User is not in a community");
  }
  //* Upload the image
  String? imageURL;
  try {
    if (image != null) {
      imageURL = await uploadCommunityMabImage(image, image.path);
    }
  } catch (e) {
    rethrow;
  }
  //* Upload the files
  List<String> fileURLs = [];
  try {
    fileURLs = await uploadCommunityMabFiles(attatchements);
  } catch (e) {
    rethrow;
  }
  //* Add the event to the community document

  try {
    await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("MAB").add({
      "title": title,
      "description": description,
      "date": Timestamp.now(),
      "authorUID": getUserAuth.currentUser!.uid,
      "image": imageURL ?? "",
      "files": fileURLs,
      "dueDate": dueDate,
      "type": type,
      "subject": subject,
    });
  } catch (e) {
    rethrow;
  }
}

Future addNewLACEvent(String title, String description, int type, int subject, Timestamp dueDate, List<File> attatchements, File? image, AppState appState) async {
  if (appState.getCurrentUser.assignedSection == "0") {
    throw Exception("User is not in a section");
  }
  //* Upload the image
  String? imageURL;
  try {
    if (image != null) {
      imageURL = await uploadCommunityMabImage(image, image.path);
    }
  } catch (e) {
    rethrow;
  }
  //* Upload the files
  List<String> fileURLs = [];
  try {
    fileURLs = await uploadCommunityMabFiles(attatchements);
  } catch (e) {
    rethrow;
  }
  //* Add the event to the community document

  try {
    await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("sections").doc(appState.getCurrentUser.assignedSection).collection("LAC").add({
      "title": title,
      "description": description,
      "date": Timestamp.now(),
      "authorUID": getUserAuth.currentUser!.uid,
      "image": imageURL ?? "",
      "files": fileURLs,
      "dueDate": dueDate,
      "type": type,
      "subject": subject,
    });
  } catch (e) {
    rethrow;
  }
}

Future createUserData(String uid) async {
  //* Create user data
  CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  try {
    await userCollection.doc(uid).set({
      "exp": 0,
      "streak": 0,
      "posts": 0,
      "flashCardSets": [],
      "assignedCommunity": "",
      "sections": [],
      "roles": [],
    }).catchError((error, stackTrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
}

Future getValue(String collection, String document, String field) async {
  //* Get the collection
  CollectionReference communityCollection = FirebaseFirestore.instance.collection(collection);
  dynamic val;
  try {
    await communityCollection.doc(document).get().then((value) {
      if (value.data() == null) {
        throw Exception("Community does not exist");
      } else {
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

Future getDocument(String collection, String document) async {
  //* Get the community document
  CollectionReference communityCollection = FirebaseFirestore.instance.collection(collection);
  late DocumentSnapshot doc;
  try {
    await communityCollection.doc(document).get().then((value) {
      if (value.data() == null) {
        throw Exception("Document does not exist");
      } else {
        doc = value;
      }
    }).catchError((error, stackTrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }
  return doc;
}

Future getCommunity(String communityID) async {
  //* Get the community document
  CollectionReference communityCollection = FirebaseFirestore.instance.collection("communities");
  DocumentSnapshot<Object?>? document;
  try {
    await communityCollection.doc(communityID).get().then((value) {
      if (value.data() == null) {
        throw Exception("Community does not exist");
      } else {
        document = value;
      }
    }).catchError((error, stackTrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }

  return document;
}

Future joinCommunity(String communityID, String password, AppState appState) async {
  //* Attempt to join community
  await CommunityFunctions().joinCommunity(communityID, password, appState);
  //* Get the community document
  DocumentSnapshot<Object?>? communityDocument = await getCommunity(communityID);

  //* User
  User user = FirebaseAuth.instance.currentUser!;
  FirebaseFirestore.instance.collection("communities").doc(communityID).update({
    "members": FieldValue.arrayUnion([
      user.uid
    ])
  });

  //* Save data to community_data.dart
  setCommunityData(communityDocument!);
  //! Deprecated
  // setMabData(
  //     //! data is not complete in community document
  //     MabData(uid: 0, posts: [
  //   for (var post in communityDocument["MAB"])
  //     MabPost(
  //         uid: communityDocument["MAB"].indexOf(post),
  //         title: post["title"],
  //         description: post["description"],
  //         date: DateTime.parse(post["date"].toDate().toString()),
  //         authorUID: post["authorUID"],
  //         image: post["image"],
  //         fileAttatchments: post["files"],
  //         dueDate: DateTime.parse(post["dueDate"].toDate().toString()),
  //         type: post["type"],
  //         subject: post["subject"]),
  // ]));
  return communityDocument;
}

@Deprecated("Use joinCommunity instead")
Future joinSection(String communityID, String sectionID) async {
  try {
    await FirebaseFirestore.instance.collection("communities").doc(communityID).collection("sections").doc(sectionID).update({
      "members": FieldValue.arrayUnion([
        FirebaseAuth.instance.currentUser!.uid
      ])
    });
    //Add section to user's section
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "sections": FieldValue.arrayUnion([
        sectionID
      ])
    });
  } catch (e) {
    rethrow;
  }
}

Future getCommunityData(String communityID) async {
  //* Get the community document
  CollectionReference communityCollection = FirebaseFirestore.instance.collection("communities");
  DocumentSnapshot<Object?>? document;

  try {
    await communityCollection.doc(communityID).get().then((value) {
      // }
      if (value.data() == null) {
        throw Exception("Community does not exist");
      } else {
        document = value;
      }
    }).catchError((error, stackTrace) {
      throw error;
    });
  } catch (e) {
    rethrow;
  }

  //* Save data to community_data.dart
  setCommunityData(document!);
  //! Deprecated
  // setMabData(MabData(uid: 0, posts: [
  //   for (var post in document.data()["MAB"])
  //     MabPost(
  //         uid: 0,
  //         title: post["title"],
  //         description: post["description"],
  //         date: DateTime.parse(post["date"].toDate().toString()),
  //         authorUID: 0,
  //         image: post["image"] ?? "",
  //         fileAttatchments: [for (String file in post["files"]) file],
  //         dueDate: DateTime.parse(post["date"].toDate().toString()),
  //         type: post["type"],
  //         subject: post["subject"]),
  // ]));
  //* If the user is in a section, get the section data
  // For a later date
  return document;
}
