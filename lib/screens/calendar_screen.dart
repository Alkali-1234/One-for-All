import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/components/styled_components/container.dart';
import 'package:oneforall/components/styled_components/elevated_button.dart';
import 'package:oneforall/components/styled_components/elevated_icon_button.dart';
import 'package:oneforall/components/styled_components/primary_elevated_button.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/data/community_data.dart';
import 'package:oneforall/logger.dart';
// import 'package:oneforall/service/community_service.dart';
import 'package:provider/provider.dart';
// import '../data/user_data.dart';
import '../main.dart';

//* Models
import '../models/calendar_model/calendar_model.dart';
import '../models/month_model/month_model.dart';

//* Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

//* Logic

//* State
class CalendarState extends riverpod.Notifier<Calendar?> {
  Future<Calendar?> initializeCalendar(AppState appState, BuildContext context) async {
    logger.d("Before Initializing Calendar");
    // if (!context.mounted) return null;
    // if (ref.read(calendarInitializedProvider)) return null;
    logger.i("Initializing Calendar");
    bool missingMabData = true;
    bool missingLacData = true;
    List<Month> months = [];
    //* Attempt to get data from appstate
    if (appState.getMabData != null) {
      months = getMonthsListFromPosts(appState.getMabData!.posts, months);
      missingMabData = false;
    }
    if (appState.getLacData != null) {
      months = getMonthsListFromPosts(List<MabPost>.generate(appState.getLacData!.posts.length, (index) => MabPost(uid: index, title: appState.getLacData!.posts[index].title, description: appState.getLacData!.posts[index].description, date: appState.getLacData!.posts[index].date, authorUID: appState.getLacData!.posts[index].authorUID, image: appState.getLacData!.posts[index].image, fileAttatchments: appState.getLacData!.posts[index].fileAttatchments, dueDate: appState.getLacData!.posts[index].dueDate, type: appState.getLacData!.posts[index].type, subject: appState.getLacData!.posts[index].subject)), months);
      missingLacData = false;
    }

    //* If data is missing, get data from firebase
    if (missingMabData) {
      await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity!).collection("MAB").get().then((value) {
        List<MabPost> mabPosts = [];

        //* Map the data to MabPost
        for (var e in value.docs) {
          var element = e.data();
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
        months = getMonthsListFromPosts(mabPosts, months);
      });
    }

    if (missingLacData) {
      await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity!).collection("sections").doc(appState.getCurrentUser.assignedSection).collection("LAC").get().then((value) {
        List<LACPost> lacPosts = [];

        //* Map the data to LACPost
        for (var e in value.docs) {
          var element = e.data();
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
          logger.d("LAC Post: ${element["title"]}");
        }
        logger.d("LAC Posts: ${lacPosts.length}");
        months = getMonthsListFromPosts(List<MabPost>.generate(lacPosts.length, (index) => MabPost(uid: index, title: lacPosts[index].title, description: lacPosts[index].description, date: lacPosts[index].date, authorUID: lacPosts[index].authorUID, image: lacPosts[index].image, fileAttatchments: lacPosts[index].fileAttatchments, dueDate: lacPosts[index].dueDate, type: lacPosts[index].type, subject: lacPosts[index].subject)), months);
      });
    }
    state = Calendar(months: months);
    logger.i("Calendar Initialized");
    return state;
  }

  List<Month> getMonthsListFromPosts(List<MabPost> posts, List<Month> monthsParam) {
    List<Month> months = List.from(monthsParam);

    logger.d("Updating Months List : ${posts.length}");
    for (var post in posts) {
      final day = post.dueDate.day;
      final month = post.dueDate.month;
      final year = post.dueDate.year;

      //* Check if month is not in the list
      if (months.indexWhere((element) => element.month == month && element.year == year) == -1) {
        months.add(Month(month: month, year: year, daysList: []));
      }

      //* Update the month

      //* Get the month
      final monthIndex = months.indexWhere((element) => element.month == month && element.year == year);
      //* Days List
      List<Map<int, List<MabPost>>> daysList = List.from(months[monthIndex].daysList);

      //* Check if day is not in the list
      if (daysList.where((element) => element.entries.first.key == day).isEmpty) {
        //* Add the day with the post if it doesn't exist
        daysList.add({
          day: [
            post
          ]
        });
      } else {
        //* Update the day if it exists

        //* Get the day
        final dayIndex = daysList.indexWhere((element) => element.keys.first == day);
        //* Update the day
        daysList[dayIndex][day]!.add(post);
      }
      //* Update the daysList
      months[monthIndex] = Month(month: month, year: year, daysList: daysList);
    }
    logger.d("Updated Months List : ${months.length}");
    return months;
  }

  List<List<Map<int, List<MabPost>>>> getMonthEvents(int month, int year) {
    final monthStartingDay = DateTime(year, month, 1).weekday;
    final monthDays = DateTime(year, month + 1, 0).day;
    //* List days for 6 weeks

    //* List of 6 weeks, each week has 7 days, which has a list of events and it's date
    List<List<Map<int, List<MabPost>>>> weeks = List.generate(6, (index) => List.generate(7, (index) => {}));

    //* Fill in the dates
    for (int i = 0; i < monthDays; i++) {
      final week = (i + monthStartingDay) ~/ 7;
      final day = (i + monthStartingDay) % 7;
      weeks[week][day] = {
        i + 1: []
      };
    }
    //* Fill in previous month missing dates from the first week

    //* Get last week of the previous months' amount of days
    final lastMonthDays = DateTime(year, month, 0).day;
    for (int i = 0; i < monthStartingDay; i++) {
      weeks[0][i] = {
        lastMonthDays - monthStartingDay + i + 1: []
      };
    }

    //* Fill in next month missing dates from the last week

    //* Get the index of the last week and date

    //* Index of the week where it has an empty day
    final lastWeekIndex = weeks.indexWhere((element) => element.where((element) => element.entries.isEmpty).isNotEmpty);

    //* Index of the day where it has an empty day
    int lastWeekDate = weeks[lastWeekIndex].indexWhere((element) => element.entries.isEmpty);

    //* Fill in the missing dates

    //* The day index that will be filled
    int dayIndex = 1;

    //* Iterate through the weeks with missing dates
    for (int i = lastWeekIndex; i < weeks.length; i++) {
      //* Iterate through the dates with missing dates
      for (int j = lastWeekDate; j < 7; j++) {
        weeks[i][j] = {
          dayIndex: []
        };
        dayIndex++;
      }
      lastWeekDate = 0;
    }
    return weeks;
  }

  @override
  Calendar? build() {
    return null;
  }
}

