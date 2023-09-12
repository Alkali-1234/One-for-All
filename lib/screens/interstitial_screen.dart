import 'package:flutter/material.dart';
import 'package:oneforall/interstitial_ad.dart';

class InterstitialScreen extends StatelessWidget {
  const InterstitialScreen({super.key, required this.onClosed, required this.onFailed});
  final Function onClosed;
  final Function onFailed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: InterstitialAdWidget(onClosed: onClosed, onFailed: onFailed),
      body: Center(
        child: Text('Please wait...', style: Theme.of(context).textTheme.displaySmall),
      ),
    );
  }
}
