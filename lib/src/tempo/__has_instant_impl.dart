part of '../../tempo.dart';

/// Implementation of common operations for HasInstant classes.
abstract mixin class _HasInstantImpl implements HasInstant {
  @override
  int compareTo(HasInstant other) {
    return Comparable.compare(unixTimestamp, other.toInstant().unixTimestamp);
  }

  @override
  bool operator >(HasInstant other) => compareTo(other) > 0;

  @override
  bool operator >=(HasInstant other) => compareTo(other) >= 0;

  @override
  bool operator <(HasInstant other) => compareTo(other) < 0;

  @override
  bool operator <=(HasInstant other) => compareTo(other) <= 0;

  @override
  OffsetDateTime atOffset(ZoneOffset offset) =>
      OffsetDateTime.fromInstant(this, offset);

  @override
  ZonedDateTime inTimezone([String? zoneId]) =>
      ZonedDateTime.fromInstant(this, zoneId);

  @override
  Timespan timespanUntil(HasInstant other) =>
      other.toInstant().unixTimestamp - unixTimestamp;
}
