import 'package:flutter/material.dart';
import '../constants.dart';
import '../service/auth_service.dart';
import 'package:email_validator/email_validator.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  String emailQuery = "";
  String passwordQuery = "";
  String error = "";
  int currentStep = 0;
  //0 = welcome
  //1 = account creation
  //2 = join a school or a community
  //3 = settings configuration

  void changeCurrentStep(int value) {
    setState(() {
      currentStep = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.background,
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/logbg.png'))),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: currentStep == 0
                  ? WelcomeScreen(
                      textTheme: textTheme,
                      changeCurrentStep: changeCurrentStep)
                  : currentStep == 1
                      ? AccountCreationScreen(
                          theme: theme,
                          textTheme: textTheme,
                          changeStep: changeCurrentStep)
                      : Container(),
            ),
          ),
        ));
  }
}

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen(
      {super.key,
      required this.theme,
      required this.textTheme,
      required this.changeStep});
  final ColorScheme theme;
  final TextTheme textTheme;
  final Function changeStep;

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  String userNameQuery = "";
  String emailQuery = "";
  String passwordQuery = "";
  String retypePasswordQuery = "";
  String error = "";
  bool isLoading = false;
  bool success = false;

  @override
  Widget build(BuildContext context) {
    var theme = widget.theme;
    var textTheme = widget.textTheme;
    var changeStep = widget.changeStep;

    Future<bool> createAccountValidation() async {
      //If loading, return
      if (isLoading) {
        return false;
      }
      setState(() {
        error = "";
        isLoading = true;
      });
      //Check if forms are filled
      if (userNameQuery == "" ||
          emailQuery == "" ||
          passwordQuery == "" ||
          retypePasswordQuery == "") {
        debugPrint("e");
        setState(() {
          isLoading = false;
          error = "Please fill in all fields.";
        });
        return false;
      }
      //Validate username
      if (userNameQuery.length < 3) {
        setState(() {
          isLoading = false;
          error = "Username must be at least 3 characters long.";
        });
        return false;
      }
      if (userNameQuery.length > 20) {
        setState(() {
          isLoading = false;
          error = "Username must be less than 20 characters long.";
        });
        return false;
      }
      if (userNameQuery.contains(" ")) {
        setState(() {
          isLoading = false;
          error = "Username cannot contain spaces.";
        });
        return false;
      }
      //Validate email
      if (!EmailValidator.validate(emailQuery)) {
        setState(() {
          isLoading = false;
          error = "Please enter a valid email.";
        });
        return false;
      }
      //Validate password
      if (passwordQuery != retypePasswordQuery) {
        setState(() {
          isLoading = false;
          error = "Passwords do not match.";
        });
        return false;
      }
      //Create account
      var result =
          await createAccount(emailQuery, passwordQuery, userNameQuery);
      if (result != true) {
        setState(() {
          isLoading = false;
          error = result;
        });
        return false;
      }
      setState(() {
        success = true;
        isLoading = false;
      });
      await Future.delayed(const Duration(seconds: 3));
      //Go to step 2
      changeStep(2);
      return true;
    }

    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              Text("1. Set up your account",
                  style: widget.textTheme.displayMedium!
                      .copyWith(fontWeight: FontWeight.w400)),
            ],
          ),
          //Account creation form
          const SizedBox(height: 50),

          FormField(
            textTheme: textTheme,
            theme: theme,
            hintText: "Username",
            onChanged: (value) => setState(() {
              userNameQuery = value;
            }),
          ),
          const SizedBox(height: 10),
          FormField(
            textTheme: textTheme,
            theme: theme,
            hintText: "Email",
            onChanged: (value) => setState(() {
              emailQuery = value;
            }),
          ),
          const SizedBox(height: 10),
          FormField(
            textTheme: textTheme,
            theme: theme,
            hintText: "Password",
            onChanged: (value) => setState(() {
              passwordQuery = value;
            }),
          ),
          const SizedBox(height: 10),
          FormField(
            textTheme: textTheme,
            theme: theme,
            hintText: "Retype Password",
            onChanged: (value) => setState(() {
              retypePasswordQuery = value;
            }),
          ),
          const SizedBox(height: 30),
          //Create account button. Primary gradient, rounded corners. And also "i already have an account" button, elevated button with secondary color background and tertiary borders
          Container(
            height: 40,
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(100))),
            child: ElevatedButton(
              onPressed: () {
                createAccountValidation();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: theme.onBackground,
                          strokeWidth: 2,
                        ),
                      )
                    : success
                        ? Icon(Icons.check, color: theme.onBackground, size: 20)
                        : Text("Create Account",
                            style: textTheme.displaySmall!
                                .copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          //Error text
          const SizedBox(height: 5),
          error != ""
              ? Text(error,
                  style: textTheme.displaySmall!.copyWith(color: theme.error))
              : Container(),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondary,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  side: BorderSide(color: theme.tertiary, width: 1),
                  padding: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100))),
              child: Text("I already have an account",
                  style: textTheme.displaySmall!
                      .copyWith(fontWeight: FontWeight.normal)),
            ),
          ),
        ],
      ),
    );
  }
}

class FormField extends StatelessWidget {
  const FormField({
    super.key,
    required this.textTheme,
    required this.theme,
    required this.onChanged,
    required this.hintText,
  });

  final TextTheme textTheme;
  final ColorScheme theme;
  final Function onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => onChanged(value),
      style: textTheme.displaySmall,
      cursorColor: theme.onBackground,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 10),
        filled: true,
        fillColor: theme.primary.withOpacity(0.125),
        hintText: hintText,
        hintStyle: textTheme.displaySmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
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
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.textTheme,
    required this.changeCurrentStep,
  });

  final TextTheme textTheme;
  final Function changeCurrentStep;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        "Welcome!",
        style: textTheme.displayLarge!.copyWith(fontSize: 48),
        textAlign: TextAlign.center,
      ),
      Text("Let's get you started.",
          style:
              textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w400)),
      const SizedBox(height: 20),
      Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          // decoration: BoxDecoration(
          //     image: DecorationImage(
          //         image: AssetImage(
          //             'assets/images/getstarted.png'))),
          child: Center(child: Text("Logo", style: textTheme.displayMedium))),
      const SizedBox(height: 50),
      Container(
        height: 40,
        decoration: const BoxDecoration(
            gradient: primaryGradient,
            borderRadius: BorderRadius.all(Radius.circular(100))),
        child: ElevatedButton(
          onPressed: () {
            changeCurrentStep(1 /*account creation*/);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Text("Get Started",
                style: textTheme.displaySmall!
                    .copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      const SizedBox(height: 100),
    ]);
  }
}
