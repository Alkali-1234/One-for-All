import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:oneforall/data/community_data.dart';
import 'package:provider/provider.dart';
import '../service/community_service.dart';

import '../main.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  Map<String, dynamic> localCommunityData = {};

  void initializeCommunityData(AppState appState) async {
    if (appState.getCurrentUser.assignedCommunity == null) {
      return;
    }

    if (appState.communityData.isNotEmpty) {
      setState(() {
        localCommunityData = appState.communityData;
      });
      return;
    }

    //* Get community data from database
    await getDocument("communities", appState.getCurrentUser.assignedCommunity!)
        .then((value) async {
      value is DocumentSnapshot;
      appState.setCommunityData(value.data()!);
      appState.communityData.addEntries([
        MapEntry("id", value.id),
      ]);
      //* Add section data from database
      //communities/{communityId}/sections/{sectionId}
      // await value.reference.collection("sections").get().then((value) {
      //   value.docs.forEach((element) {
      //     appState.communityData["_sections"].add(element.data());
      //     appState.communityData["_sections"].last.addEntries([
      //       MapEntry("id", element.id),
      //     ]);
      //   });
      // });
      QuerySnapshot sectionData = await FirebaseFirestore.instance
          .collection("communities")
          .doc(appState.getCurrentUser.assignedCommunity)
          .collection("sections")
          .get();
      //Add section data to community data, and also ids
      appState.communityData.addEntries([
        MapEntry("_sections", sectionData.docs.map((e) => e.data()).toList()),
      ]);
      //* Add ids
      appState.communityData.update("_sections", (value) {
        List<dynamic> temp = value;
        for (var i = 0; i < temp.length; i++) {
          temp[i].addEntries([
            MapEntry("id", sectionData.docs[i].id),
          ]);
        }

        return temp;
      });

      setState(() {
        localCommunityData = value.data()!;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initializeCommunityData(context.read<AppState>());
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var theme = appState.currentUserSelectedTheme.colorScheme;
    var textTheme = appState.currentUserSelectedTheme.textTheme;
    return Scaffold(
      backgroundColor: appState.currentUserSelectedTheme.colorScheme.background,
      body: SafeArea(child: Builder(builder: (context) {
        if (appState.communityData.isEmpty) {
          return Center(
              child: Text(
            "Loading...",
            style: textTheme.displaySmall,
          ));
        }

        return Column(
          children: [
            Stack(children: [
              //Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image:
                            NetworkImage(appState.communityData["image"] ?? ""),
                        fit: BoxFit.cover)),
              ),
              //Gradient
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      theme.background.withOpacity(0),
                      theme.background.withOpacity(0.5),
                      theme.background.withOpacity(1),
                    ])),
              ),
              // Back button and settings button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Back button
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.onBackground,
                        )),
                    //Settings button
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => const CommunitySettingsModal());
                        },
                        icon: Icon(
                          Icons.settings,
                          color: theme.onBackground,
                        )),
                  ],
                ),
              ),
            ]),
            //Community Name
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    appState.communityData["name"] ?? "",
                    style: textTheme.displayLarge,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    appState.communityData["subName"] ?? "",
                    style: textTheme.displaySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            //ID
            ListTile(
              leading: Icon(
                Icons.qr_code,
                color: theme.onBackground,
              ),
              title: Text(
                "ID",
                style: textTheme.displaySmall,
              ),
              trailing: Text(
                appState.communityData["id"] ?? "",
                style: textTheme.displaySmall,
              ),
            ),
            //Members
            ListTile(
              leading: Icon(
                Icons.people,
                color: theme.onBackground,
              ),
              title: Text(
                "Members",
                style: textTheme.displaySmall,
              ),
              trailing: Text(
                appState.communityData["members"]?.length.toString() ?? "0",
                style: textTheme.displaySmall,
              ),
            ),
            //Sections
            ListTile(
              leading: Icon(
                Icons.list,
                color: theme.onBackground,
              ),
              title: Text(
                "Sections",
                style: textTheme.displaySmall,
              ),
              trailing: Text(
                appState.communityData["_sections"]?.length.toString() ?? "0",
                style: textTheme.displaySmall,
              ),
            ),
            Divider(color: theme.secondary),
            //* Sections list
            Expanded(
              child: ListView.builder(
                  itemCount: appState.communityData["_sections"]?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      splashColor: theme.secondary,
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => SelectedSection(
                                  sectionData: appState
                                      .communityData["_sections"][index],
                                ));
                      },
                      title: Text(
                        appState.communityData["_sections"][index]["name"] ??
                            "",
                        style: textTheme.displaySmall,
                      ),
                      trailing: Text(
                        "${appState.communityData["_sections"][index]["members"]?.length.toString() ?? "0"} Members",
                        style: textTheme.displaySmall,
                      ),
                    );
                  }),
            ),
          ],
        );
      })),
    );
  }
}

