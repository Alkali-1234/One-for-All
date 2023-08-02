import 'dart:ui';

import 'package:flutter/material.dart';
import '../data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  // final _tabController = TabController(length: 3, vsync: TickerProvider());
  static const List<Tab> _themes = [
    Tab(text: "Great Default Blue"),
    Tab(text: "Clean Dark"),
    Tab(text: "Bright Light"),
  ];

  int selectedTheme = 0;
  int currentLoading = 0;
  //0 = not loading, 1 = save in progress, 2 = clear cache in progress, 3 = logout in progress

  void saveSettings() async {
    if (currentLoading != 0) return;
    debugPrint("Save pressed");
    setState(() {
      currentLoading = 1;
    });
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setInt("theme", selectedTheme);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.black,
        content: Text("Saved Settings!", style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 1),
      ),
    );
    debugPrint("Saved settings");
    setState(() {
      currentLoading = 0;
    });
  }

  void clearCache() async {
    if (currentLoading != 0) return;
    debugPrint("Clear cache pressed");
    await SharedPreferences.getInstance().then((prefs) {
      prefs
        ..remove("email")
        ..remove("password")
        ..remove("hasOpenedBefore");
    });
    debugPrint("Cleared cache");
    const SnackBar(
      backgroundColor: Colors.black,
      content: Text("Cache cleared!", style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 1),
    );
  }

  void logoutUser() async {
    if (currentLoading != 0) return;
    debugPrint("Logout pressed");
    setState(() {
      currentLoading = 3;
    });
    await logout().catchError((error, stacktrace) {
      debugPrint("Error logging out: $error");
      debugPrint(stacktrace.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text("Error logging out! ${error.toString()}",
              style: const TextStyle(color: Colors.white)),
        ),
      );
      setState(() {
        currentLoading = 0;
      });
      return;
    });
    debugPrint("Logged out");
    setState(() {
      currentLoading = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/purpwallpaper 2.png'),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //* Back button
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: theme.onBackground,
                              ),
                            ),
                          ),
                          //* Settings icon
                          Hero(
                            tag: "settings",
                            child: Icon(
                              Icons.settings,
                              size: 100,
                              color: theme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text("Settings",
                              style: textTheme.displayMedium!.copyWith(
                                color: theme.onBackground,
                              )),

                          const SizedBox(height: 20),
                          //* User info card
                          Card(
                            color: theme.secondary,
                            elevation: 4.0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                        getUserData.profilePicture == ""
                                            ? "https://picsum.photos/200"
                                            : getUserData.profilePicture,
                                      )),
                                  const SizedBox(width: 16.0),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        getUserData.username,
                                        style: textTheme.displaySmall!.copyWith(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.end,
                                      ),
                                      Text(
                                        getUserData.email,
                                        style: textTheme.displaySmall,
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Text("Theme", style: textTheme.displaySmall),
                          const SizedBox(height: 10),
                          //* Theme switch (Great Default Blue, Clean Dark, Bright Light), use tabbarview
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: DefaultTabController(
                              length: _themes.length,
                              child: Builder(builder: (context) {
                                final TabController _tabController =
                                    DefaultTabController.of(context);
                                _tabController.addListener(() {
                                  debugPrint(
                                      "Selected Index: ${_tabController.index}");
                                  if (!_tabController.indexIsChanging) {
                                    setState(() {
                                      selectedTheme = _tabController.index;
                                    });
                                  }
                                });
                                return TabBarView(
                                  controller: _tabController,
                                  children: _themes
                                      .map((Tab tab) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: theme.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                tab.text!,
                                                style: textTheme.displaySmall,
                                              )),
                                            ),
                                          ))
                                      .toList(),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 5),
                          //* Current theme three dots indicator
                          SizedBox(
                            height: 10,
                            width: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: selectedTheme == 0
                                        ? theme.onBackground
                                        : theme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: selectedTheme == 1
                                        ? theme.onBackground
                                        : theme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: selectedTheme == 2
                                        ? theme.onBackground
                                        : theme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //* Save button
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                debugPrint("Save pressed");
                                // just show snakbar for now (im lazy)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.black,
                                    content: Text("Saved Settings!",
                                        style: TextStyle(color: Colors.white)),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.secondary,
                                shadowColor: Colors.transparent,
                                side: BorderSide(color: theme.tertiary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Save",
                                style: textTheme.displaySmall,
                              ),
                            ),
                          ),
                          //* Clear cache and logout button
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // just show snakbar for now (im scared it will break the app lol)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.black,
                                    content: Text("Cache cleared!",
                                        style: TextStyle(color: Colors.white)),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.secondary,
                                shadowColor: Colors.transparent,
                                side: BorderSide(color: theme.tertiary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Clear Cache",
                                style: textTheme.displaySmall,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                debugPrint("Logout pressed");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Logout",
                                style: textTheme.displaySmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
