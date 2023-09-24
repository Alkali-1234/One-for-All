import 'package:flutter/material.dart';

class FadeInTransition extends StatefulWidget {
  const FadeInTransition({super.key, required this.child, this.yOffsetMultiplier, this.delayMilliseconds, this.duration});
  final Widget child;
  final double? yOffsetMultiplier;
  final int? delayMilliseconds;
  final int? duration;

  @override
  State<FadeInTransition> createState() => _FadeInTransitionState();
}

class _FadeInTransitionState extends State<FadeInTransition> {
  Tween<double> tween = Tween<double>(begin: 0, end: 0);

  void startTween() async {
    await Future.delayed(Duration(milliseconds: widget.delayMilliseconds ?? 0));
    setState(() {
      tween = Tween<double>(begin: 0, end: 1);
    });
  }

  @override
  void initState() {
    if (widget.delayMilliseconds != null) startTween();
    if (widget.delayMilliseconds == null) tween = Tween<double>(begin: 0, end: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: tween,
      duration: Duration(milliseconds: widget.duration ?? 500),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 1 - value * (widget.yOffsetMultiplier ?? 1)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
