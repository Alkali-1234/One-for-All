// import 'dart:math';

//Firebase

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/data/user_data.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:introduction_screen/introduction_screen.dart';
import 'package:animations/animations.dart';

//Data
import 'data/community_data.dart';

//Screens
import 'screens/navigation_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterDownloader.initialize(debug: true);
  debugPrint(
    "Initialized app! : ${Firebase.app().options.projectId}",
  );

  runApp(const MyApp());
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
  // //* get theme func
  Future<ThemeData> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("theme")) {
      final theme = prefs.getInt("theme");
      if (theme == 0) {
        return defaultBlueTheme;
      } else if (theme == 1) {
        return darkTheme;
      } else if (theme == 2) {
        return lightTheme;
      } else {
        return defaultBlueTheme;
      }
    } else {
      return defaultBlueTheme;
    }
  }

  //* User data section

  ///The current user data
  late UserData _currentUser;

  ///Gets the current user data
  UserData get getCurrentUser => _currentUser;

  ///Sets the current user data
  void setCurrentUser(UserData user) {
    print(user);
    print("User set!");
    _currentUser = user;
    print(_currentUser);
    notifyListeners();
  }

  //! Might be useless, as streambuilder is used instead
  //* Community data section
  late MabData _mabData;
  MabData get getMabData => _mabData;
  void setMabData(MabData mabData) {
    _mabData = mabData;
    notifyListeners();
  }

  late LACData _lacData;
  LACData get getLacData => _lacData;
  void setLacData(LACData lacData) {
    _lacData = lacData;
    notifyListeners();
  }

  late RecentActivities _recentActivities;
  RecentActivities get getRecentActivities => _recentActivities;
  set setRecentActivities(RecentActivities recentActivities) {
    _recentActivities = recentActivities;
    notifyListeners();
  }

  final prefs = SharedPreferences.getInstance();

  ThemeData _currentUserSelectedTheme = defaultBlueTheme;
  ThemeData get currentUserSelectedTheme => _currentUserSelectedTheme;
  set currentUserSelectedTheme(ThemeData theme) {
    _currentUserSelectedTheme = theme;
    notifyListeners();
  }
}

//Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //The controller for the sidebar
  final _sidebarController = SidebarXController(selectedIndex: 0);
  //Global key for the scaffold
  final _key = GlobalKey<ScaffoldState>();
  int selectedScreen = 0;
  bool reverseTransition = false;
  //HomePage State

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
      debugPrint("Selected Screen: $selectedScreen");
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      //Global key for the scaffold
      key: _key,
      //Sidebar
      drawer: SidebarXWidget(controller: _sidebarController),
      //Background
      backgroundColor: theme.background,
      //Main application
      body: SafeArea(
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: appState.currentUserSelectedTheme == defaultBlueTheme
              ? const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/purpwallpaper 2.png'),
                      fit: BoxFit.cover))
              : BoxDecoration(
                  color:
                      appState.currentUserSelectedTheme.colorScheme.background),
          child: Column(children: [
            Hero(
              tag: "topAppBar",
              child: Container(
                width: double.infinity,
                color: theme.secondary,
                //Top App Bar
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            {_key.currentState?.openDrawer(), debugPrint("e")},
                        child: Icon(
                          Icons.menu,
                          color: theme.onPrimary,
                          size: 30,
                        ),
                      ),
                      Text(getUserData.username, style: textTheme.displaySmall),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: theme.onPrimary,
                          borderRadius: BorderRadius.circular(20),
                          gradient: getPrimaryGradient,
                        ),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            child: Image.network(getUserData.profilePicture,
                                fit: BoxFit.cover)),
                      )
                    ],
                  ),
                ), //END OF TOP APP BAR
              ),
            ),
            //Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: PageTransitionSwitcher(
                  reverse: reverseTransition,
                  transitionBuilder:
                      (child, primaryAnimation, secondaryAnimation) =>
                          SharedAxisTransition(
                    transitionType: SharedAxisTransitionType.horizontal,
                    fillColor: Colors.transparent,
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  ),
                  child: selectedScreen == 0
                      ? const HomeScreen()
                      : selectedScreen == 1
                          ? const NavigationScreen()
                          : selectedScreen == 2
                              ? ProfileScreen()
                              : Container(),
                ),
              ),
            ),
            //END OF MAIN CONTENT

            //Bottom Nav Bar
            BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: theme.secondary,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    selectedScreen == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    color: theme.onPrimary,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    selectedScreen == 1
                        ? Icons.grid_view_rounded
                        : Icons.grid_view_outlined,
                    color: theme.onPrimary,
                  ),
                  label: "Navigation",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    selectedScreen == 2
                        ? Icons.person_rounded
                        : Icons.person_outline,
                    color: theme.onPrimary,
                  ),
                  label: "Profile",
                ),
              ],
              onTap: (index) => setSelectedScreen(index),
              currentIndex: selectedScreen,
            )
          ]),
        ),
      ),
    );
  }
}

