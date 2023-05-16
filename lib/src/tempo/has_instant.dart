part of '../../tempo.dart';

/// Interface implemented by any class that is tied to a specific [Instant]
/// in time.
abstract class HasInstant implements Comparable<HasInstant> {
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
