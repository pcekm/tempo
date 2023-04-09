import 'package:sprintf/sprintf.dart';
import 'package:tuple/tuple.dart';

import 'localdate.dart';
import 'localtime.dart';
import 'weekday.dart';

/// Contains a local date on the proleptic Gregorian calendar with no timezone.
class LocalDate {
  static const int _daysPerWeek = 7;

  // Internally, dates are represented in days since 12:00 January 1, 4713 BC
  // on the proleptic Julian calendar. Because this is externally meaningless
  // without a time zone, these values need to be private.
  final int _julianDays;

  const LocalDate([int year = 0, int month = 1, int day = 1])
      // See https://en.wikipedia.org/wiki/Julian_day
      : _julianDays = ((1461 * (year + 4800 + (month - 14) ~/ 12)) ~/ 4 +
            (367 * (month - 2 - 12 * ((month - 14) ~/ 12))) ~/ 12 -
            (3 * ((year + 4900 + (month - 14) ~/ 12) ~/ 100)) ~/ 4 +
            day -
            32075);

  const LocalDate._(this._julianDays);

  /// The earliest date that can be properly represented by this class.
  static const LocalDate minimum = LocalDate._(0);

  /// The latest date that can be _safely_ represented by this class across
  /// web and native platforms. Native platforms with 64-bit ints will be able
  /// to exceed this by quite a bit.
  static const LocalDate safeMaximum = LocalDate._(9007199254740992);

  /// Constructs a [LocalDate] with the current date and time in the
  /// current time zone.
  LocalDate.now() : this.fromDateTime(DateTime.now());

  /// Constructs a [LocalDate] from a standard Dart [DateTime].
  /// The timezone (if any) of [dateTime] is ignored.
  LocalDate.fromDateTime(DateTime dateTime)
      : this(dateTime.year, dateTime.month, dateTime.day);

  Tuple3<int, int, int> _yearMonthDay() {
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

    return Tuple3<int, int, int>(Y, M, D);
  }

  int get year => _yearMonthDay().item1;
  int get month => _yearMonthDay().item2;
  int get day => _yearMonthDay().item3;

  Weekday get weekday => Weekday.values[_julianDays % _daysPerWeek + 1];

  @override
  bool operator ==(Object other) =>
      other is LocalDate && _julianDays == other._julianDays;

  bool operator >(LocalDate other) => _julianDays > other._julianDays;

  bool operator >=(LocalDate other) => _julianDays >= other._julianDays;

  bool operator <(LocalDate other) => _julianDays < other._julianDays;

  bool operator <=(LocalDate other) => _julianDays <= other._julianDays;

  /// Returns the date in ISO 8601 format.
  @override
  String toString() {
    var format = "%${(year < 1 || year > 9999) ? '+05' : '04'}d-%02d-%02d";
    return sprintf(format, [year, month, day]);
  }
}
