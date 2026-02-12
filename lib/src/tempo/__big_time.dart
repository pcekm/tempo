part of '../../tempo.dart';

/// A base for classes built on a single, large number in nanoseconds.
///
/// This represents a duration of time equal to
///
/// [_secondPart] + [_nanosecondPart] * `10^-9` seconds.
///
/// The component numbers will always be normalized as follows:
///
///   - `-10^9` < [_nanosecondPart] < `10^9`
///   - [_secondPart].sign == [_nanosecondPart].sign
///
/// ## Longest _BigTime
///
/// The longest representable timespans are a bit complicated.
/// This stores two ints: one for the number of seconds, and one for a
/// nanosecond fraction of seconds. Dart's
/// [maximum int size](https://dart.dev/guides/language/numbers) varies,
/// but you can count on at least 53 bits. Since `_BigTime` dedicates a full
/// int to seconds it can cover at least `2^53` seconds, which is roughly 200
/// million years.
///
/// With that said, other factors will limit the practical maximum. In
/// particular, conversion operations like [inMicroseconds] and date
/// arithmetic could overflow.
///
/// ## Rationale
///
/// Ideally this shouldn't be an abstract base class, but rather something like
/// a [Timespan]. In fact, Tempo used to _use_ a Timespan. The inheritance is
/// necessary because it provides much better support for const constructors.
@immutable
class _BigTime {
  /// Constructs a `_BigTime` with normalized signs.
  ///
  /// Either [_secondPart] or [_nanosecondPart] may be negative and any value, but
  /// the result will be normalized as follows:
  ///
  ///   - `-10^9` < [_nanosecondPart] < `10^9`
  ///   - [_secondPart].sign == [_nanosecondPart].sign
  const _BigTime({
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
    int nanoseconds = 0,
  }) : this._normalizedSign(
            days * _secondsPerDay +
                hours * _secondsPerHour +
                minutes * _secondsPerMinute +
                seconds +
                milliseconds ~/ _millisecondsPerSecond +
                microseconds ~/ _microsecondsPerSecond +
                nanoseconds ~/ _nsPerSecond,
            _nsPerMillisecond *
                    (milliseconds % _millisecondsPerSecond +
                        (milliseconds % _millisecondsPerSecond != 0 &&
                                milliseconds < 0
                            ? -_millisecondsPerSecond
                            : 0)) +
                _nsPerMicrosecond *
                    (microseconds % _microsecondsPerSecond +
                        (microseconds % _microsecondsPerSecond != 0 &&
                                microseconds < 0
                            ? -_microsecondsPerSecond
                            : 0)) +
                nanoseconds % _nsPerSecond +
                (nanoseconds % _nsPerSecond != 0 && nanoseconds < 0
                    ? -_nsPerSecond
                    : 0));

  const _BigTime._normalizedSign(int secondPart, int nanosecondPart)
      : _secondPart = secondPart +
            (secondPart < 0 && nanosecondPart > 0 ? 1 : 0) +
            (secondPart > 0 && nanosecondPart < 0 ? -1 : 0),
        _nanosecondPart = nanosecondPart +
            (secondPart < 0 && nanosecondPart > 0 ? -_nsPerSecond : 0) +
            (secondPart > 0 && nanosecondPart < 0 ? _nsPerSecond : 0);

  _BigTime.copy(_BigTime bigTime)
      : _secondPart = bigTime._secondPart,
        _nanosecondPart = bigTime._nanosecondPart;

  static const _hoursPerDay = 24;
  static const _minutesPerHour = 60;
  static const _secondsPerMinute = 60;
  static const _millisecondsPerSecond = 1000;
  static const _microsecondsPerSecond = 1000000;
  static const _nsPerSecond = 1000000000;
  static const _secondsPerHour = _minutesPerHour * _secondsPerMinute;

  static const _minutesPerDay = _minutesPerHour * _hoursPerDay;
  static const _secondsPerDay = _secondsPerMinute * _minutesPerDay;

  static const _nsPerMicrosecond = 1000;
  static const _nsPerMillisecond = 1000000;

  /// The whole part of the number.
  final int _secondPart;

  /// The fractional part of the number.
  final int _nanosecondPart;

  /// Determines if the timespan is negative.
  bool get _isNegative => _secondPart.isNegative || _nanosecondPart.isNegative;

  /// Addition operation.
  _BigTime _add(_BigTime other) => _BigTime(
      seconds: _secondPart + other._secondPart,
      nanoseconds: _nanosecondPart + other._nanosecondPart);

  /// Multiplication operation. Fractional results are rounded towards zero.
  _BigTime _mul(num other) => _BigTime(
      seconds: (_secondPart * other).truncate(),
      nanoseconds: (_nanosecondPart * other).truncate());

  /// Integer truncating division operation.
  _BigTime _div(num other) => _BigTime(
      seconds: _secondPart ~/ other, nanoseconds: _nanosecondPart ~/ other);

  /// Rounds this to the nearest [other].
  ///
  /// More precisely, returns a _BigTime t such that t is divisible by [other],
  /// and this - [other] < t <= this. When [other] is negative, t will be
  /// this <= t < this + [other].
  _BigTime _quantize(_BigTime other) {
    final point = BigInt.from(1000000000);
    final thisBig =
        BigInt.from(_secondPart) * point + BigInt.from(_nanosecondPart);
    final otherBig = BigInt.from(other._secondPart) * point +
        BigInt.from(other._nanosecondPart);
    final res = thisBig ~/ otherBig * otherBig -
        (thisBig.isNegative != otherBig.isNegative ? otherBig : BigInt.zero);
    return _BigTime(
        seconds: (res ~/ point).toInt(), nanoseconds: (res % point).toInt());
  }

  /// Unary negation operation.
  _BigTime _neg() =>
      _BigTime(seconds: -_secondPart, nanoseconds: -_nanosecondPart);

  /// Returns the absolute value of this `_BigTime`.
  _BigTime _abs() {
    // Important: this is only true because both parts are normalized
    // with matching signs.
    return _BigTime(
        seconds: _secondPart.abs(), nanoseconds: _nanosecondPart.abs());
  }

  /// Compares this to another `_BigTime`.
  ///
  /// Returns 0 if they are equal, -1 if this < [other] and 1 if this > [other].
  int _compareTo(_BigTime other) {
    int secondCmp = Comparable.compare(_secondPart, other._secondPart);
    if (secondCmp == 0) {
      return Comparable.compare(_nanosecondPart, other._nanosecondPart);
    }
    return secondCmp;
  }

  @override
  String toString() => '$_secondPart.${_zeroPad(_nanosecondPart, 9)}';
}
