part of '../../tempo.dart';

/// Interface implemented by classes that provide the time of day.
///
/// {@category local}
abstract interface class HasTime {
  /// The hour from 0 to 23.
  int get hour;

  /// The minute from 0 to 59.
  int get minute;

  /// The second from 0 to 59.
  int get second;

  /// The nanoseconds from 0 to 999,999,999.
  int get nanosecond;
}
