import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';
import 'get_started.dart';

//Shared preferences
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_data.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String verbose = "";

  void pushToPage(Widget page) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => page));
    return;
  }

  void initializeApp() async {
    setState(() {
      verbose = "Initializing...";
    });
    final prefs = await SharedPreferences.getInstance();
    //If first time opening app, go to getstarted page
    if (!prefs.containsKey("hasOpenedBefore")) {
      setState(() {
        verbose = "First time opening app. Going to get started page...";
      });
      // await Future.delayed(const Duration(seconds: 3));
      pushToPage(const GetStartedScreen());
      return;
    }
    debugPrint("Has opened before");
    setState(() {
      verbose = "Checking for saved credentials...";
    });
    //If none, go to login page
    if (!prefs.containsKey("email") || !prefs.containsKey("password")) {
      setState(() {
        verbose = "No saved credentials found. Going to login page...";
      });
      await Future.delayed(const Duration(seconds: 3));
      pushToPage(const LoginScreen());
      return;
    }
    String email = prefs.getString("email") ?? "";
    String password = prefs.getString("password") ?? "";
    //If yes, try to login
    setState(() {
      verbose = "Logging in...";
    });
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          verbose = "User not found. Going to login page...";
        });
        await Future.delayed(const Duration(seconds: 3));
        pushToPage(const LoginScreen());
        return;
      } else {
        setState(() {
          verbose = "Failed to login: ${e.code}. Going to login page...";
        });
        await Future.delayed(const Duration(seconds: 3));
        pushToPage(const LoginScreen());
        return;
      }
    }
    setState(() {
      verbose = "Setting things up...";
    });
    final auth = FirebaseAuth.instance;
    //Set user data
    getUserData.uid = auth.currentUser!.uid;
    getUserData.email = auth.currentUser!.email!;
    getUserData.username = auth.currentUser!.displayName!;
    getUserData.profilePicture = auth.currentUser!.photoURL!;
    setState(() {
      verbose = "Retrieving user data...";
    });

    setState(() {
      verbose = "Finished!";
    });
    await Future.delayed(const Duration(seconds: 3));
    pushToPage(const MyApp(
      showReload: false,
    ));
  }

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Text(
              verbose,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
