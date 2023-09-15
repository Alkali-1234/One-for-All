import 'package:flutter/material.dart';

class TextInputStyle {
  TextInputStyle({
    required this.theme,
    required this.textTheme,
  });
  final ColorScheme theme;
  final TextTheme textTheme;

  InputDecoration getTextInputStyle() {
    final style = InputDecoration(
      filled: true,
      fillColor: theme.primary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: theme.primary,
        ),
      ),
    );
    return style;
  }
}
