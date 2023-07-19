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
    "dates": [0, 0, 0, 0, 0, 0, 0]
  },
  "week2": {
    "dates": [0, 0, 0, 0, 0, 0, 0]
  },
  "week3": {
    "dates": [0, 0, 0, 0, 0, 0, 0]
  },
  "week4": {
    "dates": [0, 0, 0, 0, 0, 0, 0]
  },
  "week5": {
    "dates": [0, 0, 0, 0, 0, 0, 0]
  },
  "week6": {
    "dates": [0, 0, 0, 0, 0, 0, 0]
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
  "data" : {
    "hasLoggedIn" : false,
    "email" : "",
    "password" : "",

  }
};
