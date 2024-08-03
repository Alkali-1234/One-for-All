import 'package:flutter/material.dart';
import '../../constants.dart';

class DarkStyledIconButton extends StatefulWidget {
  const DarkStyledIconButton({super.key, required this.onPressed, required this.icon, required this.size});
  final Function onPressed;
  final IconData icon;
  final double? size;

  @override
  State<DarkStyledIconButton> createState() => _DarkStyledIconButtonState();
}

class _DarkStyledIconButtonState extends State<DarkStyledIconButton> {
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
            child: Icon(
              widget.icon,
              size: widget.size,
              color: Colors.white,
              shadows: hovering == false
                  ? [
                      BoxShadow(
                        offset: Offset(-value, -value),
                        color: const Color.fromRGBO(255, 255, 255, 0.10),
                        blurRadius: 12,
                      ),
                      BoxShadow(
                        offset: Offset(value * 2, value * 2),
                        color: const Color.fromRGBO(0, 0, 0, 0.50),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
          );
        },
        tween: pressAnimOffsetY,
      ),
    );
  }
}

class LightStyledIconButton extends StatefulWidget {
  const LightStyledIconButton({super.key, required this.onPressed, required this.icon, this.size});
  final Function onPressed;
  final IconData icon;
  final double? size;

  @override
  State<LightStyledIconButton> createState() => _LightStyledIconButtonState();
}

class _LightStyledIconButtonState extends State<LightStyledIconButton> {
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
            child: Icon(
              size: widget.size,
              widget.icon,
              color: Colors.black,
              shadows: hovering == false
                  ? [
                      BoxShadow(
                        offset: Offset(value * (4 / 3), value * (5 / 3)),
                        color: const Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
          );
        },
        tween: pressAnimOffsetY,
      ),
    );
  }
}

class StyledIconButton extends StatelessWidget {
  const StyledIconButton({super.key, required this.theme, required this.onPressed, required this.icon, this.size});
  final Themes theme;
  final Function onPressed;
  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) return DarkStyledIconButton(onPressed: onPressed, icon: icon, size: size);
    return LightStyledIconButton(onPressed: onPressed, icon: icon, size: size);
  }
}
