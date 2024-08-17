import 'package:flutter/material.dart';
import 'package:oneforall/logger.dart';
import '../../constants.dart';
import 'inner_shadow.dart';

class DarkStyledToggleableButton extends StatefulWidget {
  const DarkStyledToggleableButton({super.key, required this.onPressed, required this.child, required this.value});
  final Function? onPressed;
  final Widget child;
  final bool value;

  @override
  State<DarkStyledToggleableButton> createState() => _DarkStyledToggleableButtonState();
}

class _DarkStyledToggleableButtonState extends State<DarkStyledToggleableButton> {
  late bool hovering = widget.value;
  late Tween<double> pressAnimOffsetY = Tween(begin: widget.value == false ? 0 : 3, end: widget.value == false ? 0 : 3);

  @override
  void didUpdateWidget(covariant DarkStyledToggleableButton oldWidget) {
    setState(() {
      hovering = widget.value;
      if (widget.value == false) pressAnimOffsetY = Tween(begin: 3, end: 0);
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    return GestureDetector(
      onTapDown: (details) {
        if (widget.onPressed == null) return;
        setState(() {
          if (value == false) {
            hovering = true;
            pressAnimOffsetY = Tween(begin: 0, end: 3);
          }
        });
        logger.d(value);
      },
      onTapUp: (details) {
        if (widget.onPressed == null) return;
        setState(() {
          widget.onPressed!();
        });
        logger.d(value);
      },
      onTapCancel: () {
        if (widget.onPressed == null) return;
        setState(() {
          if (value == false) {
            hovering = false;
            pressAnimOffsetY = Tween(begin: 3, end: 0);
          }
        });
        logger.d(value);
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 100),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        tween: pressAnimOffsetY,
        child: AnimatedContainer(
          key: ValueKey(value),
          duration: const Duration(milliseconds: 100),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF24272C),
            borderRadius: BorderRadius.circular(15),
            boxShadow: hovering == false
                ? [
                    const BoxShadow(
                      offset: Offset(-3, -3),
                      color: Color.fromRGBO(255, 255, 255, 0.10),
                      blurRadius: 12,
                    ),
                    const BoxShadow(
                      offset: Offset(6, 6),
                      color: Color.fromRGBO(0, 0, 0, 0.50),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class LightStyledHoverableButton extends StatefulWidget {
  const LightStyledHoverableButton({super.key, required this.onPressed, required this.child, required this.value});
  final Function? onPressed;
  final Widget child;
  final bool value;

  @override
  State<LightStyledHoverableButton> createState() => _LightStyledHoverableButtonState();
}

class _LightStyledHoverableButtonState extends State<LightStyledHoverableButton> {
  bool hovering = false;
  Tween<double> pressAnimOffsetY = Tween(begin: 0, end: 0);
  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    return GestureDetector(
      onTapDown: (details) {
        if (widget.onPressed == null) return;
        setState(() {
          if (value == false) hovering = true;
          pressAnimOffsetY = Tween(begin: 0, end: 3);
        });
      },
      onTapUp: (details) {
        if (widget.onPressed == null) return;
        setState(() {
          widget.onPressed!();
          hovering = value;
          pressAnimOffsetY = Tween(begin: 3, end: 0);
        });
      },
      onTapCancel: () {
        if (widget.onPressed == null) return;
        setState(() {
          if (value == false) hovering = false;
          pressAnimOffsetY = Tween(begin: 3, end: 0);
        });
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 100),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        tween: pressAnimOffsetY,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(15),
                boxShadow: hovering == false
                    ? [
                        const BoxShadow(
                          offset: Offset(4, 5),
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
            ),
            IgnorePointer(
              child: InnerShadow(
                shadows: [
                  Shadow(offset: const Offset(-1, -1), color: const Color(0xFFC4C4C4).withOpacity(0.3), blurRadius: 2)
                ],
                child: Container(decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(15)), height: 55, width: 400, child: Center(child: widget.child)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StyledToggleableButton extends StatelessWidget {
  const StyledToggleableButton({super.key, required this.theme, required this.onPressed, required this.child, required this.value});
  final Themes theme;
  final Function? onPressed;
  final Widget child;
  final bool value;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) return DarkStyledToggleableButton(onPressed: onPressed, value: value, child: child);
    return LightStyledHoverableButton(onPressed: onPressed, value: value, child: child);
  }
}
