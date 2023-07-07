import 'package:flutter/material.dart';

const pi = 3.14;

const rareMainTheme = Color.fromRGBO(0, 163, 255, 1);
get getRareMainTheme => rareMainTheme;

const primaryGradient = LinearGradient(
  colors: [
    Color.fromRGBO(0, 163, 255, 1),
    Color.fromRGBO(0, 56, 164, 1),
  ],
  stops: [0.0, 1.0],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

get getPrimaryGradient => primaryGradient;

const primaryShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.5),
  blurRadius: 10,
  offset: Offset(0, 1),
);

get getPrimaryShadow => primaryShadow;