//SidebarWidget
class SidebarXWidget extends StatelessWidget {
  const SidebarXWidget({Key? key, required SidebarXController controller})
      : _controller = controller,
        super(key: key);
  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        decoration: BoxDecoration(color: theme.background),
        iconTheme: const IconThemeData(color: Colors.white),
        selectedIconTheme: IconThemeData(color: getRareMainTheme),
        textStyle: textTheme.displaySmall,
        selectedTextStyle: textTheme.displaySmall,
      ),
      items: const [
        SidebarXItem(icon: Icons.home, label: '  Home'),
      ],
      extendedTheme: const SidebarXTheme(width: 140),
    );
  }
}

/// Home **Screen** NOT Home Page
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //HomeScreen State
  int MABSelectedFilter = 0;
  bool reverseTransition = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    AppState appState = Provider.of(context);
    void setMABSelectedFilter(int filter) {
      setState(() {
        if (filter > MABSelectedFilter) {
          reverseTransition = false;
        } else {
          reverseTransition = true;
        }
        MABSelectedFilter = filter;
      });
      debugPrint("Selected Filter: $MABSelectedFilter");
    }

    return Column(
      children: [
        //WIDGET
        Flexible(
          flex: 2,
          child: Column(
            children: [
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
                      hint:
                          Text("MAB - Widget", style: textTheme.displayMedium),
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
                      onChanged: (value) => debugPrint(value.toString()),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              //Widget Content
              Container(
                decoration: BoxDecoration(
                    color: theme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.secondary,
                      width: 1,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      //Filters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Filter 1 (ALL)
                          Column(
                            children: [
                              Container(
                                height: 38,
                                width: MediaQuery.of(context).size.width * 0.29,
                                decoration: BoxDecoration(
                                    //Bit spaghetti but it works
                                    //Basically if the filter is 0 (all) then it will have a gradient and a shadow, else it will be the secondary color
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: MABSelectedFilter == 0
                                        ? getPrimaryGradient
                                        : null,
                                    boxShadow: MABSelectedFilter == 0
                                        ? [
                                            const BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                    color: MABSelectedFilter == 0
                                        ? null
                                        : theme.secondary),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => {setMABSelectedFilter(0)},
                                    child: FittedBox(
                                      child: Text(
                                        "All",
                                        style: textTheme.displaySmall!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )),
                              ),
                              SizedBox(height: MABSelectedFilter == 0 ? 2 : 0),
                            ],
                          ),
                          //Filter 2 (Announcements)
                          Column(
                            children: [
                              Container(
                                height: 38,
                                width: MediaQuery.of(context).size.width * 0.29,
                                decoration: BoxDecoration(
                                    //Bit spaghetti but it works
                                    //Basically if the filter is 0 (all) then it will have a gradient and a shadow, else it will be the secondary color
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: MABSelectedFilter == 1
                                        ? getPrimaryGradient
                                        : null,
                                    boxShadow: MABSelectedFilter == 1
                                        ? [
                                            const BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                    color: MABSelectedFilter == 1
                                        ? null
                                        : theme.secondary),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: theme.onSecondary,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                              SizedBox(height: MABSelectedFilter == 1 ? 2 : 0),
                            ],
                          ),

                          Column(
                            children: [
                              Container(
                                height: 38,
                                width: MediaQuery.of(context).size.width * 0.29,
                                decoration: BoxDecoration(
                                    //Bit spaghetti but it works
                                    //Basically if the filter is 0 (all) then it will have a gradient and a shadow, else it will be the secondary color
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: MABSelectedFilter == 2
                                        ? getPrimaryGradient
                                        : null,
                                    boxShadow: MABSelectedFilter == 2
                                        ? [
                                            const BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                    color: MABSelectedFilter == 2
                                        ? null
                                        : theme.secondary),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: theme.onSecondary,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                              SizedBox(height: MABSelectedFilter == 2 ? 2 : 0),
                            ],
                          ),
                        ],
                      ),

                      Divider(
                        color: theme.onPrimary,
                        thickness: 1,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.17,
                        child: StreamBuilder(
                            initialData: null,
                            //!!! Change this to the actual community ID
                            stream: FirebaseFirestore.instance
                                .collection("communities")
                                .doc("P3xcmRih8YYxkOqsuV7u")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: Text("Loading MAB data...",
                                      style: textTheme.displaySmall!),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Error loading MAB data ${snapshot.error}",
                                    style: textTheme.displaySmall!
                                        .copyWith(color: theme.error),
                                  ),
                                );
                              }

                              if (!snapshot.hasData) {
                                return Center(
                                  child: Text(
                                    "No MAB data",
                                    style: textTheme.displaySmall!
                                        .copyWith(color: theme.error),
                                  ),
                                );
                              }
                              MabData mabData = MabData(uid: 0, posts: [
                                for (var post in snapshot.data!["MAB"])
                                  MabPost(
                                      uid: 0,
                                      title: post["title"],
                                      description: post["description"],
                                      date: DateTime.parse(
                                          post["date"].toDate().toString()),
                                      authorUID: 0,
                                      image: post["image"] ?? "",
                                      fileAttatchments: [
                                        for (String file in post["files"]) file
                                      ],
                                      dueDate: DateTime.parse(
                                          post["date"].toDate().toString()),
                                      type: post["type"],
                                      subject: post["subject"])
                              ]);
                              return ListView.builder(
                                itemCount: mabData.posts.length,
                                itemBuilder: (context, index) {
                                  MabPost post = mabData.posts[index];
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 100),
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                    child: MABSelectedFilter == 0 ||
                                            post.type == MABSelectedFilter
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                side: BorderSide(
                                                    color: theme.secondary,
                                                    width: 1),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                backgroundColor:
                                                    theme.secondary,
                                                foregroundColor:
                                                    theme.onSecondary,
                                                shadowColor: Colors.black,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () => {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        MABModal(
                                                          title: post.title,
                                                          description:
                                                              post.description,
                                                          image: post.image,
                                                          attatchements: post
                                                              .fileAttatchments,
                                                        ))
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    height: 30,
                                                    child: FittedBox(
                                                      child: Text(
                                                        post.title,
                                                        style: textTheme
                                                            .displaySmall!
                                                            .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ),
                                                  ),
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    child: Container(
                                                      color: theme.secondary,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6.0),
                                                        child: Text(
                                                          //days left due, and the day it is due
                                                          "${post.dueDate.difference(DateTime.now()).inDays} Days (${DateFormat("E").format(post.dueDate)})",
                                                          style: textTheme
                                                              .displaySmall,
                                                        ),
                                                      ),
                                                    ),
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
              style: textTheme.displayLarge!.copyWith(
                fontWeight: FontWeight.w600,
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
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        //Top
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.yellow,
                              size: 36,
                            ),
                            Text(getUserData.exp.toString(),
                                style: textTheme.displayMedium!
                                    .copyWith(fontWeight: FontWeight.bold)),
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
                            Text(getUserData.streak.toString(),
                                style: textTheme.displayMedium!
                                    .copyWith(fontWeight: FontWeight.bold)),
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
                            Text(getUserData.posts.toString(),
                                style: textTheme.displayMedium!
                                    .copyWith(fontWeight: FontWeight.bold)),
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
    CarouselController controller = CarouselController();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          carouselController: controller,
          items: [
            for (int i = 0; i < getRecentActivities.activities.length; i++)
              RecentActivityCard(
                theme: theme,
                textTheme: textTheme,
                activity: getRecentActivities.activities[i],
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
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //Left (Profile Picture)
                children: [
                  //Profile Pictre (will show gradient if unavailable)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: theme.onPrimary,
                        gradient: getPrimaryGradient,
                        shape: BoxShape.circle),
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        child: Image.network(
                          activity.authorProfilePircture,
                          fit: BoxFit.cover,
                        )),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${activity.authorName} just posted a new ${getTypes[activity.type]}!",
                        style: textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      Row(
                        children: [
                          Text(
                              "${DateTime.now().difference(activity.date).inMinutes} Minutes ago",
                              style: textTheme.displaySmall),
                          Text(" • ", style: textTheme.displaySmall),
                          Text(activity.other, style: textTheme.displaySmall),
                          // Text(" • ", style: textTheme.displaySmall),
                          // Text("///", style: textTheme.displaySmall)
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//Mab Modal
class MABModal extends StatelessWidget {
  const MABModal(
      {super.key,
      required this.title,
      required this.description,
      this.image,
      required this.attatchements});
  final String title, description;
  final List<String> attatchements;
  final String? image;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      elevation: 2,
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
            Text(description,
                style: textTheme.displaySmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            //Image
            Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                    color: theme.primaryContainer,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: theme.secondary, width: 1)),
                child: Center(
                  child: image == null || image == ""
                      ? Text(
                          "No Image",
                          style: textTheme.displaySmall,
                        )
                      : Image.network(image!),
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
                      onPressed: () => {},
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
                            Text(attatchements[index],
                                style: textTheme.displaySmall),
                            Icon(
                              Icons.download_sharp,
                              color: theme.onSecondary,
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
                onPressed: () => {Navigator.pop(context)},
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
