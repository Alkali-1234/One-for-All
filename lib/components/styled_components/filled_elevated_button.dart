import 'package:flutter/material.dart';

class FilledElevatedButton extends StatefulWidget {
  const FilledElevatedButton({super.key, required this.onPressed, required this.child, required this.color, this.shadowOpacity = 0.25});
  final Function onPressed;
  final Widget child;
  final Color color;
  final double shadowOpacity;

  @override
  State<FilledElevatedButton> createState() => _FilledElevatedButtonState();
}

class _FilledElevatedButtonState extends State<FilledElevatedButton> {
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
            color: widget.color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: hovering == false
                ? [
                    BoxShadow(
                      offset: const Offset(-3, -3),
                      color: widget.color.withOpacity(widget.shadowOpacity),
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
