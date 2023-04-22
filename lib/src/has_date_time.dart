import 'weekday.dart';

/// Inteface for classes that provide date and time fields.
abstract class HasDateTime {
  /// The year.
  ///
  /// May be zero or negative. Zero means -1 BCE, -1 means -2 BCE, etc.
  /// This is also called astronomical year numbering.
  int get year;

  /// The month from 1 to 12.
  int get month;

  /// The day starting at 1.
  int get day;

  /// Gets the day of the week.
  Weekday get weekday;

  /// The number of days since the beginning of the year. This will range from
  /// 1 to 366.
  int get ordinalDay;

  /// The hour from 0 to 23.
  int get hour;

  /// The minute from 0 to 59.
  int get minute;

  /// The second from 0 to 59.
  int get second;

  /// The nanoseconds from 0 to 999,999,999.
  int get nanosecond;
}
