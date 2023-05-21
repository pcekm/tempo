part of '../../tempo.dart';

/// A duration of time with nanosecond precision.
///
/// This represents a duration of time equal to
///
/// [seconds] + [nanosecondPart] * `10^-9` seconds.
///
/// The component numbers will always be normalized as follows:
///
///   - `-10^9` < [nanosecondPart] < `10^9`
///   - [seconds].sign == [nanosecondPart].sign
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
/// number of seconds, and one for a nanosecond fraction of seconds.
///
/// Dart's [maximum int size](https://dart.dev/guides/language/numbers) varies,
/// but you can count on at least 53 bits. Which means `Duration` can cover
/// at least `2^53 / (86400 * 10^6)` or about `10^5` days. [Timespan]
/// dedicates a full int to seconds and can cover at least `2^53` seconds,
/// which is roughly 200 million years.
///
/// With that said, other factors will limit the practical maximum. In
/// particular, conversion operations like [inMicroseconds] and date
/// arithmetic could overflow.
@immutable
class Timespan implements Comparable<Timespan> {
  static const int _hoursPerDay = 24;
  static const int _minutesPerHour = 60;
  static const int _secondsPerMinute = 60;
  static const int _millisecondsPerSecond = 1000;
  static const int _microsecondsPerSecond = 1000000;
  static const int _nanosecondsPerSecond = 1000000000;
  static const int _secondsPerHour = _minutesPerHour * _secondsPerMinute;

  static const int _minutesPerDay = _minutesPerHour * _hoursPerDay;
  static const int _secondsPerDay = _secondsPerMinute * _minutesPerDay;

  static const int _nsPerMicrosecond = 1000;
  static const int _nsPerMillisecond = 1000000;

  /// The whole number of seconds.
  final int seconds;

  /// The fractional part of the number of seconds in nanoseconds.
  final int nanosecondPart;

  Timespan._(this.seconds, this.nanosecondPart);

  /// Constructs a normalized Timespan from a seconds and nanoseconds part.
  ///
  /// Either [seconds] or [nanoseconds] may be negative and any value, but
  /// the result will be normalized as follows:
  ///
  ///   - `-10^9` < [nanosecondPart] < `10^9`
  ///   - [seconds].sign == [nanosecondPart].sign
  factory Timespan._fromParts(int seconds, int nanoseconds) {
    seconds += nanoseconds ~/ _nanosecondsPerSecond;
    nanoseconds = nanoseconds.remainder(_nanosecondsPerSecond);
    if (seconds < 0 && nanoseconds > 0) {
      ++seconds;
      nanoseconds -= _nanosecondsPerSecond;
    } else if (seconds > 0 && nanoseconds < 0) {
      --seconds;
      nanoseconds += _nanosecondsPerSecond;
    }
    assert(seconds.sign * nanoseconds.sign != -1);
    return Timespan._(seconds, nanoseconds);
  }

  /// Constructs a [Timespan].
  ///
  /// This is meant to work much like a higher-precision [Duration].
  ///
  /// Any fields may be positive or negative, but the result will always
  /// be normalized as follows:
  ///
  ///   - `-10^9` < [nanosecondPart] < `10^9`
  ///   - [seconds].sign == [nanosecondPart].sign
  factory Timespan(
      {int days = 0,
      int hours = 0,
      int minutes = 0,
      int seconds = 0,
      int milliseconds = 0,
      int microseconds = 0,
      int nanoseconds = 0}) {
    var secondPart = days * _secondsPerDay +
        hours * _secondsPerHour +
        minutes * _secondsPerMinute +
        seconds;

    /// Divide seconds out of each fractional part to minimize the risk of
    /// overflow.
    secondPart += milliseconds ~/ _millisecondsPerSecond;
    milliseconds = milliseconds.remainder(_millisecondsPerSecond);

    secondPart += microseconds ~/ _microsecondsPerSecond;
    microseconds = microseconds.remainder(_microsecondsPerSecond);

    secondPart += nanoseconds ~/ _nanosecondsPerSecond;
    nanoseconds = nanoseconds.remainder(_nanosecondsPerSecond);

    var nanosecondPart = milliseconds * _nsPerMillisecond +
        microseconds * _nsPerMicrosecond +
        nanoseconds;
    return Timespan._fromParts(secondPart, nanosecondPart);
  }

  /// Constructs a [Timespan] from a [Duration].
  factory Timespan.fromDuration(Duration duration) =>
      Timespan(microseconds: duration.inMicroseconds);

