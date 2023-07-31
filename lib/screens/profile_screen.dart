import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oneforall/service/auth_service.dart';
import '../data/user_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = getUserData.username;
  String email = getUserData.email;
  String password = '';

  final _formKey = GlobalKey<FormState>();

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Save changes to the user profile
      debugPrint('Changes saved!');
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(getUserData
                                  .profilePicture !=
                              ''
                          ? getUserData.profilePicture
                          : 'https://api.dicebear.com/6.x/initials/svg?seed=invalid_username'),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Handle edit profile picture
                          debugPrint('Edit profile picture clicked!');
                        },
                      ),
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
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: username,
                        decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: theme.onBackground)),
                        style: textTheme.displaySmall!,
                        onChanged: (value) => setState(() => username = value),
                        validator: (value) {
                          if (value == "" || value == null) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: email,
                        decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: theme.onBackground)),
                        style: textTheme.displaySmall!,
                        onChanged: (value) => setState(() => email = value),
                        validator: (value) {
                          if (value == "" || value == null) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: password,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: theme.onBackground)),
                        style: textTheme.displaySmall!,
                        onChanged: (value) => setState(() => password = value),
                        validator: (value) {
                          if (value == "" || value == null) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Save Changes',
                      style: textTheme.displaySmall!
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
