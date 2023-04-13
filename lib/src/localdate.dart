import 'dart:math';

import 'package:sprintf/sprintf.dart';

import 'period.dart';
import 'util.dart';
import 'weekday.dart';

/// Contains a local date on the proleptic Gregorian calendar with no timezone.
class LocalDate {
  static const int _daysPerWeek = 7;

  final int year;
  final int month;
  final int day;

  LocalDate([this.year = 0, this.month = 1, this.day = 1]) {
    _validate();
  }

  factory LocalDate._fromJulianDays(int days) {
    var parts = julianDaysToGregorian(days);
    return LocalDate(parts.item1, parts.item2, parts.item3);
  }

  /// The earliest date that can be properly represented by this class.
  static final LocalDate minimum = LocalDate._fromJulianDays(0);

  /// The latest date that can be _safely_ represented by this class across
  /// web and native platforms. Native platforms with 64-bit ints will be able
  /// to exceed this by quite a bit.
  static final LocalDate safeMaximum =
      LocalDate._fromJulianDays(9007199254740992);

  /// Creates a [LocalDate] with the current date and time in the
  /// current time zone.
  LocalDate.now() : this.fromDateTime(DateTime.now());

  /// Creates a [LocalDate] from a standard Dart [DateTime].
  /// The timezone (if any) of [dateTime] is ignored.
  LocalDate.fromDateTime(DateTime dateTime)
      : this(dateTime.year, dateTime.month, dateTime.day);

  /// Parses a [LocalDate] from an ISO 8601 date string. Any non-date
  /// parts of the string will be silently discarded. Uses [DateTime.parse].
  factory LocalDate.parse(String dateString) {
    var dateTime = DateTime.parse(dateString);
    return LocalDate(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Returns a new date with one or more fields replaced. Adjusts the day
  /// if the resulting month is shorter.
  ///
  /// ```dart
  /// var date = LocalDate(2000, 1, 31);
  /// date.replace(month: 4) == LocalDate(2001, 4, 30);
  /// ```
  LocalDate replace({int? year, int? month, int? day}) {
    year ??= this.year;
    month ??= this.month;
    day ??= this.day;
    day = min(day, daysInMonth(year, month));
    return LocalDate(year, month, day);
  }

  /// The number of days since 12:00 January 1, 4713 BC on the proleptic Julian
  /// calendar.
  int get _julianDays => gregorianToJulianDay(year, month, day);

  /// True if this date falls on a leap year.
  bool get isLeapYear => checkLeapYear(year);

  Weekday get weekday => Weekday.values[_julianDays % _daysPerWeek + 1];

  /// The number of days since the beginning of the year. This will range from
  /// 1 to 366.
  int get ordinalDay => _julianDays - LocalDate(year)._julianDays + 1;

  /// The number of full months since 0000-01-01 (i.e. not including the
  /// current month).
  int get _absoluteMonth => 12 * year + month - 1;

  /// Finds the [Period] between this date and another. It first finds the
  /// number of months by advancing the smaller date until it is within 1
  /// month of the larger. Then it finds the number of days between them.
  /// The final result is normalized into years, months and days—all positive
  /// or all negative (if [other] is earlier than this).
  ///
  /// ```dart
  /// LocalDate(2000, 1, 1).until(LocalDate(2000, 3, 2)) ==
  ///     Period(months: 2, days: 1);
  /// LocalDate(2000, 3, 2).until(LocalDate(2000, 1, 1)) ==
  ///     Period(months: -2, days: -1);
  /// LocalDate(2000, 1, 2).until(LocalDate(2000, 3, 1)) ==
  ///     Period(months: 1, days: 28);
  /// LocalDate(2001, 1, 2).until(LocalDate(2001, 3, 1)) ==
  ///     Period(months: 1, days: 27);
  /// LocalDate(2000, 1, 1).until(LocalDate(2010, 2, 3)) ==
  ///     Period(years: 10, months: 1, days: 2);
  /// ```
  Period until(LocalDate other) {
    late int sign;
    late LocalDate d1;
    late LocalDate d2;
    if (other >= this) {
      sign = 1;
      d1 = this;
      d2 = other;
    } else {
      sign = -1;
      d1 = other;
      d2 = this;
    }
    var months = d2._absoluteMonth - d1._absoluteMonth;
    if (d1.day <= d2.day) {
      return Period(months: sign * months, days: sign * (d2.day - d1.day))
          .normalize();
    } else {
      --months;
      var advanced = d1 + Period(months: months);
      return Period(
              months: sign * months,
              days: sign *
                  (daysInMonth(advanced.year, advanced.month) -
                      advanced.day +
                      d2.day))
          .normalize();
    }
  }

  /// Adds a [Period] of time.
  ///
  /// This increments (or decrements) the date by a specific number of months
  /// or years while—as much as possible—keeping the day the same. When this
  /// is not possible the result will be the last day of the month. For
  /// example, adding one month to `2023-01-31` gives `2023-01-28`.
  ///
  /// This increments (or decrements) by the days part of the period increments
  /// (or decrements) the date last. Doing so could be surprising if the
  /// month/year operation landed on a shorter month. For example:
  ///
  /// ```dart
  /// var date = LocalDate(2023, 1, 31);
  /// var period = Period(months: 1, days: 1);
  /// date + period == LocalDate(2023, 3, 1);
  /// ```
  LocalDate operator +(Period p) {
    var y = year + p.years + p.months ~/ 12;
    var months = p.months.remainder(12);
    var m = month + months;
    if (m < 1) {
      --y;
    } else if (m > 12) {
      ++y;
    }
    m = (m - 1) % 12 + 1;
    var d = LocalDate(y, m, min(day, daysInMonth(y, m)));
    return LocalDate._fromJulianDays(d._julianDays + p.days);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate && _julianDays == other._julianDays;

  @override
  int get hashCode => _julianDays.hashCode;

  bool operator >(LocalDate other) => _julianDays > other._julianDays;

  bool operator >=(LocalDate other) => _julianDays >= other._julianDays;

  bool operator <(LocalDate other) => _julianDays < other._julianDays;

  bool operator <=(LocalDate other) => _julianDays <= other._julianDays;

  /// Returns the date in ISO 8601 format.
  @override
  String toString() {
    var format = "%${(year < 1 || year > 9999) ? '+05' : '04'}d-%02d-%02d";
    return sprintf(format, [year, month, day]);
  }

  // Throws an error if this date is invalid.
  void _validate() {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(toString(), 'month');
    }
    if (day < 1 || day > daysInMonth(year, month)) {
      throw ArgumentError.value(toString(), 'day');
    }
  }
}
