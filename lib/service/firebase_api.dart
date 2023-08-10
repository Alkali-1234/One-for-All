import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oneforall/service/auth_service.dart';

Future backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
  //* Get notification name
  //Name format:
  // "{notificationtype} {notificationid}"
  //Types: MAB, LAC, Recent Activity, etc.
}

Future initializeFCM() async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  await _firebaseMessaging.requestPermission();
  final fcmToken = await _firebaseMessaging.getToken();
  print('Initialized FCM with token: $fcmToken');
  if (fcmToken != null) {
    await saveFCMToken(fcmToken);
  }

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    handleNotification(message);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    print('Message data: ${message.data}');
    handleNotification(message);
  });
}

Future handleNotification(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
  //* Get notification data
  if (message.data.containsKey("MAB")) {
    //TODO handle MAB
  } else if (message.data.containsKey("LAC")) {
    //TODO handle LAC
  } else if (message.data.containsKey("Recent Activity")) {
    //TODO handle Recent Activity
  }
  //Name format:
  // "{notificationtype} {notificationid}"
  //Types: MAB, LAC, Recent Activity, etc.
}

Future sendNotification(
    String title, String body, String token, String type) async {
  //TODO send notification
}
