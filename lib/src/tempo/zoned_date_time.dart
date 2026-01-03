part of '../../tempo.dart';

/// A date and time in a specific time zone.
///
/// The time zone defaults to "UTC" and may be changed by setting [defaultZoneId].
///
/// {@category absolute}
@immutable
class ZonedDateTime
    with _HasInstantImpl, _Formatting
    implements HasDateTime, HasInstant, _ConvertibleDate {
  @override
  Timespan get unixTimestamp => _dateTime.unixTimestamp;

  const ZonedDateTime._(this._dateTime, this.offset, this.zoneId);

  ZonedDateTime._fromInstantWithZoneId(
      Instant instant, this.zoneId, this.offset)
      : _dateTime = OffsetDateTime.fromInstant(instant, offset);

  /// Constructs a `ZonedDateTime` from an [Instant].
  ///
  /// {@template zone_id}
  /// The resulting object will be in [zoneId] if it's given, or [defaultZoneId]
  /// if not.
  /// {@endtemplate}
  ZonedDateTime.fromInstant(HasInstant instant, [String? zoneId])
      : this._fromInstantWithZoneId(
            instant.toInstant(),
            zoneId ?? defaultZoneId,
            _lookupTimeZone(zoneId ?? defaultZoneId, instant));

  /// Creates a ZonedDateTime using a time since midnight, January 1, 1970 UTC.
  ///
  /// {@macro zone_id}
  ///
  /// The Unix timestamp can be provided in any units supported by [Timespan].
  /// These examples all produce the same time:
  ///
  /// ```dart
  /// ZonedDateTime.fromUnix(Timespan(seconds: 1));
  /// ZonedDateTime.fromUnix(Timespan(milliseconds: 1000));
  /// ZonedDateTime.fromUnix(Timespan(nanoseconds: 1000000000));
  /// ```
  ZonedDateTime.fromUnix(Timespan unixTimestamp, [String? zoneId])
      : this.fromInstant(Instant.fromUnix(unixTimestamp), zoneId);

  /// Parses a `ZonedDateTime` from an ISO-8601 formatted string.
  ///
  /// Assumes input strings without a zone offset are local to [zoneId] (or
  /// [defaultZoneId] if that's unset).
  /// {@macro zone_id}
  factory ZonedDateTime.parse(String isoString, [String? zoneId]) {
    final parsed = _parseIso8160DateTime(isoString);
    if (parsed.offset != null) {
      return parsed.datetime.atOffset(parsed.offset!).inTimezone(zoneId);
    } else {
      return parsed.datetime.inTimezone(zoneId);
    }
  }

  /// Creates a `ZonedDateTime` from individual components in a given time zone.
  ///
  /// Throws [ArgumentError] if [zoneId] is invalid.
  ///
  /// {@template impossible_times}
  /// Some dates and times are impossible or ambiguous in a given time zone.
  /// When switching to daylight savings, the local time "springs forward"
  /// skipping an hour. When switching back to standard time, the local time
  /// "falls back," repeating the same hour.
  ///
  /// The exact behavior in these situations is currently unspecified
  /// and may change in the future. However, the result will be close.
  /// {@endtemplate}
  factory ZonedDateTime.withZoneId(String zoneId, int year,
          [int month = 1,
          int day = 1,
          int hour = 0,
          int minute = 0,
          int second = 0,
          int nanosecond = 0]) =>
      _forLocal(
          LocalDateTime(year, month, day, hour, minute, second, nanosecond),
          zoneId);

  /// Creates a `ZonedDateTime` from individual components in the default time
  /// zone specified by [defaultZoneId].
  ///
  /// {@macro impossible_times}
  ///
  /// {@macro astro_year}
  factory ZonedDateTime(int year,
          [int month = 1,
          int day = 1,
          int hour = 0,
          int minute = 0,
          int second = 0,
          int nanosecond = 0]) =>
      _forLocal(
          LocalDateTime(year, month, day, hour, minute, second, nanosecond),
          defaultZoneId);

  /// Converts a [DateTime] to a `ZonedDateTime`.
  ///
  /// {@macro zone_id}
  ///
  /// ## Caveats
  ///
  /// Be careful when using `DateTime` for its date and time values (like a
  /// [LocalDateTime]). This conversion treats `DateTime` like
  /// it's an [Instant]. Which means the date and time of the result will
  /// be different if the timezones don't match. (I've personally been
  /// surprised by this when hard coding [defaultZoneId] in a test. It
  /// passed locally but failed later in a Github action, because the
  /// `DateTime` time zone was different.)
  ///
  /// Best practice: Don't use `DateTime` as a `LocalDateTime`, and when
  /// interacting with APIs that use it that way, convert it to `LocalDateTime` as
  /// soon as possible. To catch these issues in unit tests, set [defaultZoneId]
  /// to something that's likely to always conflict with the system time zone. I
  /// suggest "Pacific/Kiritimati."
  ZonedDateTime.fromDateTime(DateTime dateTime, [String? zoneId])
      : this.fromInstant(Instant.fromDateTime(dateTime), zoneId);

  /// Creates a `ZonedDateTime` using the current time.
  ///
  /// {@macro zone_id}
  ZonedDateTime.now([String? zoneId]) : this.fromDateTime(clock.now(), zoneId);

  /// Looks up a time zone and throws ArgumentError if it's invalid.
  static NamedZoneOffset _lookupTimeZone(String zoneId, HasInstant instant) {
    var tz = TimeZoneDatabase().rules[zoneId]?.offsetFor(instant);
    if (tz == null) {
      throw ArgumentError.value(zoneId, 'zoneId');
    }
    return tz;
  }

  /// Builds a `ZonedDateTime` for the given LocalDateTime and zone id.
  ///
  /// What's going on here:
  /// There's a chicken and egg problem. We need an Instant to determine
  /// the correct time zone (that's how they're defined in IANA's data),
  /// but we don't know the instant without knowing the time zone.
  /// Instead, start at the previous day and skip forward. This is
  /// a bit fiddly, but I don't have any better ideas right now.
  static ZonedDateTime _forLocal(LocalDateTime local, [String? zoneId]) {
    zoneId ??= defaultZoneId;
    var instant = Instant._fromRataDieDate(
        local.date.minusTimespan(Timespan(days: 1))._asTimespan);
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

  /// The earliest possible datetime.
  static const ZonedDateTime minimum = ZonedDateTime._(
      OffsetDateTime.minimum, NamedZoneOffset('UTC', false, 0), 'UTC');

  /// The latest possible datetime.
  static const ZonedDateTime maximum = ZonedDateTime._(
      OffsetDateTime.maximum, NamedZoneOffset('UTC', false, 0), 'UTC');

  final OffsetDateTime _dateTime;

  /// The offset from UTC.
  final NamedZoneOffset offset;

  /// A string that uniquely identifies the time zone.
  final String zoneId;

  /// The common designation for the time zone (e.g. UTC, PST, PDT, CET, CEST).
  ///
  /// These strings are not necessarily unique but are commonly used and
  /// understood by humans. See [zoneId] for a unique identifier.
  String get timeZone => offset.name;

  /// If this is a daylight savings (or summer) time.
  bool get isDst => offset.isDst;

  /// Converts this to a [LocalDateTime].
  ///
  /// The result will have exactly the same year, month, day, etc. but will
  /// lack any time zone information.
  @override
  LocalDateTime toLocal() => _dateTime.toLocal();

  /// Returns an equivalent [OffsetDateTime] with the same offset.
  ///
  /// To convert this to an `OffsetDateTime` with a different offset, use
  /// [atOffset].
  OffsetDateTime get asOffsetDateTime => _dateTime;

  /// Converts this to an `OffsetDateTime`.
  ///
  /// If unspecified, [offset] defaults to the offset for [defaultZoneId].
  /// To retain the existing offset, use [asOffsetDateTime].
  @override
  OffsetDateTime atOffset([ZoneOffset? offset]);

  /// Converts this to a standard Dart [DateTime] in the **local** time zone.
  ///
  /// [DateTime] only supports two time zones: "local" and UTC, so this
  /// conversion loses the time zone.
  @override
  DateTime toDateTime() => DateTime.fromMicrosecondsSinceEpoch(
      _dateTime.toInstant().unixTimestamp.inMicroseconds);

  @override
  Instant toInstant() => _dateTime.toInstant();

  /// Adds a [Timespan].
  ///
  /// This increments the underlying [Instant] by exactly [timespan].
  /// When adding a whole number of days, this could result in the time
  /// changing because of daylight savings.
  ///
  /// See also [plusPeriod].
  ZonedDateTime plusTimespan(Timespan timespan) =>
      ZonedDateTime.fromInstant(toInstant().plusTimespan(timespan), zoneId);

  /// Subtracts a [Timespan].
  ///
  /// This decrements the underlying [Instant] by exactly [timespan].
  /// When subtracting a whole number of days, this could result in the time
  /// changing because of daylight savings.
  ///
  /// See also [minusPeriod].
  ZonedDateTime minusTimespan(Timespan timespan) =>
      ZonedDateTime.fromInstant(toInstant().minusTimespan(timespan), zoneId);

  /// Adds a [Period].
  ///
  /// This works like [LocalDateTime.plusPeriod], but has the same limitations
  /// as the [ZonedDateTime()] constructor. The result may be adjusted if
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
  /// as the [ZonedDateTime()] constructor. The result may be adjusted if
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
  bool get inLeapYear => _dateTime.inLeapYear;

  /// Returns this as an ISO 8601-formatted string with an offset.
  ///
  /// ```dart
  /// ZonedDateTime('America/Los Angeles', 2000, 1, 1, 12, 30).toString() ==
  ///     '2000-01-01T12:30-0800';
  /// ZonedDateTime('America/Los Angeles', 2000, 6, 1, 12, 30).toString() ==
  ///     '2000-06-01T12:30-0700';
  /// ```
  @override
  String toString() => _iso8601DateTime(this, offset);

  /// The equality operator.
  ///
  /// Two [ZonedDateTime]s compare equal if and only if they have the same
  /// date/time _and_ the same [zoneId]. If you just want to know if two
  /// represent the same moment in time, use [compareTo] or [toInstant].
  ///
  /// ```dart
  /// // Same moment in time; different time zones:
  /// var d1 = ZonedDateTime('America/Denver', 2023, 1, 1);
  /// var d2 = ZonedDateTime('America/Los Angeles', 2022, 12, 31, 23);
  ///
  /// d1 != d2;
  /// d1.compareTo(d2) == 0;
  /// d1.toInstant() == d2.toInstant();
  /// ```
  @override
  bool operator ==(Object other) =>
      other is ZonedDateTime &&
      _dateTime == other._dateTime &&
      zoneId == other.zoneId;

  @override
  int get hashCode => Object.hash(_dateTime, zoneId);
}
