part of '../../goodtime.dart';

/// A point in time in a specific time zone.
///
///
class ZonedDateTime implements HasDateTime, HasInstant {
  final OffsetDateTime _dateTime;
  final TimeZone _timeZone;

  /// A string that uniqueley identifies the time zone.
  final String zoneId;

  ZonedDateTime._(this._dateTime, this.zoneId, this._timeZone);

  /// Constructs a [ZonedDateTime] from an [Instant] and a zone ID.
  factory ZonedDateTime.fromInstant(HasInstant instant, String zoneId) {
    var timeZone = _lookupTimeZone(zoneId, instant);
    var dateTime = OffsetDateTime.fromInstant(instant, timeZone.offset);
    return ZonedDateTime._(dateTime, zoneId, timeZone);
  }

  /// Creates a [ZonedDateTime] from indiviual components.
  ///
  /// Throws [ArgumentError] if [zoneId] is invalid.
  ///
  /// Some dates and times are impossible in a given time zone.
  /// When switching to daylight savings, the local time "springs forward"
  /// usually by one hour at 2 AM. So a time of, say, 2:15 doesn't exist.
  ///
  /// Other dates and times are ambiguous in a given time zone. When switching
  /// back to standard time, the local time "falls back," repeating the same
  /// hour again. So a time of, say, 1:15 happens twice.
  ///
  /// The exact behavior of this constructor in these situations is currently
  /// unspecified and may change in the future. However, the result will
  /// be close.
  factory ZonedDateTime(String zoneId, int year,
          [int month = 1,
          int day = 1,
          int hour = 0,
          int minute = 0,
          int second = 0,
          int nanosecond = 0]) =>
      _forLocal(
          LocalDateTime(year, month, day, hour, minute, second, nanosecond),
          zoneId);

  /// Converts a [DateTime] to a [ZonedDateTime].
  ///
  /// This requires a [zoneId] arg because [DateTime] doesn't provide enough
  /// information about the time zone to derive it.
  factory ZonedDateTime.fromDateTime(DateTime dateTime, String zoneId) =>
      ZonedDateTime.fromInstant(Instant.fromDateTime(dateTime), zoneId);

  /// Creates a [ZonedDateTime] using the current time.
  ///
  /// This requires a [zoneId] arg because it's not currently possible to
  /// discover the system time zone using Dart's standard library.
  factory ZonedDateTime.now(String zoneId) =>
      ZonedDateTime.fromDateTime(DateTime.now(), zoneId);

  /// Looks up a time zone and throws ArgumentError if it's invalid.
  static TimeZone _lookupTimeZone(String zoneId, HasInstant instant) {
    var tz = lookupTimeZone(zoneId, instant);
    if (tz == null) {
      throw ArgumentError.value(zoneId, 'zoneId');
    }
    return tz;
  }

  /// What's going on here:
  /// We have a chicken and egg problem. We need an Instant to determine
  /// the correct time zone (that's how they're defined in ARIN's data),
  /// but we don't know the instant without knowing the time zone.
  /// Instead, start at the previous day and skip forward. This is
  /// a bit fiddly, but I don't have any better ideas right now.
  static ZonedDateTime _forLocal(LocalDateTime local, String zoneId) {
    var instant = Instant._fromJulianDay(
        local.date.minusTimespan(Timespan(days: 1))._julianDay);
    var candidate = ZonedDateTime.fromInstant(instant, zoneId);
    while (candidate.toLocal() < local) {
      instant = instant.plusTimespan(candidate.toLocal().timespanUntil(local));
      candidate = ZonedDateTime.fromInstant(instant, zoneId);
    }
    if (candidate.toLocal() > local) {
      // We either overshot or the requested date was in the gap between
      // a jump forward. See if jumping back again fixes things. If not,
      // we've done the best we can.
      instant = instant.plusTimespan(candidate.toLocal().timespanUntil(local));
      var dt = ZonedDateTime.fromInstant(instant, zoneId);
      if (dt.toLocal() == local) {
        return dt;
      }
    }
    return candidate;
  }

