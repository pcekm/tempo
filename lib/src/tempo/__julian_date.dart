part of '../../tempo.dart';

/// Base class for classes that have a Julian Date.
///
/// At its core, this is a single number representing seconds and nanoseconds
/// since the start of the Julian period at noon, November 24, 4714 BC on the
/// proleptic Gregorian calendar.
abstract class _JulianDate extends _BigTime implements HasDate {
  _JulianDate._fromBigTime(super.ts) : super.copy();

  /// Builds a Julian date from individual parts.
  ///
  /// The resulting date is guaranteed to be valid, even if the inputs are
  /// not. Callers should not depend on any specific date resulting from
  /// invalid inputs.
  const _JulianDate(
      [int year = 0,
      int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int seconds = 0,
      int nanosecond = 0])
      // See: Baum, Peter. (2017). Date Algorithms.
      : this._jdStep1(
            year + (month - 14) ~/ 12, // Subtracts 1 if month is Jan or Feb
            (month - 3) % 12 + 3, // Remaps 1 -> 13 and 2 -> 14.
            day,
            hour * _nsPerHour +
                minute * _nsPerMinute +
                seconds * _nsPerSecond +
                nanosecond);

  /// Step 1 in the Julian date calculation.
  const _JulianDate._jdStep1(int yearPrime, int monthPrime, int day, int nanos)
      : this._jdStep2(
            day +
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
                    : (yearPrime + 1) ~/ 400 - 1) +
                1721118 +
                (nanos >= 0
                    ? nanos ~/ _nsPerDay
                    : (nanos + 1) ~/ _nsPerDay - 1),
            nanos % _nsPerDay);

  /// Step 2 in the Julian date calculation.
  const _JulianDate._jdStep2(int jdn, int nanos)
      : super(_sPerDay * (jdn - (nanos >= _noonNs ? 1 : 0)),
            (nanos + _noonNs) % _nsPerDay);

  static const _sPerDay = 86400;
  static const _nsPerSecond = 1000000000;
  static const _nsPerMinute = 60 * _nsPerSecond;
  static const _nsPerHour = 60 * _nsPerMinute;
  static const _nsPerDay = 24 * _nsPerHour;
  static const _noonNs = _nsPerDay ~/ 2;

  Timespan get _julianDate =>
      Timespan(seconds: _secondPart, nanoseconds: _nanosecondPart);

  /// The Julian Day Number of the day this date lands on.
  ///
  /// This is a whole number of days, and will be the same for all times of day on
  /// a given date. (Unlike [_julianDateDays], which changes at noon.)
  int get _julianDayNumber => (_julianDate + Timespan(hours: 12)).inDays;

  /// Converts a Julian day to years, months, days, and nanoseconds past
  /// midnight on the Gregorian calendar.
  Gregorian get _asGregorian => julianDayToGregorian(_julianDate);

  @override
  int get year => _asGregorian.year;
  @override
  int get month => _asGregorian.month;
  @override
  int get day => _asGregorian.day;
}
