import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import '../data/user_data.dart';
import 'flashcardsPlay_screen.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/purpwallpaper 2.png'),
                fit: BoxFit.cover)),
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    //App Bar
                    Container(
                      color: theme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.arrow_back,
                                color: theme.onPrimary,
                              ),
                            ),
                            Text("Alkaline", style: textTheme.displaySmall),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: theme.onPrimary,
                                borderRadius: BorderRadius.circular(20),
                                gradient: getPrimaryGradient,
                              ),
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  child: Image.network(
                                      'https://picsum.photos/200')),
                            )
                          ],
                        ),
                      ),
                    ),
                    //End of App Bar
                    //Body
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Flexible(
                              flex: 3,
                              child: TextField(
                                onChanged: (value) => {},
                                keyboardAppearance: Brightness.dark,
                                cursorColor: theme.onPrimary,
                                style: textTheme.displayMedium!.copyWith(
                                    color: theme.onPrimary,
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: theme.primary,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    hintText: 'Search',
                                    suffixIcon: Icon(Icons.search,
                                        color: theme.onPrimary, size: 50),
                                    hintStyle: textTheme.displayMedium!
                                        .copyWith(
                                            color: theme.onPrimary
                                                .withOpacity(0.25),
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Flexible(
                              flex: 10,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Library",
                                          style: textTheme.displayLarge),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                          getUserData.flashCardSets.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: theme.secondary,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: theme.tertiary,
                                            ),
                                          ),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        SelectedSetModal(
                                                          flashcardSet: getUserData
                                                                  .flashCardSets[
                                                              index],
                                                        ));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor:
                                                    theme.onPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                getUserData
                                                    .flashCardSets[index].title,
                                                style: textTheme.displayMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ))),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}

class SelectedSetModal extends StatelessWidget {
  const SelectedSetModal({super.key, required this.flashcardSet});
  final FlashcardSet flashcardSet;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Top
              Column(
                children: [
                  Text(flashcardSet.title, style: textTheme.displayLarge),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  //Middle
                  Container(
                    decoration: BoxDecoration(
                      color: theme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Number of questions",
                                style: textTheme.displaySmall),
                            Text(flashcardSet.flashcards.length.toString(),
                                style: textTheme.displaySmall)
                          ]),
                    ),
                  ),
                ],
              ),
              //Bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.secondary,
                        foregroundColor: theme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardsPlayScreen(flashcardsSet: flashcardSet)));
                      },
                      child: const Text("Open")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.secondary,
                        foregroundColor: theme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
