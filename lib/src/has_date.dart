import 'weekday.dart';

/// Interface implemented by objects that have a date on the
/// ISO 8601 calendar.
abstract class HasDate {
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

  /// Converts this to a [DateTime] in the local time zone.
  DateTime toDateTime();
}
