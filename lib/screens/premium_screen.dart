import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key, required this.totalSpent});
  final double totalSpent;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final freeFeatures = [
    "Access to all features",
    "Learn and communicate 500% faster*",
    "Unobstructive ads",
    "Unlimited quota",
  ];

  final earlySupporterFeatures = [
    "One time payment",
    "Your name will be written in credits",
    "Early supporter badge",
    "Access to new features early",
    "Listed as VIP",
    "Access to all free features",
  ];

  final premiumFeatures = [
    "AI features listed below",
    "Automatic flashcard, quiz, notes, summary generation",
    "Premium badge",
    "Access to new features early",
    "Access to all free features",
  ];

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    var t = appState.currentUserSelectedTheme.colorScheme;
    var tt = appState.currentUserSelectedTheme.textTheme;
    return Scaffold(
        backgroundColor: t.background,
        appBar: AppBar(
          backgroundColor: t.background,
          title: Text(
            "Your Plan",
            style: tt.displayMedium,
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: t.onBackground,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              //Free plan
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: t.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 10,
                        child: Column(
                          children: [
                            Text(
                              "Free",
                              style: tt.displayLarge,
                            ),
                            Text(
                              "0\$",
                              style: tt.displayMedium,
                            ),
                            const SizedBox(height: 20),
                            //Features
                            Expanded(
                              child: ListView.builder(
                                  itemCount: freeFeatures.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: const Icon(Icons.check, color: Colors.green),
                                      title: Text(freeFeatures[index], style: tt.displaySmall),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                          flex: 1,
                          child: SizedBox.expand(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: t.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: null,
                                child: Text("Selected", style: tt.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: t.secondary))),
                          )),
                    ],
                  ),
                ),
              ),
            ])));
  }
}
