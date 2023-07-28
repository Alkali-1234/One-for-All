import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oneforall/constants.dart';
import '../data/community_data.dart';
import '../service/community_service.dart';

class MABLACScreen extends StatefulWidget {
  const MABLACScreen({super.key});

  @override
  State<MABLACScreen> createState() => _MABLACScreenState();
}

class _MABLACScreenState extends State<MABLACScreen> {
  int selectedSection = 0;
  String searchQuery = "";
  SearchController searchController = SearchController();
  //0 = MAB
  //1 = LAC
  int selectedTypeFilter = 0;
  //0 = All
  //1 = Announces
  //2 = Tasks

  //TODO Make subject filter dynamic
  int selectedSubjectFilter = 0;
  //0 = All
  //...
  int selectedDueFilter = 0;
  //0 = All
  //1 = in 3 days
  //2 = in 7 days
  //3 = in 14 days
  int sortFilter = 0;
  //0 = Newest
  //1 Due date

  bool isItemValid(
      String title, String description, int subject, int type, DateTime due) {
    //1: Does item title or desc contain search query
    if (title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        description.toLowerCase().contains(searchQuery.toLowerCase())) {
      //2: Does item type match filter
      if (type == selectedTypeFilter || selectedTypeFilter == 0) {
        //3: Does item subject match filter
        if (subject + 1 == selectedSubjectFilter ||
            selectedSubjectFilter == 0) {
          //4: Does item due date match filter
          if (due.isBefore(DateTime.now()
                  .add(Duration(days: getDueDates[selectedDueFilter]))) ||
              selectedDueFilter == 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/purpwallpaper 2.png'),
                fit: BoxFit.cover)),
        child: SafeArea(
            child: Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => const NewEventModal());
                  },
                  backgroundColor: theme.primary,
                  child: const Icon(Icons.add),
                ),
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    //App Bar
                    Container(
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  child: Image.network(
                                      'https://picsum.photos/200')),
                            )
                          ],
                        ),
                      ),
                    ),
                    //End of App Bar
                    //Body
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          //Top selection
                          Flexible(
                            flex: 1,
                            child: Row(children: [
                              Flexible(
                                flex: 1,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: selectedSection == 0
                                            ? constraints.maxHeight
                                            : constraints.maxHeight - 10,
                                        width: constraints.maxWidth,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedSection = 0;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.all(8),
                                            backgroundColor:
                                                selectedSection == 0
                                                    ? theme.primaryContainer
                                                    : theme.secondary,
                                            foregroundColor: theme.onPrimary,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "MAB",
                                            style: textTheme.displaySmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              Flexible(
                                flex: 1,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: selectedSection == 1
                                            ? constraints.maxHeight
                                            : constraints.maxHeight - 10,
                                        width: constraints.maxWidth,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedSection = 1;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.all(8),
                                            backgroundColor:
                                                selectedSection == 1
                                                    ? theme.primaryContainer
                                                    : theme.secondary,
                                            foregroundColor: theme.onPrimary,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "LAC",
                                            style: textTheme.displaySmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ]),
                          ),
                          Flexible(
                              flex: 14,
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    color: theme.primaryContainer,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(children: [
                                      //Search bar
                                      Flexible(
                                        flex: 3,
                                        child: TextField(
                                          controller: searchController,
                                          onChanged: (value) => setState(() {
                                            searchQuery = value;
                                          }),
                                          keyboardAppearance: Brightness.dark,
                                          cursorColor: theme.onPrimary,
                                          style: textTheme.displayMedium!
                                              .copyWith(
                                                  color: theme.onPrimary,
                                                  fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                              filled: true,
                                              fillColor: theme.primary,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              hintText: 'Search',
                                              suffixIcon: Icon(Icons.search,
                                                  color: theme.onPrimary,
                                                  size: 50),
                                              hintStyle: textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                      color: theme.onPrimary
                                                          .withOpacity(0.25),
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      //Filters
                                      Flexible(
                                          flex: 3,
                                          child: Column(children: [
                                            Flexible(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  //Filter by

                                                  //All
                                                  Flexible(
                                                    flex: 1,
                                                    child: LayoutBuilder(
                                                        builder: (context, c) {
                                                      return Container(
                                                        width: c.maxWidth - 10,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              theme.secondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: DropdownButton(
                                                            value:
                                                                selectedTypeFilter,
                                                            icon: const Icon(
                                                                null),
                                                            underline:
                                                                Container(),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedTypeFilter =
                                                                    value
                                                                        as int;
                                                              });
                                                            },
                                                            items: const [
                                                              DropdownMenuItem(
                                                                value: 0,
                                                                child: Text(
                                                                    "All",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 1,
                                                                child:
                                                                    FittedBox(
                                                                  child: Text(
                                                                      "Announces",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 2,
                                                                child: Text(
                                                                    "Tasks",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  //Subject
                                                  Flexible(
                                                    flex: 1,
                                                    child: LayoutBuilder(
                                                        builder: (context, c) {
                                                      return Container(
                                                        width: c.maxWidth - 10,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              theme.secondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: DropdownButton(
                                                              value:
                                                                  selectedSubjectFilter,
                                                              icon: const Icon(
                                                                  null),
                                                              underline:
                                                                  Container(),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  selectedSubjectFilter =
                                                                      value
                                                                          as int;
                                                                });
                                                              },
                                                              items:
                                                                  List.generate(
                                                                      getSubjects
                                                                              .length +
                                                                          1,
                                                                      (index) =>
                                                                          DropdownMenuItem(
                                                                            value:
                                                                                index,
                                                                            child: index == 0
                                                                                ? const Text("All", style: TextStyle(color: Colors.white))
                                                                                : FittedBox(child: Text(getSubjects[index - 1], style: const TextStyle(color: Colors.white))),
                                                                          ))),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  //Due
                                                  Flexible(
                                                    flex: 1,
                                                    child: LayoutBuilder(
                                                        builder: (context, c) {
                                                      return Container(
                                                        width: c.maxWidth - 10,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              theme.secondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: DropdownButton(
                                                            value:
                                                                selectedDueFilter,
                                                            icon: const Icon(
                                                                null),
                                                            underline:
                                                                Container(),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedDueFilter =
                                                                    value
                                                                        as int;
                                                              });
                                                            },
                                                            items: const [
                                                              DropdownMenuItem(
                                                                value: 0,
                                                                child: Text(
                                                                    "All",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 1,
                                                                child:
                                                                    FittedBox(
                                                                  child: Text(
                                                                      "3 Days",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 2,
                                                                child: Text(
                                                                    "7 Days",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                              DropdownMenuItem(
                                                                  value: 3,
                                                                  child: Text(
                                                                      "14 Days",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)))
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            const Flexible(
                                              flex: 1,
                                              child: Row(
                                                children: [
                                                  // Container(
                                                  //   width:
                                                  //       MediaQuery.of(context)
                                                  //               .size
                                                  //               .width *
                                                  //           0.3,
                                                  //   decoration: BoxDecoration(
                                                  //     color: theme.secondary,
                                                  //     borderRadius:
                                                  //         BorderRadius.circular(
                                                  //             10),
                                                  //   ),
                                                  //   child: Padding(
                                                  //     padding:
                                                  //         const EdgeInsets.all(
                                                  //             8.0),
                                                  //     child: DropdownButton(
                                                  //       value: sortFilter,
                                                  //       icon: const Icon(null),
                                                  //       underline: Container(),
                                                  //       onChanged: (value) {
                                                  //         setState(() {
                                                  //           sortFilter =
                                                  //               value as int;
                                                  //         });
                                                  //       },
                                                  //       items: const [
                                                  //         DropdownMenuItem(
                                                  //           value: 0,
                                                  //           child: Text(
                                                  //               "Newest",
                                                  //               style: TextStyle(
                                                  //                   color: Colors
                                                  //                       .white)),
                                                  //         ),
                                                  //         DropdownMenuItem(
                                                  //           value: 1,
                                                  //           child: FittedBox(
                                                  //             child: Text(
                                                  //                 "Due Date",
                                                  //                 style: TextStyle(
                                                  //                     color: Colors
                                                  //                         .white)),
                                                  //           ),
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            )
                                          ])),
                                      const SizedBox(height: 10),
                                      //List of items
                                      Flexible(
                                          flex: 20,
                                          child: SizedBox.expand(
                                            child: LayoutBuilder(
                                                builder: (context, c) {
                                              return ListView.builder(
                                                  itemCount: selectedSection ==
                                                          0
                                                      ? getMabData.posts.length
                                                      : getLACData.posts.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return selectedSection == 1
                                                        ? isItemValid(
                                                                getLACData
                                                                    .posts[
                                                                        index]
                                                                    .title,
                                                                getLACData
                                                                    .posts[
                                                                        index]
                                                                    .description,
                                                                getLACData
                                                                    .posts[
                                                                        index]
                                                                    .subject,
                                                                getLACData
                                                                    .posts[
                                                                        index]
                                                                    .type,
                                                                getLACData
                                                                    .posts[
                                                                        index]
                                                                    .dueDate)
                                                            ? ListItem(
                                                                theme: theme,
                                                                textTheme:
                                                                    textTheme,
                                                                c: c,
                                                                title: getLACData
                                                                    .posts[
                                                                        index]
                                                                    .title,
                                                                description:
                                                                    getLACData
                                                                        .posts[
                                                                            index]
                                                                        .description,
                                                                subject: getLACData
                                                                    .posts[
                                                                        index]
                                                                    .subject,
                                                                type: getLACData
                                                                    .posts[
                                                                        index]
                                                                    .type,
                                                                due: getLACData
                                                                    .posts[
                                                                        index]
                                                                    .dueDate)
                                                            : Container()
                                                        : isItemValid(
                                                                getMabData
                                                                    .posts[
                                                                        index]
                                                                    .title,
                                                                getMabData
                                                                    .posts[
                                                                        index]
                                                                    .description,
                                                                getMabData
                                                                    .posts[
                                                                        index]
                                                                    .subject,
                                                                getMabData
                                                                    .posts[
                                                                        index]
                                                                    .type,
                                                                getMabData
                                                                    .posts[
                                                                        index]
                                                                    .dueDate)
                                                            ? ListItem(
                                                                theme: theme,
                                                                textTheme:
                                                                    textTheme,
                                                                c: c,
                                                                title: getMabData
                                                                    .posts[
                                                                        index]
                                                                    .title,
                                                                description:
                                                                    getMabData
                                                                        .posts[
                                                                            index]
                                                                        .description,
                                                                subject: getMabData
                                                                    .posts[
                                                                        index]
                                                                    .subject,
                                                                type: getMabData
                                                                    .posts[
                                                                        index]
                                                                    .type,
                                                                due: getMabData
                                                                    .posts[
                                                                        index]
                                                                    .dueDate)
                                                            : Container();
                                                  });
                                            }),
                                          )),
                                    ]),
                                  ))),
                        ]),
                      ),
                    ),
                  ],
                ))));
  }
}

class NewEventModal extends StatefulWidget {
  const NewEventModal({super.key});

  @override
  State<NewEventModal> createState() => _NewEventModalState();
}

class _NewEventModalState extends State<NewEventModal> {
  String title = "";
  String description = "";
  int subject = 0;
  int type = 1;
  Timestamp? dueDate;
  //1 = Announces
  //2 = Tasks
  File? image;
  List<File> attatchements = [];

  //* Backend variables
  bool isLoading = false;
  bool success = false;
  String error = "";

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    //* Adds new file to the community document
    void addNewEvent() async {
      //* Spam prevention
      if (isLoading) {
        return;
      }
      //* Check if all fields are filled
      if (title == "" || description == "" || dueDate == null) {
        setState(() {
          error = "Please fill in all fields";
        });
        return;
      }
      //* Set loading to true
      setState(() {
        isLoading = true;
      });
      //* Add the event to the community document
      //TODO implement
    }

    return Dialog(
      elevation: 2,
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("New Event", style: textTheme.displayLarge),
            const SizedBox(height: 8),
            //* Title textfield
            SizedBox(
              height: 40,
              child: TextField(
                onChanged: (value) => setState(() {
                  title = value;
                }),
                style: textTheme.displaySmall,
                cursorColor: theme.onBackground,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  filled: true,
                  fillColor: theme.primary.withOpacity(0.125),
                  hintText: "Title",
                  hintStyle: textTheme.displaySmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.onBackground, width: 1),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            //* Description textfield
            SizedBox(
              height: 40,
              child: TextField(
                onChanged: (value) => setState(() {
                  description = value;
                }),
                style: textTheme.displaySmall,
                cursorColor: theme.onBackground,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  filled: true,
                  fillColor: theme.primary.withOpacity(0.125),
                  hintText: "Description",
                  hintStyle: textTheme.displaySmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.onBackground, width: 1),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            //* Due date field
            Row(
              children: [
                Text("Due date:", style: textTheme.displaySmall),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        fieldLabelText: Text("Due date:",
                                style: TextStyle(color: theme.onBackground))
                            .data,
                        builder: (context, child) => Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: theme.secondary,
                                  onPrimary: theme.onPrimary,
                                  surface: theme.secondary,
                                  onSurface: theme.onPrimary,
                                  background: theme.background,
                                  onBackground: theme.onBackground,
                                ),
                                dialogBackgroundColor: theme.background,
                                textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                  foregroundColor: theme.onBackground,
                                )),
                              ),
                              child: child!,
                            ));
                    if (picked != null) {
                      setState(() {
                        dueDate = Timestamp.fromDate(picked);
                      });
                    }
                  },
                  child: Text(
                      dueDate == null
                          ? "Select a date"
                          : DateFormat("dd/MM/yyyy").format(dueDate!.toDate()),
                      style: textTheme.displaySmall!
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 8),
            //* Subject field
            Row(
              children: [
                Text("Subject: ", style: textTheme.displaySmall),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: DropdownButton(
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(30),
                    hint: const Text("Subject"),
                    value: subject,
                    icon: const Icon(null),
                    underline: Container(),
                    onChanged: (value) {
                      setState(() {
                        subject = value as int;
                      });
                      debugPrint("Changed subject to $subject");
                    },
                    items: List.generate(
                        getSubjects.length,
                        (index) => DropdownMenuItem(
                            value: index,
                            child: Text(getSubjects[index],
                                textAlign: TextAlign.center,
                                style: textTheme.displaySmall!
                                    .copyWith(fontWeight: FontWeight.bold)))),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            //* Type field
            Row(
              children: [
                Text("Type: ", style: textTheme.displaySmall),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: DropdownButton(
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(30),
                    hint: const Text("Type"),
                    value: type,
                    icon: const Icon(null),
                    underline: Container(),
                    onChanged: (value) {
                      setState(() {
                        type = value as int;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text("Announcement",
                            textAlign: TextAlign.center,
                            style: textTheme.displaySmall!
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("Task",
                            textAlign: TextAlign.center,
                            style: textTheme.displaySmall!
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            //* Image field
            Row(
              children: [
                Text("Image: ", style: textTheme.displaySmall),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      //* Show image picker
                      final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 50,
                          maxWidth: 500,
                          maxHeight: 500);
                      if (pickedFile == null) return;
                      setState(() {
                        image = File(pickedFile.path);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Select an image",
                      style: textTheme.displaySmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            //* Show image if there is one
            if (image != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: FileImage(image!), fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 8),
            //* Attatchements field
            Row(
              children: [
                Text("Attatchements: ", style: textTheme.displaySmall),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      //* Show image picker
                      final pickedFiles = await ImagePicker().pickMultipleMedia(
                          imageQuality: 50, maxWidth: 500, maxHeight: 500);
                      setState(() {
                        for (var file in pickedFiles) {
                          attatchements.add(File(file.path));
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Pick attatchements",
                      style: textTheme.displaySmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            //* Confirm button
            Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () => addNewEvent(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  //* Confirm button text : if loading, show loading indicator, if not loading and there is error, show error text, else show confirm text
                  child: isLoading
                      ? CircularProgressIndicator(color: theme.onBackground)
                      : !isLoading && error != ""
                          ? Text(error,
                              style: textTheme.displaySmall!
                                  .copyWith(color: theme.error))
                          : Text("Confirm",
                              style: textTheme.displaySmall!
                                  .copyWith(fontWeight: FontWeight.bold)),
                ))
          ],
        ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.theme,
    required this.textTheme,
    required this.c,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.due,
  });

  final ColorScheme theme;
  final TextTheme textTheme;
  final BoxConstraints c;
  final String title;
  final String description;
  final int subject;
  final int type;
  final DateTime due;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
          height: c.maxHeight * 0.165,
          decoration: BoxDecoration(
            color: theme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return MABModal(
                        title: title,
                        description: description,
                        image: null,
                        attatchements: const ["https://picsum.photos/200/300"]);
                  });
            },
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.all(12),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        title,
                        style: textTheme.displayMedium,
                        maxLines: 1,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                            color: theme.secondary,
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                            "${due.difference(DateTime.now()).inDays + 1} Days (${DateFormat("E").format(due)})",
                            style: textTheme.displaySmall),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        //Profilepicture
                        Container(
                          width: MediaQuery.of(context).size.width * 0.05,
                          height: MediaQuery.of(context).size.width * 0.05,
                          decoration: BoxDecoration(
                            color: theme.onPrimary,
                            borderRadius: BorderRadius.circular(20),
                            gradient: getPrimaryGradient,
                          ),
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              child:
                                  Image.network('https://picsum.photos/200')),
                        ),
                        const SizedBox(width: 10),
                        Text("Alkaline", style: textTheme.displaySmall),
                        const SizedBox(width: 10),
                        Icon(
                          type == 1 ? Icons.announcement_rounded : Icons.task,
                          size: MediaQuery.of(context).size.width * 0.05,
                          color: theme.onPrimary,
                        ),
                        const SizedBox(width: 3),
                        Text(type == 1 ? "Announcement" : "Task",
                            style: textTheme.displaySmall)
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: theme.secondary,
                          borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.all(5),
                      child: Text(getSubjects[subject],
                          style: textTheme.displaySmall),
                    ),
                  ],
                )
              ],
            ),
          )),
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
                  child: image == null
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
