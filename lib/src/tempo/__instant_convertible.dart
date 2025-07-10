part of '../../tempo.dart';

/// Interface for objects that can convert themselves to an [Instant].
abstract interface class _InstantConvertible {
  /// Converts this to an Instant in UTC.
  Instant toInstant();
}
