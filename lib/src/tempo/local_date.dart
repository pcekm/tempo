part of '../../tempo.dart';

/// A date with no timezone.
///
/// {@category local}
@immutable
class LocalDate extends _RataDieDate
    with _Formatting
    implements
        HasDate,
        Comparable<LocalDate>,
        _PeriodArithmetic<LocalDate>,
        _ConvertibleDate {
  /// Constructs a `LocalDate` from individual parts.
  ///
  /// {@macro astro_year}
  ///
  /// The resulting date is guaranteed to be valid, even if the inputs are
  /// not. Callers should not depend on any specific date resulting from
  /// invalid inputs.
  const LocalDate([int year = 0, int month = 1, int day = 1])
      : super(year, month, day, 0, 0, 0, 0);

  LocalDate._fromRataDieDate(super.bigTime) : super._fromBigTime();

  /// Constructs a `LocalDate` with the current date and time in the
  /// current time zone.
  ///
  /// {@macro datetime_precision}
  LocalDate.now() : this.fromDateTime(clock.now());

  /// Constructs a `LocalDate` from a standard Dart [DateTime].
  ///
  /// The timezone (if any) of [dateTime] is ignored.
  LocalDate.fromDateTime(DateTime dateTime)
      : this(dateTime.year, dateTime.month, dateTime.day);

  /// Parses an ISO 8601 date string.
  ///
  /// ```dart
  /// var date = LocalDate.parse('2000-06-05');
  /// date == LocalDate(2000, 6, 5);
  /// ```
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

  /// The earliest supported date.
  static const LocalDate minimum = LocalDate(-9999, 1, 1);

  /// The latest supported date.
  static const LocalDate maximum = LocalDate(9999, 12, 31);

  /// True if this date falls in a leap year.
  bool get isLeapYear => checkLeapYear(year);

  @override
  DateTime toDateTime() => DateTime(year, month, day);

  @override
  OffsetDateTime atOffset([ZoneOffset? offset]) =>
      OffsetDateTime.fromLocalDateTime(toLocal(), offset);

  @override
  ZonedDateTime inTimezone([String? zoneId]) =>
      ZonedDateTime.withZoneId(zoneId ?? defaultZoneId, year, month, day);

  @override
  Instant toInstant() => Instant._fromRataDieDate(this);

  @override
  LocalDateTime toLocal() => LocalDateTime.combine(this);

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
  /// [timespanUntil].
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
    var otherDate = LocalDate(other.year, other.month, other.day);
    late int sign;
    late LocalDate d1;
    late LocalDate d2;
    if (otherDate._asTimespan.inDays >= _asTimespan.inDays) {
      sign = 1;
      d1 = this;
      d2 = otherDate;
    } else {
      sign = -1;
      d1 = otherDate;
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
      Timespan(days: other._asTimespan.inDays - _asTimespan.inDays);

  /// Adds a [Timespan].
  ///
  /// The date is incremented or decremented by the number of days in the
  /// timespan. Fractional results are rounded down.
  LocalDate plusTimespan(Timespan t) =>
      LocalDate._fromRataDieDate(_asTimespan + t);

  /// Subtracts a [Timespan].
  ///
  /// The date is decremented or incremented by the number of days in the
  /// timespan. Fractional results are rounded down.
  LocalDate minusTimespan(Timespan t) =>
      LocalDate._fromRataDieDate(_asTimespan - t);

  /// Adds [Period] of time.
  ///
  /// Increments the date by a specific number of months
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
  /// Decrements the date by a specific number of months
  /// or years while—as much as possible—keeping the day the same. When this
  /// is not possible the result will be the last day of the month. For
  /// example, subtracting one month from `2023-03-31` gives `2023-01-28`.
  ///
  /// The days part is applied last. For example, subtracting one month and
  /// one day from `2023-03-31` first subtracts one month to get `2023-02-28`
  /// and then subtracts one day for a final result of `2023-02-27`.
  @override
  LocalDate minusPeriod(Period p) => plusPeriod(-p);

  @override
  int compareTo(LocalDate other) {
    return _asTimespan.compareTo(other._asTimespan);
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
  int get hashCode => _asTimespan.hashCode;

  /// Returns the date in ISO 8601 format.
  ///
  /// For example, 2000-01-02.
  @override
  String toString() => _iso8601Date(this);
}
