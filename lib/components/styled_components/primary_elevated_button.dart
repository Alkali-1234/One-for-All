import 'package:flutter/material.dart';
import '../../constants.dart';

class DarkStyledPrimaryElevatedButton extends StatefulWidget {
  const DarkStyledPrimaryElevatedButton({super.key, required this.onPressed, required this.child});
  final Function onPressed;
  final Widget child;

  @override
  State<DarkStyledPrimaryElevatedButton> createState() => _DarkStyledPrimaryElevatedButtonState();
}

class _DarkStyledPrimaryElevatedButtonState extends State<DarkStyledPrimaryElevatedButton> {
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
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFF2196F3),
              Color(0xFF673AB7)
            ]),
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

class LightStyledPrimaryElevatedButton extends StatefulWidget {
  const LightStyledPrimaryElevatedButton({super.key, required this.onPressed, required this.child});
  final Function onPressed;
  final Widget child;

  @override
  State<LightStyledPrimaryElevatedButton> createState() => _LightStyledPrimaryElevatedButtonState();
}

class _LightStyledPrimaryElevatedButtonState extends State<LightStyledPrimaryElevatedButton> {
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
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFF21B38F),
              Color(0xFF19C17E)
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class StyledPrimaryElevatedButton extends StatelessWidget {
  const StyledPrimaryElevatedButton({super.key, required this.theme, required this.onPressed, required this.child});
  final Themes theme;
  final Function onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) return DarkStyledPrimaryElevatedButton(onPressed: onPressed, child: child);
    return LightStyledPrimaryElevatedButton(onPressed: onPressed, child: child);
  }
}
