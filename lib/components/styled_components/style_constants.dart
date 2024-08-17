import 'package:flutter/material.dart';
import 'package:oneforall/constants.dart';

class StyleConstants {
  //* Dark Theme
  static Color darkBackgroundColor = const Color(0xFF24272C);
  static List<Shadow> darkInnerShadows = [
    Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 7, offset: const Offset(4, 4)),
    Shadow(color: Colors.white.withOpacity(0.1), blurRadius: 7, offset: const Offset(-2, -3))
  ];
  static List<Shadow> darkShadows = [
    const BoxShadow(
      offset: Offset(-3, -3),
      color: Color.fromRGBO(255, 255, 255, 0.10),
      blurRadius: 12,
    ),
    const BoxShadow(
      offset: Offset(6, 6),
      color: Color.fromRGBO(0, 0, 0, 0.50),
      blurRadius: 12,
    )
  ];
  static LinearGradient darkGradient = const LinearGradient(colors: [
    Color(0xFF2196F3),
    Color(0xFF673AB7)
  ]);

  //* Light
  static Color lightBackgroundColor = const Color(0xFFF1F1F1);
  static List<Shadow> lightShadows = [
    const BoxShadow(
      offset: Offset(4, 5),
      color: Color.fromRGBO(0, 0, 0, 0.25),
      blurRadius: 12,
    ),
  ];
}

Themes getThemeFromTheme(ColorScheme theme) {
  if (theme == lightTheme.colorScheme) {
    return Themes.light;
  }
  return Themes.dark;
}
