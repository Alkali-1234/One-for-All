import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/data/community_data.dart';
// import 'package:oneforall/service/community_service.dart';
import 'package:provider/provider.dart';
// import '../data/user_data.dart';
import '../main.dart';

//* Models
import '../models/calendar_model/calendar_model.dart';
import '../models/month_model/month_model.dart';

//* Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

//* State
class CalendarState extends riverpod.Notifier<Calendar> {
  Future<void> initializeCalendar(AppState appState) async {
    if (ref.read(calendarInitializedProvider)) return;
    ref.read(calendarInitializedProvider.notifier).state = false;
    bool missingMabData = false;
    bool missingLacData = false;
    List<Month> months = [];
    //* Attempt to get data from appstate
    if (appState.getMabData != null) {
      months.addAll(getMonthsListFromPosts(appState.getMabData!.posts));
      missingMabData = false;
    }
    if (appState.getLacData != null) {
      months.addAll(getMonthsListFromPosts(List<MabPost>.generate(appState.getLacData!.posts.length, (index) => MabPost(uid: index, title: appState.getLacData!.posts[index].title, description: appState.getLacData!.posts[index].description, date: appState.getLacData!.posts[index].date, authorUID: appState.getLacData!.posts[index].authorUID, image: appState.getLacData!.posts[index].image, fileAttatchments: appState.getLacData!.posts[index].fileAttatchments, dueDate: appState.getLacData!.posts[index].dueDate, type: appState.getLacData!.posts[index].type, subject: appState.getLacData!.posts[index].subject))));
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
        months.addAll(getMonthsListFromPosts(mabPosts));
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
        }
        months.addAll(getMonthsListFromPosts(List<MabPost>.generate(lacPosts.length, (index) => MabPost(uid: index, title: lacPosts[index].title, description: lacPosts[index].description, date: lacPosts[index].date, authorUID: lacPosts[index].authorUID, image: lacPosts[index].image, fileAttatchments: lacPosts[index].fileAttatchments, dueDate: lacPosts[index].dueDate, type: lacPosts[index].type, subject: lacPosts[index].subject))));
      });
    }
    ref.read(calendarInitializedProvider.notifier).state = true;
  }

  List<Month> getMonthsListFromPosts(List<MabPost> posts) {
    List<Month> months = [];
    for (var post in posts) {
      final day = post.dueDate.day;
      final month = post.dueDate.month;
      final year = post.dueDate.year;

      //* Check if month is not in the list
      if (state.months.indexWhere((element) => element.month == month && element.year == year) == -1) {
        months.add(Month(month: month, year: year, daysList: []));
      }

      //* Update the month

      //* Get the month
      final monthIndex = months.indexWhere((element) => element.month == month && element.year == year);
      //* Get the daysList
      final daysList = months[monthIndex].daysList;
      //* Check if day is not in the list
      if (daysList.where((element) => element.keys.first == day).isEmpty) {
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
    for (int i = monthDays + monthStartingDay; i < 42; i++) {
      weeks[5][i % 7] = {
        i - monthDays - monthStartingDay + 1: []
      };
    }
    return weeks;
  }

  @override
  Calendar build() {
    return const Calendar(months: []);
  }
}

final calendarProvider = riverpod.NotifierProvider<CalendarState, Calendar>(CalendarState.new);

final calendarInitializedProvider = riverpod.StateProvider<bool>((ref) => false);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  bool reversed = false;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: MainContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                                // calendarKey.currentState!.initializeCalendarEvents(appState);
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
                                // calendarKey.currentState!.initializeCalendarEvents(appState);
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
                    child: riverpod.Consumer(builder: (context, ref, child) {
                      final calendar = ref.watch(calendarProvider.notifier);
                      return FutureBuilder(
                          future: calendar.initializeCalendar(context.read<AppState>()),
                          builder: (context, snapshot) {
                            return CalendarWidget(
                              key: Key(selectedMonth.toString() + selectedYear.toString()),
                              selectedMonth: selectedMonth,
                              selectedYear: selectedYear,
                            );
                          });
                    })),
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

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    final calendarData = ref.watch(calendarProvider.notifier).getMonthEvents(selectedMonth, selectedYear);

    Color getDateColor(int date) {
      //1 Event = 0xFF00FFA3
      //2-3 Events = 0xFFF9FF00
      //4-5 Events = 0xFFFF9900
      //6+ Events = 0xFFFF0000
      if (calendarData[selectedMonth][date].isNotEmpty) {
        if (calendarData[selectedMonth][date].length == 1) {
          return const Color(0xFF00FFA3);
        } else if (calendarData[selectedMonth][date].length >= 2 && calendarData[selectedMonth][date].length <= 3) {
          return const Color(0xFFF9FF00);
        } else if (calendarData[selectedMonth][date].length >= 4 && calendarData[selectedMonth][date].length <= 5) {
          return const Color(0xFFFF9900);
        } else if (calendarData[selectedMonth][date].length >= 6) {
          return const Color(0xFFFF0000);
        }
      }
      return theme.secondary;
    }

    return SizedBox.expand(
        child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border.all(color: theme.secondary),
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
          for (int week = 0; week < 6; week++) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int day = 0; day < 7; day++)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: selectedYear == DateTime.now().year.toInt() && selectedMonth == DateTime.now().month.toInt() && getCurrentDate(calendarData, week, day) == DateTime.now().day.toInt()
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: getPrimaryGradient,
                          )
                        : BoxDecoration(borderRadius: BorderRadius.circular(20), color: getDateColor(getCurrentDate(calendarData, week, day)), border: Border.all(color: theme.tertiary)),
                    child: ElevatedButton(
                      onPressed: () {
                        if (getCurrentDate(calendarData, week, day) != 0) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SelectedDateModal(
                                  lacPosts: const [],
                                  //* Check if it was last month's date
                                  mabPosts: getCurrentDate(calendarData, week, day) > 7 && week == 0
                                      ? calendarData[selectedMonth - 1 == 0 ? 12 : selectedMonth][getCurrentDate(calendarData, week, day)].entries.first.value
                                      //* Check if it was next month's date
                                      : getCurrentDate(calendarData, week, day) < 7 && week >= 5
                                          ? calendarData[selectedMonth + 1 == 13 ? 1 : selectedMonth][getCurrentDate(calendarData, week, day)].entries.first.value
                                          //* Current month's date
                                          : calendarData[selectedMonth][getCurrentDate(calendarData, week, day)].entries.first.value,
                                  title: "${calendarData[selectedMonth][getCurrentDate(calendarData, week, day)].entries.first.value.length} Events",
                                  description: "${calendarData[selectedMonth][getCurrentDate(calendarData, week, day)].entries.first.value} of ${getMonthsOfTheYear[selectedMonth]}, $selectedYear",
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
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.all(0),
                        backgroundColor: Colors.transparent,
                        foregroundColor: theme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(getCurrentDate(calendarData, week, day).toString(), style: textTheme.displaySmall),
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
