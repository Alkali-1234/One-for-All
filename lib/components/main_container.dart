import 'package:flutter/material.dart';
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
    return Container(
      decoration: theme == defaultBlueTheme.colorScheme
          ? const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/purpwallpaper 2.png"),
                fit: BoxFit.cover,
              ),
            )
          : null,
      child: Column(
        children: [
          //App Bar
          Hero(
            tag: "topAppBar",
            child: Container(
              color: theme.secondary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: widget.onClose != null ? () => widget.onClose!() : () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: theme.onPrimary,
                        ),
                      ),
                      Text(appState.getCurrentUser.username, style: textTheme.displaySmall),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: theme.onPrimary,
                          borderRadius: BorderRadius.circular(20),
                          gradient: getPrimaryGradient,
                        ),
                        child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(15)), child: Image.network(appState.getCurrentUser.profilePicture, fit: BoxFit.cover)),
                      )
                    ],
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
      ),
    );
  }
}
