import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oneforall/components/base_shimmer.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/styles/styles.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class CommunitySettingsScreen extends StatefulWidget {
  const CommunitySettingsScreen({
    super.key,
    required this.communityID,
    required this.communityName,
    required this.communityDescription,
    required this.communityImage,
    required this.communityMembers,
    required this.communitySections,
  });
  final String communityID;
  final String communityName;
  final String communityDescription;
  final String communityImage;
  final List<String> communityMembers;
  final List<dynamic> communitySections;

  @override
  State<CommunitySettingsScreen> createState() => _CommunitySettingsScreenState();
}

class _CommunitySettingsScreenState extends State<CommunitySettingsScreen> {
  String communityNameQuery = "";
  String communityDescriptionQuery = "";
  String communityImageQuery = "";
  File? communityImageFile;

  List<String> commmunityMembersUsernames = [];
  Map<String, dynamic> communityMembersDataSnapshot = {};

  late final getUsernamesFunction = getUsernames();

  Future<List<String>> getUsernames() async {
    try {
      // final collectionGroup = FirebaseFirestore.instance.collection('users');
      // final query = collectionGroup.where(FieldPath.documentId, whereIn: widget.communityMembers);

      final querySnapshot = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: widget.communityMembers).get();

      final usernames = querySnapshot.docs.map((doc) => doc.get('username'));

      // Process the usernames here
      print(usernames);
      setState(() {
        commmunityMembersUsernames = List<String>.from(usernames);
        communityMembersDataSnapshot = querySnapshot.docs.asMap().map((key, value) => MapEntry(value.id, value.data()));
      });
      return List<String>.from(usernames);
    } on FirebaseException catch (e) {
      print('Error fetching usernames: $e');
      return [
        "error fetching usernames: $e"
      ];
    }
  }

  Future<void> saveChanges() async {
    try {
      if (communityNameQuery != widget.communityName) {
        await FirebaseFirestore.instance.collection('communities').doc(widget.communityID).update({
          "name": communityNameQuery
        });
      }
      if (communityDescriptionQuery != widget.communityDescription) {
        await FirebaseFirestore.instance.collection('communities').doc(widget.communityID).update({
          "description": communityDescriptionQuery
        });
      }
      if (communityImageFile != null) {
        //* Upload image to firebase storage
        String url = await FirebaseStorage.instance.ref('community_images/${widget.communityID}').putFile(communityImageFile!).then((taskSnapshot) => taskSnapshot.ref.getDownloadURL());
        await FirebaseFirestore.instance.collection('communities').doc(widget.communityID).update({
          "image": url
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Changes saved successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Error saving changes: $e",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    // var appState = Provider.of<AppState>(context);
    return Container(
      decoration: theme == defaultBlueTheme.colorScheme
          ? const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/purpwallpaper 2.png"),
                fit: BoxFit.cover,
              ),
            )
          : BoxDecoration(color: theme.background),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            foregroundColor: theme.onBackground,
            backgroundColor: Colors.transparent,
            title: Text('Admin Dashboard', style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    style: textTheme.displaySmall,
                    initialValue: widget.communityName,
                    onChanged: (value) => setState(() {
                      communityNameQuery = value;
                    }),
                    cursorColor: theme.onBackground,
                    decoration: TextInputStyle(theme: theme, textTheme: textTheme).getTextInputStyle(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: textTheme.displaySmall,
                    initialValue: widget.communityDescription,
                    onChanged: (value) => setState(() {
                      communityDescriptionQuery = value;
                    }),
                    cursorColor: theme.onBackground,
                    decoration: TextInputStyle(theme: theme, textTheme: textTheme).getTextInputStyle(),
                  ),
                  const SizedBox(height: 10),
                  //* Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Community Image", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                          onPressed: () async => communityImageFile = await ImagePicker().pickImage(source: ImageSource.gallery) as File,
                          icon: Icon(
                            Icons.add_a_photo,
                            color: theme.onBackground,
                          )),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 100,
                      child: Image.network(
                        widget.communityImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //* Members
                  Row(
                    children: [
                      Icon(Icons.people, color: theme.onBackground),
                      const SizedBox(width: 10),
                      Text("Members", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Expanded(
                      child: FutureBuilder(
                          future: getUsernamesFunction,
                          builder: (context, value) {
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: value.connectionState == ConnectionState.waiting ? 5 : commmunityMembersUsernames.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: BaseShimmer(
                                    enabled: value.connectionState == ConnectionState.waiting,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        title: Text(value.connectionState == ConnectionState.waiting ? "Loading..." : commmunityMembersUsernames[index], style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                                        trailing: IconButton(
                                          onPressed: () => setState(() {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return ManageUserDialog(
                                                    uid: widget.communityMembers[index],
                                                    username: commmunityMembersUsernames[index],
                                                    profilePicture: communityMembersDataSnapshot[widget.communityMembers[index]]["profilePicture"],
                                                    roles: List<String>.from(communityMembersDataSnapshot[widget.communityMembers[index]]["roles"]),
                                                  );
                                                });
                                          }),
                                          icon: Icon(Icons.construction, color: theme.onBackground),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          })),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.grid_3x3, color: theme.onBackground),
                      const SizedBox(width: 10),
                      Text("Sections", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  //* Sections
                  Expanded(
                      child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widget.communitySections.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              widget.communitySections[index]["name"],
                              style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                            ),
                            trailing: IconButton(
                              onPressed: () => setState(() {
                                //TODO remove section from community
                              }),
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                  //* Save and discard
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => saveChanges(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text("Save", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text("Discard", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

class ManageUserDialog extends StatefulWidget {
  const ManageUserDialog({super.key, required this.uid, required this.username, required this.profilePicture, required this.roles});
  final String uid;
  final String username;
  final String profilePicture;
  final List<String> roles;

  @override
  State<ManageUserDialog> createState() => _ManageUserDialogState();
}

class _ManageUserDialogState extends State<ManageUserDialog> {
  Future<void> removeUser(AppState appState) async {
    try {
      await FirebaseFirestore.instance.collection('communities').doc(appState.getCurrentUser.assignedCommunity).update({
        "members": FieldValue.arrayRemove([
          widget.uid
        ])
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "User removed successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Error removing user: $e",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  //* Add roles
  bool isAddingRole = false;
  String roleToAdd = "";
  TextEditingController roleToAddController = TextEditingController();

  Future<void> addRoleToUser() async {
    if (roleToAdd.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        "roles": FieldValue.arrayUnion([
          roleToAdd
        ])
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Role added successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      setState(() {
        widget.roles.add(roleToAdd);
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Error adding role: $e",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> deleteRoleFromUser(String role) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        "roles": FieldValue.arrayRemove([
          role
        ])
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Role removed successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      setState(() {
        widget.roles.remove(roleToAdd);
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Error removing role: $e",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Manage User", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(widget.uid, style: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.25))),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      height: 75,
                      width: 75,
                      child: Image.network(
                        widget.profilePicture,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.username, style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            //* User Roles
            Row(
              children: [
                Icon(Icons.label, color: theme.onBackground),
                const SizedBox(width: 10),
                Text("Roles", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(alignment: WrapAlignment.start, textDirection: TextDirection.ltr, spacing: 10, children: [
              for (var role in widget.roles)
                Chip(
                  deleteIcon: Icon(Icons.close, size: 15, color: theme.onBackground),
                  onDeleted: () => deleteRoleFromUser(role),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  backgroundColor: role == "admin" ? Colors.red : theme.primaryContainer,
                  label: Text(role, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                ),
              if (isAddingRole)
                IntrinsicWidth(
                  child: TextFormField(
                      cursorColor: theme.onBackground,
                      decoration: TextInputStyle(theme: theme, textTheme: textTheme).getTextInputStyle().copyWith(border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none)),
                      onFieldSubmitted: (value) {
                        addRoleToUser();
                        setState(() {
                          isAddingRole = false;
                          roleToAddController.clear();
                          roleToAdd = "";
                        });
                      },
                      onTapOutside: (event) {
                        addRoleToUser();
                        setState(() {
                          isAddingRole = false;
                          roleToAddController.clear();
                          roleToAdd = "";
                        });
                      },
                      controller: roleToAddController,
                      onChanged: (value) => setState(() => roleToAdd = value),
                      style: textTheme.displaySmall),
                ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isAddingRole = true;
                  });
                  //* Focus on the text field
                },
                child: Chip(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  backgroundColor: theme.secondary,
                  side: BorderSide.none,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Add Role", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      Icon(Icons.add, size: 15, color: theme.onBackground),
                    ],
                  ),
                ),
              ),
            ]),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    removeUser(context.read<AppState>());
                  },
                  child: Text("Remove User", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}