  /// The common designation for the current time zone (e.g. UTC, PST,
  /// PDT, CET, CEST).
  ///
  /// These strings are not necessarily unique but are commonly used and
  /// understood. See [zoneId] for a unique identifier.
  String get timeZone => _timeZone.designation;

  /// The offset from UTC.
  ZoneOffset get offset => _timeZone.offset;

  /// If this is a daylight savings (or summer) time.
  bool get isDst => _timeZone.isDst;

  /// Converts this to a [LocalDateTime].
  ///
  /// The result will have exactly the same year, month, day, etc. but will
  /// lack any time zone information.
  LocalDateTime toLocal() => _dateTime.toLocal();

  /// Converts this to an [OffsetDateTime] with the same offset.
  OffsetDateTime toOffset() => _dateTime;

  /// Converts this to a standard Dart [DateTime] **in the system time zone**.
  ///
  /// Unfortunately, [DateTime] only supports two time zones: "system" and UTC,
  /// so this conversion loses the time zone.
  @override
  DateTime toDateTime() => DateTime.fromMicrosecondsSinceEpoch(
      _dateTime.asInstant.unixTimestamp.inMicroseconds);

  @override
  Instant get asInstant => _dateTime.asInstant;

  /// Adds a [Timespan].
  ///
  /// This increments the underlying [Instant] by exactly [timespan].
  /// When adding a whole number of days, this could result in the time
  /// changing because of daylight savings.
  ///
  /// See also [plusPeriod].
  ZonedDateTime plusTimespan(Timespan timespan) =>
      ZonedDateTime.fromInstant(asInstant.plusTimespan(timespan), zoneId);

  /// Subtracts a [Timespan].
  ///
  /// This decrements the underlying [Instant] by exactly [timespan].
  /// When adding a whole number of days, this could result in the time
  /// changing because of daylight savings.
  ///
  /// See also [minusPeriod].
  ZonedDateTime minusTimespan(Timespan timespan) =>
      ZonedDateTime.fromInstant(asInstant.minusTimespan(timespan), zoneId);

  /// Adds a [Period].
  ///
  /// This works like [LocalDateTime.plusPeriod], but has the same limitations
  /// as the [LocalDateTime()] constructor. The result may be adjusted if
  /// it lands in the gap during a switch to daylight savings, or it may be
  /// ambiguous if it lands in the hour that repeats during a switch
  /// back to standard time.
  ///
  /// See also [plusTimespan].
  ZonedDateTime plusPeriod(Period period) =>
      ZonedDateTime._forLocal(_dateTime.toLocal().plusPeriod(period), zoneId);

  /// Subtracts a [Period].
  ///
  /// This works like [LocalDateTime.minusPeriod], but has the same limitations
  /// as the [LocalDateTime()] constructor. The result may be adjusted if
  /// it lands in the gap during a switch to daylight savings, or it may be
  /// ambiguous if it lands in the hour that repeats during a switch
  /// back to standard time.
  ///
  /// See also [minusTimespan].
  ZonedDateTime minusPeriod(Period period) =>
      ZonedDateTime._forLocal(_dateTime.toLocal().minusPeriod(period), zoneId);

  @override
  int get year => _dateTime.year;

  @override
  int get month => _dateTime.month;

  @override
  int get day => _dateTime.day;

  @override
  int get hour => _dateTime.hour;

  @override
  int get minute => _dateTime.minute;

  @override
  int get second => _dateTime.second;

  @override
  int get nanosecond => _dateTime.nanosecond;

  @override
  Weekday get weekday => _dateTime.weekday;

  @override
  int get ordinalDay => _dateTime.ordinalDay;

  @override
  int compareTo(HasInstant other) => _dateTime.compareTo(other);

  @override
  bool operator <(HasInstant other) => _dateTime < other;

  @override
  bool operator <=(HasInstant other) => _dateTime <= other;

  @override
  bool operator >(HasInstant other) => _dateTime > other;

  @override
  bool operator >=(HasInstant other) => _dateTime >= other;

  @override
  String toString() => _dateTime.toString();

  @override
  bool operator ==(Object other) =>
      other is ZonedDateTime &&
      _dateTime == other._dateTime &&
      zoneId == other.zoneId;

  @override
  int get hashCode => Object.hash(_dateTime, zoneId);
}
