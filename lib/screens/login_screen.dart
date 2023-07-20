import 'package:flutter/material.dart';
import '../constants.dart';
import '../service/auth_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String emailQuery = "";
  String passwordQuery = "";
  String error = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
        decoration: const BoxDecoration(
            image:
                DecorationImage(image: AssetImage('assets/images/logbg.png'))),
        child: SafeArea(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        Text(
                          "Log In",
                          style: textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (value) => setState(() {
                            emailQuery = value;
                          }),
                          style: textTheme.displaySmall,
                          cursorColor: theme.onBackground,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 10),
                            filled: true,
                            fillColor: theme.primary.withOpacity(0.125),
                            hintText: "Email",
                            hintStyle: textTheme.displaySmall,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          onChanged: (value) => setState(() {
                            passwordQuery = value;
                          }),
                          cursorColor: theme.onBackground,
                          style: textTheme.displaySmall,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 10),
                            filled: true,
                            fillColor: theme.primary.withOpacity(0.125),
                            hintText: "Password",
                            hintStyle: textTheme.displaySmall,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: getPrimaryGradient,
                          ),
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                var loginResult = await login(
                                    emailQuery, passwordQuery, false);
                                if (loginResult) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MyApp(showReload: false)));
                                } else {
                                  setState(() {
                                    isLoading = false;
                                    error = "Failed to login";
                                  });
                                }
                              },
                              child: Text("Log In",
                                  style: textTheme.displaySmall!
                                      .copyWith(fontWeight: FontWeight.bold))),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.secondary,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(color: theme.tertiary),
                              ),
                              onPressed: () {
                                //TODO: Implement sign up page
                              },
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.onSecondary),
                                    )
                                  : Text("Create a new account",
                                      style: textTheme.displaySmall!.copyWith(
                                          fontWeight: FontWeight.bold))),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
