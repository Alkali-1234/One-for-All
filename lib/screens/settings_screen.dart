import 'dart:ui';
import 'package:oneforall/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
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
  static const List<Tab> _themes = [
    Tab(text: "Great Default Blue"),
    Tab(text: "Clean Dark"),
    Tab(text: "Bright Light"),
  ];

  ThemeData? savedTheme;

  int selectedTheme = 0;
  //0 = default blue 1 = dark 2 = light
  int currentLoading = 0;
  late TabController _tabController;
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
    ThemeData themeUsed = selectedTheme == 0
        ? defaultBlueTheme
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
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
    final prefs = await SharedPreferences.getInstance();
    prefs
      ..remove("email")
      ..remove("password")
      ..remove("theme")
      ..remove("hasOpenedBefore");
    debugPrint("Cleared cache");
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.black,
      content: Text("Cache cleared!", style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 1),
    ));
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
          backgroundColor: Colors.red,
          content: Text("Error logging out! ${error.toString()}", style: const TextStyle(color: Colors.white)),
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
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  void initState() {
    super.initState();
    //* Set the theme setting to the current theme
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.currentTheme == defaultBlueTheme
          ? _tabController.animateTo(0)
          : widget.currentTheme == darkTheme
              ? _tabController.animateTo(1)
              : _tabController.animateTo(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = Provider.of<AppState>(context);
    return Container(
      decoration: appState.currentUserSelectedTheme == defaultBlueTheme ? const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/purpwallpaper 2.png'), fit: BoxFit.cover)) : BoxDecoration(color: appState.currentUserSelectedTheme.colorScheme.background),
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
                                if (currentLoading != 0) return;
                                if (Theme.of(context) != passedUserTheme) {
                                  appState.currentUserSelectedTheme = passedUserTheme;
                                }
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
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                        appState.getCurrentUser.profilePicture == "" ? "https://picsum.photos/200" : appState.getCurrentUser.profilePicture,
                                      )),
                                  const SizedBox(width: 16.0),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        appState.getCurrentUser.username,
                                        style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.end,
                                      ),
                                      Text(
                                        appState.getCurrentUser.email,
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
                                _tabController = DefaultTabController.of(context);
                                _tabController.addListener(() {
                                  debugPrint("Selected Index: ${_tabController.index}");
                                  if (!_tabController.indexIsChanging) {
                                    setState(() {
                                      selectedTheme = _tabController.index;
                                    });
                                    //* change theme
                                    switch (_tabController.index) {
                                      case 0:
                                        setState(() {
                                          appState.currentUserSelectedTheme = defaultBlueTheme;
                                        });
                                        break;
                                      case 1:
                                        setState(() {
                                          appState.currentUserSelectedTheme = darkTheme;
                                        });
                                        break;
                                      case 2:
                                        setState(() {
                                          appState.currentUserSelectedTheme = lightTheme;
                                        });
                                        break;
                                      default:
                                        debugPrint("Invalid theme index");
                                    }
                                  }
                                });
                                return TabBarView(
                                  controller: _tabController,
                                  children: _themes
                                      .map((Tab tab) => Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: theme.secondary,
                                                borderRadius: BorderRadius.circular(10),
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
                                    color: selectedTheme == 0 ? theme.onBackground : theme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: selectedTheme == 1 ? theme.onBackground : theme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: selectedTheme == 2 ? theme.onBackground : theme.primaryContainer,
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
                                saveSettings();
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
                                showDialog(context: context, builder: (_) => ConfirmationModal(clearCacheFunction: clearCache));
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
                                logoutUser();
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
