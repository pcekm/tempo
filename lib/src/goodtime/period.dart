part of '../../goodtime.dart';

/// Represents a period between two dates on a calendar.
///
/// Unlike [Timespan] and [Duration], which both represent an absolute length of
/// time, the exact length of time this represents varies according to
/// the dates it's relative to.
///
/// ```dart
/// var d1 = LocalDate(2023, 2, 1);
/// var d2 = LocalDate(2023, 3, 2);
/// d1.periodUntil(d2) == Period(months: 1, days: 1);
/// d2.timespanUntil(d2) == Timespan(days: 29);
/// ```
class Period {
  final int years;
  final int months;
  final int days;

  const Period({this.years = 0, this.months = 0, this.days = 0});

  /// Provided for convenience and readability. Equivalent to
  /// Period(days: 7 * weeks).
  const Period.ofWeeks(int weeks) : this(days: 7 * weeks);

  /// Returns an equivalent period in which months is less than 12. This does
  /// not attempt to convert days to months or years, which would be ambiguous.
  ///
  /// ```dart
  /// Period(months: 25).normalize() == Period(years: 2, months: 1);
  /// Period(months: 12, days: 5).normalize() == Period(years: 1, days: 5);
  /// Period(days: 35).normalize() == Period(days: 35);  // unchanged
  /// ```
  Period normalize() => Period(
      years: years + months ~/ 12, months: months.remainder(12), days: days);

  Period operator -() {
    return Period(years: -years, months: -months, days: -days);
  }

  /// Tests whether this [Period] is exactly the same as another.
  ///
  /// Periods compare equal if and only if each of [years], [months] and [days]
  /// are equal. Because "year" and "month" are flexible concepts—some years
  /// and months are different than others (leap years, Februarys), comparing
  /// them to days would be ambiguous.
  ///
  /// Furthermore, even though a period of 1 year is unambiguously the same
  /// amount of time as 12 months, they would still be unequal.
  ///
  /// ```dart
  /// Period(days: 30) != Period(months: 1);
  /// Period(years: 1) != Period(months: 12);
  ///
  /// ```
  @override
  bool operator ==(Object other) =>
      other is Period &&
      years == other.years &&
      months == other.months &&
      days == other.days;

  @override
  int get hashCode => Object.hash(years, months, days);

  @override
  String toString() {
    if (days == 0 && months == 0 && years == 0) {
      return 'P0D';
    }
    String y = years != 0 ? '${years}Y' : '';
    String m = months != 0 ? '${months}M' : '';
    String d = days != 0 ? '${days}D' : '';
    return 'P$y$m$d';
  }
}