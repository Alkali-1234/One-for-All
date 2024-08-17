import "package:flutter/material.dart";
import "package:oneforall/constants.dart";

class DarkStyledContainer extends Container {
  DarkStyledContainer({super.key, super.child, super.height, super.width});

  @override
  Decoration? get decoration => BoxDecoration(color: darkTheme.colorScheme.background, borderRadius: BorderRadius.circular(20), boxShadow: const [
        BoxShadow(
          offset: Offset(-3, -3),
          color: Color.fromRGBO(255, 255, 255, 0.05),
          blurRadius: 12,
        ),
        BoxShadow(
          offset: Offset(6, 6),
          color: Color.fromRGBO(0, 0, 0, 0.2),
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
          color: Color.fromRGBO(0, 0, 0, 0.11),
          blurRadius: 12,
        ),
      ]);
}

class StyledContainer extends StatelessWidget {
  const StyledContainer({super.key, required this.theme, this.child, this.height, this.width});
  final Themes theme;
  final Widget? child;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (theme == Themes.dark) {
      return DarkStyledContainer(
        height: height,
        width: width,
        child: child,
      );
    }
    return LightStyledContainer(height: height, width: width, child: child);
  }
}
