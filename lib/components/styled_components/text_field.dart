import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';

import 'inner_shadow.dart';

class StyledDarkThemeTextField extends StatefulWidget {
  const StyledDarkThemeTextField({super.key, this.controller, this.hint, this.onChanged, this.textField});
  final TextEditingController? controller;
  final String? hint;
  final Function? onChanged;
  final TextField? textField;

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
                child: widget.textField == null
                    ? TextField(
                        controller: widget.controller,
                        onChanged: widget.onChanged != null ? (value) => widget.onChanged!(value) : null,
                        style: textTheme.displaySmall,
                        cursorColor: Colors.white,
                        decoration: InputDecoration.collapsed(hintText: widget.hint, hintStyle: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: textTheme.displaySmall!.color!.withOpacity(0.5))),
                      )
                    : copyWithTextField(
                        textField: widget.textField,
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
  const StyledLightThemeTextField({super.key, this.controller, this.hint, this.onChanged, this.textField});
  final TextEditingController? controller;
  final String? hint;
  final Function? onChanged;
  final TextField? textField;

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
                child: widget.textField == null
                    ? TextField(
                        controller: widget.controller,
                        onChanged: widget.onChanged != null ? (value) => widget.onChanged!(value) : null,
                        style: textTheme.displaySmall,
                        decoration: InputDecoration.collapsed(hintText: widget.hint, hintStyle: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: textTheme.displaySmall!.color!.withOpacity(0.5))),
                      )
                    : copyWithTextField(
                        textField: widget.textField,
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
  const StyledTextField({super.key, required this.theme, this.onChanged, this.controller, this.hint, this.textField});
  final Themes theme;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hint;
  final TextField? textField;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) {
      return StyledDarkThemeTextField(
        onChanged: onChanged,
        controller: controller,
        hint: hint,
        textField: textField,
      );
    }
    return StyledLightThemeTextField(
      onChanged: onChanged,
      controller: controller,
      hint: hint,
      textField: textField,
    );
  }
}

TextField copyWithTextField({
  TextField? textField,
  TextEditingController? controller,
  String? hintText,
  TextStyle? style,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  bool? obscureText,
  bool? autofocus,
  bool? enabled,
  FocusNode? focusNode,
  Function(String)? onChanged,
  Function(String)? onSubmitted,
  InputDecoration? decoration,
  Color? cursorColor,
}) {
  return TextField(
    controller: controller ?? textField?.controller,
    onChanged: onChanged ?? textField?.onChanged,
    onSubmitted: onSubmitted ?? textField?.onSubmitted,
    keyboardType: keyboardType ?? textField?.keyboardType,
    textInputAction: textInputAction ?? textField?.textInputAction,
    obscureText: obscureText ?? textField?.obscureText ?? false,
    autofocus: autofocus ?? textField?.autofocus ?? false,
    enabled: enabled ?? textField?.enabled,
    focusNode: focusNode ?? textField?.focusNode,
    style: style ?? textField?.style,
    cursorColor: cursorColor ?? textField?.cursorColor,
    decoration: decoration ??
        textField?.decoration?.copyWith(
          hintText: hintText ?? textField.decoration?.hintText,
          hintStyle: style ?? textField.decoration?.hintStyle,
        ),
  );
}
