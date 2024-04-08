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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      filled: true,
      fillColor: theme.primary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: theme.onBackground,
        ),
      ),
      hintStyle: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold, color: theme.onBackground.withOpacity(0.25)),
    );
    return style;
  }
}

class BaseElevatedButtonInputStyle {
  BaseElevatedButtonInputStyle({
    required this.theme,
    required this.textTheme,
  });
  final ColorScheme theme;
  final TextTheme textTheme;

  late ButtonStyle style = ElevatedButton.styleFrom(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    backgroundColor: theme.secondary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    side: BorderSide(color: theme.tertiary, width: 1),
  );
}
