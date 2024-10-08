import 'package:flutter/material.dart';
import '../../constants.dart';
import 'inner_shadow.dart';

class DarkStyledTouchableContainer extends StatefulWidget {
  const DarkStyledTouchableContainer({super.key, required this.onPressed, required this.child});
  final Function onPressed;
  final Widget child;

  @override
  State<DarkStyledTouchableContainer> createState() => _DarkStyledTouchableContainerState();
}

class _DarkStyledTouchableContainerState extends State<DarkStyledTouchableContainer> {
  bool hovering = false;
  Tween<double> pressAnimOffsetY = Tween(begin: 0, end: 0);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => setState(() {
        hovering = true;
        pressAnimOffsetY = Tween(begin: 0, end: 3);
      }),
      onTapUp: (details) => setState(() {
        hovering = false;
        pressAnimOffsetY = Tween(begin: 3, end: 0);
        widget.onPressed();
      }),
      onTapCancel: () => setState(() {
        hovering = false;
        pressAnimOffsetY = Tween(begin: 3, end: 0);
      }),
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
          duration: const Duration(milliseconds: 100),
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

class LightStyledTouchableContainer extends StatefulWidget {
  const LightStyledTouchableContainer({super.key, required this.onPressed, required this.child});
  final Function onPressed;
  final Widget child;

  @override
  State<LightStyledTouchableContainer> createState() => _LightStyledTouchableContainerState();
}

class _LightStyledTouchableContainerState extends State<LightStyledTouchableContainer> {
  bool hovering = false;
  Tween<double> pressAnimOffsetY = Tween(begin: 0, end: 0);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => setState(() {
        hovering = true;
        pressAnimOffsetY = Tween(begin: 0, end: 3);
      }),
      onTapUp: (details) => setState(() {
        hovering = false;
        pressAnimOffsetY = Tween(begin: 3, end: 0);
        widget.onPressed();
      }),
      onTapCancel: () => setState(() {
        hovering = false;
        pressAnimOffsetY = Tween(begin: 3, end: 0);
      }),
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

class StyledTouchableContainer extends StatelessWidget {
  const StyledTouchableContainer({super.key, required this.theme, required this.onPressed, required this.child});
  final Themes theme;
  final Function onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) return DarkStyledTouchableContainer(onPressed: onPressed, child: child);
    return LightStyledTouchableContainer(onPressed: onPressed, child: child);
  }
}
