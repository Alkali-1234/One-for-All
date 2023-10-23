import "package:flutter/material.dart";

class FlashComboModal extends StatefulWidget {
  const FlashComboModal({super.key, required this.number});
  final int number;

  @override
  State<FlashComboModal> createState() => _FlashComboModalState();
}

class _FlashComboModalState extends State<FlashComboModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Tween<double> tweenAnim;
  late Tween<double> opacityTween;

  void startSequence() async {
    setState(() {
      opacityTween = Tween<double>(begin: 0, end: 1);
      tweenAnim = Tween<double>(begin: 50, end: 5);
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      tweenAnim = Tween<double>(begin: 5, end: -5);
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      opacityTween = Tween<double>(begin: 1, end: 0);
      tweenAnim = Tween<double>(begin: -5, end: -50);
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    startSequence();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: opacityTween,
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: tweenAnim,
                builder: (context, value, child) {
                  return Transform.translate(
                      offset: Offset(value, 0),
                      child: Text(
                        "${widget.number.toString()}x",
                        style: textTheme.displayLarge!.copyWith(fontSize: 64, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                      ));
                },
              ),
            )
          ],
        ));
  }
}