  /// Parses an ISO 8601 period string.
  ///
  /// Any years, months or weeks fields will be ignored.
  ///
  /// ```dart
  /// Timespan.parse('PT1H2M3S') == Timespan(hours: 1, minutes: 2, seconds: 3);
  /// Timespan.parse('PT3.2S') == Timespan(seconds: 3, nanoseconds: 200000000);
  /// Timespan.parse('P1DT3M') == Timespan(days: 1, minutes: 3);
  /// Timespan.parse('P1YT3S') == Timespan(seconds: 3);  // Ignores years.
  /// ```
  factory Timespan.parse(String periodString) {
    var fields = _parseIso8601Period(periodString);
    return Timespan(
        days: fields.days,
        hours: fields.hours,
        minutes: fields.minutes,
        seconds: fields.seconds,
        nanoseconds: fields.nanoseconds);
  }

  /// Gets the timespan in days.
  int get inDays => (seconds ~/ _secondsPerDay).truncate();

  /// Gets the timespan in hours.
  int get inHours => seconds ~/ _secondsPerHour;

  /// Gets the timespan in minutes.
  int get inMinutes => seconds ~/ _secondsPerMinute;

  /// Gets the timespan in seconds.
  int get inSeconds => seconds;

  int _sum(int secondMultiplier, int nanoDivisor) =>
      (seconds * secondMultiplier + nanosecondPart / nanoDivisor).truncate();

  /// Gets the timespan in milliseconds.
  int get inMilliseconds => _sum(_millisecondsPerSecond, _nsPerMillisecond);

  /// Gets the timespan in microseconds.
  int get inMicroseconds => _sum(_microsecondsPerSecond, _nsPerMicrosecond);

  /// Gets the timespan in nanoseconds.
  int get inNanoseconds => _sum(_nanosecondsPerSecond, 1);

  /// Determines if the timespan is negative.
  bool get isNegative => seconds.isNegative || nanosecondPart.isNegative;

  /// Addition operator.
  Timespan operator +(Timespan other) => Timespan._fromParts(
      seconds + other.seconds, nanosecondPart + other.nanosecondPart);

  /// Subtraction operator.
  Timespan operator -(Timespan other) => Timespan._fromParts(
      seconds - other.seconds, nanosecondPart - other.nanosecondPart);

  /// Multiplication operator. Fractional results are rounded towards zero.
  Timespan operator *(num other) => Timespan._fromParts(
      (seconds * other).truncate(), (nanosecondPart * other).truncate());

  /// Integer division operator.
  Timespan operator ~/(num other) =>
      Timespan._fromParts(seconds ~/ other, nanosecondPart ~/ other);

  /// Less than operator.
  bool operator <(Timespan other) => compareTo(other) < 0;

  /// Less than or equal operator.
  bool operator <=(Timespan other) => compareTo(other) <= 0;

  /// Greater than operator.
  bool operator >(Timespan other) => compareTo(other) > 0;

  /// Greater than or equal operator.
  bool operator >=(Timespan other) => compareTo(other) >= 0;

  /// Unary negation operator.
  Timespan operator -() => Timespan._fromParts(-seconds, -nanosecondPart);

  /// Converts this to a duration with a loss of precision.
  Duration toDuration() => Duration(microseconds: inMicroseconds);

  /// Returns the absolute value of this [Timespan].
  Timespan abs() {
    // Important: this is only true because both parts are normalized
    // with matching signs.
    return Timespan._fromParts(seconds.abs(), nanosecondPart.abs());
  }

  /// Compares this to another [Timespan].
  ///
  /// Returns 0 if they are equal, -1 if this < [other] and 1 if this > [other].
  @override
  int compareTo(Timespan other) {
    int secondCmp = Comparable.compare(seconds, other.seconds);
    if (secondCmp == 0) {
      return Comparable.compare(nanosecondPart, other.nanosecondPart);
    }
    return secondCmp;
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
    if (seconds == 0 && nanosecondPart == 0) {
      return 'P0D';
    }

    int days = seconds ~/ _secondsPerDay;
    int hours = (seconds ~/ _secondsPerHour).remainder(_hoursPerDay);
    int minutes = (seconds ~/ _secondsPerMinute).remainder(_minutesPerHour);
    int secondsOfDay = seconds.remainder(_secondsPerMinute);

    var d = days != 0 ? '${days}D' : '';
    var h = hours != 0 ? '${hours}H' : '';
    var m = minutes != 0 ? '${minutes}M' : '';
    var s = secondsOfDay != 0 || nanosecondPart != 0 ? '$secondsOfDay' : '';
    if (secondsOfDay == 0 && nanosecondPart < 0) {
      s = '-0';
    }
    s += nanosecondPart != 0
        ? ".${'${nanosecondPart.abs()}'.padLeft(9, '0')}"
        : '';
    s += s != '' ? 'S' : '';
    return 'P$d${h.isNotEmpty || m.isNotEmpty || s.isNotEmpty ? "T" : ""}$h$m$s';
  }

  @override
  bool operator ==(Object other) =>
      (other is Timespan) &&
      seconds == other.seconds &&
      nanosecondPart == other.nanosecondPart;

  @override
  int get hashCode => Object.hash(seconds, nanosecondPart);
}
