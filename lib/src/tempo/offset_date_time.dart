part of '../../tempo.dart';

/// A date and time at a fixed offset from UTC.
@immutable
class OffsetDateTime
    implements HasInstant, HasDateTime, _PeriodArithmetic<OffsetDateTime> {
  /// The earliest possible datetime.
  static final OffsetDateTime minimum =
      OffsetDateTime.fromLocalDateTime(LocalDateTime.minimum, ZoneOffset(0));

  /// The latest possible datetime.
  static final OffsetDateTime maximum =
      OffsetDateTime.fromLocalDateTime(LocalDateTime.maximum, ZoneOffset(0));

  static LocalDateTime _mkDateTime(Instant instant, ZoneOffset offset) {
    var parts = julianDayToGregorian(
        instant.plusTimespan(offset.asTimespan)._julianDay);
    return LocalDateTime(
        parts.year, parts.month, parts.day, 0, 0, 0, parts.nanosecond);
  }

  /// Constructs an [OffsetDateTime] from an offset and the individual
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
    var instant = Instant._fromJulianDay(
      gregorianToJulianDay(
        Gregorian(
          year,
          month,
          day,
          dateTime.time.nanosecondsSinceMidnight,
        ),
      ),
    ).minusTimespan(offset.asTimespan);
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

  /// Parses an [OffsetDateTime] from an ISO-8601 formatted string.
  ///
  /// ```dart
  /// OffsetDateTime.parse('2000-01-02T03:04+0545') ==
  ///   OffsetDateTime(ZoneOffset(5, 45), 2000, 1, 2, 3, 4);
  /// ```
  factory OffsetDateTime.parse(String isoString) =>
      _parseIso8160DateTime(isoString);

  OffsetDateTime._(this._dateTime, this._instant, this.offset);

  final LocalDateTime _dateTime;
  final Instant _instant;

  /// The amount the time zone is offset from UTC.
  final ZoneOffset offset;

  @override
  Timespan get unixTimestamp => _instant.unixTimestamp;

  @override
  ZonedDateTime inTimezone(String zoneId) =>
      ZonedDateTime.fromInstant(this, zoneId);

  @override
  OffsetDateTime atOffset(ZoneOffset offset) =>
      OffsetDateTime.fromInstant(this, offset);

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

  @override
  int get year => _dateTime.year;

  @override
  int get month => _dateTime.month;

  @override
  int get day => _dateTime.day;

  @override
  Weekday get weekday => _dateTime.weekday;

  @override
  int get ordinalDay => _dateTime.ordinalDay;

  @override
  int get hour => _dateTime.hour;

  @override
  int get minute => _dateTime.minute;

  @override
  int get second => _dateTime.second;

  @override
  int get nanosecond => _dateTime.nanosecond;

  @override
  Timespan timespanUntil(HasInstant other) => _instant.timespanUntil(other);

  /// Adds a [Timespan].
  ///
  /// This increments the underlying [Instant] by exactly [timespan].
  /// See also [plusPeriod].
  ///
  /// ```dart
  /// var timespan = Timespan(hours: 1, minutes: 1);
  /// var dt = OffsetDateTime(ZoneOffset(-8), 2000, 1, 1, 12, 0);
  /// dt.plusTimespan(timespan) ==
  ///   OffsetDateTime(ZoneOffset(-8), 2000, 1, 1, 13, 1);
  /// ```
  OffsetDateTime plusTimespan(Timespan timespan) =>
      OffsetDateTime.fromInstant(_instant.plusTimespan(timespan), offset);

  /// Subtracts a [Timespan].
  ///
  /// This decrements the underlying [Instant] by exactly [timespan].
  /// See also [minusPeriod].
  ///
  /// ```dart
  /// var timespan = Timespan(hours: 1, minutes: 1);
  /// var dt = OffsetDateTime(ZoneOffset(-8), 2000, 1, 1, 12, 0);
  /// dt.minusTimespan(timespan) ==
  ///   OffsetDateTime(ZoneOffset(-8), 2000, 1, 1, 11, 59);
  /// ```
  OffsetDateTime minusTimespan(Timespan timespan) =>
      OffsetDateTime.fromInstant(_instant.minusTimespan(timespan), offset);

  @override
  OffsetDateTime plusPeriod(Period period) =>
      OffsetDateTime.fromLocalDateTime(_dateTime.plusPeriod(period), offset);

  @override
  OffsetDateTime minusPeriod(Period period) =>
      OffsetDateTime.fromLocalDateTime(_dateTime.minusPeriod(period), offset);

  @override
  int compareTo(HasInstant other) => _instant.compareTo(other);

  @override
  bool operator >(HasInstant other) => compareTo(other) > 0;

  @override
  bool operator >=(HasInstant other) => compareTo(other) >= 0;

  @override
  bool operator <(HasInstant other) => compareTo(other) < 0;

  @override
  bool operator <=(HasInstant other) => compareTo(other) <= 0;

  /// Formats this as an ISO 8601 date time with offset.
  ///
  /// ```dart
  /// OffsetDateTime(ZoneOffset(-7), 2023, 1, 2, 3, 4, 5).toString() ==
  ///   '2023-01-02T03:04:05-0700'
  /// ```
  @override
  String toString() => _iso8601DateTime(this, offset);

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
