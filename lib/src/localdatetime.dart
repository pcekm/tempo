import 'localdate.dart';
import 'localtime.dart';
import 'weekday.dart';

/// Contains a date and time with no time zone on the proleptic Gregorian
/// calendar.
class LocalDateTime {
  static const int _secsPerDay = 86400;
  static const int _secsPerMinute = 60;
  static const int _secsPerHour = 3600;
  static const int _milli = 1000;
  static const int _micro = 1000000;

  // Internally, this is represented in (fractional) seconds since 12:00
  // January 1, 4713 BC on the proleptic Julian calendar. Since this
  // value is externally meaningless without a time zone, these values
  // need to be private.
  final int _julianSeconds;

  // The fractional part of _julianSeconds.
  final int _julianMicroseconds;

  const LocalDateTime(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : _julianSeconds = _secsPerDay *
                ((1461 * (year + 4800 + (month - 14) ~/ 12)) ~/ 4 +
                    (367 * (month - 2 - 12 * ((month - 14) ~/ 12))) ~/ 12 -
                    (3 * ((year + 4900 + (month - 14) ~/ 12) ~/ 100)) ~/ 4 +
                    day -
                    32075) +
            (hour - 12) * _secsPerHour +
            minute * _secsPerMinute +
            second +
            millisecond ~/ _milli +
            microsecond ~/ _micro,
        _julianMicroseconds =
            (millisecond % _milli) * _milli + (microsecond % _micro);

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

    final int J = _julianSeconds ~/ _secsPerDay;
    final int f = J + j + (((4 * J + B) ~/ 146097) * 3) ~/ 4 + C;
    final int e = r * f + v;
    final int g = (e % p) ~/ r;
    final int h = u * g + w;

    final int D = (h % s) ~/ u + 1 + (hour < 12 ? 1 : 0);
    final int M = (h ~/ s + m) % n + 1;
    final int Y = e ~/ p - y + (n + m - M) ~/ n;

    return LocalDate(Y, M, D);
  }

  int get year => this.date.year;
  int get month => this.date.month;
  int get day => this.date.day;

  LocalTime get time => LocalTime(
      this.hour, this.minute, this.second, this.millisecond, this.microsecond);

  int get hour => (_julianSeconds ~/ _secsPerHour + 12) % 24;
  int get minute => (_julianSeconds ~/ _secsPerMinute) % 60;
  int get second => _julianSeconds % 60;
  int get millisecond => _julianMicroseconds ~/ _milli;
  int get microsecond => _julianMicroseconds % _micro - millisecond * _milli;

  Weekday get weekday => Weekday
      .values[((_julianSeconds + 12 * _secsPerHour) ~/ _secsPerDay) % 7 + 1];

  @override
  bool operator ==(Object other) =>
      other is LocalDateTime &&
      _julianSeconds == other._julianSeconds &&
      _julianMicroseconds == other._julianMicroseconds;

  bool operator >(LocalDateTime other) =>
      _julianSeconds > other._julianSeconds ||
      (_julianSeconds == other._julianSeconds &&
          _julianMicroseconds > other._julianMicroseconds);

  bool operator >=(LocalDateTime other) =>
      _julianSeconds >= other._julianSeconds ||
      (_julianSeconds == other._julianSeconds &&
          _julianMicroseconds >= other._julianMicroseconds);

  bool operator <(LocalDateTime other) =>
      _julianSeconds < other._julianSeconds ||
      (_julianSeconds == other._julianSeconds &&
          _julianMicroseconds < other._julianMicroseconds);

  bool operator <=(LocalDateTime other) =>
      _julianSeconds <= other._julianSeconds ||
      (_julianSeconds == other._julianSeconds &&
          _julianMicroseconds <= other._julianMicroseconds);
}
