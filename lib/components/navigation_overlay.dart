// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oneforall/components/styled_components/elevated_icon_button.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:oneforall/components/styled_components/touchable_container.dart';
import 'package:oneforall/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oneforall/logger.dart';
import 'package:oneforall/screens/quizzes_screen.dart';
import 'package:showcaseview/showcaseview.dart';

import '../screens/calendar_screen.dart';
import '../screens/community_screen.dart';
import '../screens/flashcards_screen.dart';
import '../screens/forum_screen.dart';
import '../screens/information_screen.dart';
import '../screens/mab_lac_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/premium_screen.dart';
import '../screens/settings_screen.dart';

class NavigationButton extends StatefulWidget {
  const NavigationButton({
    super.key,
    required this.ctheme,
  });

  final Themes ctheme;

  @override
  State<NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<NavigationButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _animation = Tween<double>(begin: 0, end: MediaQuery.of(context).size.height * 1.3).animate(_controller);

  OverlayEntry? overlayEntry;

  @override
  void dispose() {
    logger.d("DISPOSE");
    _controller.reverse();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var ctheme = getThemeFromTheme(theme);
    var textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 50,
      child: Hero(
        tag: "menu",
        child: Consumer(builder: (context, ref, child) {
          return StyledIconButton(
            size: 32,
            theme: ctheme,
            onPressed: () {
              ref.read(overlayStateProvider.notifier).state = true;
              final overlay = Overlay.of(context);
              final overlayEntry = OverlayEntry(builder: (context) {
                return Positioned.fill(child: Consumer(builder: (context, ref, child) {
                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return ClipPath(
                        clipper: RadiusClipper(radius: _animation.value),
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(color: const Color(0xFF0D1116).withOpacity(0.8)),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Hero(
                                          tag: "menu",
                                          child: StyledIconButton(
                                            size: 32,
                                            theme: ctheme,
                                            onPressed: () async {
                                              await _controller.reverse();
                                              this.overlayEntry!.remove();
                                            },
                                            icon: Icons.arrow_back_rounded,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Navigation",
                                          style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    Expanded(
                                        child: GridView(
                                      physics: const ClampingScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 16, crossAxisCount: 2, crossAxisSpacing: 16, childAspectRatio: 2.5),
                                      children: [
                                        ListItem(
                                          disabled: true,
                                          icon: const Icon(
                                            Icons.article,
                                            color: Colors.white,
                                          ),
                                          title: "Summaries",
                                          gradientColor1: Colors.grey,
                                          gradientColor2: Colors.grey,
                                          route: null, // No route since it's disabled
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          disabled: true,
                                          icon: const Icon(
                                            Icons.calendar_month,
                                            color: Colors.white,
                                          ),
                                          title: "Refresher",
                                          gradientColor1: Colors.grey,
                                          gradientColor2: Colors.grey,
                                          route: null, // No route since it's disabled
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.note,
                                            color: Colors.white,
                                          ),
                                          title: "Flashcards",
                                          gradientColor1: const Color(0xFF21B38F),
                                          gradientColor2: const Color(0xFF19C17E),
                                          route: const FlashcardsScreen(),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.extension,
                                            color: Colors.white,
                                          ),
                                          title: "Quizzes",
                                          gradientColor1: const Color(0xFF21B38F),
                                          gradientColor2: const Color(0xFF19C17E),
                                          route: const QuizzesScreen(),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.calculate,
                                            color: Colors.white,
                                          ),
                                          title: "Notes",
                                          gradientColor1: const Color(0xFF21B38F),
                                          gradientColor2: const Color(0xFF19C17E),
                                          route: const NotesScreen(),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.list,
                                            color: Colors.white,
                                          ),
                                          title: "Announcement Board",
                                          gradientColor1: const Color(0xFF723EDC),
                                          gradientColor2: const Color(0xFF683BDB),
                                          route: ShowCaseWidget(
                                            onStart: (p0, p1) {
                                              logger.i("Starting showcase");
                                            },
                                            builder: Builder(builder: (context) {
                                              return const MABLACScreen();
                                            }),
                                          ),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                          ),
                                          title: "Calendar",
                                          gradientColor1: const Color(0xFF723EDC),
                                          gradientColor2: const Color(0xFF683BDB),
                                          route: const CalendarScreen(),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.people,
                                            color: Colors.white,
                                          ),
                                          title: "Community",
                                          gradientColor1: const Color(0xFF723EDC),
                                          gradientColor2: const Color(0xFF683BDB),
                                          route: const CommunityScreen(),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.forum,
                                            color: Colors.white,
                                          ),
                                          title: "Forums",
                                          gradientColor1: const Color(0xFF723EDC),
                                          gradientColor2: const Color(0xFF683BDB),
                                          route: const ForumScreen(),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.diamond,
                                            color: Colors.white,
                                          ),
                                          title: "Premium",
                                          gradientColor1: const Color(0xFFD428B8),
                                          gradientColor2: const Color(0xFFA22987),
                                          route: const PremiumScreen(totalSpent: 0),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.settings,
                                            color: Colors.white,
                                          ),
                                          title: "Settings",
                                          gradientColor1: const Color(0xFFD428B8),
                                          gradientColor2: const Color(0xFFA22987),
                                          route: SettingsScreen(
                                            currentTheme: Theme.of(context),
                                          ),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        ),
                                        ListItem(
                                          icon: const Icon(
                                            Icons.info,
                                            color: Colors.white,
                                          ),
                                          title: "Information",
                                          gradientColor1: const Color(0xFFD428B8),
                                          gradientColor2: const Color(0xFFA22987),
                                          route: const InformationScreen(),
                                          controller: _controller,
                                          overlayEntry: this.overlayEntry!,
                                        )
                                      ],
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }));
              });
              overlay.insert(overlayEntry);
              _controller.forward();
              setState(() {
                this.overlayEntry = overlayEntry;
              });
            },
            icon: Icons.menu_rounded,
          );
        }),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({super.key, this.disabled = false, required this.icon, required this.title, required this.gradientColor1, required this.gradientColor2, required this.route, required this.overlayEntry, required this.controller});
  final bool disabled;
  final Icon icon;
  final String title;
  final Color gradientColor1;
  final Color gradientColor2;
  final Widget? route;
  final OverlayEntry overlayEntry;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var ctheme = getThemeFromTheme(theme);
    var textTheme = Theme.of(context).textTheme;
    if (disabled == false) {
      return StyledTouchableContainer(
          theme: ctheme,
          onPressed: () {
            controller.reverse();
            overlayEntry.remove();
            Navigator.push(context, MaterialPageRoute(builder: (context) => route!));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(builder: (context, constraints) {
              return Row(
                children: [
                  Container(
                    height: constraints.maxHeight,
                    width: constraints.maxHeight,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(colors: [
                          gradientColor1,
                          gradientColor2
                        ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                    child: icon,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }),
          ));
    }
    return Container(
        decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return Row(
              children: [
                Container(
                  height: constraints.maxHeight,
                  width: constraints.maxHeight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(colors: [
                        gradientColor1,
                        gradientColor2
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: icon,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }),
        ));
  }
}

//* Clipper
class RadiusClipper extends CustomClipper<Path> {
  const RadiusClipper({required this.radius});
  final double radius;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: const Offset(0, 0), radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

final overlayStateProvider = StateProvider((ref) => false);
