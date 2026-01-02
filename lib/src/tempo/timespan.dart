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
/// The longest representable timespans are a bit complicated.
/// This stores two ints: one for the number of seconds, and one for a
/// nanosecond fraction of seconds. Dart's
/// [maximum int size](https://dart.dev/guides/language/numbers) varies,
/// but you can count on at least 53 bits. Since `Timespan` dedicates a full
/// int to seconds it can cover at least `2^53` seconds, which is roughly 200
/// million years.
///
/// With that said, other factors will limit the practical maximum. In
/// particular, conversion operations like [inMicroseconds] and date
/// arithmetic could overflow.
///
/// {@category relative}
@immutable
class Timespan extends _BigTime implements Comparable<Timespan> {
  /// Constructs a `Timespan`.
  ///
  /// This is meant to work much like a higher-precision [Duration].
  ///
  /// Any fields may be positive or negative, but the result will always
  /// be normalized as follows:
  ///
  ///   - `-10^9` < [nanosecondPart] < `10^9`
  ///   - [seconds].sign == [nanosecondPart].sign
  const Timespan({
    super.days,
    super.hours,
    super.minutes,
    super.seconds,
    super.milliseconds,
    super.microseconds,
    super.nanoseconds,
  }) : super();

  /// Constructs a `Timespan` from a [Duration].
  Timespan.fromDuration(Duration duration)
      : this(microseconds: duration.inMicroseconds);

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

  Timespan._downcast(super.bn) : super.copy();

  /// The whole number of seconds.
  int get seconds => _secondPart;

  /// The fractional part of the number of seconds in nanoseconds.
  int get nanosecondPart => _nanosecondPart;

  /// Gets the timespan in days.
  int get inDays => (seconds ~/ sPerDay).truncate();

  /// Gets the timespan in hours.
  int get inHours => seconds ~/ sPerHour;

  /// Gets the timespan in minutes.
  int get inMinutes => seconds ~/ sPerMinute;

  /// Gets the timespan in seconds.
  int get inSeconds => seconds;

  int _sum(int secondMultiplier, int nanoDivisor) =>
      (seconds * secondMultiplier + nanosecondPart / nanoDivisor).truncate();

  /// Gets the timespan in milliseconds.
  int get inMilliseconds => _sum(msPerSecond, nsPerMillisecond);

  /// Gets the timespan in microseconds.
  int get inMicroseconds => _sum(usPerSecond, nsPerMicrosecond);

  /// Gets the timespan in nanoseconds.
  int get inNanoseconds => _sum(nsPerSecond, 1);

  /// Determines if the timespan is negative.
  bool get isNegative => _isNegative;

  /// Addition operator.
  Timespan operator +(Timespan other) => Timespan._downcast(_add(other));

  /// Subtraction operator.
  Timespan operator -(Timespan other) => Timespan._downcast(_add(-other));

  /// Multiplication operator. Fractional results are rounded towards zero.
  Timespan operator *(num other) {
    final result = _mul(other);
    return Timespan(
        seconds: result._secondPart, nanoseconds: result._nanosecondPart);
  }

  /// Integer division operator.
  Timespan operator ~/(num other) => Timespan._downcast(_div(other));

  /// Less than operator.
  bool operator <(Timespan other) => _compareTo(other) < 0;

  /// Less than or equal operator.
  bool operator <=(Timespan other) => _compareTo(other) <= 0;

  /// Greater than operator.
  bool operator >(Timespan other) => _compareTo(other) > 0;

  /// Greater than or equal operator.
  bool operator >=(Timespan other) => _compareTo(other) >= 0;

  /// Unary negation operator.
  Timespan operator -() => Timespan._downcast(_neg());

  /// Converts this to a duration with a loss of precision.
  Duration toDuration() => Duration(microseconds: inMicroseconds);

  /// Returns the absolute value of this `Timespan`.
  Timespan abs() => Timespan._downcast(_abs());

  /// Compares this to another `Timespan`.
  ///
  /// Returns 0 if they are equal, -1 if this < [other] and 1 if this > [other].
  @override
  int compareTo(Timespan other) => _compareTo(other);

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

    int days = seconds ~/ sPerDay;
    int hours = (seconds ~/ sPerHour).remainder(hoursPerDay);
    int minutes = (seconds ~/ sPerMinute).remainder(minutesPerHour);
    int secondsOfDay = seconds.remainder(sPerMinute);

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
