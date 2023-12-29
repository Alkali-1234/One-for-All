import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/screens/thread_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';
import '../main.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> with TickerProviderStateMixin {
  // final _tabItems = ["Community", "My Posts"];
  //! Temp solution
  final List<Tab> _tabs = const [
    // Tab(
    //   text: "All",
    // ),
    Tab(
      text: "Community",
    ),
    Tab(
      text: "Local",
    )
  ];

  late TabController _tabController;

  // String searchQuery = "";
  // List<dynamic> filters = [
  //   0,
  //   0,
  //   0,
  // ];

  //Will be initialized later
  List<dynamic> tags = [
    "All"
  ];

  void setTags(List<dynamic> tags) {
    this.tags = tags;
  }

  void addTag(String tag) {
    tags.add(tag);
  }

  int selectedTag = 0;

  // void initializeTags() {
  //   //Get tags from database
  //   //! Temporary
  //   tags = [
  //     "All",
  //     "Tag1",
  //     "Tag2",
  //     "Tag3"
  //   ];
  // }

  // bool validateItem(List<dynamic> tags, String title, String description, DateTime dateCreated, DateTime lastActive) {
  //   bool isValid = true;
  //   //Check if item has selected tag
  //   if (selectedTag != 0) {
  //     if (tags.contains(tags[filters[0]]) == false) {
  //       isValid = false;
  //     }
  //   }
  //   if (isValid == false) return false;
  //   //Check if item contains search query
  //   if (searchQuery != "") {
  //     if (title.contains(searchQuery) == false || description.contains(searchQuery) == false) {
  //       isValid = false;
  //     }
  //   }
  //   if (isValid == false) return false;
  //   //Check if item is within date range
  //   if (filters[1] != 0) {
  //     switch (filters[1]) {
  //       case 1:
  //         if (dateCreated.day != DateTime.now().day) {
  //           isValid = false;
  //         }
  //         break;
  //       case 2:
  //         if (dateCreated.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
  //           isValid = false;
  //         }
  //         break;
  //       case 3:
  //         if (dateCreated.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
  //           isValid = false;
  //         }
  //         break;
  //       case 4:
  //         if (dateCreated.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
  //           isValid = false;
  //         }
  //         break;
  //       default:
  //         isValid = false;
  //     }
  //   }
  //   if (isValid == false) return false;
  //   //Check if item is within date range
  //   if (filters[2] != 0) {
  //     switch (filters[2]) {
  //       case 1:
  //         if (lastActive.day != DateTime.now().day) {
  //           isValid = false;
  //         }
  //         break;
  //       case 2:
  //         if (lastActive.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
  //           isValid = false;
  //         }
  //         break;
  //       case 3:
  //         if (lastActive.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
  //           isValid = false;
  //         }
  //         break;
  //       case 4:
  //         if (lastActive.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
  //           isValid = false;
  //         }
  //         break;
  //       default:
  //         isValid = false;
  //     }
  //   }
  //   return isValid;
  // }

  int selectedTab = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTab = _tabController.index + 1;
      });
    });
    var appState = context.read<AppState>();
    communityForumStream = appState.getCurrentUser.assignedCommunity != "0" ? FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("forum").snapshots() : const Stream.empty();
    localForumStream = appState.getCurrentUser.assignedSection != "0" ? FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("sections").doc(appState.getCurrentUser.assignedSection ?? "").collection("forum").snapshots() : const Stream.empty();
  }

  //* Strams
  late Stream communityForumStream;
  late Stream localForumStream;

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    var tm = appState.currentUserSelectedTheme.colorScheme;
    var ttm = appState.currentUserSelectedTheme.textTheme;
    return Container(
      decoration: appState.currentUserSelectedTheme == defaultBlueTheme ? const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/purpwallpaper 2.png"), fit: BoxFit.cover)) : BoxDecoration(color: tm.background),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Forums",
            style: ttm.displayMedium,
          ),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: tm.onBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: tm.onBackground,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => NewThreadWidget(
                      tags: tags,
                    ));
          },
          backgroundColor: tm.secondary,
          foregroundColor: tm.onPrimary,
          child: Icon(
            Icons.add,
            color: tm.onBackground,
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Column(
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
              ),
              const SizedBox(
                height: 10,
              ),
              // //Search bar
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextField(
              //     style: ttm.displaySmall,
              //     onChanged: (value) => setState(() {
              //       searchQuery = value;
              //     }),
              //     cursorColor: tm.onBackground,
              //     decoration: InputDecoration(
              //         hintText: "Search",
              //         hintStyle: ttm.displaySmall,
              //         fillColor: tm.primary,
              //         prefixIcon: Icon(
              //           Icons.search,
              //           color: tm.onBackground,
              //         ),
              //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.transparent, width: 0))),
              //   ),
              // ),
              //Filters
              //Tags, Date Creation, Date Last Active
              Expanded(
                child: StreamBuilder(
                    // stream: FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("forum").snapshots(),
                    stream: selectedTab == 1 ? communityForumStream : localForumStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return Center(child: Text("Error loading data ${snapshot.error}"));
                      if (snapshot.hasData == false) return Center(child: Text("No data", style: ttm.displaySmall));
                      return StreamBody(
                          textTheme: ttm,
                          resetTags: () => setTags([
                                "All"
                              ]),
                          snapshot: snapshot,
                          addTag: (tag) => addTag(tag),
                          target: selectedTab == 0
                              ? "all"
                              : selectedTab == 1
                                  ? "community"
                                  : "local");
                    }),
              )
            ]),
      ),
    );
  }
}

