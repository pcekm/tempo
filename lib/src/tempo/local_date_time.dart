part of '../../tempo.dart';

/// A date and time with no time zone.
///
/// This is a combination of [LocalDate] and [LocalTime]. The individual
/// parts can be retrieved with [date] and [time].
///
/// {@category local}
@immutable
class LocalDateTime extends _RataDieDate
    with _TimeFields, _Formatting
    implements
        Comparable<LocalDateTime>,
        HasDateTime,
        _PeriodArithmetic<LocalDateTime>,
        _ConvertibleDate {
  /// Constructs a new `LocalDateTime`.
  ///
  /// The time arguments wrap in exactly the same way they do in [LocalTime],
  /// with one addition. A wrap increments or decrements the date part
  /// accordingly.
  ///
  /// The date args are passed to [LocalDate()] which may throw an
  /// exception if the values are invalid.
  ///
  /// ```dart
  /// LocalDateTime(2000, 1, 1, 25) == LocalDateTime(2000, 1, 2, 1);
  /// LocalDateTime(2000, 1, 1, -1) == LocalDateTime(1999, 12, 31, 23);
  /// ```
  ///
  /// {@macro astro_year}
  const LocalDateTime(
      [super.year,
      super.month,
      super.day,
      super.hour,
      super.minute,
      super.second,
      super.nanosecond]);

  /// Constructs a `LocalDateTime` with the current date and time in the
  /// current time zone.
  ///
  /// {@macro datetime_precision}
  LocalDateTime.now() : this.fromDateTime(clock.now());

  /// Constructs a `LocalDateTime` from a standard Dart [DateTime].
  ///
  /// The timezone (if any) of [dateTime] is ignored.
  LocalDateTime.fromDateTime(DateTime dateTime)
      : this(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
            dateTime.second,
            dateTime.millisecond * _nsPerMillisecond +
                dateTime.microsecond * _nsPerMicrosecond);

  /// Makes a `LocalDateTime` from a [LocalDate] and an optional [LocalTime].
  ///
  /// Uses midnight if no time is provided.
  LocalDateTime.combine(LocalDate date, [LocalTime? time])
      : this(date.year, date.month, date.day, time?.hour ?? 0,
            time?.minute ?? 0, time?.second ?? 0, time?.nanosecond ?? 0);

  LocalDateTime._fromRataDieDate(super.rd) : super._fromBigTime();

  /// Parses an ISO 8601 datetime string. Discards the zone offset (if any).
  ///
  /// ```dart
  /// var dt = LocalDateTime.parse('2020-03-04T05:06');
  /// dt == LocalDateTime(2020, 3, 4, 5, 6);
  /// ```
  factory LocalDateTime.parse(String dateTime) =>
      _parseIso8160DateTime(dateTime).datetime;

  /// The earliest possible datetime.
  static const minimum = LocalDateTime(-9999);

  /// The latest possible datetime.
  static const maximum = LocalDateTime(9999, 12, 31, 23, 59, 59, 999999999);

  static const _nsPerMicrosecond = 1000;
  static const _nsPerMillisecond = 1000000;

  /// The date part of this [DateTime].
  LocalDate get date => LocalDate._fromRataDieDate(this);

  /// The time part of this [DateTime].
  LocalTime get time => _time;

  /// Returns a new datetime with one or more fields replaced.
  ///
  /// See [LocalDate.replace] and [LocalTime.replace] for more information on
  /// replacements to the respective parts of the datetime.
  ///
  /// ```dart
  /// var dt = LocalDateTime(2000, 1, 31, 12, 23);
  /// dt.replace(month: 4) == LocalDateTime(2000, 4, 30, 12, 23);
  /// dt.replace(second: 59) == LocalDateTime(2000, 4, 30, 12, 23, 59);
  /// ```
  LocalDateTime replace(
      {int? year,
      int? month,
      int? day,
      int? hour,
      int? minute,
      int? second,
      int? nanosecond}) {
    return LocalDateTime.combine(
        date.replace(year: year, month: month, day: day),
        time.replace(
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond));
  }

  /// Converts this to a DateTime.
  ///
  /// The result will have the same date and time as this and will be in the
  /// local time zone.
  @override
  DateTime toDateTime() =>
      DateTime(year, month, day, hour, minute, second, 0, nanosecond ~/ 1000);

  /// Converts this to an Instant.
  @override
  Instant toInstant() => Instant._fromRataDieDate(this);

  @override
  OffsetDateTime atOffset([ZoneOffset? offset]) =>
      OffsetDateTime.fromLocalDateTime(this, offset);

  @override
  ZonedDateTime inTimezone([String? zoneId]) => ZonedDateTime.withZoneId(
      zoneId ?? defaultZoneId,
      year,
      month,
      day,
      hour,
      minute,
      second,
      nanosecond);

  /// Returns this unchanged. Provided for completeness.
  @override
  LocalDateTime toLocal() => this;

  /// Finds the timespan between this and [other].
  ///
  /// ```dart
  /// LocalDateTime dt1 = LocalDateTime(2000, 1, 1, 2);
  /// LocalDateTime dt2 = LocalDateTime(2000, 2, 2, 3);
  /// dt1.timespanUntil(dt2) == Timespan(days: 32, hours: 1);
  /// ```
  Timespan timespanUntil(LocalDateTime other) =>
      other._asTimespan - _asTimespan;

  /// Finds the [Period] between this and another [HasDate].
  ///
  /// The time component (if any) is ignored.
  ///
  /// It first finds the number of months by advancing the smaller date
  /// until it is within 1 month of the larger. Then it finds the number
  /// of days between them. The final result is normalized into years,
  /// months and days—all positive or all negative.
  ///
  /// To count the total amount of time, use [timespanUntil].
  ///
  /// ```dart
  /// LocalDateTime(2000, 1, 1, 12, 20).periodUntil(LocalDate(2000, 3, 2)) ==
  ///     Period(months: 2, days: 1);
  /// LocalDateTime(2000, 3, 2).periodUntil(LocalDateTime(2000, 1, 1)) ==
  ///     Period(months: -2, days: -1);
  /// LocalDateTime(2000, 1, 2).periodUntil(LocalDateTime(2000, 3, 1)) ==
  ///     Period(months: 1, days: 28);
  /// LocalDateTime(2001, 1, 2).periodUntil(LocalDateTime(2001, 3, 1)) ==
  ///     Period(months: 1, days: 27);
  /// LocalDateTime(2000, 1, 1).periodUntil(LocalDateTime(2010, 2, 3)) ==
  ///     Period(years: 10, months: 1, days: 2);
  /// ```
  Period periodUntil(HasDate other) => date.periodUntil(other);

  /// Adds a [Period] of time.
  ///
  /// This acts on the date parts in exactly the same way as
  /// [LocalDate.plusPeriod()] and leaves the time untouched.
  ///
  /// ```dart
  /// var d = LocalDateTime(2000);
  /// d.plusPeriod(Period(days: 1)) == LocalDateTime(2000, 1, 2);
  /// ```
  @override
  LocalDateTime plusPeriod(Period amount) =>
      LocalDateTime.combine(date.plusPeriod(amount), time);

  /// Subtracts a [Period] of time.
  ///
  /// This acts on the date parts in exactly the same way as
  /// [LocalDate.plusPeriod()] and leaves the time untouched.
  ///
  /// ```dart
  /// var d = LocalDateTime(2000);
  /// d.plusPeriod(Period(days: 1)) == LocalDateTime(2000, 1, 2);
  /// ```
  @override
  LocalDateTime minusPeriod(Period amount) =>
      LocalDateTime.combine(date.minusPeriod(amount), time);

  /// Adds a [Timespan].
  ///
  /// ```dart
  /// var dt = LocalDateTime(2000, 1, 1);
  /// var timespan = Timespan(days: 30, hours: 1);
  /// dt.plusTimespan(timespan) == LocalDateTime(2000, 1, 31, 1);
  /// ```
  LocalDateTime plusTimespan(Timespan amount) =>
      LocalDateTime._fromRataDieDate(_asTimespan + amount);

  /// Subtracts a [Timespan].
  ///
  /// ```dart
  /// var dt = LocalDateTime(2000, 2, 1);
  /// var timespan = Timespan(days: 30, hours: 1);
  /// dt.minusTimespan(timespan) == LocalDateTime(2000, 1, 1, 23);
  /// ```
  LocalDateTime minusTimespan(Timespan amount) =>
      LocalDateTime._fromRataDieDate(_asTimespan - amount);

  @override
  int compareTo(LocalDateTime other) =>
      _asTimespan.compareTo(other._asTimespan);

  /// Greater than operator.
  bool operator >(LocalDateTime other) => compareTo(other) > 0;

  /// Greater than or equals operator.
  bool operator >=(LocalDateTime other) => compareTo(other) >= 0;

  /// Less than operator.
  bool operator <(LocalDateTime other) => compareTo(other) < 0;

  /// Less than or equals operator.
  bool operator <=(LocalDateTime other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDateTime && date == other.date && time == other.time;

  @override
  int get hashCode => Object.hash(date, time);

  /// Returns the date and time in ISO 8601 format.
  ///
  /// For example, 2000-01-02T12:00:01.000000009.
  @override
  String toString() => _iso8601DateTime(this);
}
