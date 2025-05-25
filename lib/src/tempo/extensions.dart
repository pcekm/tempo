part of '../../tempo.dart';

/// Adds Tempo conversion methods to the standard [DateTime] class.
extension TempoDateTime on DateTime {
  /// Converts this to a [LocalDateTime].
  ///
  /// The result will have exactly the same year, month, day, etc. but will
  /// lack any time zone information.
  LocalDateTime toLocal() => LocalDateTime.fromDateTime(this);

  /// Converts this to an [Instant].
  Instant toInstant() => Instant.fromDateTime(this);

  /// Converts this to an [OffsetDateTime] with the given [offset].
  OffsetDateTime atOffset(ZoneOffset offset) =>
      OffsetDateTime.fromDateTime(this);

  /// Converts this to a [ZonedDateTime] in the time zone given by [zoneId].
  ///
  /// Uses [ZonedDateTime.defaultZoneId] if [zoneId] is not given.
  ZonedDateTime inTimezone([String? zoneId]) =>
      ZonedDateTime.fromDateTime(this, zoneId);
}

/// Adds Tempo conversion methods to the standard [Duration] class.
extension TempoDuration on Duration {
  /// Converts this to a [Timespan].
  Timespan toTimespan() => Timespan.fromDuration(this);
}
