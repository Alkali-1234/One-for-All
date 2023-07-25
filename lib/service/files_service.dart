import 'package:firebase_storage/firebase_storage.dart';    // For File Upload To Firestore
import 'package:flutter/material.dart';
import 'dart:io';

Future uploadUserPP(BuildContext context, File image, String fileName) async {
  Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('user_profile_pictures/$fileName');
  UploadTask uploadTask =firebaseStorageRef.putFile(image);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  await taskSnapshot.ref.getDownloadURL().then(
        (value) => debugPrint("Done: $value"),
  );
}

Future uploadCommunityImage(BuildContext context, File image, String fileName) async {
  Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('community_images/$fileName');
  UploadTask uploadTask = firebaseStorageRef.putFile(image);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  await taskSnapshot.ref.getDownloadURL().then(
        (value) => debugPrint("Done: $value"),
  );
}

Future uploadCommunityMabImage(BuildContext context, File image, String fileName) async {
  Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('community_images/community_mab_images/$fileName');
  UploadTask uploadTask = firebaseStorageRef.putFile(image);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  await taskSnapshot.ref.getDownloadURL().then(
        (value) => debugPrint("Done: $value"),
  );
}

Future uploadCommunityMabFiles(BuildContext context, List<File> files, String fileName) async {
    await Future.wait(files.map((file) async {
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('community_files/community_mab_files/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      await taskSnapshot.ref.getDownloadURL().then(
            (value) => debugPrint("Done: $value"),
      );
    }));
}
