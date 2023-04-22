import 'weekday.dart';
import 'timespan.dart';

/// A simple data object containing a Gregorian date + nanoseconds since
/// the beginning of the day.
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

/// TODO: This doesn't work properly in JS.
///
/// A Julian Day equal to [day] + [fraction] / [denominator].
///
/// This tries to make no assumptions about the underlying time scale.
/// For example, if this is used to represent the last second of `2016-12-31`
/// UTC (a day with a leap second), the denominator could be one second
/// bigger than normal.
//
// Note: It would be cool if this could be implemented in terms of
// Timespan. There are some issues with doing that, however. Mainly I'm
// not keen on complicating the end-user API with the ability to choose
// arbitrary denominators. So far I'm not actually using arbitrary
// denominators, though. And if I can implement leap seconds without them,
// then this becomes easier.
class JulianDay implements Comparable<JulianDay> {
  // The number of nanoseconds in a day.
  static const int _nsPerDay = 86400 * 1000000000;

  // Lookup table for fromGregorian().
  static const List<int> _monthTable = [
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

  /// The whole numbered day. Also called the Julian Day Number.
  ///
  /// May be positive or negative.
  final int day;

  /// The fractional part of the day. Always positive.
  ///
  /// This field has a denominator of [denominator].
  final int fraction;

  /// The denominator for [fraction].
  ///
  /// In almost every case this will be the number of nanoseconds in a day,
  /// `86400 ⨉ 10^9`, but there could be exceptions for different precisions
  /// or (gasp!) time scales with leap seconds.
  final int denominator;

  JulianDay._(this.day, this.fraction, this.denominator);

  /// Constructs a julian day equal to [day] + [fraction] / [denominator].
  ///
  /// Either [day] or [fraction] may be any number, but they will be
  /// normalized to make [this.fraction] positive and less than denominator.
  ///
  /// The [denominator]  must be greater than zero and defaults to
  /// the number of nanoseconds in a day.
  factory JulianDay(
      [int day = 0, int fraction = 0, int denominator = _nsPerDay]) {
    assert(denominator > 0);
    day += (fraction / denominator).floor();
    fraction = fraction.remainder(denominator);
    if (fraction.isNegative) {
      fraction = denominator + fraction;
    }
    assert(!fraction.isNegative);
    return JulianDay._(day, fraction, denominator);
  }

  /// Converts a Gregorian date and time to a Julian Day (JD).
  factory JulianDay.fromGregorian(Gregorian date,
      [int denominator = _nsPerDay]) {
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
    return JulianDay(
        jdn, (denominator / 2).floor() + date.nanosecond, denominator);
  }

  /// Constructs a Julian day from the [Timespan] since the start of the Julian
  /// period.
  factory JulianDay.fromTimespan(Timespan span) {
    return JulianDay(span.dayPart, span.nanosecondPart);
  }

  /// Converts a [JulianDay] to years, months, days, and nanoseconds past
  /// midnight on the Gregorian calendar.
  Gregorian toGregorian() {
    // See: Baum, Peter. (2017). Date Algorithms.
    int z = day -
        1721118 +
        ((fraction - (denominator / 2).floor()) / denominator).floor();
    int remainder = (fraction - (denominator / 2).floor()) % denominator;
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

  /// Adds days and nanoseconds and returns a new object.
  JulianDay plus(int days, [int nanoseconds = 0]) =>
      JulianDay(day + days, fraction + nanoseconds, denominator);

  /// Subtracts days and nanoseconds and returns a new object.
  JulianDay minus(int days, [int nanoseconds = 0]) =>
      JulianDay(day - days, fraction - nanoseconds, denominator);

  /// Returns the day of the week.
  Weekday get weekday => Weekday.values[plus(0, _nsPerDay ~/ 2).day % 7 + 1];

  /// Converts this to a **less precise** double.
  ///
  /// This can be quite handy, but the result will only have about millisecond
  /// precision.
  double toDouble() => day + fraction / denominator;

  @override
  int compareTo(JulianDay other) {
    if (day == other.day) {
      return Comparable.compare(fraction, other.fraction);
    }
    return Comparable.compare(day, other.day);
  }

  @override
  String toString() => '[$day + $fraction / $denominator]';

  @override
  bool operator ==(Object other) =>
      (other is JulianDay) &&
      day == other.day &&
      fraction == other.fraction &&
      denominator == other.denominator;

  @override
  int get hashCode => Object.hash(day, fraction, denominator);
}
