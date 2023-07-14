import 'package:flutter/material.dart';

//Screens
import 'mab_lac_screen.dart';
import 'calendar_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return Column(
      //Title
      children: [
        Flexible(
          flex: 3,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Flexible(
                flex: 1,
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      Text("Self Development", style: textTheme.displayMedium),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Summaries, Refresher, Flashcards, Quizzes
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.article,
                            name: "Summaries",
                          ),
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.calendar_month,
                            name: "Refresher",
                          ),
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.note,
                            name: "Flashcards",
                          ),
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.extension,
                            name: "Quizzes",
                          ),
                        ],
                      )
                    ],
                  );
                }),
              ),
              Flexible(
                flex: 1,
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      Text("Tools", style: textTheme.displayMedium),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Notes, Calendar, M.A.B
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.import_contacts,
                            name: "Notes",
                          ),
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.calendar_today,
                            name: "Calendar",
                            onPressed: () {
                              debugPrint("Calendar");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CalendarScreen()),
                              );
                            },
                          ),
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.list,
                            name: "M.A.B",
                            onPressed: () {
                              debugPrint("M.A.B");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MABLACScreen()),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  );
                }),
              ),
              Flexible(
                flex: 1,
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      Text("Community & Other", style: textTheme.displayMedium),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Forums, Sharing, Premium, Settings
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.forum,
                            name: "Forums",
                          ),
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.share,
                            name: "Sharing",
                          ),
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.diamond,
                            name: "Premium",
                          ),
                          NavigationItem(
                            theme: theme,
                            constraints: constraints,
                            icon: Icons.settings,
                            name: "Settings",
                          ),
                        ],
                      )
                    ],
                  );
                }),
              )
            ],
          ),
        ),
        Flexible(
            flex: 1,
            child: Center(
              child: Row(
                children: [
                  Text("\"Buy premium for free rizz\"\n -Sun Tzu, Art of War",
                      style: textTheme.displayMedium),
                ],
              ),
            ))
      ],
    );
  }
}

class NavigationItem extends StatelessWidget {
  const NavigationItem(
      {super.key,
      required this.theme,
      required this.constraints,
      required this.icon,
      required this.name,
      this.onPressed});

  final ColorScheme theme;
  final BoxConstraints constraints;
  final IconData icon;
  final String name;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: constraints.maxWidth * 0.235,
      height: constraints.maxWidth * 0.235,
      child: ElevatedButton(
        onPressed: () {
          debugPrint("hi");
          onPressed!();
        },
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.all(8),
          backgroundColor: theme.secondary,
          foregroundColor: theme.onPrimary,
          side: BorderSide(color: theme.tertiary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: FittedBox(
          child: Column(
            children: [
              Icon(icon, size: 50),
              Text(name),
            ],
          ),
        ),
      ),
    );
  }
}
