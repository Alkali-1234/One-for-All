import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/components/profile_viewer.dart';
import 'package:oneforall/components/styled_components/elevated_icon_button.dart';
import 'package:oneforall/components/styled_components/style_constants.dart';
import 'package:oneforall/constants.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key, required this.child, this.onClose});
  final Widget child;
  final Function? onClose;

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var ctheme = getThemeFromTheme(theme);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 10,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          backgroundColor: theme.background,
          leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Hero(
                tag: "menu",
                child: StyledIconButton(
                  theme: ctheme,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icons.arrow_back_rounded,
                  size: 32,
                ),
              )),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(text: appState.getCurrentUser.username, style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w900)),
                ]),
              ),
              GestureDetector(
                onTap: () => showModalBottomSheet(context: context, builder: (c) => ProfileViewer(uid: FirebaseAuth.instance.currentUser!.uid)),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: theme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                    gradient: getPrimaryGradient,
                  ),
                  child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(15)), child: Image.network(appState.getCurrentUser.profilePicture, fit: BoxFit.cover)),
                ),
              )
            ],
          ),
        ),
        body: SafeArea(top: false, child: widget.child));
  }
}
