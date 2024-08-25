import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/components/styled_components/elevated_button.dart';
import 'package:oneforall/components/styled_components/elevated_icon_button.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:oneforall/components/styled_components/text_field.dart';
import 'package:oneforall/components/styled_components/touchable_container.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/logger.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:oneforall/data/user_data.dart';
import 'package:provider/provider.dart';
import '../components/styled_components/container.dart';
import '../data/community_data.dart';
import '../main.dart';
import '../service/community_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

  //Dynamic at a later date
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

  bool isItemValid(MabPost post) {
    final title = post.title;
    final description = post.description;
    final due = post.dueDate;
    final type = post.type;
    final subject = post.subject;

    //1: Does item title or desc contain search query
    if (title.toLowerCase().contains(searchQuery.toLowerCase()) || description.toLowerCase().contains(searchQuery.toLowerCase())) {
      //2: Does item type match filter
      if (type == selectedTypeFilter || selectedTypeFilter == 0) {
        //3: Does item subject match filter
        //If subject filter is 1 only show items with subject 1
        //If subject filter is 0 show all items
        //If subject filter is 2 show items with subject other than 1
        if (subject + 1 == selectedSubjectFilter || selectedSubjectFilter == 0 || (selectedSubjectFilter == 2 && subject != 1)) {
          //4: Does item due date match filter
          if (due.isBefore(DateTime.now().add(Duration(days: getDueDates[selectedDueFilter]))) || selectedDueFilter == 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  //* Streams
  late Stream mabDataStream;
  late Stream lacDataStream;

  @override
  void initState() {
    super.initState();
    var appState = context.read<AppState>();
    mabDataStream = appState.getCurrentUser.assignedCommunity != "0" ? FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("MAB").snapshots() : const Stream.empty();
    lacDataStream = appState.getCurrentUser.assignedSection != "0" ? FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("sections").doc(appState.getCurrentUser.assignedSection).collection("LAC").snapshots() : const Stream.empty();
    logger.d(lacDataStream);
  }

  /// Reverse the animation
  bool reverse = false;

  void toggleSection() {
    setState(() {
      if (selectedSection == 0) {
        selectedSection = 1;
      } else {
        selectedSection = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = Provider.of<AppState>(context);
    var ctheme = getThemeFromTheme(theme);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => NewEventModal(
                      selectedSection: selectedSection,
                    ));
          },
          backgroundColor: theme.secondary,
          child: const Icon(Icons.add),
        ),
        backgroundColor: Colors.transparent,
        body: MainContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (context, constraints) {
              return Column(children: [
                const SizedBox(
                  height: 16,
                ),
                //* Title Text
                Wrap(
                  children: [
                    Text(
                      selectedSection == 0 ? "Main" : "Local",
                      style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    StyledIconButton(
                      theme: ctheme,
                      onPressed: () {
                        setState(() {
                          reverse = false;
                        });

                        toggleSection();
                      },
                      icon: Icons.cached_rounded,
                      size: 24,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Announcement",
                      style: textTheme.displayMedium,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Board",
                      style: textTheme.displayMedium,
                    )
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),
                Expanded(
                  child: Column(children: [
                    //Search bar
                    StyledTextField(
                      theme: ctheme,
                      controller: searchController,
                      onChanged: (value) => setState(() {
                        searchQuery = value;
                      }),
                      hint: "Search",
                    ),
                    const SizedBox(height: 16),
                    //Filters
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Filter by

                          //All
                          Flexible(
                            flex: 1,
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButton(
                                isExpanded: true,
                                value: selectedTypeFilter,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTypeFilter = value as int;
                                  });
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text(
                                      "All",
                                      style: TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: FittedBox(
                                      child: Text(
                                        "Announces",
                                        style: TextStyle(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text(
                                      "Tasks",
                                      style: TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          //Subject
                          Flexible(
                            flex: 1,
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButton(
                                  isExpanded: true,
                                  value: selectedSubjectFilter,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSubjectFilter = value as int;
                                    });
                                  },
                                  items: List.generate(
                                      getSubjects.length + 1,
                                      (index) => DropdownMenuItem(
                                            value: index,
                                            child: index == 0 ? const Text("All", style: TextStyle(color: Colors.white)) : FittedBox(child: Text(getSubjects[index - 1], style: const TextStyle(color: Colors.white))),
                                          ))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          //Due
                          Flexible(
                            flex: 1,
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButton(
                                isExpanded: true,
                                value: selectedDueFilter,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDueFilter = value as int;
                                  });
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text("All", style: TextStyle(color: Colors.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: FittedBox(
                                      child: Text("3 Days", style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text("7 Days", style: TextStyle(color: Colors.white)),
                                  ),
                                  DropdownMenuItem(value: 3, child: Text("14 Days", style: TextStyle(color: Colors.white)))
                                ].map((e) => DropdownMenuItem(value: e.value, child: FittedBox(child: e.child))).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    //List of items
                    Expanded(
                      child: selectedSection == 0
                          ? StreamBuilder(
                              stream: mabDataStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                      child: Text(
                                    "Loading...",
                                    style: textTheme.displaySmall,
                                  ));
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text(
                                    "Error: ${snapshot.error}",
                                    style: textTheme.displaySmall!.copyWith(color: theme.error),
                                  ));
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: Text(
                                    "No data",
                                    style: textTheme.displaySmall,
                                  ));
                                }
                                MabData mabData = MabData(uid: 0, posts: [
                                  for (var post in (selectedSection == 0 ? snapshot.data?.docs ?? [] : snapshot.data?.docs ?? []))
                                    MabPost(
                                        uid: 0,
                                        title: post["title"],
                                        description: post["description"],
                                        date: DateTime.parse(post["date"].toDate().toString()),
                                        authorUID: 0,
                                        image: post["image"] ?? "",
                                        fileAttatchments: [
                                          for (String file in post["files"]) file
                                        ],
                                        dueDate: DateTime.parse(post["dueDate"].toDate().toString()),
                                        type: post["type"],
                                        subject: post["subject"])
                                ]);
                                mabData.posts.sort((a, b) => b.date.compareTo(a.date));
                                return ListView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    //MabData is misleading, it's actually both !!!!! (no way) (crazy right?)
                                    itemCount: mabData.posts.length,
                                    itemBuilder: (context, index) {
                                      MabPost post = mabData.posts[index];
                                      return isItemValid(post) ? ListItem(theme: theme, textTheme: textTheme, post: post) : const SizedBox();
                                    });
                              })
                          : StreamBuilder(
                              stream: lacDataStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                      child: Text(
                                    "Loading...",
                                    style: textTheme.displaySmall,
                                  ));
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text(
                                    "Error: ${snapshot.error}",
                                    style: textTheme.displaySmall!.copyWith(color: theme.error),
                                  ));
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: Text(
                                    "No data",
                                    style: textTheme.displaySmall,
                                  ));
                                }
                                MabData mabData = MabData(uid: 0, posts: [
                                  for (var post in (selectedSection == 0 ? snapshot.data?.docs ?? [] : snapshot.data?.docs ?? []))
                                    MabPost(
                                        uid: 0,
                                        title: post["title"],
                                        description: post["description"],
                                        date: DateTime.parse(post["date"].toDate().toString()),
                                        authorUID: 0,
                                        image: post["image"] ?? "",
                                        fileAttatchments: [
                                          for (String file in post["files"]) file
                                        ],
                                        dueDate: DateTime.parse(post["dueDate"].toDate().toString()),
                                        type: post["type"],
                                        subject: post["subject"])
                                ]);
                                mabData.posts.sort((a, b) => b.date.compareTo(a.date));
                                return ListView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    //MabData is misleading, it's actually both !!!!! (no way) (crazy right?)
                                    itemCount: mabData.posts.length,
                                    itemBuilder: (context, index) {
                                      MabPost post = mabData.posts[index];
                                      return isItemValid(post) ? ListItem(theme: theme, textTheme: textTheme, post: post) : const SizedBox();
                                    });
                              }),
                    ),
                  ]),
                ),
              ]);
            }),
          ),
        ));
  }
}

