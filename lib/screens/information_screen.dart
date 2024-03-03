import 'package:flutter/material.dart';

import 'credits_screen.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
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
              subtitle: "v0.0.5.1",
            ),
            ListItem(textTheme: textTheme, title: "Build Number", subtitle: "75adf7b"),
            ListItem(textTheme: textTheme, title: "Branch", subtitle: "main/stable"),
            ListItem(textTheme: textTheme, title: "Flutter SDK Version", subtitle: "3.16.9"),
            ListItem(textTheme: textTheme, title: "Dart Version", subtitle: "3.2.6"),
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
                showDialog(context: context, builder: (context) => AlertDialog(titleTextStyle: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold), contentTextStyle: textTheme.displaySmall!, title: const Text("Licenced under the Apache Licence 2.0"), content: Text(Licence().licence)));
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

class Licence {
  String licence = """Copyright 2024 M. Algazel F

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.""";
}