class StreamBody extends StatefulWidget {
  const StreamBody({super.key, required this.snapshot, required this.addTag, required this.target, required this.resetTags, required this.textTheme});
  final AsyncSnapshot snapshot;
  final Function addTag;
  final String target;
  final Function resetTags;
  final TextTheme textTheme;

  @override
  State<StreamBody> createState() => _StreamBodyState();
}

class _StreamBodyState extends State<StreamBody> {
  // final List<Tab> _tabs = const [
  //   Tab(
  //     text: "All",
  //   ),
  //   Tab(
  //     text: "Community",
  //   ),
  //   Tab(
  //     text: "Local",
  //   )
  // ];

  // late TabController _tabController;

  String searchQuery = "";
  List<dynamic> filters = [
    0,
    0,
    0,
  ];

  //Will be initialized later

  int selectedTag = 0;

  // void initializeTags() {
  //   //Get tags from database
  //   //! Temporary
  //   tags = [
  //     "All",
  //     "Tag1",
  //     "Tag2",
  //     "Tag3"
  //   ];
  // }

  bool validateItem(List<dynamic> tags, String title, String description, DateTime dateCreated, DateTime lastActive) {
    bool isValid = true;
    //Check if item has selected tag
    if (filters[0] != 0 && filters[0] != 1) {
      if (tags.contains(this.tags[filters[0] - 1]) == false) {
        isValid = false;
      }
    }
    if (isValid == false) return false;
    //Check if item contains search query
    if (searchQuery != "") {
      if (title.contains(searchQuery) == false && description.contains(searchQuery) == false) {
        isValid = false;
      }
    }
    if (isValid == false) return false;
    //Check if item is within date range
    if (filters[1] != 0 && filters[1] != 1) {
      switch (filters[1]) {
        case 2:
          if (dateCreated.day != DateTime.now().day) {
            isValid = false;
          }
          break;
        case 3:
          if (dateCreated.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
            isValid = false;
          }
          break;
        case 4:
          if (dateCreated.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
            isValid = false;
          }
          break;
        default:
          isValid = false;
      }
    }
    if (isValid == false) return false;
    //Check if item is within date range
    if (filters[2] != 0 && filters[2] != 1) {
      switch (filters[2]) {
        case 2:
          if (lastActive.day != DateTime.now().day) {
            isValid = false;
          }
          break;
        case 3:
          if (lastActive.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
            isValid = false;
          }
          break;
        case 4:
          if (lastActive.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
            isValid = false;
          }
          break;
        default:
          isValid = false;
      }
    }
    return isValid;
  }

  @override
  void initState() {
    super.initState();
    getTags();
    for (var i = 0; i < tags.length; i++) {
      dropdownItems.add(DropdownMenuItem(
        value: i + 1,
        child: Text(
          tags[i],
          style: widget.textTheme.displaySmall,
        ),
      ));
    }
  }

  List<dynamic> tags = [
    "All"
  ];

  void getTags() {
    tags = [
      "All"
    ];
    widget.resetTags();
    for (var item in widget.snapshot.data.docs) {
      for (var tag in item["tags"]) {
        if (tags.contains(tag) == false) {
          tags.add(tag);
          widget.addTag(tag);
        }
      }
    }
    debugPrint(tags.toString());
  }

  List<DropdownMenuItem> dropdownItems = [];

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    var tm = appState.currentUserSelectedTheme.colorScheme;
    var ttm = appState.currentUserSelectedTheme.textTheme;
    AsyncSnapshot snapshot = widget.snapshot;

