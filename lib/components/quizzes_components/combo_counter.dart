import 'dart:async';

import 'package:flutter/material.dart';

class ComboCounter extends StatefulWidget {
  const ComboCounter({
    super.key,
    required this.theme,
  });
  final ColorScheme theme;

  @override
  State<ComboCounter> createState() => ComboCounterState();
}

class ComboCounterState extends State<ComboCounter> {
  int maxCombo = 0;
  int counter = 0;

  late StatefulWidget comboBarWidget;

  Tween<double> timeLeftTween = Tween<double>(begin: 1, end: 0);
  int timeLeftDurationMilliseconds = 5000;

  Timer? timeLeftTimer;

  Tween<double> comboBarTween = Tween<double>(begin: 1, end: 0);

  @override
  void initState() {
    super.initState();
    var theme = widget.theme;

    comboBarWidget = TweenAnimationBuilder(
        key: UniqueKey(),
        tween: comboBarTween,
        duration: Duration(milliseconds: timeLeftDurationMilliseconds),
        builder: (context, value, child) {
          return LinearProgressIndicator(
            key: UniqueKey(),
            value: value,
            backgroundColor: theme.primary,
            valueColor: AlwaysStoppedAnimation<Color>(theme.onBackground),
          );
        });
  }

  //* Functions
  void addComboCount() {
    // var theme = Theme.of(context).colorScheme;
    timeLeftTimer?.cancel();
    setState(() {
      comboBarTween = Tween<double>(begin: 1.0, end: 0.0);
      counter++;
      if (counter > maxCombo) {
        maxCombo = counter;
      }
      // comboBarWidget = TweenAnimationBuilder(
      //     key: UniqueKey(),
      //     tween: Tween<double>(begin: 1.0, end: 0.0),
      //     duration: Duration(milliseconds: timeLeftDurationMilliseconds),
      //     builder: (context, value, child) {
      //       return LinearProgressIndicator(
      //         key: UniqueKey(),
      //         value: value,
      //         backgroundColor: theme.primary,
      //         valueColor: AlwaysStoppedAnimation<Color>(theme.onBackground),
      //       );
      //     });
    });
    startTimer();
  }

  void pauseTimer() {
    var theme = widget.theme;
    setState(() {
      timeLeftTimer?.cancel();
      timeLeftTimer = null;
      comboBarTween = Tween<double>(begin: 1.0, end: 1.0);
      comboBarWidget = TweenAnimationBuilder(
        key: UniqueKey(),
        tween: comboBarTween,
        duration: const Duration(milliseconds: 0),
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: value,
            backgroundColor: theme.primary,
            valueColor: AlwaysStoppedAnimation<Color>(theme.onBackground),
          );
        },
      );
    });
  }

  void resetComboCount() {
    if (!mounted) return;
    var theme = widget.theme;
    setState(() {
      comboBarTween = Tween<double>(begin: 0.0, end: 0.0);
      counter = 0;
      comboBarWidget = TweenAnimationBuilder(
        key: UniqueKey(),
        tween: comboBarTween,
        duration: const Duration(milliseconds: 0),
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: value,
            backgroundColor: theme.primary,
            valueColor: AlwaysStoppedAnimation<Color>(theme.onBackground),
          );
        },
      );
    });
  }

  void startTimer() async {
    var theme = widget.theme;
    double targetSeconds = 5 - (counter / 10) > 1 ? 5 - (counter / 10) : 1;
    int totalMilliseconds = (targetSeconds * 1000).toInt();
    setState(() {
      timeLeftDurationMilliseconds = totalMilliseconds;
      timeLeftTween = Tween<double>(begin: 1, end: 0);
      comboBarWidget = TweenAnimationBuilder(
          key: UniqueKey(),
          tween: comboBarTween,
          duration: Duration(milliseconds: timeLeftDurationMilliseconds),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              key: UniqueKey(),
              value: value,
              backgroundColor: theme.primary,
              valueColor: AlwaysStoppedAnimation<Color>(theme.onBackground),
            );
          });
      timeLeftTimer = Timer(Duration(milliseconds: totalMilliseconds), () {
        resetComboCount();
      });
    });

    // timeLeftTimer = Timer.periodic(Duration(milliseconds: totalMilliseconds), (timer) {
    //   setState(() {
    //     timeLeft -= 0.1;
    //     if (timeLeft <= 0) {
    //       timeLeftTimer?.cancel();
    //       timeLeftTimer = null;
    //       counter = 0;
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //* Counter
        Text(
          "${counter}x",
          style: textTheme.displayMedium,
        ),
        //* Bar
        comboBarWidget,
      ],
    );
  }
}