final calendarProvider = riverpod.NotifierProvider<CalendarState, Calendar?>(CalendarState.new);

final calendarInitializedProvider = riverpod.StateProvider<bool>((ref) => false);

class CalendarScreen extends riverpod.ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  riverpod.ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends riverpod.ConsumerState<CalendarScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  bool reversed = false;

  late final initializeCalendarFunction = Future(() => ref.read(calendarProvider.notifier).initializeCalendar(context.read<AppState>(), context));

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    final calendar = ref.watch(calendarProvider);
    var ctheme = getThemeFromTheme(theme);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: MainContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                //Month and year
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
                    StyledIconButton(
                      theme: ctheme,
                      onPressed: () {
                        setState(() {
                          reversed = true;
                          if (selectedMonth - 1 == 0) {
                            selectedMonth = 13;
                            selectedYear--;
                          }
                          selectedMonth--;
                        });
                        // calendarKey.currentState!.initializeCalendarEvents(appState);
                      },
                      icon: Icons.arrow_left_rounded,
                      size: 48,
                    ),
                    Text(getMonthsOfTheYear[selectedMonth], style: textTheme.displayLarge),
                    StyledIconButton(
                      theme: ctheme,
                      onPressed: () {
                        setState(() {
                          reversed = false;
                          if (selectedMonth + 1 == 13) {
                            selectedMonth = 0;
                            selectedYear++;
                          }
                          selectedMonth++;
                        });
                        // calendarKey.currentState!.initializeCalendarEvents(appState);
                      },
                      icon: Icons.arrow_right_rounded,
                      size: 48,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  flex: 5,
                  child: FutureBuilder(
                      future: initializeCalendarFunction,
                      builder: (context, snapshot) {
                        if (calendar == null) {
                          return Center(
                              child: Text(
                            "Loading...",
                            style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                          ));
                        }
                        return PageTransitionSwitcher(
                          reverse: reversed,
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          ),
                          child: CalendarWidget(
                            key: Key(selectedMonth.toString() + selectedYear.toString()),
                            selectedMonth: selectedMonth,
                            selectedYear: selectedYear,
                          ),
                        );
                      }),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ));
  }
}

