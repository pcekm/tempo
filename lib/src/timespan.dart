/// A duration of time with nanosecond precision.
///
/// This represents a duration of time equal to
///
/// [dayPart] + [nanosecondPart] / nanoseconds_per_day
///
/// The component numbers will always be normalized as follows:
///
///   * -1 < [nanosecondPart] < 1
///   * [dayPart].sign == [nanosecondPart].sign
///
/// There are two important differences between this and [Duration]:
/// precision and longest representable timespan. This has nanosecond
/// precision vs. microsecond for `Duration`, and it can represent
/// much longer time spans (read on for details).
///
/// ## Longest Timespan
///
/// The longest representable timespans are a bit complicated. `Duration`
/// stores a single [int] in microseconds. This stores two ints: one for the
/// number of days, and one for a nanosecond fraction of days.
///
/// Dart's [maximum int size](https://dart.dev/guides/language/numbers) varies,
/// but you can count on at least 53 bits. Which means `Duration` can cover
/// at least `2^53 / (86400 * 10^6)` or about `10^5` days. Since this class
/// dedicates a full int just to days, it can cover at least `2^53` days,
/// or about `9 * 10^15`.
///
/// With that said, other factors will limit the practical maximum. In
/// particular, conversion operations like [inMicroseconds] and date
/// arithmetic could overflow.
class Timespan implements Comparable<Timespan> {
  static const int _hoursPerDay = 24;
  static const int _minutesPerHour = 60;
  static const int _secondsPerMinute = 60;
  static const int _nanosecondsPerSecond = 1000000000;

  static const int _minutesPerDay = _minutesPerHour * _hoursPerDay;
  static const int _secondsPerDay = _secondsPerMinute * _minutesPerDay;
  static const int _millisecondsPerDay = 1000 * _secondsPerDay;
  static const int _microsecondsPerDay = 1000 * _millisecondsPerDay;
  static const int _nanosecondsPerDay = 1000 * _microsecondsPerDay;

  static const int _nsPerMicrosecond = 1000;
  static const int _nsPerMillisecond = 1000000;
  static const int _nsPerSecond = 1000000000;
  static const int _nsPerMinute = 60 * _nsPerSecond;
  static const int _nsPerHour = 60 * _nsPerMinute;

  /// The whole number of days.
  ///
  /// Mathematically, [dayPart] = int([dayPart] + [nanosecondPart]), where
  /// [int()](https://mathworld.wolfram.com/IntegerPart.html) gives the integer
  /// part of a real number.
  final int dayPart;

  /// The fractional part of the day in nanoseconds.
  ///
  /// Mathematically, [nanosecondPart] = frac([dayPart] + [nanosecondPart]),
  /// where [frac()](https://mathworld.wolfram.com/FractionalPart.html) gives
  /// the fractional part of a real number.
  final int nanosecondPart;

  Timespan._(this.dayPart, this.nanosecondPart);

  // Constructs a timespan from days + fraction.
  //
  // Either days or fraction may be negative and any value, but the result
  // will be normalized as follows:
  //
  //   - -1 < nanosecondPart < 1
  //   - dayPart.sign == nanosecondPart.sign
  factory Timespan._fromParts(int days, int fraction) {
    days += fraction ~/ _nanosecondsPerDay;
    fraction = fraction.remainder(_nanosecondsPerDay);
    if (days < 0 && fraction > 0) {
      ++days;
      fraction -= _nanosecondsPerDay;
    } else if (days > 0 && fraction < 0) {
      --days;
      fraction += _nanosecondsPerDay;
    }
    assert(days.sign * fraction.sign != -1);
    return Timespan._(days, fraction);
  }

  /// Constructs a [Timespan].
  ///
  /// This is meant to work much like a higher-precision [Duration].
  ///
  /// Any fields may be positive or negative, but the result will always
  /// be normalized as follows:
  ///
  ///   - -1 < [nanosecondPart] < 1
  ///   - [dayPart].sign == [nanosecondPart].sign
  factory Timespan(
      {int days = 0,
      int hours = 0,
      int minutes = 0,
      int seconds = 0,
      int milliseconds = 0,
      int microseconds = 0,
      int nanoseconds = 0}) {
    var fraction = hours * _nsPerHour +
        minutes * _nsPerMinute +
        seconds * _nsPerSecond +
        milliseconds * _nsPerMillisecond +
        microseconds * _nsPerMicrosecond +
        nanoseconds;
    return Timespan._fromParts(days, fraction);
  }

  /// Gets the timespan in days.
  ///
  /// This is equvalent to [dayPart] and included for consistency.
  int get inDays => (dayPart + nanosecondPart / _nanosecondsPerDay).truncate();

  int _sum(int dayMultiplier, int nanoDivisor) =>
      (dayPart * dayMultiplier + nanosecondPart / nanoDivisor).truncate();

