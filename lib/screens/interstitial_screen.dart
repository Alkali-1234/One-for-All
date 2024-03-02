import 'package:flutter/material.dart';
import 'package:oneforall/interstitial_ad.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

class InterstitialScreen extends StatefulWidget {
  const InterstitialScreen({super.key, required this.onClosed, required this.onFailed});
  final Function onClosed;
  final Function onFailed;

  @override
  State<InterstitialScreen> createState() => _InterstitialScreenState();
}

class _InterstitialScreenState extends State<InterstitialScreen> {
  @override
  void initState() {
    super.initState();
    doAsync();
  }

  void doAsync() async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 200));
      widget.onClosed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: kIsWeb == false && kDebugMode == false ? InterstitialAdWidget(onClosed: widget.onClosed, onFailed: widget.onFailed) : null,
      body: Center(
        child: Text('Please wait...', style: Theme.of(context).textTheme.displaySmall),
      ),
    );
  }
}
