import 'package:sprintf/sprintf.dart';
import 'package:tuple/tuple.dart';

import 'util.dart';
import 'weekday.dart';

/// Contains a local date on the proleptic Gregorian calendar with no timezone.
class LocalDate {
  static const int _daysPerWeek = 7;

  /// The number of days since 12:00 January 1, 4713 BC on the proleptic Julian
  /// calendar.
  final int julianDays;

  const LocalDate([int year = 0, int month = 1, int day = 1])
      // See https://en.wikipedia.org/wiki/Julian_day
      : julianDays = ((1461 * (year + 4800 + (month - 14) ~/ 12)) ~/ 4 +
            (367 * (month - 2 - 12 * ((month - 14) ~/ 12))) ~/ 12 -
            (3 * ((year + 4900 + (month - 14) ~/ 12) ~/ 100)) ~/ 4 +
            day -
            32075);

  const LocalDate.ofJulianDays(this.julianDays);

  /// The earliest date that can be properly represented by this class.
  static const LocalDate minimum = LocalDate.ofJulianDays(0);

  /// The latest date that can be _safely_ represented by this class across
  /// web and native platforms. Native platforms with 64-bit ints will be able
  /// to exceed this by quite a bit.
  static const LocalDate safeMaximum = LocalDate.ofJulianDays(9007199254740992);

  /// Constructs a [LocalDate] with the current date and time in the
  /// current time zone.
  LocalDate.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalDate] from a standard Dart [DateTime].
  /// The timezone (if any) of [dateTime] is ignored.
  LocalDate.fromDateTime(DateTime dateTime)
      : this(dateTime.year, dateTime.month, dateTime.day);

  int get year => julianDaysToGregorian(julianDays).item1;
  int get month => julianDaysToGregorian(julianDays).item2;
  int get day => julianDaysToGregorian(julianDays).item3;

  Weekday get weekday => Weekday.values[julianDays % _daysPerWeek + 1];

  /// The number of days since the beginning of the year. This will range from
  /// 1 to 366.
  int get ordinalDay => julianDays - LocalDate(year).julianDays + 1;

  @override
  bool operator ==(Object other) =>
      other is LocalDate && julianDays == other.julianDays;

  @override
  int get hashCode => julianDays.hashCode;

  bool operator >(LocalDate other) => julianDays > other.julianDays;

  bool operator >=(LocalDate other) => julianDays >= other.julianDays;

  bool operator <(LocalDate other) => julianDays < other.julianDays;

  bool operator <=(LocalDate other) => julianDays <= other.julianDays;

  /// Returns the date in ISO 8601 format.
  @override
  String toString() {
    var format = "%${(year < 1 || year > 9999) ? '+05' : '04'}d-%02d-%02d";
    return sprintf(format, [year, month, day]);
  }
}
