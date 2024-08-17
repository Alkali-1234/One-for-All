import 'package:flutter/material.dart';

import 'inner_shadow.dart';

class NeumorphicSwitch extends StatefulWidget {
  const NeumorphicSwitch({super.key, this.initialValue = false, required this.onChanged, this.width = 60});
  final bool initialValue;
  final Function onChanged;
  final double width;

  @override
  State<NeumorphicSwitch> createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch> {
  late bool value = widget.initialValue;

  double dragPosition = 0.0;

  bool tapDown = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            tapDown = true;
          });
        },
        onTap: () {
          setState(() {
            value = !value;
            tapDown = false;
          });
          widget.onChanged();
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            dragPosition += details.delta.dx;
          });
        },
        onHorizontalDragEnd: (details) {
          setState(() {
            if (dragPosition < 0) {
              value = false;
            }
            if (dragPosition > 0) {
              value = true;
            }
            dragPosition = 0.0;
            tapDown = false;
          });
        },
        child: LayoutBuilder(builder: (context, constraints) {
          return InnerShadow(
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 7, offset: const Offset(4, 4)),
            ],
            child: AnimatedContainer(
              curve: Curves.easeInOut,
              alignment: value == false ? Alignment.centerLeft : Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 15 / 2),
              width: double.infinity,
              height: 30,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(color: value == false ? Colors.red : Colors.green, borderRadius: BorderRadius.circular(100)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 20,
                width: tapDown ? constraints.maxWidth / 2 : 20,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 7, offset: const Offset(1, 1))
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}
