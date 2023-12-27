import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class BaseShimmer extends StatelessWidget {
  const BaseShimmer({super.key, required this.enabled, required this.child});
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: enabled
          ? Shimmer(
              enabled: enabled,
              gradient: enabled
                  ? LinearGradient(colors: [
                      Colors.grey.shade300,
                      Colors.grey.shade100,
                      Colors.grey.shade300
                    ])
                  : LinearGradient(colors: [
                      theme.onBackground,
                      theme.onBackground,
                      theme.onBackground
                    ]),
              child: child,
            )
          : child,
    );
  }
}
