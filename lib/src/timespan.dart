/// A duration of time with nanosecond precision.
///
/// This represents a duration of time equal to
///
/// [dayPart] + [nanosecondPart] / nanoseconds_per_day
///
/// There are two important differences between this and [Duration]:
/// precision and longest representable timespan. This can represent
/// spans down to the nanosecond vs. microsecond for `Duration`, and
/// it can represent much longer time spans (read on for details).
///
/// ## Longest Timespan
///
/// The longest representable timespans are a bit complicated. [Duration]
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

  /// The raw whole number of days.
  ///
  /// May be positive or negative.
  ///
  /// **Important**: If this is negative, it is _not_ equal to the floor
  /// of the number of days spanned by this. Use [inDays] for that instead.
  final int dayPart;

  /// The raw fractional part of the day in nanoseconds;
  ///
  /// This will always be positive, even when [dayPart] is negative.
  final int nanosecondPart;

  Timespan._(this.dayPart, this.nanosecondPart);

  // Constructs a timespan from days + fraction.
  //
  // Either days or fraction may be negative, but the result
  // will be normalized to a positive fraction less than one day.
  //
  // The first part of this is straightforward. Divide out the whole days,
  // floor(fraction / denominator), add that to days, and leave the remainder.
  //
  // Forcing the fraction to be positive is a bit trickier. The key
  // realization is this:
  //
  //    -a / b = (b - a) / b - 1
  //
  // Since in this case a < b, then b - a must be positive. Bringing that
  // back into this timespan, we have
  //
  //    days + -a / b = days + (b - a) / b - 1
  //                  = (days - 1) + (b - a) / b
  factory Timespan._fromParts(int days, int fraction) {
    days += (fraction / _nanosecondsPerDay).floor();
    fraction = fraction.remainder(_nanosecondsPerDay);
    if (fraction.isNegative) {
      fraction = _nanosecondsPerDay + fraction;
    }
    assert(!fraction.isNegative);
    return Timespan._(days, fraction);
  }

  /// Constructs a [Timespan].
  ///
  /// This is meant to work much like [Duration] with [nanoseconds].
  ///
  /// Any fields may be positive or negative, but the result will always
  /// be normalized to a positive [microseconds].
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
  /// This is _not_ equivalent to [dayPart] for negative timespans.
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
  bool get isNegative => dayPart.isNegative;

  Timespan operator +(Timespan other) => Timespan._fromParts(
      dayPart + other.dayPart, nanosecondPart + other.nanosecondPart);
  Timespan operator -(Timespan other) => Timespan._fromParts(
      dayPart - other.dayPart, nanosecondPart - other.nanosecondPart);
  Timespan operator *(num other) => Timespan._fromParts(
      (dayPart * other).floor(), (nanosecondPart * other).floor());
  Timespan operator ~/(num other) =>
      Timespan._fromParts(dayPart ~/ other, nanosecondPart ~/ other);

  bool operator <(Timespan other) => compareTo(other) < 0;
  bool operator <=(Timespan other) => compareTo(other) <= 0;
  bool operator >(Timespan other) => compareTo(other) > 0;
  bool operator >=(Timespan other) => compareTo(other) >= 0;

  Timespan operator -() => Timespan._fromParts(-dayPart, -nanosecondPart);

  /// Converts this to a duration with a loss of precision.
  Duration toDuration() => Duration(microseconds: inMicroseconds);

  /// Returns the absolute value of this [Timespan].
  Timespan abs() {
    if (dayPart >= 0) {
      return this;
    } else {
      return Timespan._fromParts(-dayPart, -nanosecondPart);
    }
  }

  @override
  int compareTo(Timespan other) {
    int daycmp = Comparable.compare(dayPart, other.dayPart);
    if (daycmp == 0) {
      return Comparable.compare(nanosecondPart, other.nanosecondPart);
    }
    return daycmp;
  }

  /// Returns a string formatted as an ISO 8601 time duration.
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
