part of '../../tempo.dart';

/// Interface implemented by objects that have a date on the
/// ISO 8601 calendar.
///
/// {@category local}
abstract interface class HasDate {
  /// The year.
  ///
  /// {@template astro_year}
  /// The year field uses astronomical year numbering. This is based on
  /// CE / AD and is the same for year 1 onwards. Unlike CE / AD, it
  /// includes a year zero and may be negative. Some examples:
  ///
  /// | CE / BCE                 | Astronomical |
  /// | -----------------------: | -----------: |
  /// |                 2025 CE  |         2025 |
  /// |                 1066 CE  |         1066 |
  /// |                    1 CE  |            1 |
  /// |                    1 BCE |            0 |
  /// |                    2 BCE |           -1 |
  /// |                  480 BCE |         -479 |
  /// {@endtemplate}
  int get year;

  /// The month from 1 to 12.
  int get month;

  /// The day starting at 1.
  int get day;

  /// The day of the week.
  Weekday get weekday;

  /// The number of days since the beginning of the year.
  ///
  /// Ranges from 1 to 365 (or 366 on a leap year).
  int get ordinalDay;
}
