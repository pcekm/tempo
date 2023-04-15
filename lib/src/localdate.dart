import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:sprintf/sprintf.dart';

import 'interfaces.dart';
import 'period.dart';
import 'util.dart';
import 'weekday.dart';

/// A date fixed at midnight local time.
class LocalDate implements HasDate {
  static const int _daysPerWeek = 7;

  @override
  final int year;

  @override
  final int month;

  @override
  final int day;

  /// Constructs a [LocalDate] from individual parts.
  ///
  /// The [year] uses ISO 8601, or astronomical year numbering and may be
  /// zero or negative. When negative, year equates to year - 1 BCE. Throws
  /// an exception if [month] or [day] is invalid.
  LocalDate([this.year = 0, this.month = 1, this.day = 1]) {
    _validate();
  }

  factory LocalDate._fromRataDieUsec(Int64 rataDieUsec) {
    var parts = rataDieUsecToGregorian(rataDieUsec);
    return LocalDate(parts.item1, parts.item2, parts.item3);
  }

  /// Constructs a [LocalDate] with the current date and time in the
  /// current time zone.
  LocalDate.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalDate] from a standard Dart [DateTime].
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

  @override
  Int64 get rataDieUsec => gregorianToRataDieUsec(year, month, day);

  /// True if this date falls in a leap year.
  bool get isLeapYear => checkLeapYear(year);

  Weekday get weekday =>
      Weekday.values[(epochUsecToDay(rataDieUsec) - 1) % _daysPerWeek + 1];

  /// The number of days since the beginning of the year. This will range from
  /// 1 to 366.
  int get ordinalDay =>
      epochUsecToDay(rataDieUsec) -
      epochUsecToDay(LocalDate(year).rataDieUsec) +
      1;

  /// The number of full months since 0000-01-01 (i.e. not including the
  /// current month).
  static int _absoluteMonth(HasDate date) => 12 * date.year + date.month - 1;

  /// Finds the [Period] between this date and another. It first finds the
  /// number of months by advancing the smaller date until it is within 1
  /// month of the larger. Then it finds the number of days between them.
  /// The final result is normalized into years, months and days—all positive
  /// or all negative.
  ///
  /// To count the number of days between two dates, use [durationUntil()].
  ///
  /// ```dart
  /// LocalDate(2000, 1, 1).periodUntil(LocalDate(2000, 3, 2)) ==
  ///     Period(months: 2, days: 1);
  /// LocalDate(2000, 3, 2).periodUntil(LocalDate(2000, 1, 1)) ==
  ///     Period(months: -2, days: -1);
  /// LocalDate(2000, 1, 2).periodUntil(LocalDate(2000, 3, 1)) ==
  ///     Period(months: 1, days: 28);
  /// LocalDate(2001, 1, 2).periodUntil(LocalDate(2001, 3, 1)) ==
  ///     Period(months: 1, days: 27);
  /// LocalDate(2000, 1, 1).periodUntil(LocalDate(2010, 2, 3)) ==
  ///     Period(years: 10, months: 1, days: 2);
  /// ```
  Period periodUntil(HasDate other) {
    late int sign;
    late LocalDate d1;
    late HasDate d2;
    if (other.rataDieUsec >= rataDieUsec) {
      sign = 1;
      d1 = this;
      d2 = other;
    } else {
      sign = -1;
      d1 = LocalDate._fromRataDieUsec(other.rataDieUsec);
      d2 = this;
    }
    var months = _absoluteMonth(d2) - _absoluteMonth(d1);
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

  /// Returns the [Duration] between this and another date. The result will
  /// always be an integer number of days. This works on [LocalDate]
  /// and [LocalDateTime].
  ///
  /// To find the number of years, months and days between two dates, use
  /// [periodUntil()].
  Duration durationUntil(HasRataDie other) {
    return Duration(microseconds: (other.rataDieUsec - rataDieUsec).toInt());
  }

  /// Adds a [Duration] or [Period]. The behavior depends on the type.
  ///
  /// ## Duration
  ///
  /// The date is incremented or decremented by the number of days in the
  /// duration. Fractional results are rounded down.
  ///
  /// Note: Any duration of less than one second is treated as zero. This
  /// behavior may change in the future, so please don't depend on it.
  ///
  /// ```dart
  /// LocalDate(2000) + Duration(days: 1) == LocalDate(2000, 1, 2);
  /// LocalDate(2000) + Duration(days: -1) == LocalDate(1999, 12, 31);
  /// LocalDate(2000) + Duration(hours: 23) == LocalDate(2000);
  /// LocalDate(2000) + Duration(hours: -23) == LocalDate(1999, 12, 31);
  /// ```
  ///
  /// ## Period
  ///
  /// Increments (or decrements) the date by a specific number of months
  /// or years while—as much as possible—keeping the day the same. When this
  /// is not possible the result will be the last day of the month. For
  /// example, adding one month to `2023-01-31` gives `2023-01-28`.
  ///
  /// The days part is applied last. For example, adding one month and one day
  /// to `2023-01-31` first adds one month to get `2023-02-28` and then
  /// adds one day for a final result of `2023-03-01`.
  ///
  /// ```dart
  /// LocalDate(2023, 1, 31) + Period(months: 1, days: 1) ==
  ///     LocalDate(2023, 3, 1);
  /// LocalDate(2023, 3, 31) + Period(months: -1, days: -1) ==
  ///     LocalDate(2023, 2, 27);
  /// ```
  LocalDate operator +(Object other) {
    if (other is Duration) {
      return _addDuration(other);
    } else if (other is Period) {
      return _addPeriod(other);
    } else {
      throw ArgumentError(
          'Invalid type for LocalDate addition: ${other.runtimeType}');
    }
  }

  LocalDate _addDuration(Duration d) =>
      LocalDate._fromRataDieUsec(rataDieUsec + d.inMicroseconds);

  LocalDate _addPeriod(Period p) {
    var y = year + p.years + p.months ~/ 12;
    var months = p.months.remainder(12);
    var m = month + months;
    if (m < 1) {
      --y;
    } else if (m > 12) {
      ++y;
    }
    m = (m - 1) % 12 + 1;
    return LocalDate(y, m, min(day, daysInMonth(y, m)))
        ._addDuration(Duration(days: p.days));
  }

  int _compare(HasRataDie other) {
    return Comparable.compare(rataDieUsec, other.rataDieUsec);
  }

  bool operator >(HasRataDie other) => _compare(other) > 0;

  bool operator >=(HasRataDie other) => _compare(other) >= 0;

  bool operator <(HasRataDie other) => _compare(other) < 0;

  bool operator <=(HasRataDie other) => _compare(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDate && rataDieUsec == other.rataDieUsec;

  @override
  int get hashCode => rataDieUsec.hashCode;

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
