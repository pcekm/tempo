part of '../../goodtime.dart';

/// Represents a time of day without a time zone.
///
/// Internally this stores the time in [nanosecondsSinceMidnight], which
/// means it can represent any time down to the nanosecond. This does
/// not support leap seconds.
class LocalTime implements Comparable<LocalTime>, HasTime {
  static const int _nano = 1000000000;

  static const int _nsPerS = 1000000000;
  static const int _nsPerMs = 1000000;
  static const int _nsPerUs = 1000;

  static const int _secsPerDay = 86400;
  static const int _secsPerMinute = 60;
  static const int _minsPerHour = 60;
  static const int _secsPerHour = 3600;
  static const int _hoursPerDay = 24;

  /// The time in nanoseconds relative to midnight.
  final int nanosecondsSinceMidnight;

  /// Constructs a new [LocalTime]. If the provided values are bigger than
  /// expected (e.g. minute = 61), the residues will increment the overall time
  /// accordingly. Much like a real clock, this will wrap around if the
  /// total is longer than a day. It will also wrap in the other direction
  /// if the result is negative.
  ///
  /// ```dart
  /// LocalTime(12, 60, 0) == LocalTime(13, 0, 0);
  /// LocalTime(12, 1, 60) == LocalTime(12, 2, 0);
  /// LocalTime(23, 60, 0) == LocalTime(0, 0, 0);
  /// LocalTime(0, 0, -1) == LocalTime(23, 59, 59);
  /// ```
  LocalTime([int hour = 0, int minute = 0, int second = 0, int nanosecond = 0])
      : nanosecondsSinceMidnight = (hour * _secsPerHour * _nano +
                minute * _secsPerMinute * _nano +
                second * _nsPerS +
                nanosecond) %
            (_secsPerDay * _nano);

  /// Constructs a [LocalTime] with the current time in the current time zone.
  ///
  /// The result will have a maximum resolution of microseconds, and on web
  /// platforms it may be milliseconds.
  LocalTime.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalTime] from a standard Dart [DateTime].
  ///
  /// The timezone (if any) of [dateTime] is ignored. The resulting time will
  /// have a maximum resolution of microseconds, and on web platforms it may
  /// be milliseconds.
  LocalTime.fromDateTime(DateTime dateTime)
      : this(dateTime.hour, dateTime.minute, dateTime.second,
            dateTime.millisecond * _nsPerMs + dateTime.microsecond * _nsPerUs);

  /// Returns a new time with one or more fields replaced.
  ///
  /// ```dart
  /// var time = LocalTime(1, 23, 40);
  /// time.replace(minute: 2) == LocalTime(1, 2, 40);
  /// ```
  LocalTime replace({int? hour, int? minute, int? second, int? nanosecond}) {
    hour ??= this.hour;
    minute ??= this.minute;
    second ??= this.second;
    nanosecond ??= this.nanosecond;
    return LocalTime(hour, minute, second, nanosecond);
  }

  /// The hour from 0 to 23.
  @override
  int get hour =>
      (nanosecondsSinceMidnight ~/ (_secsPerHour * _nano)) % _hoursPerDay;

  /// The minute from 0 to 59.
  @override
  int get minute =>
      (nanosecondsSinceMidnight ~/ (_secsPerMinute * _nano)) % _minsPerHour;

  /// Seconds from 0 to 59.
  @override
  int get second => (nanosecondsSinceMidnight ~/ _nano) % _secsPerMinute;

  /// Nanoseconds from 0 to 999,999,999.
  @override
  int get nanosecond => nanosecondsSinceMidnight % _nsPerS;

  /// Finds the [Timespan] between two times. The result will be negative if
  /// [other] is earlier than this.
  Timespan timespanUntil(LocalTime other) =>
      Timespan(nanoseconds: other.nanosecondsSinceMidnight) -
      Timespan(nanoseconds: nanosecondsSinceMidnight);

  /// Adds a [Timespan]. If [span] covers more than one day, the result will
  /// wrap.
  LocalTime plusTimespan(Timespan span) =>
      LocalTime(0, 0, 0, nanosecondsSinceMidnight + span.nanosecondPart);

  /// Subtracts a [Timespan]. If [span] covers more than one day, the result
  /// will wrap.
  LocalTime minusTimespan(Timespan span) =>
      LocalTime(0, 0, 0, nanosecondsSinceMidnight - span.nanosecondPart);

  /// Compares this to another [LocalTime].
  @override
  int compareTo(LocalTime other) => Comparable.compare(
      nanosecondsSinceMidnight, other.nanosecondsSinceMidnight);

  /// Greater than operator.
  bool operator >(LocalTime other) =>
      nanosecondsSinceMidnight > other.nanosecondsSinceMidnight;

  /// Greater than or equals operator.
  bool operator >=(LocalTime other) =>
      nanosecondsSinceMidnight >= other.nanosecondsSinceMidnight;

  /// Less than operator.
  bool operator <(LocalTime other) =>
      nanosecondsSinceMidnight < other.nanosecondsSinceMidnight;

  /// Less than or equals operator.
  bool operator <=(LocalTime other) =>
      nanosecondsSinceMidnight <= other.nanosecondsSinceMidnight;

  @override
  bool operator ==(Object other) =>
      other is LocalTime &&
      nanosecondsSinceMidnight == other.nanosecondsSinceMidnight;

  @override
  int get hashCode => nanosecondsSinceMidnight.hashCode;

  /// Returns the time in ISO 8601 format.
  ///
  /// For example, 04:30:55.123456789.
  @override
  String toString() => _iso8601Time(this);
}
