import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
// import 'package:oneforall/service/firebase_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key, required this.threadID, required this.subscribed, required this.target});
  final String threadID;
  final bool subscribed;
  final String target;

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  String messageQuery = "";
  bool isLoading = false;
  void sendMessage(AppState appState, ColorScheme tm) async {
    if (messageQuery != "") {
      setState(() {
        isLoading = true;
      });
      try {
        if (widget.target == "community") {
          await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("forum").doc(widget.threadID).update(
            {
              "replies": FieldValue.arrayUnion([
                {
                  "message": messageQuery,
                  "author": appState.getCurrentUser.username,
                  "authorpfp": appState.getCurrentUser.profilePicture,
                  "time": Timestamp.now(),
                }
              ])
            },
          );
        }
        if (widget.target == "local") {
          await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("sections").doc(appState.getCurrentUser.assignedSection).collection("forum").doc(widget.threadID).update(
            {
              "replies": FieldValue.arrayUnion([
                {
                  "message": messageQuery,
                  "author": appState.getCurrentUser.username,
                  "authorpfp": appState.getCurrentUser.profilePicture,
                  "time": Timestamp.now(),
                }
              ])
            },
          );
        }
      } on Exception catch (e) {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: TextStyle(color: tm.onBackground)),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        isLoading = false;
        messageQuery = "";
      });
      _messageQueryController.clear();
    }
  }

  final TextEditingController _messageQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    var tm = appState.currentUserSelectedTheme.colorScheme;
    var ttm = appState.currentUserSelectedTheme.textTheme;

    return Container(
      decoration: appState.currentUserSelectedTheme == defaultBlueTheme
          ? const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/purpwallpaper 2.png'),
                fit: BoxFit.cover,
              ),
            )
          : BoxDecoration(color: tm.background),
      child: StreamBuilder(
          stream: widget.target == "community" ? FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("forum").doc(widget.threadID).snapshots() : FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("sections").doc(appState.getCurrentUser.assignedSection).collection("forum").doc(widget.threadID).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text('Loading...', style: ttm.displayMedium),
                ),
                body: Center(
                  child: Text('Loading...', style: ttm.displaySmall),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.exists == false) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text('No data', style: ttm.displayMedium),
                ),
                body: Center(
                  child: Text('No data', style: ttm.displaySmall),
                ),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Error', style: ttm.displayMedium),
                ),
                body: Center(
                  child: Text('Error', style: ttm.displaySmall),
                ),
              );
            }
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: tm.background,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: tm.onBackground),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text('Thread ${snapshot.data!.id}', style: ttm.displayMedium),
              ),
              body: ThreadBody(snapshot: snapshot, appState: appState, tm: tm, ttm: ttm, threadID: widget.threadID, subscribed: widget.subscribed),
            );
          }),
    );
  }
}

class ThreadBody extends StatefulWidget {
  const ThreadBody({super.key, required this.snapshot, required this.appState, required this.tm, required this.ttm, required this.threadID, required this.subscribed});
  final AsyncSnapshot snapshot;
  final AppState appState;
  final ColorScheme tm;
  final TextTheme ttm;
  final String threadID;
  final bool subscribed;

  @override
  State<ThreadBody> createState() => _ThreadBodyState();
}