  /// Gets the timespan in hours.
  int get inHours => _sum(_hoursPerDay, _nsPerHour);

  /// Gets the timespan in minutes.
  int get inMinutes => _sum(_minutesPerDay, _nsPerMinute);

  /// Gets the timespan in seconds.
  int get inSeconds => _sum(_secondsPerDay, _nsPerSecond);

  /// Gets the timespan in milliseconds.
  int get inMilliseconds => _sum(_millisecondsPerDay, _nsPerMillisecond);

  /// Gets the timespan in microseconds.
  int get inMicroseconds => _sum(_microsecondsPerDay, _nsPerMicrosecond);

  /// Gets the timespan in nanoseconds.
  int get inNanoseconds => _sum(_nanosecondsPerDay, 1);

  /// Determines if the timespan is negative.
  bool get isNegative => dayPart.isNegative || nanosecondPart.isNegative;

  /// Addition operator.
  Timespan operator +(Timespan other) => Timespan._fromParts(
      dayPart + other.dayPart, nanosecondPart + other.nanosecondPart);

  /// Subtraction operator.
  Timespan operator -(Timespan other) => Timespan._fromParts(
      dayPart - other.dayPart, nanosecondPart - other.nanosecondPart);

  /// Multiplication operator. Fractional results are rounded towards zero.
  Timespan operator *(num other) => Timespan._fromParts(
      (dayPart * other).truncate(), (nanosecondPart * other).truncate());

  /// Integer division operator.
  Timespan operator ~/(num other) =>
      Timespan._fromParts(dayPart ~/ other, nanosecondPart ~/ other);

  /// Less than operator.
  bool operator <(Timespan other) => compareTo(other) < 0;

  /// Less than or equal operator.
  bool operator <=(Timespan other) => compareTo(other) <= 0;

  /// Greater than operator.
  bool operator >(Timespan other) => compareTo(other) > 0;

  /// Greater than or equal operator.
  bool operator >=(Timespan other) => compareTo(other) >= 0;

  /// Unary negation operator.
  Timespan operator -() => Timespan._fromParts(-dayPart, -nanosecondPart);

  /// Converts this to a duration with a loss of precision.
  Duration toDuration() => Duration(microseconds: inMicroseconds);

  /// Returns the absolute value of this [Timespan].
  Timespan abs() {
    // Important: this is only true because the both parts are normalized
    // with matching signs.
    return Timespan._fromParts(dayPart.abs(), nanosecondPart.abs());
  }

  /// Compares this to another [Timespan].
  ///
  /// Returns 0 if they are equal, -1 if this < [other] and 1 if this > [other].
  @override
  int compareTo(Timespan other) {
    int daycmp = Comparable.compare(dayPart, other.dayPart);
    if (daycmp == 0) {
      return Comparable.compare(nanosecondPart, other.nanosecondPart);
    }
    return daycmp;
  }

  /// Returns a string formatted as an ISO 8601 time duration.
  ///
  /// Some examples:
  ///   * One day: P1D
  ///   * Ten minutes: PT10M
  ///   * Two days, three hours, one minute, 30 seconds: P2DT3H1M30S
  ///   * Negative duration: P-3DT-1H
  @override
  String toString() {
    if (dayPart == 0 && nanosecondPart == 0) {
      return 'P0D';
    }
    int adjDays = dayPart;
    int adjFraction = nanosecondPart;
    if (dayPart.isNegative && nanosecondPart > 0) {
      ++adjDays;
      adjFraction = -(_nanosecondsPerDay - nanosecondPart);
    }
    int hours = (adjFraction ~/ _nsPerHour).remainder(_hoursPerDay);
    int minutes = (adjFraction ~/ _nsPerMinute).remainder(_minutesPerHour);
    int seconds = (adjFraction ~/ _nsPerSecond).remainder(_secondsPerMinute);
    int nanos = adjFraction.remainder(_nanosecondsPerSecond);

    var d = adjDays != 0 ? '${adjDays}D' : '';
    var h = hours != 0 ? '${hours}H' : '';
    var m = minutes != 0 ? '${minutes}M' : '';
    var s = seconds != 0 || nanos != 0 ? '$seconds' : '';
    if (seconds == 0 && nanos < 0) {
      s = '-0';
    }
    s += nanos != 0 ? ".${'${nanos.abs()}'.padLeft(9, '0')}" : '';
    s += s != '' ? 'S' : '';
    return 'P$d${h.isNotEmpty || m.isNotEmpty || s.isNotEmpty ? "T" : ""}$h$m$s';
  }

  @override
  bool operator ==(Object other) =>
      (other is Timespan) &&
      dayPart == other.dayPart &&
      nanosecondPart == other.nanosecondPart;

  @override
  int get hashCode => Object.hash(dayPart, nanosecondPart);
}