    return Column(
      children: [
        //Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) => setState(() {
              searchQuery = value;
            }),
            cursorColor: tm.onBackground,
            style: ttm.displayMedium!.copyWith(color: tm.onPrimary, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                filled: true,
                fillColor: tm.primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                hintText: 'Search',
                suffixIcon: Icon(Icons.search, color: tm.onPrimary, size: 50),
                hintStyle: ttm.displayMedium!.copyWith(color: tm.onPrimary.withOpacity(0.25), fontWeight: FontWeight.bold)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Tags
              //Gets values from tags list
              Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: DropdownButton(
                      hint: Text(
                        "Tags",
                        style: ttm.displaySmall,
                      ),
                      value: filters[0] == 0 ? null : filters[0],
                      onChanged: (value) {
                        setState(() {
                          filters[0] = value;
                        });
                      },
                      items: dropdownItems,
                    ),
                  )),
              const SizedBox(
                width: 5,
              ),
              //Date Creation
              Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: DropdownButton(
                      hint: Text(
                        "Date Creation",
                        style: ttm.displaySmall,
                      ),
                      value: filters[1] == 0 ? null : filters[1],
                      onChanged: (value) {
                        setState(() {
                          filters[1] = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            "All",
                            style: ttm.displaySmall,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(
                            "Today",
                            style: ttm.displaySmall,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(
                            "Last 7 Days",
                            style: ttm.displaySmall,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text(
                            "Last 30 Days",
                            style: ttm.displaySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(
                width: 5,
              ),
              //Date Last Active
              Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: DropdownButton(
                      hint: Text(
                        "Date Last Active",
                        style: ttm.displaySmall,
                      ),
                      value: filters[2] == 0 ? null : filters[2],
                      onChanged: (value) {
                        setState(() {
                          filters[2] = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            "All",
                            style: ttm.displaySmall,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(
                            "Today",
                            style: ttm.displaySmall,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(
                            "Last 7 Days",
                            style: ttm.displaySmall,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text(
                            "Last 30 Days",
                            style: ttm.displaySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
                // stream: FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("forum").snapshots(),
                builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Text("Loading...", style: ttm.displaySmall),
                );
              }
              if (!snapshot.hasData) {
                return Center(
                  child: Text("No Data", style: ttm.displaySmall),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}", style: ttm.displaySmall),
                );
              }
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    Map<String, dynamic>? data = snapshot.data?.docs[index].data();
                    if (data == null) {
                      return Center(
                        child: Text("No Data.. for some reason i can't explain", style: ttm.displaySmall),
                      );
                    }
                    if (validateItem(data["tags"], data["title"], data["description"], data["creationDate"].toDate(), data["lastActive"].toDate()) != true) {
                      return Container();
                    }
                    tags.addAll(data["tags"]);
                    return Container(
                      decoration: BoxDecoration(
                        border: index != snapshot.data!.docs.length - 1 ? Border(bottom: BorderSide(color: tm.onBackground.withOpacity(0.5))) : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                        title: Text(data["title"], style: ttm.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(data["description"], style: ttm.displaySmall),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${data["replies"].length} Replies",
                              style: ttm.displaySmall,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: tm.onBackground.withOpacity(0.5),
                            )
                          ],
                        ),
                        // style: ElevatedButton.styleFrom(
                        //   backgroundColor: Colors.transparent,
                        //   elevation: 0,
                        //   shadowColor: Colors.transparent,
                        //   surfaceTintColor: Colors.transparent,
                        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        // ),
                        onTap: () async {
                          late bool subscribed;
                          final prefs = await SharedPreferences.getInstance();
                          if (prefs.containsKey("forum_${appState.getCurrentUser.assignedCommunity}_${snapshot.data!.docs[index].id}")) {
                            subscribed = true;
                          } else {
                            subscribed = false;
                          }

                          if (!mounted) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ThreadScreen(
                                        threadID: snapshot.data!.docs[index].id,
                                        subscribed: subscribed,
                                        target: widget.target,
                                      )));
                        },
                      ),
                    );
                  });
            }),
          ),
        ),
      ],
    );
  }
}

class NewThreadWidget extends StatefulWidget {
  const NewThreadWidget({super.key, required this.tags});
  final List<dynamic> tags;

  @override
  State<NewThreadWidget> createState() => _NewThreadWidgetState();
}

class _NewThreadWidgetState extends State<NewThreadWidget> {
  List<String> tags = [];