class _ThreadBodyState extends State<ThreadBody> {
  String messageQuery = "";
  bool isLoading = false;
  void sendMessage(AppState appState, ColorScheme tm) async {
    if (messageQuery != "") {
      setState(() {
        isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection("communities").doc(appState.getCurrentUser.assignedCommunity).collection("forum").doc(widget.threadID).update(
          {
            "replies": FieldValue.arrayUnion([
              {
                "message": messageQuery,
                "author": appState.getCurrentUser.username,
                "authorpfp": appState.getCurrentUser.profilePicture,
                "time": Timestamp.now(),
              }
            ])
          },
        );
      } on Exception catch (e) {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: TextStyle(color: tm.onBackground)),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
      //Send notification
      // sendNotification("${appState.getCurrentUser.username} sent a new message", messageQuery, {}, "forum_${appState.getCurrentUser.assignedCommunity}_${widget.threadID}");
      setState(() {
        isLoading = false;
        messageQuery = "";
      });
      _messageQueryController.clear();
    }
  }

  final TextEditingController _messageQueryController = TextEditingController();

  late bool subscribed = false;

  void toggleSubscription(AppState appState) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("forum_${appState.getCurrentUser.assignedCommunity}_${widget.threadID}")) {
      FirebaseMessaging.instance.unsubscribeFromTopic("forum_${appState.getCurrentUser.assignedCommunity}_${widget.threadID}");
      prefs.remove("forum_${appState.getCurrentUser.assignedCommunity}_${widget.threadID}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unsubscribed from thread', style: TextStyle(color: Colors.white)),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      FirebaseMessaging.instance.subscribeToTopic("forum_${appState.getCurrentUser.assignedCommunity}_${widget.threadID}");
      prefs.setBool("forum_${appState.getCurrentUser.assignedCommunity}_${widget.threadID}", true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscribed to thread', style: TextStyle(color: Colors.white)),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
    setState(() {
      subscribed = !subscribed;
    });
  }

  @override
  void initState() {
    subscribed = widget.subscribed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncSnapshot snapshot = widget.snapshot;
    final AppState appState = widget.appState;
    final ColorScheme tm = widget.tm;
    final TextTheme ttm = widget.ttm;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(snapshot.data!['title'], style: ttm.displayMedium),
              subscribed
                  ? IconButton(
                      onPressed: () => toggleSubscription(appState),
                      icon: Icon(
                        Icons.notifications,
                        color: tm.onBackground,
                      ))
                  : IconButton(onPressed: () => toggleSubscription(appState), icon: Icon(Icons.notifications_none, color: tm.onBackground)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(snapshot.data!['description'], style: ttm.displaySmall),
            ],
          ),
          const SizedBox(height: 5),
          //Tags
          Row(children: [
            for (var i = 0; i < snapshot.data!['tags'].length; i++) ...[
              const SizedBox(width: 5),
              Chip(side: BorderSide(color: tm.secondary), label: Text("#${snapshot.data!['tags'][0]}", style: ttm.displaySmall), backgroundColor: tm.primaryContainer),
            ]
          ]),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  //Pfp
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(snapshot.data!['authorPFP']),
                  ),
                  const SizedBox(width: 5),
                  Text("${snapshot.data!['author']}", style: ttm.displaySmall),
                ],
              ),
              Text(snapshot.data!['creationDate'].toDate().toString(), style: ttm.displaySmall!.copyWith(color: tm.onBackground.withOpacity(0.25))),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Icon(Icons.forum_rounded, color: tm.onBackground),
              const SizedBox(width: 5),
              Text("Discussion", style: ttm.displayMedium),
            ],
          ),
          const SizedBox(height: 10),
          //Send a message
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 7,
                child: SizedBox(
                  width: double.infinity,
                  child: TextField(
                    style: ttm.displaySmall,
                    cursorColor: tm.onBackground,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      hintText: 'Send a message',
                      hintStyle: ttm.displaySmall!.copyWith(color: tm.onBackground.withOpacity(0.25)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: tm.onBackground.withOpacity(0.1),
                    ),
                    onChanged: (value) => messageQuery = value,
                    onSubmitted: (value) => sendMessage(appState, tm),
                    controller: _messageQueryController,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: isLoading
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: tm.onBackground))
                    : IconButton(
                        onPressed: () {
                          sendMessage(appState, tm);
                        },
                        icon: Icon(Icons.send_rounded, color: tm.onBackground.withOpacity(0.25)),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          //Discussion
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                  shape: Border.symmetric(horizontal: BorderSide(color: tm.onBackground.withOpacity(0.25), width: 0.5)),
                  title: Text(snapshot.data!['replies'][snapshot.data!['replies'].length - (index + 1)]['author'], style: ttm.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(snapshot.data!['replies'][snapshot.data!['replies'].length - (index + 1)]['message'], style: ttm.displaySmall),
                  leading: CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(snapshot.data!['replies'][snapshot.data!['replies'].length - (index + 1)]['authorpfp']),
                  ),
                  trailing: Text("${DateTime.now().difference(snapshot.data!['replies'][snapshot.data!['replies'].length - (index + 1)]['time'].toDate()).inMinutes} Minutes ago", style: ttm.displaySmall!.copyWith(color: tm.onBackground.withOpacity(0.25))));
            },
            itemCount: snapshot.data!['replies'].length,
            physics: const BouncingScrollPhysics(),
          ))
        ],
      ),
    );
  }
}
