import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';

import 'inner_shadow.dart';

class StyledDarkThemeTextField extends StatefulWidget {
  const StyledDarkThemeTextField({super.key, this.controller, this.hint, this.onChanged});
  final TextEditingController? controller;
  final String? hint;
  final Function? onChanged;

  @override
  State<StyledDarkThemeTextField> createState() => _StyledDarkThemeTextFieldState();
}

class _StyledDarkThemeTextFieldState extends State<StyledDarkThemeTextField> {
  @override
  Widget build(BuildContext context) {
    var textTheme = darkTheme.textTheme;
    return Stack(
      children: [
        InnerShadow(
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 7, offset: const Offset(4, 4)),
              Shadow(color: Colors.white.withOpacity(0.1), blurRadius: 7, offset: const Offset(-2, -3))
            ],
            child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF24272C),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const SizedBox())),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: widget.onChanged != null ? (value) => widget.onChanged!(value) : null,
                  style: textTheme.displaySmall,
                  cursorColor: Colors.white,
                  decoration: InputDecoration.collapsed(hintText: widget.hint, hintStyle: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: textTheme.displaySmall!.color!.withOpacity(0.5))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StyledLightThemeTextField extends StatefulWidget {
  const StyledLightThemeTextField({super.key, this.controller, this.hint, this.onChanged});
  final TextEditingController? controller;
  final String? hint;
  final Function? onChanged;

  @override
  State<StyledLightThemeTextField> createState() => _StyledLightThemeTextFieldState();
}

class _StyledLightThemeTextFieldState extends State<StyledLightThemeTextField> {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        InnerShadow(
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 7, offset: const Offset(4, 4)),
              Shadow(color: Colors.white.withOpacity(1), blurRadius: 7, offset: const Offset(-2, -3))
            ],
            child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const SizedBox())),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: widget.onChanged != null ? (value) => widget.onChanged!(value) : null,
                  style: textTheme.displaySmall,
                  decoration: InputDecoration.collapsed(hintText: widget.hint, hintStyle: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: textTheme.displaySmall!.color!.withOpacity(0.5))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StyledTextField extends StatelessWidget {
  const StyledTextField({super.key, required this.theme, this.onChanged, this.controller, this.hint});
  final Themes theme;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) {
      return StyledDarkThemeTextField(
        onChanged: onChanged,
        controller: controller,
        hint: hint,
      );
    }
    return StyledLightThemeTextField(
      onChanged: onChanged,
      controller: controller,
      hint: hint,
    );
  }
}
