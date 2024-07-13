import "package:flutter/material.dart";
import "package:oneforall/constants.dart";

class DarkStyledContainer extends Container {
  DarkStyledContainer({super.key, super.child, super.height, super.width});

  @override
  Decoration? get decoration => BoxDecoration(color: darkTheme.colorScheme.background, borderRadius: BorderRadius.circular(20), boxShadow: const [
        BoxShadow(
          offset: Offset(-3, -3),
          color: Color.fromRGBO(255, 255, 255, 0.07),
          blurRadius: 12,
        ),
        BoxShadow(
          offset: Offset(6, 6),
          color: Color.fromRGBO(0, 0, 0, 0.25),
          blurRadius: 12,
        ),
      ]);
}

class LightStyledContainer extends Container {
  LightStyledContainer({super.key, super.child, super.height, super.width});

  @override
  Decoration? get decoration => BoxDecoration(color: lightTheme.colorScheme.background, borderRadius: BorderRadius.circular(20), boxShadow: const [
        BoxShadow(
          offset: Offset(4, 5),
          color: Color.fromRGBO(0, 0, 0, 0.125),
          blurRadius: 12,
        ),
      ]);
}

class StyledContainer extends StatelessWidget {
  const StyledContainer({
    super.key,
    required this.theme,
  });
  final Themes theme;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) return DarkStyledContainer();
    return LightStyledContainer();
  }
}
