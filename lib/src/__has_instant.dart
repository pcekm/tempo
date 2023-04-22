part of '../goodtime.dart';

/// Interface implemented by any class that is tied to a specific [Instant]
/// in time.
abstract class _HasInstant implements Comparable<_HasInstant> {
  /// Converts this to an [Instant].
  Instant get asInstant;

  /// Greater than operator.
  bool operator >(_HasInstant other);

  /// Greater than or equals operator.
  bool operator >=(_HasInstant other);

  /// Less than operator.
  bool operator <(_HasInstant other);

  /// Less than or equals operator.
  bool operator <=(_HasInstant other);
}
