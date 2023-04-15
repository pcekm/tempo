/// Low-level functions for manipulating dates and times.

import 'package:fixnum/fixnum.dart';
import 'package:tuple/tuple.dart';

const int _micro = 1000000;

const int _usecPerSecond = _micro;
const int _usecPerMinute = 60 * _usecPerSecond;
const int _usecPerHour = 60 * _usecPerMinute;
const int _usecPerDay = 24 * _usecPerHour;
const int _usecPerHalfDay = _usecPerDay ~/ 2;

final Int64 _rataDieAdjustmentNs =
    Int64(1721424) * _usecPerDay + _usecPerHalfDay;

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

// Converts microseconds to hours, minutes and seconds, and microseconds.
Tuple4<int, int, int, int> _usecToHmsn(int usec) {
  return Tuple4<int, int, int, int>(
      usec ~/ _usecPerHour,
      (usec ~/ _usecPerMinute) % 60,
      (usec ~/ _usecPerSecond) % 60,
      usec % _micro);
}

int _hmsnToUsec(int hour, int minute, int second, int microsecond) {
  return hour * _usecPerHour +
      minute * _usecPerMinute +
      second * _usecPerSecond +
      microsecond;
}

// Converts microseconds to a fractional day: usec / _usecPerDay.
// This is a bit tricky because Int64 only does truncating division.
num _divideUsecByDay(Int64 usec) {
  // This works because _usecsPerDay factors to 2^13 * 3^3 * 5^8.
  // Which means we can shift off the lower 13 bits to get 51 bits that
  // fits into num, and then divide by 3^3 + 5^8 = 10546875.
  return (usec >> 13).toInt() / 10546875;
}

/// Converts microseconds from an epoch (e.g. Julian Date or Rata Die)
/// to a whole numbered day. For Julian Date, this will be the day
/// starting at noon. For Rata Die, it will be the day starting at
/// midnight.
int epochUsecToDay(Int64 usec) {
  if (usec < 0) {
    --usec;
  }
  return _divideUsecByDay(usec).floor();
}

/// Converts Julian date (in microseconds) to Gregorian year, month day, hour
/// minute, second, and microsecond.
///
/// See: Baum, Peter. (2017). Date Algorithms.
Tuple7<int, int, int, int, int, int, int> julianDayUsecToGregorian(
    Int64 julianDayUsec) {
  int z = (_divideUsecByDay(julianDayUsec - _usecPerHalfDay) - 1721118).floor();
  int remainder = ((julianDayUsec - _usecPerHalfDay) % _usecPerDay).toInt();
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
  Tuple4<int, int, int, int> t = _usecToHmsn(remainder);
  return Tuple7<int, int, int, int, int, int, int>(
      year, month, day, t.item1, t.item2, t.item3, t.item4);
}

/// Converts a Gregorian date and time to a Julian Day (JD) in microseconds.
/// This should only be limited by the size of Int64, and works for
/// both positive and negative JDs.
///
/// See: Baum, Peter. (2017). Date Algorithms.
Int64 gregorianToJulianDayUsec(int year, int month, int day,
    [int hour = 12, int minute = 0, int second = 0, int microsecond = 0]) {
  int z = year + (month - 14) ~/ 12;
  int f = _julianMonthTable[(month - 3) % 12]; // Shifted to start in March.
  Int64 jdn = Int64(day +
      f +
      365 * z +
      (z / 4).floor() -
      (z / 100).floor() +
      (z / 400).floor() +
      1721118);
  return jdn * _usecPerDay +
      _usecPerHalfDay +
      _hmsnToUsec(hour, minute, second, microsecond);
}

/// Converts Gregorian date and time to Rata Die microseconds for use
/// in local date calculations.
///
/// See https://en.wikipedia.org/wiki/Rata_Die.
Int64 gregorianToRataDieUsec(int year, int month, int day,
    [int hour = 0, int minute = 0, int second = 0, int microsecond = 0]) {
  return gregorianToJulianDayUsec(
          year, month, day, hour, minute, second, microsecond) -
      _rataDieAdjustmentNs;
}

/// Converts Rata Die (in nanoseconds) to Gregorian year, month, day, hour,
/// minute, second and nanosecond.
///
/// See https://en.wikipedia.org/wiki/Rata_Die.
Tuple7<int, int, int, int, int, int, int> rataDieUsecToGregorian(Int64 rd) {
  return julianDayUsecToGregorian(rd + _rataDieAdjustmentNs);
}
