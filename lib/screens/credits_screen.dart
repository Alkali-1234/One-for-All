import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            color: theme.onBackground.withOpacity(0.25),
            height: 1,
          ),
        ),
        backgroundColor: theme.background,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.onBackground,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Credits & Attribution",
          style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text("Developed by: ", style: textTheme.displaySmall),
                  const Spacer(),
                  Text("Alkaline", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IconButton(
                      onPressed: () => launchUrl(Uri.parse("https://github.com/Alkali-1234")),
                      icon: Icon(
                        Icons.open_in_new,
                        color: theme.onBackground.withOpacity(0.5),
                      ))
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text("Special thanks to: ", style: textTheme.displaySmall),
                ],
              ),
              Divider(
                color: theme.onBackground,
              ),
              Row(
                children: [
                  Text("Fabian, Emir Nasatya, Kevin Alvaro, Gede Wirya P", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
