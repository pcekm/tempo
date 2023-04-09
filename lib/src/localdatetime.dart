import 'package:sprintf/sprintf.dart';

import 'localdate.dart';
import 'localtime.dart';
import 'weekday.dart';

/// Contains a date and time with no time zone on the proleptic Gregorian
/// calendar.
class LocalDateTime {
  static const int _milli = 1000;
  static const int _micro = 1000000;

  static const int _secsPerDay = 86400;
  static const int _secsPerMinute = 60;
  static const int _minsPerHour = 60;
  static const int _secsPerHour = 3600;
  static const int _hoursPerDay = 24;

  static const int _daysPerWeek = 7;

  // Internally, dates are represented in days since 12:00 January 1, 4713 BC
  // on the proleptic Julian calendar. Because this is externally meaningless
  // without a time zone, these values need to be private.
  final int _julianDays;

  // For simplicity, this class assumes _julianDays implies no time of day.
  // To combine both of these into the fractional part of a Julian day,
  // add 12 hours and divide by the number of microseconds in a day:
  //
  //    (_microsecondsSinceMidnight + (12 * 60 * 60 * 1000000)) / (86400 * 1000000)
  final int _microsecondsSinceMidnight;

  const LocalDateTime(
      [int year = 0,
      int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      // See https://en.wikipedia.org/wiki/Julian_day
      : _julianDays = ((1461 * (year + 4800 + (month - 14) ~/ 12)) ~/ 4 +
            (367 * (month - 2 - 12 * ((month - 14) ~/ 12))) ~/ 12 -
            (3 * ((year + 4900 + (month - 14) ~/ 12) ~/ 100)) ~/ 4 +
            day -
            32075),
        _microsecondsSinceMidnight = hour * _secsPerHour * _micro +
            minute * _secsPerMinute * _micro +
            second * _micro +
            millisecond * _milli +
            microsecond;

  const LocalDateTime._(this._julianDays, this._microsecondsSinceMidnight);

  /// The earliest date that can be properly represented by this class.
  static LocalDateTime minimum = LocalDateTime._(0, 0);

  /// The latest date that can be _safely_ represented by this class across
  /// web and native platforms. Native platforms with 64-bit ints will be able
  /// to exceed this by quite a bit.
  static LocalDateTime safeMaximum = LocalDateTime._(
      9007199254740992, (_secsPerDay - 1) * _micro + _micro - 1);

  /// Constructs a [LocalDateTime] with the current date and time in the
  /// current time zone.
  LocalDateTime.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalDateTime] from a standard Dart [DateTime].
  /// The timezone (if any) of [dateTime] is ignored.
  LocalDateTime.fromDateTime(DateTime dateTime)
      : this(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
            dateTime.second,
            dateTime.millisecond,
            dateTime.microsecond);

  /// Constructs a [LocalDateTime] from a [LocalDate] and a [LocalTime].
  LocalDateTime.fromLocals(LocalDate date,
      [LocalTime time = const LocalTime(0)])
      : this(date.year, date.month, date.day, time.hour, time.minute,
            time.second, time.millisecond, time.microsecond);

  LocalDate get date {
    // See https://en.wikipedia.org/wiki/Julian_day
    const int y = 4716;
    const int j = 1401;
    const int m = 2;
    const int n = 12;
    const int r = 4;
    const int p = 1461;
    const int v = 3;
    const int u = 5;
    const int s = 153;
    const int w = 2;
    const int B = 274277;
    const int C = -38;

    final int f =
        _julianDays + j + (((4 * _julianDays + B) ~/ 146097) * 3) ~/ 4 + C;
    final int e = r * f + v;
    final int g = (e % p) ~/ r;
    final int h = u * g + w;

    final int D = (h % s) ~/ u + 1;
    final int M = (h ~/ s + m) % n + 1;
    final int Y = e ~/ p - y + (n + m - M) ~/ n;

    return LocalDate(Y, M, D);
  }

  int get year => this.date.year;
  int get month => this.date.month;
  int get day => this.date.day;

  LocalTime get time => LocalTime(
      this.hour, this.minute, this.second, this.millisecond, this.microsecond);

  int get hour =>
      (_microsecondsSinceMidnight ~/ (_secsPerHour * _micro)) % _hoursPerDay;
  int get minute =>
      (_microsecondsSinceMidnight ~/ (_secsPerMinute * _micro)) % _minsPerHour;
  int get second => (_microsecondsSinceMidnight ~/ _micro) % _secsPerMinute;
  int get millisecond => (_microsecondsSinceMidnight ~/ _milli) % 1000;
  int get microsecond => _microsecondsSinceMidnight % 1000;

  Weekday get weekday => Weekday.values[_julianDays % _daysPerWeek + 1];

  @override
  bool operator ==(Object other) =>
      other is LocalDateTime &&
      _julianDays == other._julianDays &&
      _microsecondsSinceMidnight == other._microsecondsSinceMidnight;

  bool operator >(LocalDateTime other) =>
      _julianDays > other._julianDays ||
      (_julianDays == other._julianDays &&
          _microsecondsSinceMidnight > other._microsecondsSinceMidnight);

  bool operator >=(LocalDateTime other) =>
      _julianDays >= other._julianDays ||
      (_julianDays == other._julianDays &&
          _microsecondsSinceMidnight >= other._microsecondsSinceMidnight);

  bool operator <(LocalDateTime other) =>
      _julianDays < other._julianDays ||
      (_julianDays == other._julianDays &&
          _microsecondsSinceMidnight < other._microsecondsSinceMidnight);

  bool operator <=(LocalDateTime other) =>
      _julianDays <= other._julianDays ||
      (_julianDays == other._julianDays &&
          _microsecondsSinceMidnight <= other._microsecondsSinceMidnight);

  @override
  String toString() {
    var format =
        "%${(year < 1 || year > 9999) ? '+05' : '04'}d-%02d-%02dT%02d:%02d:%02d.%03d%03d";
    return sprintf(format,
        [year, month, day, hour, minute, second, millisecond, microsecond]);
  }
}
