//
import 'package:flutter/material.dart';
import '../constants.dart';
import '../service/auth_service.dart';
import '../main.dart';
import 'package:email_validator/email_validator.dart';
import './get_started.dart';

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

  void pushToPage(Widget page) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => page));
    return;
  }

  void attemptLogin() async {
    setState(() {
      isLoading = true;
    });
    //Check if email and password are filled
    if (emailQuery == "" || passwordQuery == "") {
      setState(() {
        isLoading = false;
        error = "Please fill in all fields";
      });
      return;
    }
    //Validate email
    if (!EmailValidator.validate(emailQuery)) {
      setState(() {
        isLoading = false;
        error = "Please enter a valid email";
      });
      return;
    }
    //Attempt to login
    await login(emailQuery, passwordQuery, false)
        .then((value) => pushToPage(const HomeScreen()))
        .onError((error, stackTrace) => setState(() {
              isLoading = false;
              this.error = error.toString();
            }));
  }

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
                        SizedBox(
                          height: 40,
                          child: TextField(
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
                                borderSide: BorderSide(
                                    color: theme.onBackground, width: 1),
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
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 40,
                          child: TextField(
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
                                borderSide: BorderSide(
                                    color: theme.onBackground, width: 1),
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
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: getPrimaryGradient,
                          ),
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (isLoading == false) {
                                  attemptLogin();
                                }
                              },
                              child: isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: theme.onBackground),
                                    )
                                  : Text("Log In",
                                      style: textTheme.displaySmall!.copyWith(
                                          fontWeight: FontWeight.bold))),
                        ),
                        const SizedBox(height: 2.5),
                        error != ""
                            ? Text(error,
                                style: textTheme.displaySmall!
                                    .copyWith(color: theme.error))
                            : Container(),
                        const SizedBox(
                          height: 2.5,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
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
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const GetStartedScreen()));
                              },
                              child: Text("Create a new account",
                                  style: textTheme.displaySmall!
                                      .copyWith(fontWeight: FontWeight.bold))),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
