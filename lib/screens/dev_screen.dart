import 'package:flutter/material.dart';
import '../service/firebase_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DevScreen extends StatefulWidget {
  const DevScreen({super.key});

  @override
  State<DevScreen> createState() => _DevScreenState();
}

class _DevScreenState extends State<DevScreen> {
  bool testFunction1Running = false;
  void testFunction1() async {
    if (testFunction1Running) return;
    setState(() {
      testFunction1Running = true;
    });
    await FirebaseMessaging.instance.subscribeToTopic("MAB_test");
    await sendNotification(
      "Test Notification",
      "This is a test notification from the dev screen.",
      Map<String, dynamic>.from({
        "test": "test"
      }),
      "MAB_test",
      //Topics: MAB, LAC, Recent Activity
    );
    await FirebaseMessaging.instance.unsubscribeFromTopic("MAB_test");
    setState(() {
      testFunction1Running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Text("Dev Screen"),
            Text("This is a dev screen. It is not meant to be used."),
            Text("This screen is used for testing purposes only."),
            Text("This screen will be removed in the final release."),
            // ElevatedButton(
            //     onPressed: () => testFunction1(),
            //     child: const Text("Test Function 1 (Send Notification)")),
          ],
        ),
      ),
    );
  }
}
