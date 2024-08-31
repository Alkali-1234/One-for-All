import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/components/styled_components/filled_elevated_button.dart';
import 'package:oneforall/components/styled_components/primary_elevated_button.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:oneforall/functions/community_functions.dart';
import 'package:oneforall/logger.dart';
import 'package:oneforall/screens/login_screen.dart';
import 'package:oneforall/styles/styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../components/styled_components/elevated_icon_button.dart';
import '../components/styled_components/switch.dart';
import '../constants.dart';
import '../data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../service/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.currentTheme});
  final ThemeData currentTheme;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  // final _tabController = TabController(length: 3, vsync: TickerProvider());
  // static const List<Tab> _themes = [
  //   Tab(text: "Great Default Blue"),
  //   Tab(text: "Clean Dark"),
  //   Tab(text: "Bright Light"),
  // ];

  bool changedNotifSettings = false;

  ThemeData? savedTheme;

  int selectedTheme = 0;
  //0 = default blue 1 = dark 2 = light
  int currentLoading = 0;
  // late TabController _tabController;
  //0 = not loading, 1 = save in progress, 2 = clear cache in progress, 3 = logout in progress

  Map<String, bool> notificationSettings = {
    "MAB": true,
    "LAC": true,
    "RA": true,
  };

  void saveSettings() async {
    if (currentLoading != 0) return;
    setState(() {
      currentLoading = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(hours: 1), content: Text("Saving settings...", style: TextStyle(color: Colors.white)), backgroundColor: Colors.black));
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt("theme", selectedTheme);
    //* Theme
    ThemeData themeUsed = selectedTheme == 0
        ? darkTheme
        : selectedTheme == 1
            ? darkTheme
            : lightTheme;
    setState(() {
      savedTheme = themeUsed;
      passedUserTheme = themeUsed;
      primaryGradient = selectedTheme == 0
          ? defaultBluePrimaryGradient
          : selectedTheme == 1
              ? darkPrimaryGradient
              : lightPrimaryGradient;
    });
    //* Notification settings
    prefs.setBool("setting_notifications_MAB", notificationSettings["MAB"]!);
    prefs.setBool("setting_notifications_LAC", notificationSettings["LAC"]!);
    prefs.setBool("setting_notifications_RecentActivity", notificationSettings["RA"]!);

    if (!mounted) return;
    var appState = context.read<AppState>();

    //* Subscribe and unsubscribe from topics
    if (changedNotifSettings) {
      if (notificationSettings["MAB"]!) {
        await FirebaseMessaging.instance.subscribeToTopic("MAB_${appState.getCurrentUser.assignedCommunity}");
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic("MAB_${appState.getCurrentUser.assignedCommunity}");
      }

      if (notificationSettings["LAC"]!) {
        await FirebaseMessaging.instance.subscribeToTopic("LAC_${appState.getCurrentUser.assignedCommunity}_${appState.getCurrentUser.assignedSection}");
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic("LAC_${appState.getCurrentUser.assignedCommunity}_${appState.getCurrentUser.assignedSection}");
      }

      if (notificationSettings["RA"]!) {
        await FirebaseMessaging.instance.subscribeToTopic("RA_${appState.getCurrentUser.assignedCommunity}");
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic("RA_${appState.getCurrentUser.assignedCommunity}");
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Saved Settings!", style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 1),
      ),
    );
    setState(() {
      currentLoading = 0;
    });
  }

  void clearCache() async {
    if (currentLoading != 0) return;
    final prefs = await SharedPreferences.getInstance();
    prefs
      ..remove("email")
      ..remove("password")
      ..remove("theme")
      ..remove("hasOpenedBefore");
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.black,
      content: Text("Cache cleared!", style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 1),
    ));
  }

  void logoutUser() async {
    if (currentLoading != 0) return;
    setState(() {
      currentLoading = 3;
    });
    await logout().catchError((error, stacktrace) {
      logger.e("Error logging out: $error");
      logger.e(stacktrace.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error logging out! ${error.toString()}", style: const TextStyle(color: Colors.white)),
        ),
      );
      setState(() {
        currentLoading = 0;
      });
      return;
    });
    setState(() {
      currentLoading = 0;
    });
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void initializeNotifications() async {
    await SharedPreferences.getInstance().then((prefs) {
      notificationSettings["MAB"] = prefs.getBool("setting_notifications_MAB") ?? true;
      notificationSettings["LAC"] = prefs.getBool("setting_notifications_LAC") ?? true;
      notificationSettings["RA"] = prefs.getBool("setting_notifications_RecentActivity") ?? true;
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    //* Get saved notifcation settings
    initializeNotifications();

    //* Set the theme setting to the current theme
    widget.currentTheme.colorScheme == darkTheme.colorScheme
        ? selectedTheme = 0
        : widget.currentTheme.colorScheme == darkTheme.colorScheme
            ? selectedTheme = 1
            : selectedTheme = 2;
  }

  String communityIDQuery = "";
  String passwordQuery = "";
  bool loadingCommunity = false;

  Future<void> _joinCommunity() async {
    if (communityIDQuery.isEmpty || passwordQuery.isEmpty) return;
    setState(() {
      loadingCommunity = true;
    });
    var appState = Provider.of<AppState>(context, listen: false);
    var result = await CommunityFunctions().joinCommunity(communityIDQuery, passwordQuery, appState);
    if (!mounted) return;
    if (result == "Successfully joined community") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Joined community!", style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(result, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 4),
      ));
    }
    setState(() {
      loadingCommunity = false;
    });
  }

  Future<void> _leaveCommunity() async {
    setState(() {
      loadingCommunity = true;
    });
    var appState = Provider.of<AppState>(context, listen: false);
    var result = await CommunityFunctions().leaveCommunity(appState.getCurrentUser.assignedCommunity!, appState);
    if (!mounted) return;
    if (result == "Successfully left community") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Left community!", style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(result, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 4),
      ));
    }
    setState(() {
      loadingCommunity = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = Provider.of<AppState>(context);
    return MainContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //* Back button
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text("Theme", style: textTheme.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 10),
                    //* Theme switch (Clean Dark, Bright Light)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StyledIconButton(
                          theme: selectedTheme == 2 ? Themes.light : Themes.dark,
                          onPressed: () {
                            setState(() {
                              selectedTheme = 1;
                            });
                            //* change theme
                            appState.currentUserSelectedTheme = darkTheme;
                          },
                          icon: Icons.dark_mode_rounded,
                          size: 80,
                        ),
                        StyledIconButton(
                          theme: selectedTheme == 2 ? Themes.light : Themes.dark,
                          onPressed: () {
                            setState(() {
                              selectedTheme = 2;
                            });
                            //* change theme
                            appState.currentUserSelectedTheme = lightTheme;
                          },
                          icon: Icons.light_mode_rounded,
                          size: 80,
                        )
                      ],
                    )
                  ]),
                  // //* Notification settings
                  const SizedBox(height: 25),
                  Text("Notifications", style: textTheme.headlineSmall),
                  const SizedBox(height: 5),
                  ListTile(
                      leading: Text("Main Announcement Board", style: textTheme.displaySmall),
                      trailing: NeumorphicSwitch(
                        initialValue: notificationSettings["MAB"]!,
                        onChanged: (value) => setState(() {
                          notificationSettings["MAB"] = !notificationSettings["MAB"]!;
                          changedNotifSettings = true;
                        }),
                      )),
                  ListTile(
                      leading: Text("Local Announcement Board", style: textTheme.displaySmall),
                      trailing: NeumorphicSwitch(
                        onChanged: (value) => setState(() {
                          notificationSettings["LAC"] = !notificationSettings["LAC"]!;
                          changedNotifSettings = true;
                        }),
                      )),
                  ListTile(
                      leading: Text("Recent Activity", style: textTheme.displaySmall),
                      trailing: NeumorphicSwitch(
                        onChanged: (value) => setState(() {
                          notificationSettings["RA"] = !notificationSettings["RA"]!;
                          changedNotifSettings = true;
                        }),
                      )),

                  const SizedBox(height: 25),
                  Text("Community Settings", style: textTheme.displaySmall),
                  const SizedBox(height: 10),
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text("Your Community:", style: textTheme.displaySmall),
                          Expanded(
                            child: Text(
                              appState.getCurrentUser.assignedCommunity != "0" ? appState.getCurrentUser.assignedCommunity! : "None",
                              style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (appState.getCurrentUser.assignedCommunity == "0")
                        Expanded(
                          child: TextFormField(
                            cursorColor: theme.onBackground,
                            style: textTheme.displaySmall,
                            decoration: TextInputStyle(textTheme: textTheme, theme: theme).getTextInputStyle().copyWith(hintText: "Community ID", hintStyle: textTheme.displaySmall),
                            onChanged: (value) => setState(() {
                              communityIDQuery = value;
                            }),
                          ),
                        ),
                      const SizedBox(width: 10),
                      if (appState.getCurrentUser.assignedCommunity == "0")
                        Expanded(
                          child: TextFormField(
                            cursorColor: theme.onBackground,
                            style: textTheme.displaySmall,
                            decoration: TextInputStyle(textTheme: textTheme, theme: theme).getTextInputStyle().copyWith(hintText: "Password", hintStyle: textTheme.displaySmall),
                            onChanged: (value) => setState(() {
                              passwordQuery = value;
                            }),
                          ),
                        ),
                    ],
                  ),

                  FilledElevatedButton(
                      color: appState.getCurrentUser.assignedCommunity != "0" ? Colors.red : Colors.green,
                      onPressed: appState.getCurrentUser.assignedCommunity != "0" ? () => _leaveCommunity() : () => _joinCommunity(),
                      child: loadingCommunity
                          ? SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: theme.onBackground,
                              ),
                            )
                          : Text(
                              appState.getCurrentUser.assignedCommunity != "0" ? "Leave Community" : "Join Community",
                              style: textTheme.displaySmall,
                            ))
                ],
              ),
            ),
            //* Save button
            StyledPrimaryElevatedButton(
              theme: getThemeFromTheme(theme),
              onPressed: () {
                saveSettings();
              },
              child: Text(
                "Save",
                style: textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//* Are you sure modal
class ConfirmationModal extends StatelessWidget {
  const ConfirmationModal({super.key, required this.clearCacheFunction});
  final Function clearCacheFunction;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
        child: Stack(
      children: [
        //* Blur
        Positioned.fill(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(color: theme.primaryContainer, border: Border.all(color: theme.tertiary, width: 0.5), borderRadius: const BorderRadius.all(Radius.circular(20))),
                ))),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Are you sure?", style: textTheme.displayMedium),
              const SizedBox(height: 5),
              Text("This will delete saved email/password, theme information, and information that you have opened this app before. (Not all chache)", style: textTheme.displaySmall),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(onPressed: () => clearCacheFunction(), child: Text("Yes", style: textTheme.displaySmall)),
                  const SizedBox(width: 10),
                  TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: textTheme.displaySmall))
                ],
              )
            ]),
          ),
        ),
      ],
    ));
  }
}
