import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import '../data/community_data.dart';

class MABLACScreen extends StatefulWidget {
  const MABLACScreen({super.key});

  @override
  State<MABLACScreen> createState() => _MABLACScreenState();
}

class _MABLACScreenState extends State<MABLACScreen> {
  int selectedSection = 0;
  String searchQuery = "";
  SearchController searchController = SearchController();
  //0 = MAB
  //1 = LAC
  int selectedTypeFilter = 0;
  //0 = All
  //1 = Announces
  //2 = Tasks

  //TODO Make subject filter dynamic
  int selectedSubjectFilter = 0;
  //0 = All
  //...
  int selectedDueFilter = 0;
  //0 = All
  //1 = in 3 days
  //2 = in 7 days
  //3 = in 14 days
  int sortFilter = 0;
  //0 = Newest
  //1 Due date

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
                        child: Column(children: [
                          //Top selection
                          Flexible(
                            flex: 1,
                            child: Row(children: [
                              Flexible(
                                flex: 1,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: selectedSection == 0
                                            ? constraints.maxHeight
                                            : constraints.maxHeight - 10,
                                        width: constraints.maxWidth,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedSection = 0;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.all(8),
                                            backgroundColor:
                                                selectedSection == 0
                                                    ? theme.primaryContainer
                                                    : theme.secondary,
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
                                      ),
                                    ],
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
                                        height: selectedSection == 1
                                            ? constraints.maxHeight
                                            : constraints.maxHeight - 10,
                                        width: constraints.maxWidth,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedSection = 1;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.all(8),
                                            backgroundColor:
                                                selectedSection == 1
                                                    ? theme.primaryContainer
                                                    : theme.secondary,
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
                          Flexible(
                              flex: 14,
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: theme.primaryContainer,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(children: [
                                      //Search bar
                                      Flexible(
                                        flex: 3,
                                        child: TextField(
                                          controller: searchController,
                                          onChanged: (value) => setState(() {
                                            searchQuery = value;
                                          }),
                                          keyboardAppearance: Brightness.dark,
                                          cursorColor: theme.onPrimary,
                                          style: textTheme.displayMedium!
                                              .copyWith(
                                                  color: theme.onPrimary,
                                                  fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                              filled: true,
                                              fillColor: theme.primary,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              hintText: 'Search',
                                              suffixIcon: Icon(Icons.search,
                                                  color: theme.onPrimary,
                                                  size: 50),
                                              hintStyle: textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                      color: theme.onPrimary
                                                          .withOpacity(0.25),
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      //Filters
                                      Flexible(
                                          flex: 3,
                                          child: Column(children: [
                                            Flexible(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  //Filter by

                                                  //All
                                                  Flexible(
                                                    flex: 1,
                                                    child: LayoutBuilder(
                                                        builder: (context, c) {
                                                      return Container(
                                                        width: c.maxWidth - 10,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              theme.secondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: DropdownButton(
                                                            value:
                                                                selectedTypeFilter,
                                                            icon: const Icon(
                                                                null),
                                                            underline:
                                                                Container(),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedTypeFilter =
                                                                    value
                                                                        as int;
                                                              });
                                                            },
                                                            items: const [
                                                              DropdownMenuItem(
                                                                value: 0,
                                                                child: Text(
                                                                    "All",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 1,
                                                                child:
                                                                    FittedBox(
                                                                  child: Text(
                                                                      "Announces",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 2,
                                                                child: Text(
                                                                    "Tasks",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  //Subject
                                                  Flexible(
                                                    flex: 1,
                                                    child: LayoutBuilder(
                                                        builder: (context, c) {
                                                      return Container(
                                                        width: c.maxWidth - 10,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              theme.secondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: DropdownButton(
                                                            value:
                                                                selectedSubjectFilter,
                                                            icon: const Icon(
                                                                null),
                                                            underline:
                                                                Container(),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedSubjectFilter =
                                                                    value
                                                                        as int;
                                                              });
                                                            },
                                                            items: const [
                                                              DropdownMenuItem(
                                                                value: 0,
                                                                child: Text(
                                                                    "All",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 1,
                                                                child:
                                                                    FittedBox(
                                                                  child: Text(
                                                                      "Math",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 2,
                                                                child: Text(
                                                                    "Physics",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  //Due
                                                  Flexible(
                                                    flex: 1,
                                                    child: LayoutBuilder(
                                                        builder: (context, c) {
                                                      return Container(
                                                        width: c.maxWidth - 10,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              theme.secondary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: DropdownButton(
                                                            value:
                                                                selectedDueFilter,
                                                            icon: const Icon(
                                                                null),
                                                            underline:
                                                                Container(),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedDueFilter =
                                                                    value
                                                                        as int;
                                                              });
                                                            },
                                                            items: const [
                                                              DropdownMenuItem(
                                                                value: 0,
                                                                child: Text(
                                                                    "All",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 1,
                                                                child:
                                                                    FittedBox(
                                                                  child: Text(
                                                                      "3 Days",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 2,
                                                                child: Text(
                                                                    "7 Days",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                              DropdownMenuItem(
                                                                  value: 3,
                                                                  child: Text(
                                                                      "14 Days",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)))
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Flexible(
                                              flex: 1,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    decoration: BoxDecoration(
                                                      color: theme.secondary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: DropdownButton(
                                                        value: sortFilter,
                                                        icon: const Icon(null),
                                                        underline: Container(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            sortFilter =
                                                                value as int;
                                                          });
                                                        },
                                                        items: const [
                                                          DropdownMenuItem(
                                                            value: 0,
                                                            child: Text(
                                                                "Newest",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 1,
                                                            child: FittedBox(
                                                              child: Text(
                                                                  "Due Date",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ])),
                                      const SizedBox(height: 10),
                                      //List of items
                                      Flexible(
                                          flex: 20,
                                          child: SizedBox.expand(
                                            child: LayoutBuilder(
                                                builder: (context, c) {
                                              return ListView.builder(
                                                  itemCount:
                                                      getLACData.posts.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    //TODO Filter
                                                    return getLACData
                                                                .posts[index]
                                                                .title !=
                                                            null
                                                        ? ListItem(
                                                            theme: theme,
                                                            textTheme:
                                                                textTheme,
                                                            c: c)
                                                        : Container();
                                                  });
                                            }),
                                          )),
                                    ]),
                                  ))),
                        ]),
                      ),
                    ),
                  ],
                ))));
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.theme,
    required this.textTheme,
    required this.c,
  });

  final ColorScheme theme;
  final TextTheme textTheme;
  final BoxConstraints c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
          height: c.maxHeight * 0.165,
          decoration: BoxDecoration(
            color: theme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.all(12),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Print this document", style: textTheme.displayMedium),
                    Container(
                      decoration: BoxDecoration(
                          color: theme.secondary,
                          borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.all(5),
                      child:
                          Text("3 Days (Fri)", style: textTheme.displaySmall),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        //Profilepicture
                        Container(
                          width: MediaQuery.of(context).size.width * 0.05,
                          height: MediaQuery.of(context).size.width * 0.05,
                          decoration: BoxDecoration(
                            color: theme.onPrimary,
                            borderRadius: BorderRadius.circular(20),
                            gradient: getPrimaryGradient,
                          ),
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              child:
                                  Image.network('https://picsum.photos/200')),
                        ),
                        const SizedBox(width: 10),
                        Text("Alkaline", style: textTheme.displaySmall),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.task,
                          size: MediaQuery.of(context).size.width * 0.05,
                          color: theme.onPrimary,
                        ),
                        const SizedBox(width: 3),
                        Text("Task", style: textTheme.displaySmall)
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: theme.secondary,
                          borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.all(5),
                      child: Text("English", style: textTheme.displaySmall),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
