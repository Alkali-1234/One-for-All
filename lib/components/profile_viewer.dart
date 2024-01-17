import 'package:flutter/material.dart';
import 'package:oneforall/components/base_shimmer.dart';
import 'package:oneforall/service/community_service.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ProfileViewer extends StatefulWidget {
  const ProfileViewer({super.key, required this.uid});
  final String uid;

  @override
  State<ProfileViewer> createState() => _ProfileViewerState();
}

class _ProfileViewerState extends State<ProfileViewer> {
  late final getUserData = getDocument("users", widget.uid);
  Future guestFuture() async {
    return {
      "username": "Guest",
      "profilePicture": "https://i.imgur.com/BoN9kdC.png",
      "community": "Guest",
      "roles": [],
    };
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var appState = context.watch<AppState>();
    return BottomSheet(
      backgroundColor: theme.background,
      enableDrag: false,
      onClosing: () {},
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<dynamic>(
                future: appState.getCurrentUser.username != "Guest" ? getUserData : guestFuture(),
                builder: (c, data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            data.connectionState != ConnectionState.done
                                ? BaseShimmer(
                                    enabled: data.connectionState != ConnectionState.done,
                                    child: CircleAvatar(
                                      radius: 48,
                                      backgroundImage: NetworkImage(data.data?['profilePicture'] ?? "https://i.imgur.com/BoN9kdC.png"),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 48,
                                    backgroundImage: NetworkImage(data.data?['profilePicture'] ?? "https://i.imgur.com/BoN9kdC.png"),
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FittedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    BaseShimmer(enabled: data.connectionState != ConnectionState.done, child: Text(data.data?['username'] ?? "Loading", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold))),
                                    Text(widget.uid, style: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text("Account registered at --:-- --/--/----", style: textTheme.displaySmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "Community : ",
                              style: textTheme.displaySmall,
                            ),
                            BaseShimmer(enabled: data.connectionState != ConnectionState.done, child: Text(data.data?['community'] ?? "Loading", style: textTheme.displaySmall)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        //* Roles
                        Text("Roles", style: textTheme.displaySmall),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.start,
                          textDirection: TextDirection.ltr,
                          children: [
                            for (String role in data.data?['roles'] ?? [])
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Chip(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  side: BorderSide.none,
                                  backgroundColor: role == "admin" ? Colors.red.withOpacity(0.25) : theme.primaryContainer,
                                  label: Text(
                                    role,
                                    style: textTheme.displaySmall,
                                  ),
                                ),
                              )
                          ],
                        )
                      ],
                    )),
          ),
        );
      },
    );
  }
}
