import 'localdate.dart';
import 'localtime.dart';
import 'weekday.dart';

/// Contains a date and time with no time zone on the proleptic Gregorian
/// calendar.
class LocalDateTime {
  static const int _milli = 1000;
  static const int _micro = 1000000;

  static const int _secsPerMinute = 60;
  static const int _secsPerHour = 3600;

  // The number of days since 12:00 January 1, 4713 BC on the proleptic Julian
  // calendar.
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
      //
      // Unfortunately, these calculations are repeated in LocalDate
      // and LocalTime. There's currently no getting around this if we
      // want this to be a const constructor.
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

  /// The earliest date that can be properly represented by this class.
  static final LocalDateTime minimum =
      LocalDateTime.of(LocalDate.minimum, LocalTime.minimum);

  /// The latest date that can be _safely_ represented by this class across
  /// web and native platforms. Native platforms with 64-bit ints will be able
  /// to exceed this by quite a bit.
  static final LocalDateTime safeMaximum =
      LocalDateTime.of(LocalDate.safeMaximum, LocalTime.maximum);

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

  /// Constructs a [LocalDateTime] from a [LocalDate] and an optional
  /// [LocalTime].
  LocalDateTime.of(LocalDate date, [LocalTime? time])
      : _julianDays = date.julianDays,
        _microsecondsSinceMidnight =
            (time ?? LocalTime(0)).microsecondsSinceMidnight;

  LocalDate get date => LocalDate.fromJulianDays(_julianDays);

  int get year => date.year;
  int get month => date.month;
  int get day => date.day;

  Weekday get weekday => date.weekday;

  /// The number of days since the beginning of the year. This will range from
  /// 1 to 366.
  int get ordinalDay => LocalDate.fromJulianDays(_julianDays).ordinalDay;

  LocalTime get time => LocalTime.ofMicroseconds(_microsecondsSinceMidnight);

  int get hour => time.hour;
  int get minute => time.minute;
  int get second => time.second;
  int get millisecond => time.millisecond;
  int get microsecond => time.microsecond;

  @override
  bool operator ==(Object other) =>
      other is LocalDateTime &&
      _julianDays == other._julianDays &&
      _microsecondsSinceMidnight == other._microsecondsSinceMidnight;

  @override
  int get hashCode => Object.hash(_julianDays, _microsecondsSinceMidnight);

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
  String toString() => '${date}T$time';
}
