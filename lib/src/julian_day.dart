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

/// A Julian Day equal to [day] + [fraction] / [denominator].
///
/// This tries to make no assumptions about the underlying time scale.
/// For example, if this is used to represent the last second of `2016-12-31`
/// UTC (a day with a leap second), the denominator could be one second
/// bigger than normal.
class JulianDay {
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
  ///
  /// See: Baum, Peter. (2017). Date Algorithms.
  factory JulianDay.fromGregorian(Gregorian date,
      [int denominator = _nsPerDay]) {
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

  /// Converts a [JulianDay] to years, months, days, and nanoseconds past
  /// noon on the Gregorian calendar.
  ///
  /// See: Baum, Peter. (2017). Date Algorithms.
  Gregorian toGregorian() {
    // int z = (day + fraction / denominator - 1721118.5).floor();
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

  /// Converts this to a **less precise** double.
  ///
  /// This can be quite handy, but the result will only have about millisecond
  /// precision.
  double toDouble() => day + fraction / denominator;

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