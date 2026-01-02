part of '../../tempo.dart';

/// A time zone offset from UTC.
///
/// Zone offsets can range from UTC-23:59:59 to UTC+23:59:59, although as
/// of this writing, the largest offset in use is UTC+14:00 for the
/// island of Kiritimati.
///
/// {@category absolute}
@immutable
class ZoneOffset {
  const ZoneOffset._fromSeconds(int seconds)
      : hours = (seconds ~/ 3600) % 24 -
            (seconds < 0 && (seconds ~/ 3600) % 24 > 0 ? 24 : 0),
        minutes = (seconds ~/ 60) % 60 -
            (seconds < 0 && (seconds ~/ 60) % 60 > 0 ? 60 : 0),
        seconds = seconds % 60 - (seconds < 0 && seconds % 60 > 0 ? 60 : 0);

  /// Construct a new ZoneOffset.
  ///
  /// Will be normalized such that
  ///    * `-23 <= hours <= 23`
  ///    * `-59 <= minutes <= 59`
  ///    * `-59 <= seconds <= 59`
  ///    * Numeric signs all match (Changes [minutes] and [seconds] to match
  ///      [hours]).
  const ZoneOffset(int hours, [int minutes = 0, int seconds = 0])
      : this._fromSeconds(hours * 3600 + minutes * 60 + seconds);

  /// Constructs a new ZoneOffset from a Duration.
  ///
  /// Will be normalized such that
  ///    * `-23 <= hours <= 23`
  ///    * `-59 <= minutes <= 59`
  ///    * `-59 <= seconds <= 59`
  ///    * Numeric signs all match (Changes [minutes] and [seconds] to match
  ///      [hours]).
  ZoneOffset.fromDuration(Duration amount)
      : this._fromSeconds(amount.inSeconds);

  /// Constructs a new ZoneOffset from a Timespan.
  ///
  /// Will be normalized such that
  ///    * `-23 <= hours <= 23`
  ///    * `-59 <= minutes <= 59`
  ///    * `-59 <= seconds <= 59`
  ///    * Numeric signs all match
  ZoneOffset.fromTimespan(Timespan amount)
      : this._fromSeconds(amount.inSeconds);

  /// Parses an ISO 8601 zone offset string.
  ///
  /// Normally these don't occur by themselves. This is mostly here for
  /// testing purposes.
  factory ZoneOffset.parse(String offset) => _parseIso8601Offset(offset);

  /// UTC offset hours `[-23 to +23]`.
  final int hours;

  /// UTC offset minutes `[-59 to +59]`.
  final int minutes;

  /// UTC offset seconds `[-59 to +59]`.
  final int seconds;

  /// Converts this to a [Timespan].
  Timespan get asTimespan =>
      Timespan(hours: hours, minutes: minutes, seconds: seconds);

  /// Converts this to an ISO 8601 zone offset string.
  ///
  /// ```dart
  /// ZoneOffset(-8).toString() == '-0800';
  /// ZoneOffset(5, 45).toString() == '+0545';
  /// ```
  @override
  String toString() => _iso8601ZoneOffset(this);

  /// Equality operator.
  ///
  /// Two [ZoneOffset]s are equal if and only if [hours] == [minutes].
  @override
  bool operator ==(Object other) =>
      (other is ZoneOffset) &&
      hours == other.hours &&
      minutes == other.minutes &&
      seconds == other.seconds;

  @override
  int get hashCode => Object.hash(hours, minutes, seconds);
}
