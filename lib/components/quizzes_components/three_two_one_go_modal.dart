import 'dart:async';

import 'package:flutter/material.dart';

class ThreeTwoOneGoModal extends StatefulWidget {
  const ThreeTwoOneGoModal({super.key});

  @override
  State<ThreeTwoOneGoModal> createState() => _ThreeTwoOneGoModalState();
}

class _ThreeTwoOneGoModalState extends State<ThreeTwoOneGoModal> {
  int increment = 3;
  Tween<double> peaceOutTween = Tween<double>(begin: 0, end: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (increment == 0) {
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          peaceOutTween = Tween<double>(begin: 0, end: 1);
        });
        timer.cancel();
        if (!mounted) return;
        Navigator.of(context).pop();
      }
      setState(() {
        if (increment > 0) increment--;
      });

      await Future.delayed(const Duration(seconds: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    // var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: TweenAnimationBuilder(
          tween: peaceOutTween,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          builder: (context, value, child) => Transform.translate(offset: Offset(value * constraints.maxWidth, 0), child: child),
          child: AnimatedSwitcher(
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              duration: const Duration(milliseconds: 200),
              child: Text(
                increment != 0 ? increment.toString() : "Go!",
                style: textTheme.displayLarge!.copyWith(color: Colors.white, fontStyle: FontStyle.italic),
              )),
        ),
      );
    });
  }
}
