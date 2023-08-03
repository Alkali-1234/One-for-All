import 'package:firebase_storage/firebase_storage.dart'; // For File Upload To Firestore
import 'package:flutter/material.dart';
import 'dart:io';

Future uploadUserPP(File image, String fileName) async {
  Reference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('user_profile_pictures/$fileName');
  UploadTask uploadTask = firebaseStorageRef.putFile(image);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  return await taskSnapshot.ref.getDownloadURL().then(
        (value) => value,
      );
}

Future uploadCommunityImage(
    BuildContext context, File image, String fileName) async {
  Reference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('community_images/$fileName');
  UploadTask uploadTask = firebaseStorageRef.putFile(image);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  return await taskSnapshot.ref.getDownloadURL().then(
        (value) => value,
      );
}

Future uploadCommunityMabImage(File image, String fileName) async {
  Reference firebaseStorageRef = FirebaseStorage.instance
      .ref()
      .child('community_images/community_mab_images/$fileName');
  UploadTask uploadTask = firebaseStorageRef.putFile(image);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  return await taskSnapshot.ref.getDownloadURL().then(
        (value) => value,
      );
}

Future uploadCommunityMabFiles(List<File> files) async {
  List<String> downloadURLs = [];
  await Future.wait(files.map((file) async {
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('community_files/community_mab_files/${file.path}');
    UploadTask uploadTask = firebaseStorageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then(
          (value) => downloadURLs.add(value),
        );
  }));
  return downloadURLs;
}
