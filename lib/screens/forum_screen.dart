import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with TickerProviderStateMixin {
  // final _tabItems = ["Community", "My Posts"];
  final List<Tab> _tabs = const [
    Tab(
      text: "All",
    ),
    Tab(
      text: "Community",
    ),
    Tab(
      text: "Local",
    )
  ];

  late TabController _tabController;

  //Will be initialized later
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    var tm = appState.currentUserSelectedTheme.colorScheme;
    var ttm = appState.currentUserSelectedTheme.textTheme;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Forums",
            style: ttm.displayMedium,
          ),
          backgroundColor: tm.background,
          foregroundColor: tm.onBackground,
          elevation: 0,
          leading: Hero(
            tag: "forum",
            child: Icon(
              Icons.forum_rounded,
              color: tm.onBackground,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: tm.secondary,
          foregroundColor: tm.onPrimary,
          child: Icon(
            Icons.add,
            color: tm.onBackground,
          ),
        ),
        backgroundColor: tm.background,
        body: Container(
            decoration: appState.currentUserSelectedTheme == defaultBlueTheme
                ? const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/purpbackground 2.png"),
                        fit: BoxFit.cover))
                : BoxDecoration(color: tm.background),
            child: Column(
                //Select forum: All/Global/Local using tabbar
                //Search bar
                //Filters
                //List of threads title : X Active Posts
                //List of threads

                children: [
                  TabBar(
                    tabs: _tabs,
                    labelColor: tm.onBackground,
                    unselectedLabelColor: tm.onBackground.withOpacity(0.5),
                    indicatorColor: tm.secondary,
                    controller: _tabController,
                  )
                ])));
  }
}
