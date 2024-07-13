import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/components/profile_viewer.dart';
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
    return Column(
      children: [
        //App Bar
        Hero(
          tag: "topAppBar",
          child: Container(
            color: theme.secondary,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (widget.onClose != null) {
                            widget.onClose!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: theme.onPrimary,
                        ),
                      ),
                      Text(appState.getCurrentUser.username, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          if (FirebaseAuth.instance.currentUser != null) {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return ProfileViewer(uid: FirebaseAuth.instance.currentUser!.uid);
                                });
                          }
                        },
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
              ),
            ),
          ),
        ),
        //End of App Bar
        Expanded(
          child: SafeArea(top: false, child: widget.child),
        ),
      ],
    );
  }
}
