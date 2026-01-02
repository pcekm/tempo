part of '../../tempo.dart';

/// Adds time-related fields to a [_RataDieDate].
mixin _TimeFields on _RataDieDate implements HasTime {
  static const _sPerDay = 86400;

  /// The time part of this [DateTime].
  LocalTime get _time =>
      LocalTime(0, 0, _secondPart.remainder(_sPerDay), _nanosecondPart);

  @override
  int get hour => _time.hour;

  @override
  int get minute => _time.minute;

  @override
  int get second => _time.second;

  @override
  int get nanosecond => _time.nanosecond;
}
