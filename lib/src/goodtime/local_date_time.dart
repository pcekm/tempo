part of '../../goodtime.dart';

/// Contains an ISO 8601 date and time with no time zone.
///
/// This is a combination of [LocalDate] and [LocalTime]. The individual
/// parts can be retrieved with [date] and [time].
class LocalDateTime
    implements
        Comparable<LocalDateTime>,
        HasDateTime,
        _PeriodArithmetic<LocalDateTime> {
  static const int _nsPerMicrosecond = 1000;
  static const int _nsPerMillisecond = 1000000;
  static const int _nsPerSecond = 1000000000;

  static const int _nsPerMinute = 60 * _nsPerSecond;
  static const int _nsPerHour = 60 * _nsPerMinute;

  /// The date part of this [DateTime].
  final LocalDate date;

  /// The time part of this [DateTime].
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
      int nanosecond = 0])
      : time = LocalTime(hour, minute, second, nanosecond),
        date = LocalDate(year, month, day).plusTimespan(Timespan(
            hours: hour,
            minutes: minute,
            seconds: second,
            nanoseconds: nanosecond));

  /// Constructs a [LocalDateTime] with the current date and time in the
  /// current time zone.
  ///
  /// This will have a maximum resolution of microseconds.
  LocalDateTime.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalDateTime] from a standard Dart [DateTime].
  /// The timezone (if any) of [dateTime] is ignored.
  ///
  /// This will have a maximum resolution of microseconds.
  LocalDateTime.fromDateTime(DateTime dateTime)
      : this(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
            dateTime.second,
            dateTime.millisecond * _nsPerMillisecond +
                dateTime.microsecond * _nsPerMicrosecond);

  /// Makes a [LocalDateTime] from a [LocalDate] and an optional
  /// [LocalTime]. Uses midnight if no time is provided.
  LocalDateTime.combine(this.date, [LocalTime? time])
      : time = time ?? LocalTime();

  factory LocalDateTime._fromJulianDay(Timespan julianDay) {
    var parts = julianDayToGregorian(julianDay);
    return LocalDateTime(
        parts.year, parts.month, parts.day, 0, 0, 0, parts.nanosecond);
  }

  Timespan get _julianDay => gregorianToJulianDay(Gregorian(
      year,
      month,
      day,
      hour * _nsPerHour +
          minute * _nsPerMinute +
          second * _nsPerSecond +
          nanosecond));

  /// Returns a new datetime with one or more fields replaced.
  ///
  /// See [LocalDate.replace] and [LocalTime.replace] for more information on
  /// replacements to the respective parts of the datetime.
  ///
  /// ```dart
  /// var dt = LocalDateTime(2000, 1, 31, 12, 23);
  /// dt.replace(month: 4) == LocalDateTime(2000, 4, 30, 12, 23);
  /// dt.replace(second: 59) == LocalDateTime(2000, 4, 30, 12, 23, 59);
  /// ```
  LocalDateTime replace(
      {int? year,
      int? month,
      int? day,
      int? hour,
      int? minute,
      int? second,
      int? nanosecond}) {
    return LocalDateTime.combine(
        date.replace(year: year, month: month, day: day),
        time.replace(
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond));
  }

  /// The year.
  ///
  /// May be zero or negative. Zero means -1 BCE, -1 means -2 BCE, etc.
  /// This is also called astronomical year numbering.
  @override
  int get year => date.year;

  /// The month from 1 to 12.
  @override
  int get month => date.month;

  /// The day starting at 1.
  @override
  int get day => date.day;

  /// Gets the day of the week.
  @override
  Weekday get weekday => date.weekday;

  /// The number of days since the beginning of the year. This will range from
  /// 1 to 366.
  @override
  int get ordinalDay => date.ordinalDay;

  /// The hour from 0 to 23.
  @override
  int get hour => time.hour;

  /// The minute from 0 to 59.
  @override
  int get minute => time.minute;

  /// The second from 0 to 59.
  @override
  int get second => time.second;

  /// The nanoseconds from 0 to 999,999,999.
  @override
  int get nanosecond => time.nanosecond;

  @override
  DateTime toDateTime() =>
      DateTime(year, month, day, hour, minute, second, 0, nanosecond ~/ 1000);

  /// Finds the timespan between [this] and [other].
  Timespan timespanUntil(LocalDateTime other) => other._julianDay - _julianDay;

  /// Adds a [Period] of time.
  ///
  /// This acts on the date parts in exactly the same way as
  /// [LocalDate.plusPeriod()] and leaves the time untouched.
  ///
  /// ```dart
  /// var d = LocalDateTime(2000);
  /// d.plusPeriod(Period(days: 1)) == LocalDateTime(2000, 1, 2);
  /// ```
  @override
  LocalDateTime plusPeriod(Period amount) =>
      LocalDateTime.combine(date.plusPeriod(amount), time);

  /// Subtracts a [Period] of time.
  ///
  /// This acts on the date parts in exactly the same way as
  /// [LocalDate.plusPeriod()] and leaves the time untouched.
  ///
  /// ```dart
  /// var d = LocalDateTime(2000);
  /// d.plusPeriod(Period(days: 1)) == LocalDateTime(2000, 1, 2);
  /// ```
  @override
  LocalDateTime minusPeriod(Period amount) =>
      LocalDateTime.combine(date.minusPeriod(amount), time);

  /// Adds a [Timespan].
  ///
  /// This acts on the time parts exactly like [LocalTime.plusTimespan()]
  /// and increments or decrements the date if the amount is at least
  /// 1 day or negative.
  LocalDateTime plusTimespan(Timespan amount) =>
      LocalDateTime._fromJulianDay(_julianDay + amount);

  /// Subtracts a [Timespan].
  ///
  /// This acts on the time parts exactly like [LocalTime.minusTimespan()]
  /// and increments or decrements the date if the amount is at least
  /// 1 day or positive.
  LocalDateTime minusTimespan(Timespan amount) =>
      LocalDateTime._fromJulianDay(_julianDay - amount);

  @override
  int compareTo(LocalDateTime other) => _julianDay.compareTo(other._julianDay);

  /// Greater than operator.
  bool operator >(LocalDateTime other) => compareTo(other) > 0;

  /// Greater than or equals operator.
  bool operator >=(LocalDateTime other) => compareTo(other) >= 0;

  /// Less than operator.
  bool operator <(LocalDateTime other) => compareTo(other) < 0;

  /// Less than or equals operator.
  bool operator <=(LocalDateTime other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDateTime && date == other.date && time == other.time;

  @override
  int get hashCode => Object.hash(date, time);

  /// Returns the date and time in ISO 8601 format.
  ///
  /// For example, 2000-01-02T12:00:01.000000009.
  @override
  String toString() => _iso8601DateTime(this);
}
