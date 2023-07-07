// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:intl/intl.dart';

//Data
import 'data/community_data.dart';

//Screens
import 'screens/navigation_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'One for All',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color.fromRGBO(0, 0, 0, 0.25),
            secondary: const Color.fromRGBO(255, 255, 255, 0.25),
            tertiary: const Color.fromRGBO(255, 255, 255, 0.50),
            primaryContainer: const Color.fromRGBO(255, 255, 255, 0.07),
            onPrimary: const Color.fromRGBO(255, 255, 255, 1),
            onSecondary: const Color.fromRGBO(255, 255, 255, 1),
            background: const Color.fromRGBO(24, 4, 44, 1.0),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1.0),
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.5,
            ),
            displayMedium: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1.0),
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
            displaySmall: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1.0),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

//AppState
class AppState extends ChangeNotifier {
  //Global AppState
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
  //HomePage State

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    //var appState = Provider.of<AppState>(context);

    void setSelectedScreen(int index) {
      setState(() {
        selectedScreen = index;
      });
      debugPrint("Selected Screen: $selectedScreen");
    }

    return Scaffold(
      //Global key for the scaffold
      key: _key,
      //Sidebar
      drawer: SidebarXWidget(controller: _sidebarController),
      //Background
      backgroundColor: theme.background,
      //Main application
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/purpwallpaper 2.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(children: [
            Container(
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
                    Text("Alkaline", style: textTheme.displaySmall),
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
                          child: Image.network('https://picsum.photos/200')),
                    )
                  ],
                ),
              ), //END OF TOP APP BAR
            ),
            //Main Content
            //TODO Main Content and pages
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: selectedScreen == 0
                    ? HomeScreen()
                    : selectedScreen == 1
                        ? NavigationScreen()
                        : selectedScreen == 2
                            ? ProfileScreen()
                            : Container(),
              ),
            ),
            //END OF MAIN CONTENT

            //Bottom Nav Bar
            BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: theme.secondary,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    selectedScreen == 0 ? Icons.home : Icons.home_outlined,
                    color: theme.onPrimary,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.grid_view,
                    color: theme.onPrimary,
                  ),
                  label: "Navigation",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    selectedScreen == 2 ? Icons.person : Icons.person_outline,
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
        //TODO nav items, and icons, and functionality
      ],
      extendedTheme: const SidebarXTheme(width: 140),
    );
  }
}

//Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        //WIDGET
        Column(
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
                    hint: Text("Select Widget", style: textTheme.displayMedium),
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
                          "MAB",
                          style: textTheme.displayMedium,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text(
                          "MAB",
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
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: getPrimaryGradient,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 2,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => {},
                                  child: Text(
                                    "All",
                                    style: textTheme.displaySmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ),
                            SizedBox(height: 2)
                          ],
                        ),
                        //Filter 2 (Announcements)
                        Container(
                          height: 38,
                          width: 120,
                          //TODO if this button is selected, change bg color to gradient just like the ALL button
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.secondary,
                                  foregroundColor: theme.onSecondary,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              onPressed: () => {},
                              child: Text(
                                "Announces",
                                style: textTheme.displaySmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ),
                        Container(
                          height: 38,
                          width: 120,
                          //TODO if this button is selected, change bg color to gradient just like the ALL button
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.secondary,
                                  foregroundColor: theme.onSecondary,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              onPressed: () => {},
                              child: Text(
                                "Tasks",
                                style: textTheme.displaySmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ),
                      ],
                    ),

                    Divider(
                      color: theme.onPrimary,
                      thickness: 1,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: getMabData.posts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side:
                                  BorderSide(color: theme.secondary, width: 1),
                              padding: const EdgeInsets.all(8),
                              backgroundColor: theme.secondary,
                              foregroundColor: theme.onSecondary,
                              shadowColor: Colors.black,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 250,
                                  height: 30,
                                  child: FittedBox(
                                    child: Text(
                                      getMabData.posts[index].title,
                                      style: textTheme.displaySmall!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0)),
                                  child: Container(
                                    color: theme.secondary,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(
                                        //days left due, and the day it is due
                                        "${getMabData.posts[index].dueDate.difference(DateTime.now()).inDays} Days (${DateFormat("E").format(getMabData.posts[index].dueDate)})",
                                        style: textTheme.displaySmall,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
