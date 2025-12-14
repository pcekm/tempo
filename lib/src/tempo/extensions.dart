part of '../../tempo.dart';

/// Adds Tempo conversion methods to the standard [DateTime] class.
extension TempoDateTime on DateTime {
  /// Converts this to a [LocalDateTime].
  ///
  /// The result will have exactly the same year, month, day, etc. but will
  /// lack any time zone information.
  LocalDateTime toLocalDateTime() => LocalDateTime.fromDateTime(this);

  /// Converts this to an [Instant].
  Instant toInstant() => Instant.fromDateTime(this);

  /// Converts this to an [OffsetDateTime] with the given [offset].
  OffsetDateTime atOffset([ZoneOffset? offset]) =>
      OffsetDateTime.fromDateTime(this);

  /// Converts this to a [ZonedDateTime] in the time zone given by [zoneId].
  ///
  /// Uses [defaultZoneId] if [zoneId] is not given.
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
  ZonedDateTime inTimezone([String? zoneId]) =>
      ZonedDateTime.fromDateTime(this, zoneId);
}

/// Adds Tempo conversion methods to the standard [Duration] class.
extension TempoDuration on Duration {
  /// Converts this to a [Timespan].
  Timespan toTimespan() => Timespan.fromDuration(this);
}