  bool addingIcon = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  void createThread(AppState appState) async {
    if (isLoading) return;
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title cannot be empty")));
      return;
    }
    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Description cannot be empty")));
      return;
    }
    if (target == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a target")));
      return;
    }

    setState(() {
      isLoading = true;
    });
    if (target.toLowerCase() == "community") {
      FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("forum").add({
        "title": titleController.text,
        "description": descriptionController.text,
        "tags": tags,
        "creationDate": DateTime.now(),
        "lastActive": DateTime.now(),
        "replies": [],
        "author": appState.getCurrentUser.username,
        "authorPFP": appState.getCurrentUser.profilePicture,
        "authorUID": FirebaseAuth.instance.currentUser!.uid,
      }).then((value) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("forum_${appState.getCurrentUser.assignedCommunity}_${value.id}", true);
        FirebaseMessaging.instance.subscribeToTopic("forum_${appState.getCurrentUser.assignedCommunity}_${value.id}");

        if (!mounted) return;
        Navigator.pop(context);
      });
    } else {
      if (appState.getCurrentUser.assignedSection == null) return;
      FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("sections").doc(appState.getCurrentUser.assignedSection).collection("forum").add({
        "title": titleController.text,
        "description": descriptionController.text,
        "tags": tags,
        "creationDate": DateTime.now(),
        "lastActive": DateTime.now(),
        "replies": [],
        "author": appState.getCurrentUser.username,
        "authorPFP": appState.getCurrentUser.profilePicture,
        "authorUID": FirebaseAuth.instance.currentUser!.uid,
      }).then((value) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("forum_${appState.getCurrentUser.assignedCommunity}_${value.id}", true);
        FirebaseMessaging.instance.subscribeToTopic("forum_${appState.getCurrentUser.assignedCommunity}_${value.id}");

        if (!mounted) return;
        Navigator.pop(context);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  String target = "";

  TextEditingController tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    var tm = appState.currentUserSelectedTheme.colorScheme;
    var ttm = appState.currentUserSelectedTheme.textTheme;
    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: tm.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("New Thread", style: ttm.displayMedium),
            const SizedBox(height: 10),
            //Select target
            Row(
              children: [
                Text("Target: ", style: ttm.displaySmall),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: Text("Select Target", style: ttm.displaySmall),
                  value: target == "" ? null : target,
                  onChanged: (String? newValue) {
                    setState(() {
                      target = newValue!;
                    });
                  },
                  items: <String>[
                    "Community",
                    "Local"
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: ttm.displaySmall),
                    );
                  }).toList(),
                ),
              ],
            ),
            TextField(
              controller: titleController,
              style: ttm.displaySmall,
              cursorColor: tm.onBackground,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                hintText: "Title",
                hintStyle: ttm.displaySmall,
                fillColor: tm.primary,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: tm.onBackground)),
              ),
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              style: ttm.displaySmall,
              cursorColor: tm.onBackground,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                hintText: "Description",
                hintStyle: ttm.displaySmall,
                fillColor: tm.primary,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: tm.onBackground)),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              alignment: WrapAlignment.start,
              children: [
                for (var tag in tags)
                  Chip(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                    avatar: Icon(Icons.tag, color: tm.onBackground),
                    label: Text(tag, style: ttm.displaySmall),
                    backgroundColor: tm.primary,
                    labelStyle: ttm.displaySmall,
                  ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      addingIcon = true;
                    });
                  },
                  child: Chip(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                    avatar: Icon(Icons.add, color: tm.onBackground),
                    label: Text("Add Tag", style: ttm.displaySmall),
                    backgroundColor: tm.secondary,
                    labelStyle: ttm.displaySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            //Add icon
            addingIcon
                ? Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tm.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        //Search
                        TextField(
                          onChanged: (value) => setState(() {}),
                          controller: tagController,
                          cursorColor: tm.onBackground,
                          style: ttm.displaySmall,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            hintText: "Search or create tag",
                            hintStyle: ttm.displaySmall,
                            fillColor: tm.primary,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: tm.onBackground)),
                          ),
                        ),
                        //Create new tag button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (tagController.text == "") return;
                              if (tags.contains(tagController.text)) return;
                              setState(() {
                                tags.add(tagController.text);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(color: tm.tertiary),
                              backgroundColor: tm.secondary,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              "Create new tag",
                              style: ttm.displaySmall,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              alignment: WrapAlignment.start,
                              children: [
                                for (var tag in widget.tags.where((element) => element.toLowerCase().contains(tagController.text)))
                                  GestureDetector(
                                    onTap: () {
                                      if (tags.contains(tag)) return;

                                      setState(() {
                                        tags.add(tag);
                                      });
                                    },
                                    child: Chip(
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                                      avatar: Icon(Icons.tag, color: tm.onBackground),
                                      label: Text(tag, style: ttm.displaySmall),
                                      backgroundColor: tm.primary,
                                      labelStyle: ttm.displaySmall,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            const SizedBox(height: 10),
            //Create and cancel buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: tm.tertiary),
                      backgroundColor: tm.secondary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel", style: ttm.displaySmall)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: tm.tertiary),
                      backgroundColor: tm.secondary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => createThread(appState),
                    child: isLoading ? Text("Creating...", style: ttm.displaySmall) : Text("Create", style: ttm.displaySmall)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
