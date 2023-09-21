// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:oneforall/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
// import '../env/env.dart' as env;

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

Future initializeFCM(String assignedCommunity, String assignedSection) async {
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
  if (settings.authorizationStatus == AuthorizationStatus.denied || settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    print("Notifications not enabled");
    throw Exception("Notifications are required! You may disable notifications later in settings.");
  }
  final fcmToken = await _firebaseMessaging.getToken();
  print('Initialized FCM with token: $fcmToken');
  if (fcmToken != null) {
    await saveFCMToken(fcmToken);
  }

  if (assignedCommunity == "") return;
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
      await _firebaseMessaging.subscribeToTopic("LAC_${assignedCommunity}_$assignedSection");
    } else {
      await _firebaseMessaging.unsubscribeFromTopic("LAC_${assignedCommunity}_$assignedSection");
    }
  } else {
    await _firebaseMessaging.subscribeToTopic("LAC_$assignedCommunity");
  }
  if (prefs.containsKey("setting_notifications_RecentActivity")) {
    if (prefs.getBool("setting_notifications_RecentActivity")!) {
      await _firebaseMessaging.subscribeToTopic("Recent_Activity_$assignedCommunity");
    } else {
      await _firebaseMessaging.unsubscribeFromTopic("Recent_Activity_$assignedCommunity");
    }
  } else {
    await _firebaseMessaging.subscribeToTopic("Recent_Activity_$assignedCommunity");
  }

  await _firebaseMessaging.subscribeToTopic("MAB_$assignedCommunity");
  if (assignedSection != "") await _firebaseMessaging.subscribeToTopic("LAC_${assignedCommunity}_$assignedSection");
  await _firebaseMessaging.subscribeToTopic("Recent_Activity_$assignedCommunity");

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
//! NO LONGER NEEDED
@Deprecated("No longer used")
Future sendNotification(String title, String body, Map<String, dynamic> data, String topic) async {
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

  const String url = 'https://fcm.googleapis.com/v1/projects/one-for-all-vcr/messages:send';

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
      print('Error sending notification ${response.statusCode}, ${response.body}');
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
  return "null";
  //! FIXME privateKey is somehow invalid
  //Get the service account credentials
  //ignore: dead_code
  final Directory currentDirectory = Directory.current;
  print(currentDirectory.path);
  // final String email = env.Env.notificationClientEmail;
  final String privateKey = "0";
  // final String clientId = env.Env.notificationClientId;
  //wait 1 second
  await Future.delayed(const Duration(seconds: 1));
  print(privateKey);
  // final keyFile = ServiceAccountCredentials(
  //   email,
  //   ClientId(clientId),
  //   "-----BEGIN PRIVATE KEY-----\nMIIEugIBADANBgkqhkiG9w0BAQEFAASCBKQwggSgAgEAAoIBAQDHu1PHlU8t+F8u\nLiOgsmhleAkJVsvi9JZ+oy+3A5QQJ1oOXydtILqSrb4sfy6f7MA8A5sj813TlwVo\nEXX6kanoJ88LaSbXG7rqgGLFN2loWIuCLg1c6BTfzldwjbysX/gLMpTaiXPJj/xN\nACv6sL6D9tepE5eN1xSpiwrfuoatEJF25F42j+2je9yPiS/O/OTIDc08Gy/D1UnW\nVCY/ChN1T19/sQ4puKI9pfIPOL7JO8O+P28+ps/6APFpQVa5nO/mI9H8Xv9WvA2p\nLJOlHY9TBUfoI0XQ/JeVrOLd+s3MkWnLIDZqs5iMpH+NpStlmzGhkTGtbPblUuXX\nbjn5zZypAgMBAAECgf8fV1kdFjMLJPOEbOojR/6mAoXft2yXm3IeKm80hg/Tn6nX\n66ZQbTZGXcT9QQXWFgwbQq21EMaqGsC1qqIPE41KazPfLw9bLIzOrB6igyK70gKQ\ndzJGbiuVvmBK1yeDNagI+jlaZbV6Nu6FH62c8NHw6j0Fp+wQaR4czU1A8UTqse5l\ngypjBloyX6QEO+DWqhnFz4IiQvhh4vnaBzURW/XbSXk9Rj3/9sp0AIFcOqtd1EC7\n5LqQ0MlKgMAzQs7ak+UdmYUB+DiSOqskeFGekgT7VuiUovDQyLz+xd1jM7vN5vPw\nt3WD6TJRkYAbA+0eT4n7xuQ19mvrRGgDNr9kGskCgYEA/0TkSJn/EI+lDljTWrDI\nWnQsAW+TT0WwWsMfhx2o6TfJ9n3012+yqNqZIWxuvfEIJsO1e1v6pAh7r7nTq0MQ\npl/7pBIxNyZDRSS+/vIv6jwhGa/F3GH4bpXO3owcY9nsmeCGpcTy9SVCPLQd3Ivw\neKhiL77ECc5Z35s0ZzvqV30CgYEAyE26PlLaHCJ2SU4Tblf8W+Sek127dhOBf7xy\n+BYLINVp5wcB/q4PE9eaahwfUngNiF4Kx4lj31C1ZYkeAHUuV0NztASRak13eUiT\naL4F0HMEIc8wqsaghCXFPlqyNiPBo9TJTbJHbcfclVQ2T8mfMzxPXMzNUKpDSv0h\nNLgx2Z0CgYBd6srSq1Xckfz4OlYIl+Ie5X8LSDG6iLlJq2B+JbtvkscLmWvrl3z0\nAvk0AuD7oSKOoJK0wDKHB1f6XzQxXotRqx66TrcswzccyVg8FH7sfxLukG0LmD/+\n778cwg/v7M3QD3t6oeuBpiOokdwquJHQ0qLNTjJyKSmHy2KMWM7vQQKBgEri9HyU\nkULvh3XEoPMiJhFdGgRSiOGOTV4qYHlsFGEEKQHc1twWy0BJ3UtKlFNK2xRexHzx\nWsuE6yy45OSa6uZpK3rkMlGiAMbxYVtJn/bc6XCSe8l9VUnSrTmwwuwG1kCgL1rD\nCn16uXeC8oNGCCUpqSoyz5gW7+27UYzaSJjpAoGAUu3V771ku9FEABhxMPzx5k1U\neaQh/SpnirEbd2Wg3Fq2PfHBaMytY8U7AC+3QIDME6OD3s2TXIC8EUhGATh5RgT4\nfpc7UvbyqeuXhcg40xVNCeweHatqYJNvFgym4ADZ3gwrlENa9RWTvijV6utIbwDv\nYnI7MutQU3Het2xa4XQ=\n-----END PRIVATE KEY-----\n",
  // );

  //! temp
  final keyFile = ServiceAccountCredentials.fromJson(File('assets/private/one-for-all-vcr-notificationacc.json').readAsStringSync());

  //Set the scope for firebase messaging
  final scopes = [
    'https://www.googleapis.com/auth/firebase.messaging'
  ];

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
