import 'package:sprintf/sprintf.dart';

/// TODO: This repeats a lot that's in [LocalDateTime].
///
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

  final int _microsecondsSinceMidnight;

  const LocalTime(
      [int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      // See https://en.wikipedia.org/wiki/Julian_day
      : _microsecondsSinceMidnight = (hour * _secsPerHour * _micro +
                minute * _secsPerMinute * _micro +
                second * _micro +
                millisecond * _milli +
                microsecond) %
            (_secsPerDay * _micro);

  const LocalTime._(this._microsecondsSinceMidnight);

  /// The start of the day. 00:00
  static const LocalTime minimum = LocalTime._(0);

  /// The very last moment of the day as precisely as this class can
  /// represent it: 23:59.999999
  static const LocalTime maximum =
      LocalTime._((_secsPerDay - 1) * _micro + _micro - 1);

  /// Constructs a [LocalTime] with the currenttime in the current time zone.
  LocalTime.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalTime] from a standard Dart [DateTime].
  /// The timezone (if any) of [dateTime] is ignored.
  LocalTime.fromDateTime(DateTime dateTime)
      : this(dateTime.hour, dateTime.minute, dateTime.second,
            dateTime.millisecond, dateTime.microsecond);

  int get hour =>
      (_microsecondsSinceMidnight ~/ (_secsPerHour * _micro)) % _hoursPerDay;
  int get minute =>
      (_microsecondsSinceMidnight ~/ (_secsPerMinute * _micro)) % _minsPerHour;
  int get second => (_microsecondsSinceMidnight ~/ _micro) % _secsPerMinute;
  int get millisecond => (_microsecondsSinceMidnight ~/ _milli) % 1000;
  int get microsecond => _microsecondsSinceMidnight % 1000;

  @override
  bool operator ==(Object other) =>
      other is LocalTime &&
      _microsecondsSinceMidnight == other._microsecondsSinceMidnight;

  @override
  int get hashCode => _microsecondsSinceMidnight.hashCode;

  bool operator >(LocalTime other) =>
      _microsecondsSinceMidnight > other._microsecondsSinceMidnight;

  bool operator >=(LocalTime other) =>
      _microsecondsSinceMidnight >= other._microsecondsSinceMidnight;

  bool operator <(LocalTime other) =>
      _microsecondsSinceMidnight < other._microsecondsSinceMidnight;

  bool operator <=(LocalTime other) =>
      _microsecondsSinceMidnight <= other._microsecondsSinceMidnight;

  @override
  String toString() => sprintf('%02d:%02d:%02d.%03d%03d',
      [hour, minute, second, millisecond, microsecond]);
}
