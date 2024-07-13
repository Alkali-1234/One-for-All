// import 'dart:math';

//Firebase

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:oneforall/components/profile_viewer.dart';
import 'package:oneforall/screens/calendar_screen.dart';
import 'package:oneforall/screens/flashcards_screen.dart';
import 'package:oneforall/screens/forum_screen.dart';
import 'package:oneforall/screens/information_screen.dart';
import 'package:oneforall/screens/mab_lac_screen.dart';
import 'package:oneforall/screens/premium_screen.dart';
import 'package:oneforall/screens/quizzes_screen.dart';
import 'package:oneforall/screens/settings_screen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/data/user_data.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:introduction_screen/introduction_screen.dart';
import 'package:animations/animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//Data
import 'data/community_data.dart';

//Screens
import 'logger.dart';
import 'models/quiz_question.dart';
import 'screens/community_screen.dart';
// import 'screens/navigation_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/loading_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //* Prevents the app from rotating
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  //* Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // * Run on emulator if debug is true
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }
  //* Initialize ads
  if (!kIsWeb) await MobileAds.instance.initialize();

  //* initialize openai
  OpenAI.requestsTimeOut = const Duration(minutes: 2);

  logger.i(
    "Initialized app! : ${Firebase.app().options.projectId}",
  );

  runApp(const riverpod.ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      builder: ((context, child) {
        var appState = Provider.of<AppState>(context);
        return MaterialApp(
            title: 'One for All',
            navigatorKey: navigatorKey,
            theme: appState.currentUserSelectedTheme,
            home: LoadingScreen(
              appstate: appState,
            ));
      }),
    );
  }
}

//AppState
class AppState extends ChangeNotifier {
  void thisNotifyListeners() {
    notifyListeners();
  }

  void setViewedShowcase(bool value) {
    viewedShowcase = value;
    notifyListeners();
  }

  bool viewedShowcase = false;

  Themes currentTheme = Themes.dark;

  // //* get theme func
  Future<ThemeData> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("theme")) {
      final theme = prefs.getInt("theme");
      if (theme == 0) {
        currentTheme = Themes.dark;
        notifyListeners();
        return darkTheme;
      } else if (theme == 1) {
        currentTheme = Themes.dark;
        notifyListeners();
        return darkTheme;
      } else if (theme == 2) {
        currentTheme = Themes.dark;
        notifyListeners();
        return lightTheme;
      } else {
        currentTheme = Themes.dark;
        notifyListeners();
        return darkTheme;
      }
    } else {
      currentTheme = Themes.dark;
      notifyListeners();
      return darkTheme;
    }
  }

  Themes getCurrentTheme() {
    return currentTheme;
  }

  //* User data section

  ///The current user data
  late UserData _currentUser;

  ///Gets the current user data
  UserData get getCurrentUser => _currentUser;

  ///Sets the current user data
  void setCurrentUser(UserData user) {
    _currentUser = user;
    notifyListeners();
  }

  void addFlashcardSet(FlashcardSet flashcardSet) {
    _currentUser.flashCardSets.add(flashcardSet);
    notifyListeners();
  }

  // Quizzes Data
  List<QuizSet> _quizzes = [];

  List<QuizSet> get getQuizzes => _quizzes;
  void setQuizzes(List<QuizSet> quizzes) {
    _quizzes = quizzes;
    notifyListeners();
  }

  //! Might be useless, as streambuilder is used instead
  //* Community data section
  MabData? _mabData;
  MabData? get getMabData => _mabData;
  void setMabData(MabData mabData) {
    _mabData = mabData;
    notifyListeners();
  }

  LACData? _lacData;
  LACData? get getLacData => _lacData;
  void setLacData(LACData lacData) {
    _lacData = lacData;
    notifyListeners();
  }

  RecentActivities _recentActivities = RecentActivities(uid: 0, activities: [
    RecentActivity(uid: 0, date: DateTime(2001, 9, 11), authorUID: 0, type: 0, other: "", authorName: "", authorProfilePircture: "")
  ]);
  RecentActivities get getRecentActivities => _recentActivities;
  set setRecentActivities(RecentActivities recentActivities) {
    _recentActivities = recentActivities;
    notifyListeners();
  }

  final prefs = SharedPreferences.getInstance();

  ThemeData _currentUserSelectedTheme = darkTheme;
  ThemeData get currentUserSelectedTheme => _currentUserSelectedTheme;
  set currentUserSelectedTheme(ThemeData theme) {
    _currentUserSelectedTheme = theme;
    notifyListeners();
  }

  Map<String, dynamic> communityData = {};
  void setCommunityData(Map<String, dynamic> data) {
    communityData = data;
    notifyListeners();
  }
}

//Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.doShowcase});
  final bool? doShowcase;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //The controller for the sidebar
  // final _sidebarController = DrawerController(child: , alignment: DrawerAlignment.start);
  //Global key for the scaffold
  final _key = GlobalKey<ScaffoldState>();
  int selectedScreen = 0;
  bool reverseTransition = false;
  //HomePage State

  //* Showcase
  GlobalKey showcase1 = GlobalKey();
  GlobalKey showcase2 = GlobalKey();

  @override
  void initState() {
    super.initState();
    var appState = Provider.of<AppState>(context, listen: false);
    if (widget.doShowcase == true && appState.viewedShowcase == false) {
      logger.i("Starting showcase");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          showcase1,
          showcase2
        ]);
        appState.setViewedShowcase(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = Provider.of<AppState>(context);

    void setSelectedScreen(int index) {
      setState(() {
        if (index > selectedScreen) {
          reverseTransition = false;
        } else {
          reverseTransition = true;
        }
        selectedScreen = index;
      });
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        // Open the app drawer
        _key.currentState?.openDrawer();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        //Global key for the scaffold
        key: _key,
        //Sidebar
        drawer: const MenuSelection(),
        //Background
        backgroundColor: theme.background,
        //Main application
        body: Builder(
            builder: (context) => Container(
                  decoration: BoxDecoration(color: appState.currentUserSelectedTheme.colorScheme.background),
                  child: Column(children: [
                    Hero(
                      tag: "topAppBar",
                      child: Container(
                        width: double.infinity,
                        color: theme.secondary,
                        //Top App Bar
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => {
                                    _key.currentState?.openDrawer(),
                                  },
                                  child: Showcase(
                                    key: showcase2,
                                    description: "This is the menu button. Tap it to access all of the features!",
                                    child: Icon(
                                      Icons.menu,
                                      color: theme.onPrimary,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                Text(appState.getCurrentUser.username, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                                GestureDetector(
                                  onTap: () => showModalBottomSheet(context: context, builder: (c) => ProfileViewer(uid: FirebaseAuth.instance.currentUser!.uid)),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: theme.onPrimary,
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: getPrimaryGradient,
                                    ),
                                    child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(15)), child: Image.network(appState.getCurrentUser.profilePicture, fit: BoxFit.cover)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ), //END OF TOP APP BAR
                      ),
                    ),
                    //Main Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PageTransitionSwitcher(
                            reverse: reverseTransition,
                            transitionBuilder: (child, primaryAnimation, secondaryAnimation) => SharedAxisTransition(
                                  transitionType: SharedAxisTransitionType.horizontal,
                                  fillColor: Colors.transparent,
                                  animation: primaryAnimation,
                                  secondaryAnimation: secondaryAnimation,
                                  child: child,
                                ),
                            child: selectedScreen == 0
                                ? HomeScreen(
                                    showcase1Key: showcase1,
                                  )
                                : selectedScreen == 1
                                    ? const ProfileScreen()
                                    : Container()),
                      ),
                    ),
                    //END OF MAIN CONTENT

                    //Bottom Nav Bar
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: BottomNavigationBar(
                            showSelectedLabels: false,
                            showUnselectedLabels: false,
                            backgroundColor: theme.secondary,
                            elevation: 0,
                            items: [
                              BottomNavigationBarItem(
                                  icon: Icon(
                                    selectedScreen == 0 ? Icons.home_rounded : Icons.home_outlined,
                                    color: theme.onPrimary,
                                  ),
                                  label: "Home",
                                  tooltip: "Home"),
                              // BottomNavigationBarItem(
                              //   icon: Icon(
                              //     selectedScreen == 1 ? Icons.grid_view_rounded : Icons.grid_view_outlined,
                              //     color: theme.onPrimary,
                              //   ),
                              //   label: "Navigation",
                              // ),
                              BottomNavigationBarItem(
                                  icon: Icon(
                                    selectedScreen == 1 ? Icons.person_rounded : Icons.person_outline,
                                    color: theme.onPrimary,
                                  ),
                                  label: "Profile",
                                  tooltip: "Profile"),
                            ],
                            onTap: (index) => setSelectedScreen(index),
                            currentIndex: selectedScreen,
                          ),
                        ),
                      ),
                    )
                  ]),
                )),
      ),
    );
  }
}

