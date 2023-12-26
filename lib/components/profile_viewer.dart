import 'package:flutter/material.dart';
import 'package:oneforall/components/base_shimmer.dart';
import 'package:oneforall/service/community_service.dart';

class ProfileViewer extends StatefulWidget {
  const ProfileViewer({super.key, required this.uid});
  final String uid;

  @override
  State<ProfileViewer> createState() => _ProfileViewerState();
}

class _ProfileViewerState extends State<ProfileViewer> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return BottomSheet(
      backgroundColor: theme.background,
      enableDrag: false,
      onClosing: () {},
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<dynamic>(
                future: getDocument("users", widget.uid),
                builder: (c, data) => Column(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                BaseShimmer(enabled: data.connectionState != ConnectionState.done, child: Text(data.data?['username'] ?? "Loading", style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold))),
                                Text(widget.uid, style: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5))),
                              ],
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
                      ],
                    )),
          ),
        );
      },
    );
  }
}
