import 'package:sprintf/sprintf.dart';

/// Contains a time of day. Think of this as exactly what you'd normally see
/// on a wall clock. It has no concept of the current date, leap seconds or
/// anything else.
class LocalTime {
  static const int _milli = 1000;
  static const int _micro = 1000000;

  static const int _secsPerDay = 86400;
  static const int _secsPerMinute = 60;
  static const int _minsPerHour = 60;
  static const int _secsPerHour = 3600;
  static const int _hoursPerDay = 24;

  final int microsecondsSinceMidnight;

  /// Constructs a new [LocalTime]. If the provided values are bigger than
  /// expected (e.g. minute = 61), the residues will increment the overall time
  /// accordingly. Throws [RangeError] if the result overflows a 24-hour
  /// period.
  ///
  /// ```dart
  /// LocalTime(12, 60, 0) == LocalTime(13, 1, 0);
  /// LocalTime(12, 1, 60) == LocalTime(12, 2, 0);
  /// LocalTime(12, 61, 0)  // Throws error
  /// ```
  LocalTime(
      [int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : microsecondsSinceMidnight = hour * _secsPerHour * _micro +
            minute * _secsPerMinute * _micro +
            second * _micro +
            millisecond * _milli +
            microsecond {
    if (this > maximum || this < minimum) {
      throw RangeError(
          'LocalTime($hour, $minute, $second, $millisecond, $microsecond) is outside of a normal day.');
    }
  }

  /// Creates a [LocalTime] using the number of microseconds since midnight.
  LocalTime.ofMicroseconds(this.microsecondsSinceMidnight);

  /// The start of the day. 00:00
  static final LocalTime minimum = LocalTime.ofMicroseconds(0);

  /// The very last moment of the day as precisely as this class can
  /// represent it: 23:59.999999
  static final LocalTime maximum =
      LocalTime.ofMicroseconds((_secsPerDay - 1) * _micro + _micro - 1);

  /// Constructs a [LocalTime] with the currenttime in the current time zone.
  LocalTime.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalTime] from a standard Dart [DateTime].
  /// The timezone (if any) of [dateTime] is ignored.
  LocalTime.fromDateTime(DateTime dateTime)
      : this(dateTime.hour, dateTime.minute, dateTime.second,
            dateTime.millisecond, dateTime.microsecond);

  int get hour =>
      (microsecondsSinceMidnight ~/ (_secsPerHour * _micro)) % _hoursPerDay;
  int get minute =>
      (microsecondsSinceMidnight ~/ (_secsPerMinute * _micro)) % _minsPerHour;
  int get second => (microsecondsSinceMidnight ~/ _micro) % _secsPerMinute;
  int get millisecond => (microsecondsSinceMidnight ~/ _milli) % 1000;
  int get microsecond => microsecondsSinceMidnight % 1000;

  @override
  bool operator ==(Object other) =>
      other is LocalTime &&
      microsecondsSinceMidnight == other.microsecondsSinceMidnight;

  @override
  int get hashCode => microsecondsSinceMidnight.hashCode;

  bool operator >(LocalTime other) =>
      microsecondsSinceMidnight > other.microsecondsSinceMidnight;

  bool operator >=(LocalTime other) =>
      microsecondsSinceMidnight >= other.microsecondsSinceMidnight;

  bool operator <(LocalTime other) =>
      microsecondsSinceMidnight < other.microsecondsSinceMidnight;

  bool operator <=(LocalTime other) =>
      microsecondsSinceMidnight <= other.microsecondsSinceMidnight;

  @override
  String toString() => sprintf('%02d:%02d:%02d.%03d%03d',
      [hour, minute, second, millisecond, microsecond]);
}
