/// Low-level functions for manipulating dates and times.

import 'package:tuple/tuple.dart';

const int _secsPerDay = 86400;
const int _secsInHalfDay = _secsPerDay ~/ 2;
const int _rataDieAdjustmentSecs = 1721424 * _secsPerDay + _secsInHalfDay;

const List<int> _daysInMonthTable = [
  0,
  31, // Jan
  29, // Feb; non-leap years are a special case
  31, // Mar
  30, // Apr
  31, // May
  30, // Jun
  31, // Jul
  31, // Aug
  30, // Sep
  31, // Oct
  30, // Nov
  31, // Dec
];

const List<int> _julianMonthTable = [
  0,
  31,
  61,
  92,
  122,
  153,
  184,
  214,
  245,
  275,
  306,
  337,
];

/// Determines if a year is a leap year.
bool checkLeapYear(int year) =>
    year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

/// Returns the days in a given month.
int daysInMonth(int year, int month) {
  return _daysInMonthTable[month] -
      (month == 2 && !checkLeapYear(year) ? 1 : 0);
}

Tuple3<int, int, int> _secondsToHms(int seconds) {
  return Tuple3<int, int, int>(
      seconds ~/ 3600, (seconds ~/ 60) % 60, seconds % 60);
}

int _hmsToSeconds(int hour, int minutes, int seconds) {
  return hour * 3600 + minutes * 60 + seconds;
}

/// Converts seconds from an epoch (e.g. Julian Date or Rata Die)
/// to a whole numbered day. For Julian Date, this will be the day
/// starting at noon. For Rata Die, it will be the day starting at
/// midnight.
int epochSecondsToDay(int seconds) {
  if (seconds < 0) {
    --seconds;
  }
  return (seconds / _secsPerDay).floor();
}

/// Converts Julian date (in seconds) to Gregorian year, month day, hours
/// minutes, and seconds.
///
/// See: Baum, Peter. (2017). Date Algorithms.
Tuple6<int, int, int, int, int, int> julianDaySecondsToGregorian(
    int julianDaySeconds) {
  int z = (julianDaySeconds / _secsPerDay - 1721118.5).floor();
  int fractionalSeconds = (julianDaySeconds - _secsInHalfDay) % _secsPerDay;
  int h = 100 * z - 25;
  int a = (h / 3652425).floor();
  int b = a - (a / 4).floor();
  int year = ((100 * b + h) / 36525).floor();
  int c = b + z - 365 * year - (year / 4).floor();
  int month = (5 * c + 456) ~/ 153;
  int day = c - (153 * month - 457) ~/ 5;
  if (month > 12) {
    ++year;
    month -= 12;
  }
  Tuple3<int, int, int> t = _secondsToHms(fractionalSeconds);
  return Tuple6<int, int, int, int, int, int>(
      year, month, day, t.item1, t.item2, t.item3);
}

/// Converts a Gregorian date to a Julian Day (JD) in seconds.
/// This should only be limited by the size of ints, and works for
/// both positive and negative JDs.
///
/// See: Baum, Peter. (2017). Date Algorithms.
int gregorianToJulianDaySeconds(int year, int month, int day,
    [int hour = 12, int minute = 0, int second = 0]) {
  int z = year + (month - 14) ~/ 12;
  int f = _julianMonthTable[(month - 3) % 12]; // Shifted to start in March.
  return (day +
              f +
              365 * z +
              (z / 4).floor() -
              (z / 100).floor() +
              (z / 400).floor() +
              1721118) *
          _secsPerDay +
      _secsInHalfDay +
      _hmsToSeconds(hour, minute, second);
}

/// Converts Gregorian year, month, day to Rata Die microseconds for use
/// in local date calculations.
///
/// See https://en.wikipedia.org/wiki/Rata_Die.
int gregorianToRataDieSeconds(int year, int month, int day,
    [int hours = 0, int minutes = 0, int seconds = 0]) {
  return gregorianToJulianDaySeconds(
          year, month, day, hours, minutes, seconds) -
      _rataDieAdjustmentSecs;
}

/// Converts Rata Die (in seconds) to Gregorian year, month, day, hours,
/// minutes, and seconds.
///
/// See https://en.wikipedia.org/wiki/Rata_Die.
Tuple6<int, int, int, int, int, int> rataDieSecondsToGregorian(int n) {
  return julianDaySecondsToGregorian(n + _rataDieAdjustmentSecs);
}
