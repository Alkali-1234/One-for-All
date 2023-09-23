import 'package:flutter/material.dart';

const pi = 3.14;

const rareMainTheme = Color.fromRGBO(0, 163, 255, 1);
get getRareMainTheme => rareMainTheme;

//May change
LinearGradient primaryGradient = const LinearGradient(
  colors: [
    Color.fromRGBO(0, 163, 255, 1),
    Color.fromRGBO(0, 163, 255, 1),
  ],
  stops: [
    0.0,
    1.0
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

get getPrimaryGradient => primaryGradient;
set setPrimaryGradient(LinearGradient gradient) => primaryGradient = gradient;

const primaryShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.5),
  blurRadius: 10,
  offset: Offset(0, 1),
);

get getPrimaryShadow => primaryShadow;

const types = {
  0: 'Quiz',
  1: 'Flashcards',
  2: 'Notes',
};

get getTypes => types;

const subjects = {
  0: 'Math',
  1: 'Science',
  2: 'English',
  3: 'History',
  4: 'IT',
  5: 'Art',
  6: 'Music',
  7: 'PE',
  8: 'Other',
};

get getSubjects => subjects;

const dueDates = {
  0: -1,
  1: 3,
  2: 7,
  3: 14,
};

get getDueDates => dueDates;

const stdCalendarData = {
  "week1": {
    "dates": [
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ]
  },
  "week2": {
    "dates": [
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ]
  },
  "week3": {
    "dates": [
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ]
  },
  "week4": {
    "dates": [
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ]
  },
  "week5": {
    "dates": [
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ]
  },
  "week6": {
    "dates": [
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ]
  }
};

get getStdCalendarData => stdCalendarData;

const monthsOfTheYear = {
  1: 'January',
  2: 'Febuary',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};

get getMonthsOfTheYear => monthsOfTheYear;

const initialLoadData = {
  "data": {
    "hasLoggedIn": false,
    "email": "",
    "password": "",
  }
};

ThemeData defaultBlueTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color.fromRGBO(0, 0, 0, 0.25),
    secondary: const Color.fromRGBO(255, 255, 255, 0.25),
    tertiary: const Color.fromRGBO(255, 255, 255, 0.50),
    primaryContainer: const Color.fromRGBO(255, 255, 255, 0.07),
    onPrimary: const Color.fromRGBO(255, 255, 255, 1),
    onSecondary: const Color.fromRGBO(255, 255, 255, 1),
    background: const Color.fromRGBO(24, 4, 44, 1.0),
    error: Colors.red,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
  ),
  useMaterial3: true,
);

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color.fromRGBO(0, 0, 0, 0.25),
    secondary: const Color.fromRGBO(255, 255, 255, 0.125),
    tertiary: const Color.fromRGBO(255, 255, 255, 0.25),
    primaryContainer: const Color.fromRGBO(255, 255, 255, 0.07),
    onPrimary: const Color.fromRGBO(255, 255, 255, 1),
    onSecondary: const Color.fromRGBO(255, 255, 255, 1),
    background: const Color.fromRGBO(30, 30, 30, 1.0),
    error: Colors.red,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
  ),
  useMaterial3: true,
);

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color.fromRGBO(0, 0, 0, 0.25),
    secondary: const Color.fromRGBO(0, 0, 0, 0.125),
    tertiary: const Color.fromRGBO(0, 0, 0, 0.2),
    primaryContainer: const Color.fromRGBO(0, 0, 0, 0.07),
    onPrimary: const Color.fromRGBO(0, 0, 0, 1),
    onSecondary: const Color.fromRGBO(0, 0, 0, 1),
    onBackground: const Color.fromRGBO(0, 0, 0, 1),
    background: const Color.fromRGBO(255, 255, 255, 1.0),
    error: Colors.red,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color.fromRGBO(0, 0, 0, 1.0),
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      color: Color.fromRGBO(0, 0, 0, 1.0),
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      color: Color.fromRGBO(0, 0, 0, 1.0),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
  ),
  useMaterial3: true,
);

const defaultBluePrimaryGradient = LinearGradient(
  colors: [
    // candidate 1
    // Color.fromRGBO(0, 150, 255, 1),
    // Color.fromRGBO(0, 150, 255, 1),
    // candidate 2
    Color.fromRGBO(31, 81, 255, 1),
    Color.fromRGBO(31, 81, 255, 1),
  ],
  stops: [
    0.0,
    1.0
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

get getDefaultBluePrimaryGradient => defaultBluePrimaryGradient;

const darkPrimaryGradient = LinearGradient(
  colors: [
    Color.fromRGBO(72, 72, 72, 1),
    Color.fromRGBO(72, 72, 72, 1),
  ],
  stops: [
    0.0,
    1.0
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

get getDarkPrimaryGradient => darkPrimaryGradient;

const lightPrimaryGradient = LinearGradient(colors: [
  Color.fromRGBO(130, 130, 130, 1),
  Color.fromRGBO(130, 130, 130, 1)
]);

get getLightPrimaryGradient => lightPrimaryGradient;

enum quizTypes {
  multipleChoice,
  trueFalse,
  dropdown,
  reorder,
}
