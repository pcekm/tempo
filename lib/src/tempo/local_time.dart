part of '../../tempo.dart';

/// A time of day without a time zone.
///
/// Internally this stores the time in [nanosecondsSinceMidnight], which
/// means it can represent any time down to the nanosecond.
///
/// {@category local}
@immutable
class LocalTime implements Comparable<LocalTime>, HasTime {
  /// Constructs a new [LocalTime].
  ///
  /// If the provided values are bigger than expected (e.g. minute = 61),
  /// the residues will increment the overall time accordingly. Much
  /// like a real clock, this will wrap around if the total is longer
  /// than a day. It will also wrap in the other direction if the result
  /// is negative.
  ///
  /// ```dart
  /// LocalTime(12, 60, 0) == LocalTime(13, 0, 0);
  /// LocalTime(12, 1, 60) == LocalTime(12, 2, 0);
  /// LocalTime(23, 60, 0) == LocalTime(0, 0, 0);
  /// LocalTime(0, 0, -1) == LocalTime(23, 59, 59);
  /// ```
  const LocalTime(
      [int hour = 0, int minute = 0, int second = 0, int nanosecond = 0])
      : nanosecondsSinceMidnight = (hour * nsPerHour +
                minute * nsPerMinute +
                second * nsPerSecond +
                nanosecond) %
            nsPerDay;

  /// Constructs a [LocalTime] with the current time in [defaultZoneId].
  ///
  /// This uses [DateTime] underneath, and the resulting time will have the same
  /// precision.
  factory LocalTime.now() => ZonedDateTime.now().toLocal().time;

  /// Constructs a [LocalTime] from a standard Dart [DateTime].
  ///
  /// The timezone (if any) of [dateTime] is ignored.
  LocalTime.fromDateTime(DateTime dateTime)
      : this(
            dateTime.hour,
            dateTime.minute,
            dateTime.second,
            dateTime.millisecond * nsPerMillisecond +
                dateTime.microsecond * nsPerMicrosecond);

  /// Parses an ISO 8601 time string.
  ///
  /// ```dart
  /// LocalTime.parse('01:02:03.000000004') == LocalTime(1, 2, 3, 4);
  /// LocalTime.parse('T010203') == LocalTime(1, 2, 3);
  /// ```
  factory LocalTime.parse(String time) => _parseIso8601Time(time);

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

  /// The earliest possible time.
  static const minimum = LocalTime(0);

  /// The latest possible time.
  static const maximum = LocalTime(23, 59, 59, nsPerSecond - 1);

  /// The time in nanoseconds relative to midnight.
  final int nanosecondsSinceMidnight;

  @override
  int get hour => (nanosecondsSinceMidnight ~/ nsPerHour) % hoursPerDay;

  @override
  int get minute => (nanosecondsSinceMidnight ~/ nsPerMinute) % minutesPerHour;

  @override
  int get second => (nanosecondsSinceMidnight ~/ nsPerSecond) % sPerMinute;

  @override
  int get nanosecond => nanosecondsSinceMidnight % nsPerSecond;

  /// Finds the [Timespan] between two times. The result will be negative if
  /// [other] is earlier than this.
  Timespan timespanUntil(LocalTime other) =>
      Timespan(nanoseconds: other.nanosecondsSinceMidnight) -
      Timespan(nanoseconds: nanosecondsSinceMidnight);

  /// Adds a [Timespan]. If [span] covers more than one day, the result will
  /// wrap.
  LocalTime operator +(Timespan span) => LocalTime(0, 0, second + span.seconds,
      nanosecondsSinceMidnight + span.nanosecondPart);

  /// Adds a [Timespan]. If [span] covers more than one day, the result will
  /// wrap.
  @Deprecated('Use + and - operators instead.')
  LocalTime plusTimespan(Timespan span) => this + span;

  /// Subtracts a [Timespan]. If [span] covers more than one day, the result
  /// will wrap.
  LocalTime operator -(Timespan span) => LocalTime(0, 0, second - span.seconds,
      nanosecondsSinceMidnight - span.nanosecondPart);

  /// Subtracts a [Timespan]. If [span] covers more than one day, the result
  /// will wrap.
  @Deprecated('Use + and - operators instead.')
  LocalTime minusTimespan(Timespan span) => this - span;

  /// {@macro quantize_base}
  ///
  /// Examples:
  ///
  /// ```dart
  /// final time = LocalTime(4, 5, 6, 7);
  /// expect(time.quantize(Timespan(days: 1)), hasTime(0));
  /// expect(time.quantize(Timespan(hours: 3)), hasTime(3));
  /// expect(time.quantize(Timespan(minutes: 10)), hasTime(4, 0));
  /// expect(time.quantize(Timespan(seconds: 4)), hasTime(4, 5, 4));
  /// expect(time.quantize(Timespan(nanoseconds: 5)), hasTime(4, 5, 6, 5));
  /// ```
  @experimental
  LocalTime quantize(Timespan amount) => LocalTime(
      0,
      0,
      0,
      (nanosecondsSinceMidnight / amount.inNanoseconds).floor() *
          amount.inNanoseconds);

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

  /// Formats object using the given format.
  ///
  /// The results for formats that include year, month or day is unspecified.
  String format(DateFormat format) =>
      format.format(DateTime(0, 1, 1, hour, minute, second));

  /// Returns the time in ISO 8601 format.
  ///
  /// ```dart
  /// LocalTime(9, 45).toString() == '09:45';
  /// LocalTime(4, 30, 55, 123456789).toString() == '04:30:55.123456789';
  /// ```
  @override
  String toString() => _iso8601Time(this);
}