//* Menu Selection
class MenuSelection extends StatefulWidget {
  const MenuSelection({super.key});

  @override
  State<MenuSelection> createState() => _MenuSelectionState();
}

class _MenuSelectionState extends State<MenuSelection> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Drawer(
      surfaceTintColor: Colors.transparent,
      backgroundColor: theme.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RawScrollbar(
            radius: const Radius.circular(100),
            trackColor: theme.background,
            thumbColor: theme.onBackground.withOpacity(0.25),
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 10,
            child: ListView.builder(
              controller: scrollController,
              itemCount: 25,
              itemBuilder: (context, index) => [
                Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, color: theme.onBackground)),
                    const SizedBox(width: 10),
                    Text("Navigate", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                //* Self development
                Text("Self Development", style: textTheme.displaySmall),
                const Divider(),
                const SizedBox(height: 5),
                DrawerItem(
                  disabled: true,
                  icon: Icons.article,
                  title: "Summaries",
                  onTap: () => null,
                ),
                DrawerItem(disabled: true, icon: Icons.calendar_month, title: "Refresher", onTap: () => null),
                DrawerItem(
                    icon: Icons.note,
                    title: "Flashcards",
                    onTap: () => {
                          Navigator.pop(context),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FlashcardsScreen(),
                            ),
                          )
                        }),
                DrawerItem(
                    icon: Icons.extension,
                    title: "Quizzes",
                    onTap: () => {
                          Navigator.pop(context),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizzesScreen(),
                            ),
                          )
                        }),
                //* Tools
                const SizedBox(height: 20),
                Text("Tools", style: textTheme.displaySmall),
                const Divider(),
                const SizedBox(height: 5),

                DrawerItem(
                    icon: Icons.list,
                    title: "Announcement Board",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MABLACScreen()));
                    }),
                DrawerItem(
                    icon: Icons.calendar_today,
                    title: "Calendar",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
                    }),
                DrawerItem(
                    disabled: false,
                    icon: Icons.calculate,
                    title: "Notes",
                    onTap: () => {
                          Navigator.pop(context),
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen()))
                        }),
                //* Commuity and other
                const SizedBox(height: 20),
                Text("Community & Other", style: textTheme.displaySmall),
                const Divider(),
                const SizedBox(height: 5),
                DrawerItem(
                    icon: Icons.people,
                    title: "Community",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityScreen()));
                    }),
                DrawerItem(
                    icon: Icons.forum,
                    title: "Forums",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForumScreen()));
                    }),
                DrawerItem(
                    icon: Icons.diamond,
                    title: "Premium",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PremiumScreen(
                                    totalSpent: 0,
                                  )));
                    }),
                DrawerItem(
                    icon: Icons.settings,
                    title: "Settings",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsScreen(
                                    currentTheme: Theme.of(context),
                                  )));
                    }),
                DrawerItem(
                    icon: Icons.info,
                    title: "Information",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const InformationScreen()));
                    })
              ][index],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({super.key, required this.icon, required this.title, required this.onTap, this.disabled});
  final IconData icon;
  final String title;
  final Function onTap;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      hoverColor: theme.onBackground.withOpacity(0.125),
      leading: Icon(icon, color: disabled == true ? theme.onBackground.withOpacity(0.5) : theme.onBackground),
      title: Text(title, style: textTheme.displaySmall!.copyWith(color: disabled == true ? theme.onBackground.withOpacity(0.5) : theme.onBackground)),
      onTap: () => onTap(),
    );
  }
}

