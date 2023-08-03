import 'package:flutter/material.dart';
import 'package:oneforall/service/auth_service.dart';
import '../main.dart';
import 'login_screen.dart';
import 'get_started.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String verbose = "";
  String loadingDots = ".";
  Icon? loadingStatus;

  void pushToPage(Widget page) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => page));
    return;
  }

  void loadingScreenAnimation() async {
    for (var i = 0; i < 4; i++) {
      setState(() {
        loadingDots = "." * (i + 1);
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }
    loadingScreenAnimation();
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
    //* Check for saved credentials
    if (prefs.containsKey("theme")) {
      setState(() {
        verbose = "Setting theme...";
      });
      String theme = prefs.getString("theme") ?? "blue";
      // pass the theme in myapp
      if (theme == "blue") {
        //TODO implement
      } else if (theme == "dark") {
        //TODO implement
      } else if (theme == "light") {
        //TODO implement
      }
    }
    if (prefs.containsKey("language")) {
      setState(() {
        verbose = "Setting language...";
      });
      String language = prefs.getString("language") ?? "en";
      // pass the language in myapp
      if (language == "en") {
        //TODO implement
      } else if (language == "id") {
        //TODO implement
      }
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
      await login(email, password, true);
    } catch (e) {
      setState(() {
        verbose = "Error logging in. Going to login page... \n $e";
      });
      await Future.delayed(const Duration(seconds: 3));
      pushToPage(const LoginScreen());
      return;
    }
    setState(() {
      verbose = "Finished!";
    });
    await Future.delayed(const Duration(seconds: 1));
    pushToPage(const MyApp(
      showReload: false,
    ));
  }

  @override
  void initState() {
    super.initState();
    initializeApp();
    loadingScreenAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loadingStatus == null
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  : loadingStatus ?? Container(),
              const SizedBox(height: 20),
              Text(
                'Loading $loadingDots',
                style: const TextStyle(
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
      ),
    );
  }
}
