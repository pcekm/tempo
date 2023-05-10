part of '../../tempo.dart';

/// A time zone offset from UTC.
///
/// Zone offsets can range from UTC-23:59:59 to UTC+23:59:59, although as
/// of this writing, the largest offset in use is UTC+14:00 for the
/// easternmost islands of Kiribati.
class ZoneOffset {
  /// UTC offset hours `[-23 to +23]`.
  final int hours;

  /// UTC offset minutes `[-59 to +59]`.
  final int minutes;

  /// UTC offset seconds `[-59 to +59]`.
  final int seconds;

  ZoneOffset._(this.hours, this.minutes, this.seconds);

  /// Construct a new ZoneOffset.
  ///
  /// Will be normalized such that
  ///    * `-23 <= hours <= 23`
  ///    * `-59 <= minutes <= 59`
  ///    * `-59 <= seconds <= 59`
  ///    * Numeric signs all match (Changes [minutes] and [seconds] to match
  ///      [hours]).
  ///
  ZoneOffset(int hours, [int minutes = 0, int seconds = 0])
      : this.fromDuration(
            Duration(hours: hours, minutes: minutes, seconds: seconds));

  /// Constructs a new ZoneOffset from a Duration.
  ///
  /// This will be normalized as described in [ZoneOffset].
  ZoneOffset.fromDuration(Duration amount)
      : this.fromTimespan(Timespan.fromDuration(amount));

  /// Constructs a new ZoneOffset from a Timespan.
  ///
  /// This will be normalized as described in [ZoneOffset].
  ZoneOffset.fromTimespan(Timespan amount)
      : this._(amount.inHours.remainder(24), amount.inMinutes.remainder(60),
            amount.inSeconds.remainder(60));

  /// Provides the platform's current default zone offset.
  factory ZoneOffset.local() {
    return ZoneOffset.fromDuration(DateTime.now().timeZoneOffset);
  }

  /// Parses an ISO 8601 zone offset string.
  ///
  /// Normally these don't occur by themselves. This is mostly here for
  /// testing purposes.
  factory ZoneOffset.parse(String offset) => _parseIso8601Offset(offset);

  /// Converts this to a [Timespan].
  Timespan get asTimespan =>
      Timespan(hours: hours, minutes: minutes, seconds: seconds);

  @override
  String toString() => _iso8601ZoneOffset(this);

  /// Equality operator.
  ///
  /// Two [ZoneOffset]s are equal if and only if [hours] == [minutes].
  @override
  bool operator ==(Object other) =>
      (other is ZoneOffset) && hours == other.hours && minutes == other.minutes;

  @override
  int get hashCode => Object.hash(hours, minutes);
}
