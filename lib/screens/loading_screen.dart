import 'package:flutter/material.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/data/user_data.dart';
import 'package:oneforall/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../main.dart';
import 'login_screen.dart';
import 'get_started.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.appstate});
  final AppState appstate;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String verbose = "";
  String loadingDots = ".";
  bool loadingStatus = false;

  void pushToPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    return;
  }

  void loadingScreenAnimation() async {
    for (var i = 0; i < 4; i++) {
      if (mounted) {
        setState(() {
          loadingDots = "." * (i + 1);
        });
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (loadingStatus == false) loadingScreenAnimation();
  }

  void initializeApp(AppState appState) async {
    //is it there because of the loading screen????
    //make sure its empty
    appState.setCommunityData({});
    // I SWEAR TO GOD IF THIS WORKS
    // I WILL BE SO HAPPY
    setState(() {
      verbose = "Initializing";
    });
    final prefs = await SharedPreferences.getInstance();
    //If first time opening app, go to getstarted page
    if (!prefs.containsKey("hasOpenedBefore")) {
      setState(() {
        verbose = "First time opening app. Going to get started page";
      });
      // await Future.delayed(const Duration(seconds: 3));
      pushToPage(const GetStartedScreen());
      return;
    }
    //* Check for saved credentials
    if (prefs.containsKey("theme")) {
      setState(() {
        verbose = "Setting theme";
      });
      int theme = prefs.getInt("theme") ?? 0;
      // pass the theme in myapp
      // bismillahirrahmanirrahim this works
      if (theme == 0) {
        passedUserTheme = darkTheme;
        primaryGradient = defaultBluePrimaryGradient;
        widget.appstate.currentUserSelectedTheme = darkTheme;
      } else if (theme == 1) {
        passedUserTheme = darkTheme;
        primaryGradient = darkPrimaryGradient;
        widget.appstate.currentUserSelectedTheme = darkTheme;
      } else if (theme == 2) {
        passedUserTheme = lightTheme;
        primaryGradient = lightPrimaryGradient;
        widget.appstate.currentUserSelectedTheme = lightTheme;
      }
    }
    if (prefs.containsKey("language")) {
      setState(() {
        verbose = "Setting language";
      });
      String language = prefs.getString("language") ?? "en";
      // pass the language in myapp
      if (language == "en") {
        //implement localization
      } else if (language == "id") {
        //implement localization
      }
    }
    setState(() {
      verbose = "Checking for saved credentials";
    });
    //If none, go to login page
    if (!prefs.containsKey("email") || !prefs.containsKey("password")) {
      setState(() {
        verbose = "No saved credentials found. Going to login page";
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
      await login(email, password, true, appState);
    } catch (e) {
      setState(() {
        verbose = "Error logging in. Going to login page \n $e";
      });
      await Future.delayed(const Duration(seconds: 3));
      pushToPage(const LoginScreen());
      return;
    }
    setState(() {
      verbose = "Finished";
      loadingStatus = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    pushToPage(ShowCaseWidget(
      builder: Builder(builder: (context) {
        return const HomePage();
      }),
    ));
  }

  @override
  void initState() {
    super.initState();
    loadingScreenAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeApp(context.read<AppState>());
    });
  }

  final buildNumber = const String.fromEnvironment('buildNumber');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StyleConstants.darkBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(filterQuality: FilterQuality.none, image: AssetImage("assets/images/logoanim.gif"), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "One for All",
                  style: darkTheme.textTheme.displayLarge,
                ),
                Text(
                  '$verbose$loadingDots',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "v0.0.6.2 REV-1",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
