part of '../../tempo.dart';

/// An ISO 8601 date with no timezone.
class LocalDate
    implements HasDate, Comparable<LocalDate>, _PeriodArithmetic<LocalDate> {
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

  factory LocalDate._fromJulianDay(Timespan julianDay) {
    var parts = julianDayToGregorian(julianDay);
    return LocalDate(parts.year, parts.month, parts.day);
  }

  /// Constructs a [LocalDate] with the current date and time in the
  /// current time zone.
  LocalDate.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalDate] from a standard Dart [DateTime].
  /// The timezone (if any) of [dateTime] is ignored.
  LocalDate.fromDateTime(DateTime dateTime)
      : this(dateTime.year, dateTime.month, dateTime.day);

  /// Parses an ISO 8601 date string.
  factory LocalDate.parse(String date) => _parseIso8601Date(date);

  /// Returns a new date with one or more fields replaced. Uses the largest
  /// valid day if the resulting month is shorter.
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

  // The Julian day represented by this date.
  Timespan get _julianDay =>
      gregorianToJulianDay(Gregorian(year, month, day, 0));

  /// True if this date falls in a leap year.
  bool get isLeapYear => checkLeapYear(year);

  @override
  Weekday get weekday => weekdayForJulianDay(_julianDay);

  @override
  DateTime toDateTime() => DateTime(year, month, day);

  @override
  int get ordinalDay =>
      _julianDay.inDays - LocalDate(year)._julianDay.inDays + 1;

  /// The number of full months since 0000-01-01 (i.e. not including the
  /// current month).
  static int _absoluteMonth(LocalDate date) => 12 * date.year + date.month - 1;

  /// Finds the [Period] between this date and another.
  ///
  /// It first finds the number of months by advancing the smaller date
  /// until it is within 1 month of the larger. Then it finds the number
  /// of days between them. The final result is normalized into years,
  /// months and days—all positive or all negative.
  ///
  /// To count the total number of days between two dates use
  /// [timespanUntil()].
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
  Period periodUntil(LocalDate other) {
    late int sign;
    late LocalDate d1;
    late LocalDate d2;
    if (other._julianDay.inDays >= _julianDay.inDays) {
      sign = 1;
      d1 = this;
      d2 = other;
    } else {
      sign = -1;
      d1 = other;
      d2 = this;
    }
    var months = _absoluteMonth(d2) - _absoluteMonth(d1);
    if (d1.day <= d2.day) {
      return Period(months: sign * months, days: sign * (d2.day - d1.day))
          .normalize();
    } else {
      --months;
      var advanced = d1.plusPeriod(Period(months: months));
      return Period(
              months: sign * months,
              days: sign *
                  (daysInMonth(advanced.year, advanced.month) -
                      advanced.day +
                      d2.day))
          .normalize();
    }
  }

  /// Returns the [Timespan] between this and another date. The result will
  /// always be an integer number of days.
  ///
  /// To find the number of years, months and days between two dates, use
  /// [periodUntil()].
  Timespan timespanUntil(LocalDate other) =>
      Timespan(days: other._julianDay.inDays - _julianDay.inDays);

  /// Adds a [Timespan].
  ///
  /// The date is incremented or decremented by the number of days in the
  /// timespan. Fractional results are rounded down.
  LocalDate plusTimespan(Timespan t) =>
      LocalDate._fromJulianDay(_julianDay + t);

  /// Subtracts a [Timespan].
  ///
  /// The date is decremented or incremented by the number of days in the
  /// timespan. Fractional results are rounded down.
  LocalDate minusTimespan(Timespan t) =>
      LocalDate._fromJulianDay(_julianDay - t);

  /// Adds [Period] of time.
  ///
  /// Increments (or decrements) the date by a specific number of months
  /// or years while—as much as possible—keeping the day the same. When this
  /// is not possible the result will be the last day of the month. For
  /// example, adding one month to `2023-01-31` gives `2023-01-28`.
  ///
  /// The days part is applied last. For example, adding one month and one day
  /// to `2023-01-31` first adds one month to get `2023-02-28` and then
  /// adds one day for a final result of `2023-03-01`.
  @override
  LocalDate plusPeriod(Period p) {
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
        .plusTimespan(Timespan(days: p.days));
  }

  /// Subtracts [Period] of time.
  ///
  /// Decrements (or increments) the date by a specific number of months
  /// or years while—as much as possible—keeping the day the same. When this
  /// is not possible the result will be the last day of the month. For
  /// example, adding one month to `2023-01-31` gives `2023-01-28`.
  ///
  /// The days part is applied last. For example, subtracting one month and
  /// one day from `2023-03-31` first subtracts one month to get `2023-02-28`
  /// and then subtracts one day for a final result of `2023-02-27`.
  @override
  LocalDate minusPeriod(Period p) => plusPeriod(-p);

  @override
  int compareTo(LocalDate other) {
    return _julianDay.compareTo(other._julianDay);
  }

  /// Greater than operator.
  bool operator >(LocalDate other) => compareTo(other) > 0;

  /// Greater than or equals operator.
  bool operator >=(LocalDate other) => compareTo(other) >= 0;

  /// Less than operator.
  bool operator <(LocalDate other) => compareTo(other) < 0;

  /// Less than or equals operator.
  bool operator <=(LocalDate other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => _julianDay.hashCode;

  /// Returns the date in ISO 8601 format.
  ///
  /// For example, 2000-01-02.
  @override
  String toString() => _iso8601Date(this);

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
