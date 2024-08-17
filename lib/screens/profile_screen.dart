import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/components/styled_components/container.dart';
import 'package:oneforall/components/styled_components/elevated_button.dart';
import 'package:oneforall/components/styled_components/filled_elevated_button.dart';
import 'package:oneforall/components/styled_components/text_field.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/screens/login_screen.dart';
import 'package:oneforall/service/auth_service.dart';
import 'package:provider/provider.dart';
//Deprecated import
// import '../data/user_data.dart';
import 'package:image_picker/image_picker.dart';

import '../logger.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //* Previous data
  String previousProfilePicture = "";
  String previousUsername = "";
  String previousEmail = "";

  //* Current
  dynamic profilePicture = "https://picsum.photos/200";
  String username = "";
  String email = "";

  ImageProvider pfpImage = const NetworkImage("https://picsum.photos/200");

  late TextEditingController usernameController = TextEditingController(text: username);
  late TextEditingController emailController = TextEditingController(text: email);

  initializeUserData(AppState appState) {
    //* Initialize user data
    profilePicture = appState.getCurrentUser.profilePicture;
    username = appState.getCurrentUser.username;
    email = appState.getCurrentUser.email;
    pfpImage = NetworkImage(appState.getCurrentUser.profilePicture);

    //* Initialize previous data
    previousProfilePicture = appState.getCurrentUser.profilePicture;
    previousUsername = appState.getCurrentUser.username;
    previousEmail = appState.getCurrentUser.email;
  }

  void _saveChanges(AppState appState) async {
    if (FirebaseAuth.instance.currentUser!.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("User is guest!", style: TextStyle(color: Colors.white))));
      return;
    }
    if (emailController.text.isNotEmpty && usernameController.text.isNotEmpty) {
      // Save changes to the user profile
      if (profilePicture is File) {
        //* Change profile picture
        try {
          String newLink = await changeUserProfilePicture(profilePicture, previousProfilePicture);
          appState.getCurrentUser.profilePicture = newLink;
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error changing profile picture! $e', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if (username != previousUsername) {
        //* Change username
        try {
          await changeUserName(username);
          appState.getCurrentUser.username = username;
        } on Exception catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error changing username! $e', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if (email != previousEmail) {
        //* Change email
        try {
          await changeUserEmail(email);
        } on Exception catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error changing email! $e', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      logger.i('Changes saved! $email');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check your new email to verify.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      return;
    } else {
      Navigator.pop(context);
      //* Show snack bar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes not saved! Please be sure that all fields are filled and changed', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }

  void changeProfilePicture() async {
    //* Handle change profile picture
    //* Pick image from gallery
    await ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        setState(() {
          profilePicture = File(value.path);
          pfpImage = FileImage(File(value.path));
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeUserData(Provider.of<AppState>(context, listen: false));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = theme == lightTheme.colorScheme ? Themes.light : Themes.dark;
    return StyledContainer(
      theme: ctheme,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: pfpImage,
                ),
                SizedBox(
                  width: 50,
                  child: StyledElevatedButton(
                      theme: ctheme,
                      onPressed: () => changeProfilePicture(),
                      child: Icon(
                        Icons.edit,
                        color: theme.onBackground,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            Text(email, style: textTheme.displaySmall),
            const SizedBox(height: 20),
            Column(
              children: [
                StyledTextField(
                  theme: ctheme,
                  controller: usernameController,
                  hint: "Username",
                  onChanged: (value) => setState(() => username = value),
                ),
                const SizedBox(height: 10),
                StyledTextField(
                  theme: ctheme,
                  controller: emailController,
                  hint: "Email",
                  onChanged: (value) => setState(() => email = value),
                ),
                const SizedBox(height: 10),
                // TextButton(
                //     style: ButtonStyle(
                //       backgroundColor: MaterialStateProperty.all(Colors.transparent),
                //       padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                //     ),
                //     onPressed: () {
                //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DevScreen()));
                //     },
                //     child: Text('Change Password (Dev)', style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500))),
              ],
            ),
            const Spacer(),
            FilledElevatedButton(
              onPressed: () => _saveChanges(context.read<AppState>()),
              color: Colors.green,
              child: Text('Save Changes', style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(
              height: 15,
            ),
            FilledElevatedButton(
              onPressed: () async {
                await logout();
                if (context.mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              color: Colors.red,
              child: Text('Logout', style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

//* Saving settings modal
class SavingSettingsModal extends StatelessWidget {
  const SavingSettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            //* Blur background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Card(
              color: theme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: theme.tertiary, width: 0.5)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Saving changes...', style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      backgroundColor: theme.onBackground,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
