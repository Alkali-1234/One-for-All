import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';
import '../data/user_data.dart';

class FlashcardsEditScreen extends StatefulWidget {
  const FlashcardsEditScreen({super.key, required this.setIndex});
  final int setIndex;

  @override
  State<FlashcardsEditScreen> createState() => _FlashcardsEditScreenState();
}

class _FlashcardsEditScreenState extends State<FlashcardsEditScreen> {
  Object questionQuery = {"queries": []};

  get getQuestionQuery => questionQuery;

  void initializeQueries(FlashcardSet set) {
    for (var i = 0; i < set.flashcards.length; i++) {
      getQuestionQuery["queries"].add({
        "id": set.flashcards[i].id,
        "question": set.flashcards[i].question,
        "answer": set.flashcards[i].answer
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeQueries(getUserData.flashCardSets[widget.setIndex]);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    int index = widget.setIndex;
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    //End of App Bar
                    //Body
                    const SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Edit Set",
                                    style: textTheme.displayMedium),
                                Text(
                                    "${getUserData.flashCardSets[index].flashcards.length} Questions",
                                    style: textTheme.displayMedium)
                              ],
                            ),
                            const SizedBox(height: 10),
                            //New Question button
                            ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.secondary,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  side: BorderSide(
                                      color: theme.tertiary, width: 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: theme.onPrimary),
                                    const SizedBox(width: 10),
                                    Text(
                                      "New Question",
                                      style: textTheme.displaySmall,
                                    ),
                                  ],
                                )),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: getUserData
                                      .flashCardSets[index].flashcards.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: theme.tertiary,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Q",
                                                      style: textTheme
                                                          .displayMedium,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    //Text Input for question
                                                    Expanded(
                                                      child: TextFormField(
                                                        cursorColor:
                                                            theme.onPrimary,
                                                        textAlign:
                                                            TextAlign.center,
                                                        initialValue:
                                                            getQuestionQuery[
                                                                        "queries"]
                                                                    [index]
                                                                ["question"],
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 0),
                                                          ),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          hintText:
                                                              "Enter Question",
                                                          hintStyle: textTheme
                                                              .displaySmall,
                                                          fillColor:
                                                              theme.primary,
                                                          filled: true,
                                                        ),
                                                        style: textTheme
                                                            .displaySmall,
                                                        onChanged: (value) {
                                                          getQuestionQuery[
                                                                      "queries"]
                                                                  [index][
                                                              "question"] = value;
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "A",
                                                      style: textTheme
                                                          .displayMedium,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: TextFormField(
                                                        cursorColor:
                                                            theme.onPrimary,
                                                        textAlign:
                                                            TextAlign.center,
                                                        initialValue:
                                                            getQuestionQuery[
                                                                    "queries"][
                                                                index]["answer"],
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 0),
                                                          ),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          hintText:
                                                              "Enter Question",
                                                          hintStyle: textTheme
                                                              .displaySmall,
                                                          fillColor:
                                                              theme.primary,
                                                          filled: true,
                                                        ),
                                                        style: textTheme
                                                            .displaySmall,
                                                        onChanged: (value) {
                                                          getQuestionQuery[
                                                                      "queries"]
                                                                  [index][
                                                              "answer"] = value;
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                    );
                                  }),
                            ),
                            const Divider(),
                            //Save and Cancel Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      //Sync with database and local data
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.secondary,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      side: BorderSide(
                                          color: theme.tertiary, width: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save,
                                            color: theme.onPrimary),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Save",
                                          style: textTheme.displaySmall,
                                        ),
                                      ],
                                    )),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.secondary,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      side: BorderSide(
                                          color: theme.tertiary, width: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cancel,
                                            color: theme.onPrimary),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Cancel",
                                          style: textTheme.displaySmall,
                                        ),
                                      ],
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ))));
  }
}