import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';

class MABLACScreen extends StatefulWidget {
  const MABLACScreen({super.key});

  @override
  State<MABLACScreen> createState() => _MABLACScreenState();
}

class _MABLACScreenState extends State<MABLACScreen> {
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
                        child: Column(children: [
                          //Top selection
                          Flexible(
                            flex: 1,
                            child: Row(children: [
                              //TODO: If MAB is selected it will look like the first one, if not it will look like the second one, same goes for LAC
                              Flexible(
                                flex: 1,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return SizedBox(
                                    height: constraints.maxHeight,
                                    width: constraints.maxWidth,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        debugPrint(
                                            constraints.maxHeight.toString());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 2,
                                        padding: const EdgeInsets.all(8),
                                        backgroundColor: theme.primaryContainer,
                                        foregroundColor: theme.onPrimary,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "MAB",
                                        style: textTheme.displaySmall,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              Flexible(
                                flex: 1,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: constraints.maxHeight - 10,
                                        width: constraints.maxWidth,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            debugPrint("hi");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 2,
                                            padding: const EdgeInsets.all(8),
                                            backgroundColor: theme.secondary,
                                            foregroundColor: theme.onPrimary,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "LAC",
                                            style: textTheme.displaySmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ]),
                          ),
                          //TODO Finish body
                          const Flexible(flex: 14, child: Placeholder()),
                        ]),
                      ),
                    ),
                  ],
                ))));
  }
}