class CalendarWidget extends riverpod.ConsumerWidget {
  const CalendarWidget({super.key, required this.selectedYear, required this.selectedMonth});
  final int selectedYear;
  final int selectedMonth;

  int getCurrentDate(List<List<Map<int, List<MabPost>>>> monthEvents, int week, int day) {
    return monthEvents[week][day].entries.first.key;
  }

  Color getDateColor(int date, int week, ColorScheme theme, List<Month> calendarMonthsData) {
    final month = //* Check if it is last weeks' month
        date > 7 && week == 0
            ? selectedMonth - 1 == 0
                ? 12
                : selectedMonth - 1
            //* Check if it is next weeks' month
            : date < 14 && week >= 4
                ? selectedMonth + 1 == 13
                    ? 1
                    : selectedMonth + 1
                //* Current month
                : selectedMonth;
    //1 Event = 0xFF00FFA3
    //2-3 Events = 0xFFF9FF00
    //4-5 Events = 0xFFFF9900
    //6+ Events = 0xFFFF0000

    //* Check if last week's month
    if (month < selectedMonth || (month == 12 && selectedMonth == 1)) {
      return Colors.transparent;
    }

    //* Check if next week's month
    if (month > selectedMonth || (month == 1 && selectedMonth == 12)) {
      return Colors.transparent;
    }

    //* Check if month exists
    if (calendarMonthsData.where((element) => element.month == month && element.year == selectedYear).isEmpty) {
      return theme.secondary;
    }

    //* Check if date exists
    if (calendarMonthsData.where((element) => element.month == month && element.year == selectedYear).first.daysList.where((element) => element.keys.first == date).isEmpty) {
      return theme.secondary;
    }

    final events = calendarMonthsData.where((element) => element.month == month && element.year == selectedYear).first.daysList.where((element) => element.keys.first == date).first.values.first;
    if (events.isNotEmpty) {
      if (events.length == 1) {
        return const Color(0xFF00FFA3);
      } else if (events.length >= 2 && events.length <= 3) {
        return const Color(0xFFF9FF00);
      } else if (events.length >= 4 && events.length <= 5) {
        return const Color(0xFFFF9900);
      } else if (events.length >= 6) {
        return const Color(0xFFFF0000);
      }
    }
    return theme.secondary;
  }

  List<MabPost> getEvents(int date, int week, List<List<Map<int, List<MabPost>>>> monthEvents, List<Month> calendarMonthsData) {
    //* Check if it is last weeks' month
    final month = date > 7 && week == 0
        ? selectedMonth - 1 == 0
            ? 12
            : selectedMonth - 1
        //* Check if it is next weeks' month
        : date < 14 && week >= 4
            ? selectedMonth + 1 == 13
                ? 1
                : selectedMonth + 1
            //* Current month
            : selectedMonth;

    //* Check if month exists
    if (calendarMonthsData.where((element) => element.month == month && element.year == selectedYear).isEmpty) {
      return [];
    }

    //* Check if date exists
    if (calendarMonthsData.where((element) => element.month == month && element.year == selectedYear).first.daysList.where((element) => element.keys.first == date).isEmpty) {
      return [];
    }

    return calendarMonthsData.where((element) => element.month == month && element.year == selectedYear).first.daysList.where((element) => element.keys.first == date).first.values.first;
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);

