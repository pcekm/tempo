part of '../../tempo.dart';

/// Either a `Timespan` or a `Period`.
///
/// This is a common type for functions that can operate on either a
/// `Timespan` or a `Period`. For example:
///
/// ```dart
/// LocalDateTime foo(RelativeTime amount) => switch (amount) {
///       Period() => _fooPeriod(amount),
///       Timespan() => _fooTimespan(amount),
///     };
/// ```
///
/// {@category relative}
sealed class RelativeTime {
  const RelativeTime();
}
