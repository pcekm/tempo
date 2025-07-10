part of '../../tempo.dart';

/// Interface for datetime classes that can convert to other datetime classes.
abstract interface class _ConvertibleDate implements _InstantConvertible {
  /// Converts this to a DateTime in the local time zone.
  DateTime toDateTime();

  /// Converts this to a ZonedDateTime.
  ///
  /// If unspecified, [zoneId] defaults to [ZonedDateTime.defaultZoneId].
  ZonedDateTime inTimezone([String? zoneId]);

  /// Converts this to an OffsetDateTime with the given offset.
  OffsetDateTime atOffset(ZoneOffset offset);

  /// Converts this to a LocalDateTime.
  LocalDateTime toLocal();
}
