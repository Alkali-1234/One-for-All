import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdWidget extends StatefulWidget {
  const InterstitialAdWidget({super.key, this.onClosed, this.onFailed});
  final Function? onClosed;
  final Function? onFailed;

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget> {
  InterstitialAd? _interstitialAd;

  //TODO Replace with actual ad unit id
  final adUnitId = Platform.isAndroid ? 'ca-app-pub-3940256099942544/1033173712' : 'ca-app-pub-3940256099942544/4411468910';

  void loadAd() {
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
            _interstitialAd!.show();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                if (widget.onFailed != null) widget.onFailed!();
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                if (widget.onClosed != null) widget.onClosed!();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('InterstitialAd failed to load: $error');
            dispose();
            if (widget.onFailed != null) widget.onFailed!();
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