    final currentMonthData = ref.watch(calendarProvider.notifier).getMonthEvents(selectedMonth, selectedYear);
    final calendarMonthsData = ref.watch(calendarProvider)!.months;

    return StyledContainer(
      theme: ctheme,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
            for (int week = 0; week < 6; week++) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int day = 0; day < 7; day++)
                    selectedYear == DateTime.now().year.toInt() && selectedMonth == DateTime.now().month.toInt() && getCurrentDate(currentMonthData, week, day) == DateTime.now().day.toInt() && getDateColor(getCurrentDate(currentMonthData, week, day), week, theme, calendarMonthsData) != Colors.transparent
                        ? SizedBox(
                            height: 30,
                            width: 30,
                            child: StyledPrimaryElevatedButton(
                              theme: ctheme,
                              onPressed: () {
                                if (getCurrentDate(currentMonthData, week, day) != 0) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SelectedDateModal(
                                          lacPosts: const [],
                                          //* Check if it was last month's date
                                          mabPosts: getEvents(getCurrentDate(currentMonthData, week, day), week, currentMonthData, calendarMonthsData),
                                          title: "${getEvents(getCurrentDate(currentMonthData, week, day), week, currentMonthData, calendarMonthsData).length} Events",
                                          description: "${getCurrentDate(currentMonthData, week, day)} of ${getMonthsOfTheYear[selectedMonth]}, $selectedYear",
                                        );
                                      });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const SelectedDateModal(
                                          title: "Invalid Date",
                                          description: "Please select a valid date",
                                          mabPosts: [],
                                          lacPosts: [],
                                        );
                                      });
                                }
                              },
                              child: Text(getCurrentDate(currentMonthData, week, day).toString(), style: textTheme.displaySmall!.copyWith(color: getDateColor(getCurrentDate(currentMonthData, week, day), week, theme, calendarMonthsData) != Colors.transparent ? theme.onBackground : theme.onBackground.withOpacity(0.5))),
                            ),
                          )
                        : SizedBox(
                            height: 30,
                            width: 30,
                            child: StyledElevatedButton(
                              theme: ctheme,
                              onPressed: () {
                                if (getCurrentDate(currentMonthData, week, day) != 0) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SelectedDateModal(
                                          lacPosts: const [],
                                          //* Check if it was last month's date
                                          mabPosts: getEvents(getCurrentDate(currentMonthData, week, day), week, currentMonthData, calendarMonthsData),
                                          title: "${getEvents(getCurrentDate(currentMonthData, week, day), week, currentMonthData, calendarMonthsData).length} Events",
                                          description: "${getCurrentDate(currentMonthData, week, day)} of ${getMonthsOfTheYear[selectedMonth]}, $selectedYear",
                                        );
                                      });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const SelectedDateModal(
                                          title: "Invalid Date",
                                          description: "Please select a valid date",
                                          mabPosts: [],
                                          lacPosts: [],
                                        );
                                      });
                                }
                              },
                              child: Text(getCurrentDate(currentMonthData, week, day).toString(), style: textTheme.displaySmall!.copyWith(color: getDateColor(getCurrentDate(currentMonthData, week, day), week, theme, calendarMonthsData) != Colors.transparent ? theme.onBackground : theme.onBackground.withOpacity(0.5))),
                            ),
                          ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

//Mab Modal
class SelectedDateModal extends StatelessWidget {
  const SelectedDateModal({super.key, required this.title, required this.description, required this.mabPosts, required this.lacPosts});
  final String title, description;
  final List<dynamic> mabPosts;
  final List<dynamic> lacPosts;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      elevation: 2,
      backgroundColor: theme.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              for (int i = 0; i < mabPosts.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          mabPosts[i].title,
                          style: textTheme.displaySmall,
                        )),
                      ],
                    ),
                  ),
                ),
              for (int i = 0; i < lacPosts.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          lacPosts[i].title,
                          style: textTheme.displaySmall,
                        )),
                      ],
                    ),
                  ),
                ),

              const SizedBox(
                height: 16,
              ),
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
      ),
    );
  }
}
