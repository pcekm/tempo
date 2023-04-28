part of '../../goodtime.dart';

/// A date and time at a fixed offset from UTC.
class OffsetDateTime
    implements HasInstant, HasDateTime, _PeriodArithmetic<OffsetDateTime> {
  static LocalDateTime _mkDateTime(Instant instant, ZoneOffset offset) {
    var parts = julianDayToGregorian(
        instant.plusTimespan(Timespan(minutes: offset.inMinutes))._julianDay);
    return LocalDateTime(
        parts.year, parts.month, parts.day, 0, 0, 0, parts.nanosecond);
  }

  /// Constructs an [OffsetDateTime] from an offset, and the individual
  /// components of the date and time.
  factory OffsetDateTime(ZoneOffset offset, int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int nanosecond = 0]) {
    var dateTime =
        LocalDateTime(year, month, day, hour, minute, second, nanosecond);
    var instant = Instant._fromJulianDay(gregorianToJulianDay(Gregorian(
            year, month, day, dateTime.time.nanosecondsSinceMidnight)))
        .minusTimespan(Timespan(minutes: offset.inMinutes));
    return OffsetDateTime._(dateTime, instant, offset);
  }

  /// Constructs an [OffsetDateTime] from a [LocalDateTime] at a fixed
  /// offset from UTC.
  factory OffsetDateTime.fromLocalDateTime(
      LocalDateTime dt, ZoneOffset offset) {
    return OffsetDateTime(offset, dt.year, dt.month, dt.day, dt.hour, dt.minute,
        dt.second, dt.nanosecond);
  }

  /// Constructs an [OffsetDateTime] with the current date and time in the
  /// local time zone.
  OffsetDateTime.now() : this.fromDateTime(DateTime.now());

  /// Constructs an [OffsetDateTime] from a [DateTime].
  ///
  /// This will have the same time zone offset as the `DateTime`.
  OffsetDateTime.fromDateTime(DateTime dateTime)
      : this.fromInstant(
            Instant.fromUnix(
                Timespan(microseconds: dateTime.microsecondsSinceEpoch)),
            ZoneOffset.fromDuration(dateTime.timeZoneOffset));

  /// Constructs an [OffsetDateTime] from an [Instant] and a fixed offset
  /// from UTC.
  ///
  /// If [offset] is unset, this defaults to zero, making this equal to
  /// UTC.
  OffsetDateTime.fromInstant(HasInstant hasInstant, [ZoneOffset? offset])
      : offset = offset ?? ZoneOffset(0),
        _dateTime = _mkDateTime(hasInstant.asInstant, offset ?? ZoneOffset(0)),
        _instant = hasInstant.asInstant;

  OffsetDateTime._(this._dateTime, this._instant, this.offset);

  final LocalDateTime _dateTime;
  final Instant _instant;

  /// The amount the time zone is offset from UTC.
  final ZoneOffset offset;

  /// Converts this to a [LocalDateTime].
  ///
  /// The result will have exactly the same year, month, day, etc. but will
  /// lack any time zone information.
  LocalDateTime toLocal() => _dateTime;

  @override
  Instant get asInstant => _instant;

  @override
  DateTime toDateTime() => DateTime.fromMicrosecondsSinceEpoch(
      _instant.unixTimestamp.inMicroseconds);

  /// The year.
  ///
  /// May be zero or negative. Zero means -1 BCE, -1 means -2 BCE, etc.
  /// This is also called astronomical year numbering.
  @override
  int get year => _dateTime.year;

  /// The month from 1 to 12.
  @override
  int get month => _dateTime.month;

  /// The day starting at 1.
  @override
  int get day => _dateTime.day;

  /// Gets the_dateTime of the week.
  @override
  Weekday get weekday => _dateTime.weekday;

  /// The number of days since the beginning of the year. This will range from
  /// 1 to 366.
  @override
  int get ordinalDay => _dateTime.ordinalDay;

  /// The hour from 0 to 23.
  @override
  int get hour => _dateTime.hour;

  /// The minute from 0 to 59.
  @override
  int get minute => _dateTime.minute;

  /// The second from 0 to 59.
  @override
  int get second => _dateTime.second;

  /// The nanoseconds from 0 to 999,999,999.
  @override
  int get nanosecond => _dateTime.nanosecond;

  /// Returns the amount of time between this and another instant in time.
  Timespan timespanUntil(HasInstant other) => _instant.timespanUntil(other);

  /// Adds a [Timespan].
  OffsetDateTime plusTimespan(Timespan span) =>
      OffsetDateTime.fromInstant(_instant.plusTimespan(span), offset);

  /// Subtracts a [Timespan].
  OffsetDateTime minusTimespan(Timespan span) =>
      OffsetDateTime.fromInstant(_instant.minusTimespan(span), offset);

  @override
  OffsetDateTime plusPeriod(Period period) =>
      OffsetDateTime.fromLocalDateTime(_dateTime.plusPeriod(period), offset);

  @override
  OffsetDateTime minusPeriod(Period period) =>
      OffsetDateTime.fromLocalDateTime(_dateTime.minusPeriod(period), offset);

  @override
  int compareTo(HasInstant other) => _instant.compareTo(other);

  /// Greater than operator.
  @override
  bool operator >(HasInstant other) => compareTo(other) > 0;

  /// Greater than or equals operator.
  @override
  bool operator >=(HasInstant other) => compareTo(other) >= 0;

  /// Less than operator.
  @override
  bool operator <(HasInstant other) => compareTo(other) < 0;

  /// Less than or equals operator.
  @override
  bool operator <=(HasInstant other) => compareTo(other) <= 0;

  /// Formats this as an ISO 8601 date time with offset.
  ///
  /// For example, `2023-01-02T03:04:05-0700`.
  @override
  String toString() => '$_dateTime$offset';

  /// The equality operator.
  ///
  /// Two [OffsetDateTime]s compare equal if and only if they have the same
  /// date _and_ the same offset. If you want to know if two represent the
  /// same moment in time, use [compareTo] or [asInstant].
  ///
  /// ```dart
  /// // Same moment in time; different zone offsets:
  /// var d1 = OffsetDateTime(ZoneOffset(0), 2023, 1, 1);
  /// var d2 = OffsetDateTime(ZoneOffset(-1), 2022, 12, 31, 23);
  ///
  /// d1 != d2;
  /// d1.compareTo(d2) == 0;
  /// d1.asInstant == d2.asInstant;
  /// ```
  @override
  bool operator ==(Object other) =>
      other is OffsetDateTime &&
      _dateTime == other._dateTime &&
      offset == other.offset;

  @override
  int get hashCode => Object.hash(_dateTime, offset);
}
