part of '../../tempo.dart';

/// Base class for classes based on a Rata Die date.
///
/// At its core, this is a single number representing seconds and nanoseconds
/// since January 1, AD 1 on the proleptic Gregorian calendar.
class _RataDieDate extends _BigTime implements HasDate {
  _RataDieDate._fromBigTime(super.bigTime) : super.copy();

  /// Builds a Rata Die date from individual parts.
  ///
  /// The resulting date is guaranteed to be valid, even if the inputs are
  /// not. Callers should not depend on any specific date resulting from
  /// invalid inputs.
  const _RataDieDate(
      [int year = 0,
      int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int seconds = 0,
      int nanosecond = 0])
      // Step 1: Adjust the year and month to create an alternative calendar
      // that begins on March 1, where months are numbered 3=March to
      // 14=February. On this calendar, leap days occur on the last day of
      // the year.
      //
      // (See: Baum, Peter. (2017). Date Algorithms.)
      : this._rdStep2(
            year + (month - 14) ~/ 12, // Subtracts 1 if month is Jan or Feb
            (month - 3) % 12 + 3, // Remaps 1 -> 13 and 2 -> 14.
            day,
            hour,
            minute,
            seconds,
            nanosecond);

  /// Step 2: Find the fractional number of days since midnight, Jan 1, AD 1.
  const _RataDieDate._rdStep2(int yearPrime, int monthPrime, int day, int hour,
      int minute, int seconds, int nanosecond)
      : super(
            days: (day +
                // This one is supposed to be truncating division, not floor
                // like the others below:
                (monthPrime * 153 - 457) ~/ 5 +
                365 * yearPrime +
                // This construct does floor division instead of truncation
                // towards zero:
                //    (n >= 0 ? n ~/ d : (n + 1) ~/ d - 1)
                (yearPrime >= 0 ? yearPrime ~/ 4 : (yearPrime + 1) ~/ 4 - 1) -
                (yearPrime >= 0
                    ? yearPrime ~/ 100
                    : (yearPrime + 1) ~/ 100 - 1) +
                (yearPrime >= 0
                    ? yearPrime ~/ 400
                    : (yearPrime + 1) ~/ 400 - 1) -
                306),
            hours: hour,
            minutes: minute,
            seconds: seconds,
            nanoseconds: nanosecond);

  static const _nsPerSecond = 1000000000;
  static const _sPerDay = 86400;
  static const _nsPerDay = 86400 * _nsPerSecond;

  Timespan get _asTimespan =>
      Timespan(seconds: _secondPart, nanoseconds: _nanosecondPart);

  /// Converts a Rata Die date to years, months, days, and nanoseconds past
  /// midnight on the Gregorian calendar.
  ({int year, int month, int day}) _toGregorian() {
    // See: Baum, Peter. (2017). Date Algorithms.
    final nanosOfDay = _asTimespan.inSeconds.remainder(_sPerDay) +
        (_asTimespan.nanosecondPart / _nsPerDay).floor();
    final z = _asTimespan.inDays + 306 + (nanosOfDay / _nsPerDay).floor();
    final g = z - 0.25;
    final a = (g / 36524.25).floor();
    final b = a - (a / 4).floor();
    final y = ((b + g) / 365.25).floor();
    final c = z + a - (a / 4).floor() - (365.25 * y).floor();
    final m = (5 * c + 456) ~/ 153;
    final f = (153 * m - 457) ~/ 5;

    final res = (year: y + m ~/ 13, month: m - 12 * (m ~/ 13), day: c - f);
    return res;
  }

  // See: Baum, Peter. (2017). Date Algorithms.
  @override
  int get year => _toGregorian().year;

  @override
  int get month => _toGregorian().month;

  @override
  int get day => _toGregorian().day;

  @override
  Weekday get weekday => Weekday.values[(_asTimespan.inDays - 1) % 7 + 1];

  @override
  int get ordinalDay =>
      _asTimespan.inDays - LocalDate(year)._asTimespan.inDays + 1;

  @override
  bool get inLeapYear => checkLeapYear(year);
}
