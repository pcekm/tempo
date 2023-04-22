part of '../goodtime.dart';

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
}
