import 'localdate.dart';
import 'localtime.dart';
import 'period.dart';
import 'weekday.dart';

/// Contains a date and time with no time zone on the proleptic Gregorian
/// calendar.
class LocalDateTime {
  static const int _milli = 1000;
  static const int _micro = 1000000;

  static const int _microsecondsPerHour = 60 * _microsecondsPerMinute;
  static const int _microsecondsPerMinute = 60 * _micro;
  static const int _microsecondsPerDay = 86400 * _micro;

  final LocalDate date;
  final LocalTime time;

  /// Constructs a new LocalDateTime.
  ///
  /// The time arguments wrap in exactly the same way they do in [LocalTime],
  /// with one addition. A wrap increments or decrements the date part
  /// accordingly.
  ///
  /// The date fields are pickier in the same way that [LocalDate]'s fields
  /// are picky.
  ///
  /// ```dart
  /// LocalDateTime(2000, 1, 1, 25) == LocalDateTime(2000, 1, 2, 1);
  /// LocalDateTime(2000, 1, 1, -1) == LocalDateTime(1999, 12, 31, 23);
  /// ```
  LocalDateTime(
      [int year = 0,
      int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : time = LocalTime(hour, minute, second, millisecond, microsecond),
        date = LocalDate(year, month, day) +
            _dateAdjustment(hour, minute, second, millisecond, microsecond);

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

  /// Makes a [LocalDateTime] from a [LocalDate] and an optional
  /// [LocalTime].
  LocalDateTime.combine(this.date, [LocalTime? time])
      : time = time ?? LocalTime();

  /// The earliest date that can be properly represented by this class.
  static final LocalDateTime minimum =
      LocalDateTime.combine(LocalDate.minimum, LocalTime.minimum);

  /// The latest date that can be _safely_ represented by this class across
  /// web and native platforms. Native platforms with 64-bit ints will be able
  /// to exceed this by quite a bit.
  static final LocalDateTime safeMaximum =
      LocalDateTime.combine(LocalDate.safeMaximum, LocalTime.maximum);

  // The amount to adjust a date if the time parameters wrap backwards
  // or forwards.
  static Period _dateAdjustment(
      int hour, int minute, int second, int millisecond, int microsecond) {
    var total = hour * _microsecondsPerHour +
        minute * _microsecondsPerMinute +
        second * _micro +
        millisecond * _milli +
        microsecond;
    if (total < 0) {
      return Period(days: -1 + total ~/ _microsecondsPerDay);
    } else {
      return Period(days: total ~/ _microsecondsPerDay);
    }
  }

  int get year => date.year;
  int get month => date.month;
  int get day => date.day;

  Weekday get weekday => date.weekday;

  int get ordinalDay => date.ordinalDay;
  int get microsecondsSinceMidnight => time.microsecondsSinceMidnight;

  int get hour => time.hour;
  int get minute => time.minute;
  int get second => time.second;
  int get millisecond => time.millisecond;
  int get microsecond => time.microsecond;

  /// Finds the duration between [this] and [other].
  Duration durationUntil(Object other) {
    if (other is LocalDateTime) {
      return date.durationUntil(other.date) + time.durationUntil(other.time);
    } else if (other is LocalDate) {
      return date.durationUntil(other);
    } else {
      throw ArgumentError(
          'Invalid type for durationUntil: ${other.runtimeType}');
    }
  }

  /// Adds a [Duration] or [Period]. Throws [ArgumentError] for other types.
  ///
  /// If [amount] is a Period, this acts on the date parts in exactly the same
  /// way as [LocalDate.operator+()]. If [amount] is a Duration, it acts
  /// on the time parts exactly like [LocalTime.operator+()] and increments
  /// or decrements the date if the amount is at least 1 day or negative.
  ///
  /// ```dart
  /// var d= LocalDateTime(2000);
  /// d + Period(days: 1) == LocalDateTime(2000, 1, 2);
  /// d - Period(days: -1) == LocalDateTime(1999, 12, 31);
  /// d + Duration(seconds: 1) == LocalDateTime(2000, 1, 1, 0, 0, 1);
  /// d + Duration(days: 1, seconds: 1) == LocalDateTime(2000, 1, 2, 0, 0, 1);
  /// d + Duration(days: -1, seconds: -1) == LocalDateTime(1999, 12, 30, 23, 59, 59);
  /// ```
  LocalDateTime operator +(Object amount) {
    if (amount is Period) {
      return LocalDateTime.combine(date + amount, time);
    }
    if (amount is Duration) {
      var days = amount.inDays - (amount.inMicroseconds < 0 ? 1 : 0);
      return LocalDateTime.combine(date + Period(days: days), time + amount);
    } else {
      throw ArgumentError(
          'Invalid type added to LocalDateTime: ${amount.runtimeType}');
    }
  }

  bool operator >(LocalDateTime other) =>
      date > other.date || (date == other.date && time > other.time);

  bool operator >=(LocalDateTime other) =>
      date >= other.date || (date == other.date && time >= other.time);

  bool operator <(LocalDateTime other) =>
      date < other.date || (date == other.date && time < other.time);

  bool operator <=(LocalDateTime other) =>
      date <= other.date || (date == other.date && time <= other.time);

  @override
  bool operator ==(Object other) =>
      other is LocalDateTime && date == other.date && time == other.time;

  @override
  int get hashCode => Object.hash(date, time);

  /// Returns the date and time in ISO 8601 format.
  @override
  String toString() => '${date}T$time';
}
