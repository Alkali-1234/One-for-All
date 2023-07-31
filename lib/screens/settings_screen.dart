import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oneforall/service/auth_service.dart';
import '../data/user_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // final _tabController = TabController(length: 3, vsync: TickerProvider());

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/pupwallpaper 2.png'),
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
                    children: [
                      const SizedBox(height: 20),
                      //* Settings icon
                      Icon(
                        Icons.settings,
                        size: 100,
                        color: theme.onBackground,
                      ),
                      const SizedBox(height: 5),
                      Text("Settings",
                          style: textTheme.displayMedium!.copyWith(
                            color: theme.onBackground,
                          )),

                      const SizedBox(height: 20),
                      //* Theme switch (Great Default Blue, Clean Dark, Bright Light), use tabbarview
                      SizedBox(
                        height: 50,
                        width: 300,
                        //! FIXME length is faulty idk why
                        child: DefaultTabController(
                          length: 3,
                          child: TabBarView(
                            children: [
                              TabBar(tabs: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Great Default Blue",
                                    style: TextStyle(color: theme.onBackground),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Clean Dark",
                                    style: TextStyle(color: theme.onBackground),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Bright Light",
                                    style: TextStyle(color: theme.onBackground),
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
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
