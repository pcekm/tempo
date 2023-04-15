import 'package:fixnum/fixnum.dart';

import 'interfaces.dart';
import 'localdate.dart';
import 'localtime.dart';
import 'period.dart';
import 'util.dart';
import 'weekday.dart';

/// Contains a date and time with no time zone on the proleptic Gregorian
/// calendar.
class LocalDateTime implements HasRataDie {
  final LocalDate date;
  final LocalTime time;

  /// Constructs a new LocalDateTime.
  ///
  /// The time arguments wrap in exactly the same way they do in [LocalTime],
  /// with one addition. A wrap increments or decrements the date part
  /// accordingly.
  ///
  /// The date args are passed to [LocalDate()] which may throw an
  /// exception if the values are invalid.
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

  // The amount to adjust a date if the time parameters wrap backwards
  // or forwards.
  static Period _dateAdjustment(
      int hour, int minute, int second, int millisecond, int microsecond) {
    var dur = Duration(
        hours: hour,
        minutes: minute,
        seconds: second,
        milliseconds: millisecond,
        microseconds: microsecond);
    if (dur.isNegative) {
      return Period(days: -1 + dur.inDays);
    } else {
      return Period(days: dur.inDays);
    }
  }

  @override
  Int64 get rataDieUsec => gregorianToRataDieUsec(
      year, month, day, hour, minute, second, millisecond * 1000 + microsecond);

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
  Duration durationUntil(HasRataDie other) {
    return Duration(microseconds: (other.rataDieUsec - rataDieUsec).toInt());
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

  int _compare(HasRataDie other) =>
      Comparable.compare(rataDieUsec, other.rataDieUsec);

  bool operator >(HasRataDie other) => _compare(other) > 0;

  bool operator >=(HasRataDie other) => _compare(other) >= 0;

  bool operator <(HasRataDie other) => _compare(other) < 0;

  bool operator <=(HasRataDie other) => _compare(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDateTime && date == other.date && time == other.time;

  @override
  int get hashCode => Object.hash(date, time);

  /// Returns the date and time in ISO 8601 format.
  @override
  String toString() => '${date}T$time';
}
