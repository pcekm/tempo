part of '../goodtime.dart';

/// Represents a single instant in time.
///
/// Leap second handling
/// [UTC-SLS](https://www.cl.cam.ac.uk/~mgk25/time/utc-sls/).
class Instant implements HasInstant {
  static final Timespan _julianOffset = Timespan(days: 2440587, hours: 12);

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
  final Timespan unixTimestamp;

  /// Creates an instant given a time since midnight, January 1, 1970 UTC.
  ///
  /// The Unix timestamp can be provided in any units supported by [Timespan].
  /// These examples all produce the same `Instant`:
  ///
  /// ```dart
  /// Instant.fromUnix(Timespan(seconds: 1));
  /// Instant.fromUnix(Timespan(milliseconds: 1000));
  /// Instant.fromUnix(Timespan(nanoseconds: 1000000000));
  /// ```
  Instant.fromUnix(this.unixTimestamp);

  Instant._fromJulianDay(Timespan julian)
      : unixTimestamp =
            Timespan(days: julian.dayPart, nanoseconds: julian.nanosecondPart) -
                _julianOffset;

  @override
  Instant get asInstant => this;

  Timespan get _julianDay => unixTimestamp + _julianOffset;

  /// Returns the amount of time between this and another instant in time.
  Timespan timespanUntil(HasInstant other) =>
      other.asInstant.unixTimestamp - unixTimestamp;

  /// Adds a [Timespan].
  Instant plusTimespan(Timespan t) => Instant.fromUnix(unixTimestamp + t);

  /// Subtracts a [Timespan].
  Instant minusTimespan(Timespan t) => Instant.fromUnix(unixTimestamp - t);

  @override
  int compareTo(HasInstant other) {
    return Comparable.compare(unixTimestamp, other.asInstant.unixTimestamp);
  }

  /// Greater than operator.
  @override
  bool operator >(HasInstant other) => compareTo(other) > 0;

  /// Greater than or equals operator.
  @override
  bool operator >=(HasInstant other) => compareTo(other) >= 0;

  /// Less than operator.
  @override
  bool operator <(HasInstant other) => compareTo(other) < 0;

  /// Less than or equals operator.
  @override
  bool operator <=(HasInstant other) => compareTo(other) <= 0;

  /// Formats this as an ISO 8601 timestamp.
  ///
  /// For example, `2000-01-02T03:04:05.123456789Z`.
  @override
  String toString() {
    var parts = julianDayToGregorian(_julianDay);
    var dateTime = LocalDateTime(
        parts.year, parts.month, parts.day, 0, 0, 0, parts.nanosecond);
    return '${dateTime.toString()}Z';
  }

  @override
  bool operator ==(Object other) =>
      (other is Instant) && unixTimestamp == other.unixTimestamp;

  @override
  int get hashCode => unixTimestamp.hashCode;
}
