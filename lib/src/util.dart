import 'package:tuple/tuple.dart';

const List<int> _daysInMonthLookup = [
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

/// Determines if a year is a leap year.
bool checkLeapYear(int year) =>
    year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

/// Returns the days in a given month.
int daysInMonth(int year, int month) {
  return _daysInMonthLookup[month] -
      (month == 2 && !checkLeapYear(year) ? 1 : 0);
}

/// Converts Julian Day to Year, Month, Day.
Tuple3<int, int, int> julianDaysToGregorian(int julianDays) {
  // Source: https://en.wikipedia.org/wiki/Julian_day
  const int y = 4716;
  const int j = 1401;
  const int m = 2;
  const int n = 12;
  const int r = 4;
  const int p = 1461;
  const int v = 3;
  const int u = 5;
  const int s = 153;
  const int w = 2;
  const int B = 274277;
  const int C = -38;

  final int f =
      julianDays + j + (((4 * julianDays + B) ~/ 146097) * 3) ~/ 4 + C;
  final int e = r * f + v;
  final int g = (e % p) ~/ r;
  final int h = u * g + w;

  final int D = (h % s) ~/ u + 1;
  final int M = (h ~/ s + m) % n + 1;
  final int Y = e ~/ p - y + (n + m - M) ~/ n;

  return Tuple3<int, int, int>(Y, M, D);
}

/// Converts Gregorian year, month, day to a Julian Day Number.
gregorianToJulianDay(int year, int month, int day) {
  return ((1461 * (year + 4800 + (month - 14) ~/ 12)) ~/ 4 +
      (367 * (month - 2 - 12 * ((month - 14) ~/ 12))) ~/ 12 -
      (3 * ((year + 4900 + (month - 14) ~/ 12) ~/ 100)) ~/ 4 +
      day -
      32075);
}
