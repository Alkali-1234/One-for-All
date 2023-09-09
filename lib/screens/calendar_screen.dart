import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/banner_ad.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/data/community_data.dart';
// import 'package:oneforall/service/community_service.dart';
import 'package:provider/provider.dart';
// import '../data/user_data.dart';
import '../main.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int selectedYear = DateTime.now().year.toInt();
  int selectedMonth = DateTime.now().month.toInt();
  bool reversed = false;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = context.watch<AppState>();
    return Container(
        decoration: appState.currentUserSelectedTheme == defaultBlueTheme ? const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/purpwallpaper 2.png'), fit: BoxFit.cover)) : BoxDecoration(color: appState.currentUserSelectedTheme.colorScheme.background),
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    //App Bar
                    Hero(
                      tag: "topAppBar",
                      child: Container(
                        color: theme.secondary,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: theme.onPrimary,
                                ),
                              ),
                              Text(appState.getCurrentUser.username, style: textTheme.displaySmall),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: theme.onPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: getPrimaryGradient,
                                ),
                                child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(15)), child: Image.network(appState.getCurrentUser.profilePicture, fit: BoxFit.cover)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    //End of App Bar
                    //Body
                    Expanded(
                        child:
                            //Calendar
                            Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          //Month and year
                          Flexible(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    transitionBuilder: (child, animation) => FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                    child: Text(selectedYear.toString(), style: textTheme.displaySmall),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            reversed = true;
                                            if (selectedMonth - 1 == 0) {
                                              selectedMonth = 13;
                                              selectedYear--;
                                            }
                                            selectedMonth--;
                                          });
                                        },
                                        child: Icon(
                                          Icons.arrow_left_rounded,
                                          color: theme.onPrimary,
                                          size: 48,
                                        ),
                                      ),
                                      Text(getMonthsOfTheYear[selectedMonth], style: textTheme.displayLarge),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            reversed = false;
                                            if (selectedMonth + 1 == 13) {
                                              selectedMonth = 0;
                                              selectedYear++;
                                            }
                                            selectedMonth++;
                                          });
                                        },
                                        child: Icon(
                                          Icons.arrow_right_rounded,
                                          color: theme.onPrimary,
                                          size: 48,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          const SizedBox(height: 15),
                          Flexible(
                              flex: 5,
                              //not working
                              child: PageTransitionSwitcher(
                                transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
                                  fillColor: Colors.transparent,
                                  transitionType: SharedAxisTransitionType.horizontal,
                                  animation: animation,
                                  secondaryAnimation: secondaryAnimation,
                                  child: child,
                                ),
                                duration: const Duration(milliseconds: 150),
                                child: Calendar(
                                  selectedMonth: selectedMonth,
                                  selectedYear: selectedYear,
                                ),
                              )),
                          const SizedBox(height: 10),
                          const Flexible(flex: 2, child: Center(child: BannerAdWidget())),
                        ],
                      ),
                    ))
                  ],
                ))));
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key, required this.selectedYear, required this.selectedMonth});
  final int selectedYear;
  final int selectedMonth;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // int firstDayOfMonth =
  //       DateTime(widget.selectedYear, widget.selectedMonth, 1).weekday;
  //   int lastDayOfMonth =
  //       DateTime(widget.selectedYear, widget.selectedMonth + 1, 0)
  //           .day; //Last day of month

  bool loading = false;

  Object calendarData = {
    "week1": {
      "dates": [
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ]
    },
    "week2": {
      "dates": [
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ]
    },
    "week3": {
      "dates": [
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ]
    },
    "week4": {
      "dates": [
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ]
    },
    "week5": {
      "dates": [
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ]
    },
    "week6": {
      "dates": [
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ]
    }
  };

  get getCalendarData => calendarData;

  Object calendarDataEvents = {
    "events": {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
      6: [],
      7: [],
      8: [],
      9: [],
      10: [],
      11: [],
      12: [],
      13: [],
      14: [],
      15: [],
      16: [],
      17: [],
      18: [],
      19: [],
      20: [],
      21: [],
      22: [],
      23: [],
      24: [],
      25: [],
      26: [],
      27: [],
      28: [],
      29: [],
      30: [],
      31: []
    }
  };

  get getCalendarDataEvents => calendarDataEvents;

  //! faulty but works
  //WORKING CODE, DO NOT TOUCH
  void initializeCalendarEvents(AppState appState) async {
    print("Initializing calendar events");
    //* Reset calendar data
    calendarDataEvents = {
      "events": {
        1: [],
        2: [],
        3: [],
        4: [],
        5: [],
        6: [],
        7: [],
        8: [],
        9: [],
        10: [],
        11: [],
        12: [],
        13: [],
        14: [],
        15: [],
        16: [],
        17: [],
        18: [],
        19: [],
        20: [],
        21: [],
        22: [],
        23: [],
        24: [],
        25: [],
        26: [],
        27: [],
        28: [],
        29: [],
        30: [],
        31: []
      }
    };
    //oh god
    //i forgot
    // LEAP YEARS
    //i wanna die
    //working with dates is a pain

    List<MabPost> mabPosts = [];
    List<LACPost> lacPosts = [];

    bool loadMabData = true;
    bool loadLacData = true;

    //Check if data is already stored in appState
    if (appState.getMabData?.posts.isNotEmpty ?? false) {
      setState(() {
        mabPosts = appState.getMabData!.posts;
        for (MabPost e in mabPosts) {
          //Check if event is in selected month and year, if yes, add to calendarDataEvents
          if (e.dueDate.month == widget.selectedMonth && e.dueDate.year == widget.selectedYear) {
            getCalendarDataEvents["events"][e.dueDate.day].add(e);
          }
        }
        loadMabData = false;
      });
    }

    if (appState.getLacData?.posts.isNotEmpty ?? false) {
      setState(() {
        lacPosts = appState.getLacData!.posts;
        for (LACPost e in lacPosts) {
          //Check if event is in selected month and year, if yes, add to calendarDataEvents
          if (e.dueDate.month == widget.selectedMonth && e.dueDate.year == widget.selectedYear) {
            getCalendarDataEvents["events"][e.dueDate.day].add(e);
          }
        }
      });
      loadLacData = false;
    }

    print("Getting MAB Data");

    //if user is not assigned to a community, return
    if (appState.getCurrentUser.assignedCommunity == null) {
      return;
    }

    if (loading) {
      return;
    }

    setState(() {
      loading = true;
    });

    //i know what i'm doing
    //istg if this breaks i'm gonna cry
    //i'm not crying you're crying
    //YOO IT WORKED
    //nvm it broke
    // wait wait wait i think i fixed it
    //LET'S GOO I FIXED IT
    //i'm so happy
    //i'm gonna cry
    if (loadMabData && appState.getCurrentUser.assignedCommunity != "0") {
      await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity!).collection("MAB").get().then((value) {
        for (var _element in value.docs) {
          var element = _element.data();
          print(element);
          //Tranform Map to MabPost
          mabPosts.add(MabPost(
            authorUID: 0,
            uid: 0,
            title: element["title"],
            description: element["description"],
            dueDate: DateTime.parse(element["dueDate"].toDate().toString()),
            date: DateTime.parse(element["date"].toDate().toString()),
            image: element["image"] ?? "",
            fileAttatchments: element["fileAttatchments"] ?? [],
            type: element["type"],
            subject: element["subject"],
          ));
        }
      });
    }

    if (loadLacData && appState.getCurrentUser.assignedCommunity != "0" && appState.getCurrentUser.assignedSection != "0") {
      await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity!).collection("sections").doc(appState.getCurrentUser.assignedSection).collection("LAC").get().then((value) {
        for (var _element in value.docs) {
          var element = _element.data();
          print(element);
          //Tranform Map to LACPost
          lacPosts.add(LACPost(
            authorUID: 0,
            uid: 0,
            title: element["title"],
            description: element["description"],
            dueDate: DateTime.parse(element["dueDate"].toDate().toString()),
            date: DateTime.parse(element["date"].toDate().toString()),
            image: element["image"] ?? "",
            fileAttatchments: element["fileAttatchments"] ?? [],
            type: element["type"],
            subject: element["subject"],
          ));
        }
      });
    }

    //Get data from MAB
    for (MabPost e in mabPosts) {
      //Check if event is in selected month and year, if yes, add to calendarDataEvents
      if (e.dueDate.month == widget.selectedMonth && e.dueDate.year == widget.selectedYear) {
        getCalendarDataEvents["events"][e.dueDate.day].add(e);
      }
    }

    //Get data from LAC
    for (LACPost e in lacPosts) {
      //Check if event is in selected month and year, if yes, add to calendarDataEvents
      if (e.dueDate.month == widget.selectedMonth && e.dueDate.year == widget.selectedYear) {
        getCalendarDataEvents["events"][e.dueDate.day].add(e);
      }
    }
    // Set data to appstate
    //for some reason does this 4 times??????
    print("Setting data to appstate");
    print(mabPosts.toList());
    print(lacPosts.toList());
    //has been set before... hmm
    appState.setMabData(MabData(uid: 0, posts: mabPosts));
    appState.setLacData(LACData(uid: 0, posts: lacPosts));

    setState(() {});
  }

  void initializeCalendar(int firstDayOfMonth, int lastDayOfMonth, AppState appState) {
    int currentDate = 1;
    //First week
    for (int i = 0; i < 7; i++) {
      if (i < firstDayOfMonth) {
        getCalendarData["week1"]["dates"][i] = 0;
      } else {
        getCalendarData["week1"]["dates"][i] = currentDate;
        currentDate++;
      }
    }
    //Second week
    for (int i = 0; i < 7; i++) {
      if (currentDate > lastDayOfMonth) {
        getCalendarData["week2"]["dates"][i] = 0;
      } else {
        getCalendarData["week2"]["dates"][i] = currentDate;
        currentDate++;
      }
    }
    //Third week
    for (int i = 0; i < 7; i++) {
      if (currentDate > lastDayOfMonth) {
        getCalendarData["week3"]["dates"][i] = 0;
      } else {
        getCalendarData["week3"]["dates"][i] = currentDate;
        currentDate++;
      }
    }
    //Fourth week
    for (int i = 0; i < 7; i++) {
      if (currentDate > lastDayOfMonth) {
        getCalendarData["week4"]["dates"][i] = 0;
      } else {
        getCalendarData["week4"]["dates"][i] = currentDate;
        currentDate++;
      }
    }
    //Fifth week
    for (int i = 0; i < 7; i++) {
      if (currentDate > lastDayOfMonth) {
        getCalendarData["week5"]["dates"][i] = 0;
      } else {
        getCalendarData["week5"]["dates"][i] = currentDate;
        currentDate++;
      }
    }
    //Sixth week
    for (int i = 0; i < 7; i++) {
      if (currentDate > lastDayOfMonth) {
        getCalendarData["week6"]["dates"][i] = 0;
      } else {
        getCalendarData["week6"]["dates"][i] = currentDate;
        currentDate++;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeCalendar(DateTime(widget.selectedYear, widget.selectedMonth, 1).weekday, DateTime(widget.selectedYear, widget.selectedMonth + 1, 0).day, context.read<AppState>());
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    initializeCalendarEvents(context.read<AppState>());

    Color getDateColor(int date) {
      //1 Event = 0xFF00FFA3
      //2-3 Events = 0xFFF9FF00
      //4-5 Events = 0xFFFF9900
      //6+ Events = 0xFFFF0000
      if (getCalendarDataEvents["events"][date] != null) {
        if (getCalendarDataEvents["events"][date].length == 1) {
          return const Color(0xFF00FFA3);
        } else if (getCalendarDataEvents["events"][date].length >= 2 && getCalendarDataEvents["events"][date].length <= 3) {
          return const Color(0xFFF9FF00);
        } else if (getCalendarDataEvents["events"][date].length >= 4 && getCalendarDataEvents["events"][date].length <= 5) {
          return const Color(0xFFFF9900);
        } else if (getCalendarDataEvents["events"][date].length >= 6) {
          return const Color(0xFFFF0000);
        }
      }
      return theme.secondary;
    }

    return SizedBox.expand(
        child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          //Days of the week
          const SizedBox(height: 10),
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("S", style: textTheme.displaySmall),
                Text("M", style: textTheme.displaySmall),
                Text("T", style: textTheme.displaySmall),
                Text("W", style: textTheme.displaySmall),
                Text("Th", style: textTheme.displaySmall),
                Text("F", style: textTheme.displaySmall),
                Text("S", style: textTheme.displaySmall),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < 6; i++) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int j = 0; j < 7; j++)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: widget.selectedYear == DateTime.now().year.toInt() && widget.selectedMonth == DateTime.now().month.toInt() && getCalendarData["week${i + 1}"]["dates"][j] == DateTime.now().day.toInt()
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: getPrimaryGradient,
                          )
                        : BoxDecoration(borderRadius: BorderRadius.circular(20), color: getDateColor(getCalendarData["week${i + 1}"]["dates"][j]), border: Border.all(color: theme.tertiary)),
                    child: ElevatedButton(
                      onPressed: () {
                        if (getCalendarData["week${i + 1}"]["dates"][j] != 0) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SelectedDateModal(
                                  title: "${getCalendarDataEvents["events"][getCalendarData["week${i + 1}"]["dates"][j]].length} Events",
                                  description: "${getCalendarData["week${i + 1}"]["dates"][j]} of ${getMonthsOfTheYear[widget.selectedMonth]}, ${widget.selectedYear}",
                                );
                              });
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const SelectedDateModal(
                                  title: "Invalid Date",
                                  description: "Please select a valid date",
                                );
                              });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.all(0),
                        backgroundColor: Colors.transparent,
                        foregroundColor: theme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(getCalendarData["week${i + 1}"]["dates"][j] == 0 ? "-" : getCalendarData["week${i + 1}"]["dates"][j].toString(), style: textTheme.displaySmall),
                    ),
                  ),
              ],
            ),
          ]
        ],
      ),
    ));
  }
}

//Mab Modal
class SelectedDateModal extends StatelessWidget {
  const SelectedDateModal({super.key, required this.title, required this.description});
  final String title, description;

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
            Text(description, style: textTheme.displaySmall, textAlign: TextAlign.center),
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
