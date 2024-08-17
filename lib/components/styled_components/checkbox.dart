import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';

import 'inner_shadow.dart';

class DarkNeumorphicCheckbox extends StatefulWidget {
  const DarkNeumorphicCheckbox({super.key, this.onValueChanged});
  final Function? onValueChanged;

  @override
  State<DarkNeumorphicCheckbox> createState() => _DarkNeumorphicCheckboxState();
}

class _DarkNeumorphicCheckboxState extends State<DarkNeumorphicCheckbox> {
  bool value = false;
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          hover = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          hover = false;
        });
      },
      onTapCancel: () {
        setState(() {
          hover = false;
        });
      },
      onTap: () {
        setState(() {
          value = !value;
        });
        if (widget.onValueChanged != null) {
          widget.onValueChanged!(value);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          InnerShadow(
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 7, offset: const Offset(4, 4)),
              Shadow(color: Colors.white.withOpacity(0.1), blurRadius: 7, offset: const Offset(-2, -3))
            ],
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFF24272C), borderRadius: BorderRadius.all(Radius.circular(5))),
              height: 30,
              width: 30,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: child.key == const ValueKey('icon_false') ? Tween<double>(begin: 1, end: 0.75).animate(animation) : Tween<double>(begin: 0.75, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: hover == true
                ? const Icon(
                    Icons.horizontal_rule_rounded,
                    color: Colors.white,
                  )
                : value == false
                    ? Container(key: const ValueKey('icon_false'))
                    : const Icon(
                        key: ValueKey('icon_true'),
                        Icons.check_rounded,
                        color: Colors.green,
                      ),
          ),
        ],
      ),
    );
  }
}

class LightNeumorphicCheckbox extends StatefulWidget {
  const LightNeumorphicCheckbox({super.key, this.onValueChanged});
  final Function? onValueChanged;

  @override
  State<LightNeumorphicCheckbox> createState() => _LightNeumorphicCheckboxState();
}

class _LightNeumorphicCheckboxState extends State<LightNeumorphicCheckbox> {
  bool value = false;
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          hover = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          hover = false;
        });
      },
      onTapCancel: () {
        setState(() {
          hover = false;
        });
      },
      onTap: () {
        setState(() {
          value = !value;
        });
        if (widget.onValueChanged != null) {
          widget.onValueChanged!(value);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          InnerShadow(
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 7, offset: const Offset(4, 4)),
              Shadow(color: Colors.white.withOpacity(0.1), blurRadius: 7, offset: const Offset(-2, -3))
            ],
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFF1F1F1), borderRadius: BorderRadius.all(Radius.circular(5))),
              height: 30,
              width: 30,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: child.key == const ValueKey('icon_false') ? Tween<double>(begin: 1, end: 0.75).animate(animation) : Tween<double>(begin: 0.75, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: hover == true
                ? const Icon(
                    Icons.horizontal_rule_rounded,
                    color: Colors.black,
                  )
                : value == false
                    ? Container(key: const ValueKey('icon_false'))
                    : const Icon(
                        key: ValueKey('icon_true'),
                        Icons.check_rounded,
                        color: Colors.green,
                      ),
          ),
        ],
      ),
    );
  }
}

class NeumorphicCheckbox extends StatelessWidget {
  const NeumorphicCheckbox({super.key, this.onValueChanged, required this.theme});
  final Function? onValueChanged;
  final Themes theme;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) {
      return DarkNeumorphicCheckbox(
        onValueChanged: onValueChanged,
      );
    }
    return LightNeumorphicCheckbox(
      onValueChanged: onValueChanged,
    );
  }
}