class CommunitySettingsModal extends StatefulWidget {
  const CommunitySettingsModal({super.key});

  @override
  State<CommunitySettingsModal> createState() => _CommunitySettingsModalState();
}

class _CommunitySettingsModalState extends State<CommunitySettingsModal> {
  @override
  Widget build(BuildContext context) {
    var theme = context.watch<AppState>().currentUserSelectedTheme.colorScheme;
    var textTheme =
        context.watch<AppState>().currentUserSelectedTheme.textTheme;
    return Dialog(
      backgroundColor: theme.background,
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 300,
        width: 300,
        child: Column(
          children: [
            Text("Community Settings", style: textTheme.displayMedium),
            //! Hardcoded
            Text("No permissions to edit this community",
                style: textTheme.displaySmall),
            //* Leave community
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: theme.error,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    child:
                        Text("Leave Community", style: textTheme.displaySmall)),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Close", style: textTheme.displaySmall)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SelectedSection extends StatefulWidget {
  const SelectedSection({super.key, required this.sectionData});
  final Map<String, dynamic> sectionData;

  @override
  State<SelectedSection> createState() => _SelectedSectionState();
}

class _SelectedSectionState extends State<SelectedSection> {
  String passwordQuery = "";
  String errorMessage = "";
  bool loading = false;

  Future attemptJoin(AppState appState) async {
    if (passwordQuery == "") {
      setState(() {
        errorMessage = "Please enter a password";
      });
    } else {
      setState(() {
        loading = true;
      });
    }
    if (passwordQuery != widget.sectionData["password"]) {
      setState(() {
        errorMessage = "Incorrect password";
        loading = false;
      });
      return;
    }
    await joinSection(appState.getCurrentUser.assignedCommunity!,
            widget.sectionData["id"])
        .catchError((e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
      return;
    });
    //* Update app state
    appState.communityData["_sections"][widget.sectionData["id"]]["members"]
        .add(appState.getCurrentUser.uid);
    setState(() {
      loading = false;
    });
    //* Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Joined section ${widget.sectionData["name"]}",
          style: const TextStyle(color: Colors.white),
        )));
  }

  @override
  Widget build(BuildContext context) {
    var theme = context.watch<AppState>().currentUserSelectedTheme.colorScheme;
    var textTheme =
        context.watch<AppState>().currentUserSelectedTheme.textTheme;
    return Dialog(
      backgroundColor: theme.background,
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 300,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text("Section ${widget.sectionData["name"]}",
                    style: textTheme.displayMedium),
                Text("Members: ${widget.sectionData["members"]?.length ?? 0}",
                    style: textTheme.displaySmall),
                //* password
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        passwordQuery = value;
                      });
                    },
                    style: textTheme.displaySmall,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0),
                      hintText: "Password",
                      errorText: errorMessage.isNotEmpty ? errorMessage : null,
                      filled: true,
                      fillColor: theme.primary,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.onBackground),
                          borderRadius: BorderRadius.circular(10)),
                      hintStyle: textTheme.displaySmall,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Close", style: textTheme.displaySmall)),
                TextButton(
                    onPressed: () => attemptJoin(context.read<AppState>()),
                    child: loading
                        ? CircularProgressIndicator(color: theme.onBackground)
                        : Text("Join", style: textTheme.displaySmall)),
              ],
            )
          ],
        ),
      ),
    );
  }
}