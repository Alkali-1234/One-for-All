// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:oneforall/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/community_data.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
// import './community_service.dart';
// import '../data/user_data.dart';

Future backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
  //* Get notification name
  //Name format:
  // "{notificationtype} {notificationid}"
  //Types: MAB, LAC, Recent Activity, etc.
}

Future initializeFCM(String assignedCommunity) async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.denied ||
      settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    print("Notifications not enabled");
    throw Exception(
        "Notifications are required! You may disable notifications later in settings.");
  }
  final fcmToken = await _firebaseMessaging.getToken();
  print('Initialized FCM with token: $fcmToken');
  if (fcmToken != null) {
    await saveFCMToken(fcmToken);
  }

  //* Subscribe to the topic

  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("setting_notifications_MAB")) {
    if (prefs.getBool("setting_notifications_MAB")!) {
      await _firebaseMessaging.subscribeToTopic("MAB_$assignedCommunity");
    } else {
      await _firebaseMessaging.unsubscribeFromTopic("MAB_$assignedCommunity");
    }
  } else {
    await _firebaseMessaging.subscribeToTopic("MAB_$assignedCommunity");
  }
  if (prefs.containsKey("setting_notifications_LAC")) {
    if (prefs.getBool("setting_notifications_LAC")!) {
      await _firebaseMessaging.subscribeToTopic("LAC_$assignedCommunity");
    } else {
      await _firebaseMessaging.unsubscribeFromTopic("LAC_$assignedCommunity");
    }
  } else {
    await _firebaseMessaging.subscribeToTopic("LAC_$assignedCommunity");
  }
  if (prefs.containsKey("setting_notifications_RecentActivity")) {
    if (prefs.getBool("setting_notifications_RecentActivity")!) {
      await _firebaseMessaging
          .subscribeToTopic("Recent_Activity_$assignedCommunity");
    } else {
      await _firebaseMessaging
          .unsubscribeFromTopic("Recent_Activity_$assignedCommunity");
    }
  } else {
    await _firebaseMessaging
        .subscribeToTopic("Recent_Activity_$assignedCommunity");
  }

  await _firebaseMessaging.subscribeToTopic("MAB_$assignedCommunity");
  await _firebaseMessaging.subscribeToTopic("LAC_$assignedCommunity");
  await _firebaseMessaging
      .subscribeToTopic("Recent_Activity_$assignedCommunity");

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      handleNotification(message);
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    print('Message data: ${message.data}');
    handleNotification(message);
  });
}

//TODO show notification
void handleNotification(RemoteMessage message) {
  print(message.data.toString());
  print(message.notification!.title);
  //* Get notification data
  //! DEPRECATED
  if (message.data.containsKey('MAB')) {
    //! Deprecated
    // //Assume that it has all fields (uid, title, description, date, authorUID, image, fileAttatchments, dueDate, type, subject)
    //// final int uid = int.parse(message.data["uid"]);
    //// final String title = message.data["title"];
    //// final String description = message.data["description"];
    // // final DateTime date = DateTime.parse(message.data["date"]);
    // // final String authorUID = message.data["authorUID"];
    // // final String image = message.data["image"];
    // // final List<String> fileAttatchments =
    // //     message.data["fileAttatchments"].split(",");
    // // final DateTime dueDate = DateTime.parse(message.data["dueDate"]);
    // // final int type = int.parse(message.data["type"]);
    // // final int subject = int.parse(message.data["subject"]);

    // // getMabData.addPost(
    // //     uid: uid,
    // //     title: title,
    // //     description: description,
    // //     date: date,
    // //     authorUID: authorUID,
    // //     image: image,
    // //     fileAttatchments: fileAttatchments,
    // //     dueDate: dueDate,
    // //     type: type,
    // //     subject: subject);
  } else if (message.data.containsKey('LAC')) {
    print("Handle LAC Notification");
  } else if (message.data.containsKey('Recent_Activity')) {
    print("Handle Recent Activity Notification");
  }
  //EXT
  //// Name format:
  //// "{notificationtype} {notificationid}"
  //// Types: MAB, LAC, Recent Activity, etc.
}

//* Send notification section
//pray to god this works
//you don't know how long it took me to get this
//update: IT WORKS!!!!
Future sendNotification(
    String title, String body, Map<String, dynamic> data, String topic) async {
  print("Sending notification");
  final String accessToken = await getAccessToken(); // FCM server key
  print('Server Key: $accessToken');

  final Map<String, dynamic> notification = {
    'body': body,
    'title': title,
  };

  final Map<String, dynamic> message = {
    'notification': notification,
    'data': data,
    'topic': topic,
  };

  const String url =
      'https://fcm.googleapis.com/v1/projects/one-for-all-vcr/messages:send';

  try {
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'message': message,
        }));

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
      return true;
    } else {
      print(
          'Error sending notification ${response.statusCode}, ${response.body}');
      return false;
    }
  } catch (e) {
    rethrow;
  }
}

Future<String> getFileContents(String path) async {
  return await rootBundle.loadString(path);
}

Future<String> getAccessToken() async {
  //Get the service account credentials
  final Directory currentDirectory = Directory.current;
  print(currentDirectory.path);
  final keyFile = ServiceAccountCredentials.fromJson(json.decode(
      await getFileContents(
          'assets/private/one-for-all-vcr-notificationacc.json')));

  //Set the scope for firebase messaging
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  //Get the access token
  final client = await auth.clientViaServiceAccount(keyFile, scopes);
  final accessToken = client.credentials.accessToken.data;

  return accessToken;
}

//! Old method that i spent 3 hours on and didn't work
// String generateAccessToken() {
//   const String projectId =
//       'one-for-all-vcr'; // Replace with your Firebase project ID
//   // const String secretJsonFilePath =
//   //     'one-for-all-vcr-firebase-adminsdk-e50ys-df13fd006e.json'; // Replace with the path to the JSON file you just downloaded

//   // final jsonFile = File(secretJsonFilePath);
//   // final jsonContents = jsonFile.readAsStringSync();
//   const String serviceAccountPrivateKey =
//       "i ain't leakin my private key"
//   print('Service Account Private Key: $serviceAccountPrivateKey');

//   final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//   final expiry = now + 3600; // Set the expiry time as needed (in seconds)
//   final jwt = JWT({
//     'iss': "firebase-admin",
//     'sub': ",
//     'aud':
//         'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
//     'iat': now,
//     'exp': expiry,
//     'target': projectId,
//   }).sign(RSAPrivateKey(serviceAccountPrivateKey),
//       algorithm: JWTAlgorithm.RS256);

//   return jwt;
// }
