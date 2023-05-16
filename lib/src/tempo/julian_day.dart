import 'package:meta/meta.dart';

import '../../tempo.dart';

/// A simple data object containing a Gregorian date + nanoseconds since
/// the beginning of the day.
@immutable
class Gregorian {
  final int year;
  final int month;
  final int day;
  final int nanosecond;

  Gregorian([this.year = 0, this.month = 1, this.day = 1, this.nanosecond = 0]);

  @override
  String toString() => '[$year, $month, $day, $nanosecond]';

  @override
  bool operator ==(Object other) =>
      other is Gregorian &&
      year == other.year &&
      month == other.month &&
      day == other.day &&
      nanosecond == other.nanosecond;

  @override
  int get hashCode => Object.hash(year, month, day, nanosecond);
}

const int _nsPerDay = 86400 * 1000000000;

// Lookup table for fromGregorian().
const List<int> _monthTable = [
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

/// Calculates the weekday for a given Julian day.
Weekday weekdayForJulianDay(Timespan julian) =>
    Weekday.values[(julian + Timespan(hours: 12)).dayPart % 7 + 1];

/// Converts a Gregorian date and time to a Julian Day (JD).
Timespan gregorianToJulianDay(Gregorian date, [int denominator = _nsPerDay]) {
  // See: Baum, Peter. (2017). Date Algorithms.
  int z = date.year + (date.month - 14) ~/ 12;
  int f = _monthTable[(date.month - 3) % 12]; // Shifted to start in March.
  int jdn = date.day +
      f +
      365 * z +
      (z / 4).floor() -
      (z / 100).floor() +
      (z / 400).floor() +
      1721118;
  return Timespan(
      days: jdn, nanoseconds: (denominator / 2).floor() + date.nanosecond);
}

/// Converts a [JulianDay] to years, months, days, and nanoseconds past
/// midnight on the Gregorian calendar.
Gregorian julianDayToGregorian(Timespan julian) {
  // See: Baum, Peter. (2017). Date Algorithms.
  int z = julian.dayPart -
      1721118 +
      ((julian.nanosecondPart - (_nsPerDay / 2).floor()) / _nsPerDay).floor();
  int remainder = (julian.nanosecondPart - (_nsPerDay / 2).floor()) % _nsPerDay;
  int h = 100 * z - 25;
  int a = (h / 3652425).floor();
  int b = a - (a / 4).floor();
  int Y = ((100 * b + h) / 36525).floor();
  int c = b + z - 365 * Y - (Y / 4).floor();
  int M = (5 * c + 456) ~/ 153;
  int D = c - (153 * M - 457) ~/ 5;
  if (M > 12) {
    ++Y;
    M -= 12;
  }
  return Gregorian(Y, M, D, remainder);
}
