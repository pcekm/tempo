part of '../../tempo.dart';

/// Interface implemented by any class that is tied to a specific [Instant]
/// in time.
abstract class HasInstant implements Comparable<HasInstant> {
  /// The amount of time since midnight, January 1, 1970 UTC.
  ///
  /// This is a [Timespan], which can be easily converted into whatever
  /// units you might require.
  ///
  /// For example:
  ///
  /// ```dart
  /// var instant = Instant.now();
  /// instant.unixTimestamp.inSeconds;
  /// instant.unixTimestamp.inMilliseconds;
  /// instant.unixTimestamp.inNanoseconds;
  /// instant.unixTimestamp.inDays;  // Probably not very useful, but it works!
  /// ```
  Timespan get unixTimestamp;

  /// Converts this to an [Instant].
  Instant get asInstant;

  /// Greater than operator.
  bool operator >(HasInstant other);

  /// Greater than or equals operator.
  bool operator >=(HasInstant other);

  /// Less than operator.
  bool operator <(HasInstant other);

  /// Less than or equals operator.
  bool operator <=(HasInstant other);

  /// Converts this to an [OffsetDateTime] with the given [offset].
  OffsetDateTime atOffset(ZoneOffset offset);

  /// Converts this to a [ZonedDateTime] with the given [zoneId].
  ZonedDateTime inTimezone(String zoneId);

  /// Finds the amount of time between this and another instant in time.
  Timespan timespanUntil(HasInstant other);

  /// Compares this to another [HasInstant].
  ///
  /// Returns a negative integer if [this] comes before [other],
  /// a positive integer if [this] comes after [other], and
  /// zero if [this] and [other] are at the exact same moment.
  @override
  int compareTo(HasInstant other);
}
