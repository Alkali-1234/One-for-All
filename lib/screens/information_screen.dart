import 'package:flutter/material.dart';

import 'credits_screen.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        bottomNavigationBar: SafeArea(
          child: Row(
            children: [
              const Spacer(),
              SizedBox(height: 40, child: Image.asset("assets/images/builtwithflutter.png")),
              const SizedBox(
                width: 8,
              )
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              foregroundColor: theme.onBackground,
              backgroundColor: theme.background,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'One for All',
                style: textTheme.displayMedium,
              ),
              floating: true,
              pinned: true,
              snap: true,
            ),
            SliverList(
                delegate: SliverChildListDelegate(
              [
                ListItem(
                  textTheme: textTheme,
                  title: "Version",
                  subtitle: "v0.0.4",
                ),
                ListItem(textTheme: textTheme, title: "Build Number", subtitle: "000000"),
                ListItem(textTheme: textTheme, title: "Branch", subtitle: "main/stable"),
                ListItem(textTheme: textTheme, title: "Flutter SDK Version", subtitle: "3.13.2"),
                ListItem(textTheme: textTheme, title: "Dart Version", subtitle: "3.1.0"),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreditsScreen()));
                  },
                  splashColor: theme.onBackground.withOpacity(0.5),
                  title: Text("Credits", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.onBackground.withOpacity(0.5),
                  ),
                ),
                ListTile(
                  onTap: () {
                    //TODO implement licence
                  },
                  splashColor: theme.onBackground.withOpacity(0.5),
                  title: Text("Licence", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            )),
          ],
        ));
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.textTheme,
    required this.title,
    required this.subtitle,
  });

  final TextTheme textTheme;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        onTap: () {},
        title: Text(
          title,
          style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          subtitle,
          style: textTheme.displaySmall!,
        ),
      ),
    );
  }
}
