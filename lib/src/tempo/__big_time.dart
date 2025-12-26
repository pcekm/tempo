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
  /// Either [secondPart] or [nanosecondPart] may be negative and any value, but
  /// the result will be normalized as follows:
  ///
  ///   - [secondPart].sign == [nanosecondPart].sign
  const _BigTime(int secondPart, int nanosecondPart)
      : this._maybeCarry(
            secondPart +
                (secondPart < 0 && nanosecondPart > 0 ? 1 : 0) +
                (secondPart > 0 && nanosecondPart < 0 ? -1 : 0),
            nanosecondPart +
                (secondPart < 0 && nanosecondPart > 0 ? -_nsPerSecond : 0) +
                (secondPart > 0 && nanosecondPart < 0 ? _nsPerSecond : 0));

  /// Performs a carry if needed.
  const _BigTime._maybeCarry(int secondPart, int nanosecondPart)
      : _secondPart = secondPart + nanosecondPart ~/ _nsPerSecond,
        _nanosecondPart = nanosecondPart % _nsPerSecond -
            (nanosecondPart < 0 ? _nsPerSecond : 0);

  _BigTime.copy(_BigTime bn)
      : _secondPart = bn._secondPart,
        _nanosecondPart = bn._nanosecondPart;

  static const int _nsPerSecond = 1000000000;

  /// The whole part of the number.
  final int _secondPart;

  /// The fractional part of the number.
  final int _nanosecondPart;

  /// Determines if the timespan is negative.
  bool get _isNegative => _secondPart.isNegative || _nanosecondPart.isNegative;

  /// Addition operation.
  _BigTime _add(_BigTime other) => _BigTime(
      _secondPart + other._secondPart, _nanosecondPart + other._nanosecondPart);

  /// Multiplication operation. Fractional results are rounded towards zero.
  _BigTime _mul(num other) => _BigTime(
      (_secondPart * other).truncate(), (_nanosecondPart * other).truncate());

  /// Integer truncating division operation.
  _BigTime _div(num other) =>
      _BigTime(_secondPart ~/ other, _nanosecondPart ~/ other);

  /// Unary negation operation.
  _BigTime _neg() => _BigTime(-_secondPart, -_nanosecondPart);

  /// Returns the absolute value of this `_BigTime`.
  _BigTime _abs() {
    // Important: this is only true because both parts are normalized
    // with matching signs.
    return _BigTime(_secondPart.abs(), _nanosecondPart.abs());
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