class NewEventModal extends StatefulWidget {
  const NewEventModal({super.key, required this.selectedSection});
  final int selectedSection;

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
      if (isLoading || success) {
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
      try {
        if (widget.selectedSection == 0) {
          await addNewMABEvent(title, description, type, subject, dueDate!, attatchements, image, Provider.of<AppState>(context, listen: false));
        } else {
          await addNewLACEvent(title, description, type, subject, dueDate!, attatchements, image, Provider.of<AppState>(context, listen: false));
        }
      } catch (e) {
        setState(() {
          error = "Error adding event $e";
          isLoading = false;
        });
        return;
      }
//* Set loading to false
      setState(() {
        isLoading = false;
        success = true;
      });

      await Future.delayed(const Duration(seconds: 1));
      if (!context.mounted) return;
      Navigator.pop(context);
    }

    return Dialog(
      surfaceTintColor: Colors.transparent,
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
                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.onBackground, width: 1),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
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
                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.onBackground, width: 1),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
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
                        fieldLabelText: Text("Due date:", style: TextStyle(color: theme.onBackground)).data,
                        builder: (context, child) => Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: theme.secondary,
                                  onPrimary: theme.onBackground,
                                  surface: theme.background,
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
                  child: Text(dueDate == null ? "Select a date" : DateFormat("dd/MM/yyyy").format(dueDate!.toDate()), style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
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
                    },
                    items: List.generate(getSubjects.length, (index) => DropdownMenuItem(value: index, child: Text(getSubjects[index], textAlign: TextAlign.center, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)))),
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
                        child: Text("Announcement", textAlign: TextAlign.center, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("Task", textAlign: TextAlign.center, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
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
                      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 500, maxHeight: 500);
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
                      style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
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
                  image: DecorationImage(image: FileImage(image!), fit: BoxFit.cover),
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
                      final pickedFiles = await ImagePicker().pickMultipleMedia(imageQuality: 50, maxWidth: 500, maxHeight: 500);
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
                      style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            //* Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => addNewEvent(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                //* Confirm button text : if loading, show loading indicator, if not loading and there is error, show error text, else show confirm text
                child: isLoading
                    ? SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: theme.onBackground))
                    : !isLoading && error != ""
                        ? Text(error, style: textTheme.displaySmall!.copyWith(color: theme.error))
                        : success
                            ? Icon(Icons.check, color: theme.onBackground)
                            : Text("Confirm", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
              ),
            )
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
    required this.post,
  });

  final ColorScheme theme;
  final TextTheme textTheme;
  final MabPost post;

  @override
  Widget build(BuildContext context) {
    String title = post.title;
    String description = post.description;
    String image = post.image;
    List<String> attatchements = post.fileAttatchments;
    int type = post.type;
    DateTime due = post.dueDate;
    var theme = Theme.of(context).colorScheme;
    var ctheme = getThemeFromTheme(theme);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: StyledTouchableContainer(
        theme: ctheme,
        onPressed: () => showDialog(context: context, builder: (context) => MABModal(title: title, description: description, image: image, attatchements: attatchements, date: due, posterUID: post.authorUID)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                        colors: post.type == 1
                            ? [
                                const Color(0xFF21B38F),
                                const Color(0xFF19C17E),
                              ]
                            : [
                                const Color(0xFF723EDC),
                                const Color(0xFF683BDB)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Icon(
                  post.type == 1 ? Icons.campaign_rounded : Icons.task_rounded,
                  color: theme.onBackground,
                  size: 32,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    //* Show in days until due unless it's more than 7 days away
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          due.difference(DateTime.now()).inDays > 7 ? DateFormat("dd/MM/yyyy").format(due) : "${due.difference(DateTime.now()).inDays} days",
                          style: textTheme.displaySmall!.copyWith(color: due.difference(DateTime.now()).inDays < 3 ? Colors.red : theme.onBackground.withOpacity(0.5)),
                        ),
                        Text(
                          subjects[post.subject]!,
                          style: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//Mab Modal
class MABModal extends StatefulWidget {
  const MABModal({super.key, required this.title, required this.description, this.image, required this.attatchements, required this.date, required this.posterUID});
  final String title, description;
  final List<String> attatchements;
  final String? image;
  final DateTime date;
  final int posterUID;

  @override
  State<MABModal> createState() => _MABModalState();
}

class _MABModalState extends State<MABModal> with TickerProviderStateMixin {
  String extractFilenameFromUrl(String url) {
    RegExp regExp = RegExp(r'(?<=cache%2F)[^?]+');
    Match? match = regExp.firstMatch(url);

    if (match != null) {
      return match.group(0)!;
    } else {
      return ""; // Return an empty string or handle the absence of a match as needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);

    void downloadFile(String downloadURL) async {
      //* Put download url link to cliboard and show snackbar
      await Clipboard.setData(ClipboardData(text: downloadURL));

      // //* Open download link in browser
      //ignore: deprecated_member_use
      await launch(downloadURL);
    }

    return Dialog.fullscreen(
      // showDragHandle: true,
      // dragHandleColor: theme.secondary,
      // constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height * 0.9),
      // enableDrag: true,
      // animationController: BottomSheet.createAnimationController(this),
      backgroundColor: theme.background,
      // onClosing: () {},
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              //Main header
              Row(
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      StyledIconButton(theme: ctheme, onPressed: () => Navigator.pop(context), icon: Icons.close),
                    ],
                  )),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        child: Text(
                          widget.title,
                          style: textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container())
                ],
              ),
              const SizedBox(height: 16),
              //Sub header
              Text(widget.description, style: textTheme.displaySmall),
              const SizedBox(height: 16),
              //Image
              widget.image?.isEmpty ?? false
                  ? StyledContainer(
                      theme: ctheme,
                      height: 250,
                      width: 250,
                      child: Text(
                        "No image",
                        style: textTheme.displaySmall,
                      ),
                    )
                  : SizedBox(
                      height: 250,
                      width: 250,
                      child: InkWell(
                        splashColor: widget.image == null || widget.image == "" ? Colors.transparent : theme.secondary.withOpacity(0.5),
                        highlightColor: widget.image == null || widget.image == "" ? Colors.transparent : theme.secondary.withOpacity(0.5),
                        onTap: () => {
                          if (widget.image != null && widget.image != "")
                            showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      surfaceTintColor: Colors.transparent,
                                      child: SizedBox(
                                          height: 300,
                                          child: PhotoView(
                                            backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                                            imageProvider: NetworkImage(widget.image!),
                                          )),
                                    ))
                        },
                        child: Center(
                          child: widget.image == null || widget.image == ""
                              ? Text(
                                  "No Image",
                                  style: textTheme.displaySmall,
                                )
                              : Image.network(widget.image!),
                        ),
                      ),
                    ),

              const SizedBox(height: 8),
              //* Date of post and user
              Row(
                children: [
                  Text(
                    "Posted on ${DateFormat("dd/MM/yyyy").format(widget.date)} by ${widget.posterUID}",
                    style: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              //Attatchements (row here to align text to the left)
              Row(
                children: [
                  Text(
                    "${widget.attatchements.length} Attatchements",
                    style: textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: widget.attatchements.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: StyledElevatedButton(
                          theme: ctheme,
                          onPressed: () => {
                            downloadFile(widget.attatchements[index]),
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Replace with actual name
                                Expanded(child: Text(extractFilenameFromUrl(widget.attatchements[index]), style: textTheme.displaySmall)),
                                const SizedBox(
                                  width: 8,
                                ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