/// Home **Screen** NOT Home Page
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.showcase1Key});
  final GlobalKey showcase1Key;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // GlobalKey showcase1 =

  //HomeScreen State
  int mabSelectedFilter = 0;
  bool reverseTransition = false;

  late Stream mabDataStream;

  @override
  void initState() {
    super.initState();
    mabDataStream = context.read<AppState>().getCurrentUser.assignedCommunity != "0" ? FirebaseFirestore.instance.collection("communities").doc(context.read<AppState>().getCurrentUser.assignedCommunity).collection("MAB").snapshots().distinct() : const Stream.empty();
    // WidgetsBinding.instance.addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([
    //       showcase1
    //     ]));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    // AppState appState = Provider.of(context);
    void setMABSelectedFilter(int filter) {
      setState(() {
        if (filter > mabSelectedFilter) {
          reverseTransition = false;
        } else {
          reverseTransition = true;
        }
        mabSelectedFilter = filter;
      });
    }

    var appState = Provider.of<AppState>(context);
    return Column(
      children: [
        //WIDGET
        Flexible(
          flex: 3,
          child: Column(
            children: [
              const SizedBox(height: 4),
              //Widget Title
              Container(
                decoration: BoxDecoration(
                  color: theme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      isExpanded: true,
                      dropdownColor: theme.secondary,
                      iconEnabledColor: Colors.white,
                      iconDisabledColor: Colors.white,
                      hint: Text("MAB - Widget", style: textTheme.displayMedium),
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            "",
                            style: textTheme.displayMedium,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(
                            "More coming soon!",
                            style: textTheme.displayMedium,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(
                            "More coming soon!",
                            style: textTheme.displayMedium,
                          ),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              //Widget Content
              Expanded(
                child: Showcase(
                  key: widget.showcase1Key,
                  description: "This is your home screen widget. Currently it is set to the Main Announcement Board widget.",
                  child: Container(
                    decoration: BoxDecoration(
                        color: theme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.secondary,
                          width: 1,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          //Filters
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //Filter 1 (ALL)
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 38,
                                      decoration: BoxDecoration(
                                          //Bit spaghetti but it works
                                          //Basically if the filter is 0 (all) then it will have a gradient and a shadow, else it will be the secondary color
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: mabSelectedFilter == 0 ? getPrimaryGradient : null,
                                          boxShadow: mabSelectedFilter == 0
                                              ? [
                                                  const BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 2,
                                                    offset: Offset(0, 2),
                                                  )
                                                ]
                                              : null,
                                          color: mabSelectedFilter == 0 ? null : theme.secondary),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () => {
                                                setMABSelectedFilter(0)
                                              },
                                          child: FittedBox(
                                            child: Text(
                                              "All",
                                              style: textTheme.displaySmall!.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                    ),
                                    SizedBox(height: mabSelectedFilter == 0 ? 2 : 0),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              //Filter 2 (Announcements)
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 38,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          //Bit spaghetti but it works
                                          //Basically if the filter is 0 (all) then it will have a gradient and a shadow, else it will be the secondary color
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: mabSelectedFilter == 1 ? getPrimaryGradient : null,
                                          boxShadow: mabSelectedFilter == 1
                                              ? [
                                                  const BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 2,
                                                    offset: Offset(0, 2),
                                                  )
                                                ]
                                              : null,
                                          color: mabSelectedFilter == 1 ? null : theme.secondary),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: theme.onSecondary,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              )),
                                          onPressed: () => setMABSelectedFilter(1),
                                          child: FittedBox(
                                            child: Text(
                                              "Announces",
                                              style: textTheme.displaySmall!.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                    ),
                                    SizedBox(height: mabSelectedFilter == 1 ? 2 : 0),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 38,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          //Bit spaghetti but it works
                                          //Basically if the filter is 0 (all) then it will have a gradient and a shadow, else it will be the secondary color
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: mabSelectedFilter == 2 ? getPrimaryGradient : null,
                                          boxShadow: mabSelectedFilter == 2
                                              ? [
                                                  const BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 2,
                                                    offset: Offset(0, 2),
                                                  )
                                                ]
                                              : null,
                                          color: mabSelectedFilter == 2 ? null : theme.secondary),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: theme.onSecondary,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              )),
                                          onPressed: () => setMABSelectedFilter(2),
                                          child: FittedBox(
                                            child: Text(
                                              "Tasks",
                                              style: textTheme.displaySmall!.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                    ),
                                    SizedBox(height: mabSelectedFilter == 2 ? 2 : 0),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Divider(
                            color: theme.onPrimary,
                            thickness: 1,
                          ),
                          Expanded(
                            child: StreamBuilder(
                                initialData: null,
                                stream: mabDataStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: Text("Loading MAB data...", style: textTheme.displaySmall!),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        "Error loading MAB data ${snapshot.error}",
                                        style: textTheme.displaySmall!.copyWith(color: theme.error),
                                      ),
                                    );
                                  }

                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: Text(
                                        "No MAB data",
                                        style: textTheme.displaySmall!.copyWith(color: theme.error),
                                      ),
                                    );
                                  }
                                  MabData mabData = MabData(uid: 0, posts: [
                                    for (var post in snapshot.data!.docs)
                                      MabPost(
                                          uid: 0,
                                          title: post["title"],
                                          description: post["description"],
                                          date: DateTime.parse(post["date"].toDate().toString()),
                                          authorUID: 0,
                                          image: post["image"] ?? "",
                                          fileAttatchments: [
                                            for (String file in post["files"]) file
                                          ],
                                          dueDate: DateTime.parse(post["dueDate"].toDate().toString()),
                                          type: post["type"],
                                          subject: post["subject"])
                                  ]);
                                  mabData.posts.sort((a, b) => b.dueDate.difference(DateTime.now()).inMilliseconds.compareTo(a.dueDate.difference(DateTime.now()).inMilliseconds));
                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: mabData.posts.length,
                                    itemBuilder: (context, index) {
                                      MabPost post = mabData.posts[index];
                                      return AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 100),
                                        transitionBuilder: (child, animation) => FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                        child: mabSelectedFilter == 0 || post.type == mabSelectedFilter
                                            ? Padding(
                                                padding: const EdgeInsets.only(bottom: 5.0),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.all(8),
                                                    backgroundColor: theme.secondary,
                                                    foregroundColor: theme.onSecondary,
                                                    shadowColor: Colors.black,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  onPressed: () => {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) => MABModal(
                                                              title: post.title,
                                                              description: post.description,
                                                              image: post.image,
                                                              attatchements: post.fileAttatchments,
                                                            ))
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          post.title,
                                                          style: textTheme.displaySmall,
                                                          textAlign: TextAlign.left,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        //days left due, and the day it is due
                                                        "${post.dueDate.difference(DateTime.now()).inDays} Days (${DateFormat("E").format(post.dueDate)})",
                                                        style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: post.dueDate.difference(DateTime.now()).inDays < 0 ? Colors.red : theme.onBackground),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      );
                                    },
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.bolt, color: theme.onPrimary, size: 45),
            const SizedBox(width: 10),
            Text(
              "Recent Activity",
              style: textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Divider(color: theme.onPrimary, thickness: 1),
        const SizedBox(height: 14),
        //Recent Activity Card
        //Card has repeating background based on what type of activity it is
        //Card format: Left: User profile, Rright: Top: {user} just posted a new {acitivity} Bottom: {X minutes ago} {subject} {any relevant e.g number of questions}
        //In this example is a Quiz card

        Flexible(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RecentActivityCarousel(theme: theme, textTheme: textTheme),
              Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    //Top
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.yellow,
                          size: 36,
                        ),
                        Text(appState.getCurrentUser.exp.toString(), style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "EXP",
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ]),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    //Top
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange,
                          size: 36,
                        ),
                        Text(appState.getCurrentUser.streak.toString(), style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Streak",
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ]),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    //Top
                    Row(
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          color: Color.fromRGBO(201, 201, 201, 1),
                          size: 36,
                        ),
                        Text(appState.getCurrentUser.posts.toString(), style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Posts",
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ]),
                ]),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class RecentActivityCarousel extends StatelessWidget {
  const RecentActivityCarousel({
    super.key,
    required this.theme,
    required this.textTheme,
  });

  final ColorScheme theme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    CarouselController controller = CarouselController();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          carouselController: controller,
          items: [
            for (int i = 0; i < appState.getRecentActivities.activities.length; i++)
              RecentActivityCard(
                theme: theme,
                textTheme: textTheme,
                activity: appState.getRecentActivities.activities[i],
              ),
          ],
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.09,
            enableInfiniteScroll: false,
            viewportFraction: 1,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.theme,
    required this.textTheme,
    required this.activity,
  });

  final ColorScheme theme;
  final TextTheme textTheme;
  final RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
            //this is the background of the card
            width: double.infinity,
            height: double.infinity,
            //Clip any overflowed items
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            //Overflowbox to prevent error
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              //The actual card
              //Column to hold the card
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  //Each row has a repeating icon rotated 45 degrees
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < 15; i++)
                        Row(
                          children: [
                            Transform.rotate(
                                angle: 0.45,
                                child: Icon(
                                    activity.type == 0
                                        ? Icons.extension
                                        : activity.type == 1
                                            ? Icons.note
                                            : activity.type == 2
                                                ? Icons.import_contacts
                                                : Icons.extension,
                                    color: theme.secondary)),
                            const SizedBox(width: 8)
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Transform.translate(
                    //Offset to move the row to the right so it aligns diagonally with the icons above
                    offset: const Offset(16, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < 15; i++)
                          Row(
                            children: [
                              Transform.rotate(
                                  angle: 0.45,
                                  child: Icon(
                                      activity.type == 0
                                          ? Icons.extension
                                          : activity.type == 1
                                              ? Icons.note
                                              : activity.type == 2
                                                  ? Icons.import_contacts
                                                  : Icons.extension,
                                      color: theme.secondary)),
                              const SizedBox(width: 8)
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Transform.translate(
                    offset: const Offset(32, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < 15; i++)
                          Row(
                            children: [
                              Transform.rotate(
                                  angle: 0.45,
                                  child: Icon(
                                      activity.type == 0
                                          ? Icons.extension
                                          : activity.type == 1
                                              ? Icons.note
                                              : activity.type == 2
                                                  ? Icons.import_contacts
                                                  : Icons.extension,
                                      color: theme.secondary)),
                              const SizedBox(width: 8)
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),

        //Card Content (foreground)
        FittedBox(
          // child: Align(
          //   alignment: Alignment.center,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       //Left (Profile Picture)
          //       children: [
          //         //Profile Pictre (will show gradient if unavailable)
          //         Container(
          //           width: 50,
          //           height: 50,
          //           decoration: BoxDecoration(color: theme.onPrimary, gradient: getPrimaryGradient, shape: BoxShape.circle),
          //           child: ClipRRect(
          //               borderRadius: const BorderRadius.all(Radius.circular(25)),
          //               child: Image.network(
          //                 activity.authorProfilePircture,
          //                 fit: BoxFit.cover,
          //               )),
          //         ),
          //         const SizedBox(width: 10),
          //         Column(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text(
          //               "${activity.authorName} just posted a new ${getTypes[activity.type]}!",
          //               style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
          //             ),
          //             Row(
          //               children: [
          //                 Text("${DateTime.now().difference(activity.date).inMinutes} Minutes ago", style: textTheme.displaySmall),
          //                 Text(" • ", style: textTheme.displaySmall),
          //                 Text(activity.other, style: textTheme.displaySmall),
          //                 // Text(" • ", style: textTheme.displaySmall),
          //                 // Text("///", style: textTheme.displaySmall)
          //               ],
          //             )
          //           ],
          //         )
          //       ],
          //     ),
          //   ),
          // ),
          child: Text("Coming soon!", style: textTheme.displaySmall),
        ),
      ],
    );
  }
}

//Mab Modal
class MABModal extends StatelessWidget {
  const MABModal({super.key, required this.title, required this.description, this.image, required this.attatchements});
  final String title, description;
  final List<String> attatchements;
  final String? image;

  String extractFilenameFromUrl(String url) {
    RegExp regExp = RegExp(r'(?<=cache%2F)[^?]+');
    Match? match = regExp.firstMatch(url);

    if (match != null) {
      return match.group(0)!;
    } else {
      return ""; // Return an empty string or handle the absence of a match as needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    void downloadFile(String downloadURL) async {
      //* Put download url link to cliboard and show snackbar
      await Clipboard.setData(ClipboardData(text: downloadURL));

      // //* Open download link in browser
      //ignore: deprecated_member_use
      await launch(downloadURL);
    }

    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: theme.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            //Main header
            Text(
              title,
              style: textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            //Sub header
            Text(description, style: textTheme.displaySmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            //Image
            Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(color: theme.primaryContainer, borderRadius: const BorderRadius.all(Radius.circular(10)), border: Border.all(color: theme.secondary, width: 1)),
                child: InkWell(
                  splashColor: image == null || image == "" ? Colors.transparent : theme.secondary.withOpacity(0.5),
                  highlightColor: image == null || image == "" ? Colors.transparent : theme.secondary.withOpacity(0.5),
                  onTap: () => {
                    if (image != null && image != "")
                      showDialog(
                          context: context,
                          builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                child: SizedBox(
                                    height: 300,
                                    child: PhotoView(
                                      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                                      imageProvider: NetworkImage(image!),
                                    )),
                              ))
                  },
                  child: Center(
                    child: image == null || image == ""
                        ? Text(
                            "No Image",
                            style: textTheme.displaySmall,
                          )
                        : Image.network(image!),
                  ),
                )),

            const SizedBox(height: 16),

            //Attatchements (row here to align text to the left)
            Row(
              children: [
                Text(
                  "${attatchements.length} Attatchements",
                  style: textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: attatchements.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: () => {
                        downloadFile(attatchements[index]),
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: theme.secondary, width: 1),
                        padding: const EdgeInsets.all(0),
                        backgroundColor: theme.secondary,
                        foregroundColor: theme.onSecondary,
                        shadowColor: Colors.black,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Replace with actual name
                            Flexible(
                              flex: 3,
                              child: Text(
                                extractFilenameFromUrl(attatchements[index]),
                                style: textTheme.displaySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Icon(
                                Icons.download_sharp,
                                color: theme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            const SizedBox(height: 16),
            //Back button
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: getPrimaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => {
                  Navigator.pop(context)
                },
                child: Text(
                  "Back",
                  style: textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
