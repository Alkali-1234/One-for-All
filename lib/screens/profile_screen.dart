import 'package:flutter/material.dart';
import '../data/user_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
      var theme = Theme.of(context).colorScheme;
      var textTheme = Theme.of(context).textTheme;
      return Column(
          children: [
              //* Profile card
          Container(
              decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(10)),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24), child: Row(
                      children: [
                          //* Profile picture
                            Container(
                                decoration: BoxDecoration(color: theme.secondary, borderRadius: BorderRadius.circular(100)),
                                child: Padding(padding: const EdgeInsets.all(0), child: Image.network(getUserData.profilePicture != "" ? getUserData.profilePicture : "https://picsum.photos/200", width: 100, height: 100))),
                            const SizedBox(width: 8),
                            //* Profile info
                            Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Text(getUserData.username, style: textTheme.displayMedium),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Exp: ${getUserData.exp}", style: textTheme.displaySmall),
                                        Text("Streak: ${getUserData.streak}", style: textTheme.displaySmall),
                                        Text("Posts: ${getUserData.posts}", style: textTheme.displaySmall),
                                      ],
                                    )
                                ],
                                
                            )
                      ],
              ))
          )
          ],
      );
  }
}
