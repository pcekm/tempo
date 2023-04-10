/// Represents a period between to dates on a calendar.
class Period {
  final int years;
  final int months;
  final int days;

  const Period({this.years = 0, this.months = 0, this.days = 0});

  /// Provided for convenience and readability. Equivalent to
  /// Period(days: 7 * weeks).
  const Period.ofWeeks(int weeks) : this(days: 7 * weeks);

  /// Periods compare equal if and only if each of [years], [months] and [days]
  /// are equal. Because "year" and "month" are flexible concepts—some years
  /// and months are different than others (leap years, Februarys), comparing
  /// them to days would be ambiguous.
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
    String y = years > 0 ? '${years}Y' : '';
    String m = months > 0 ? '${months}M' : '';
    String d = days > 0 ? '${days}D' : '';
    return 'P$y$m$d';
  }
}
