part of '../../goodtime.dart';

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

  /// The offset in the a whole number of seconds, rounded towards zero.
  int get inSeconds => hours * 3600 + minutes * 60 + seconds;

  /// The offset in the a whole number of minutes, rounded towards zero.
  int get inMinutes => hours * 60 + minutes;

  /// The offset the a whole number of hours, rounded towards zero.
  int get inHours => hours;

  @override
  String toString() {
    var parts = [
      sprintf('%+03d', [hours])
    ];
    if (minutes != 0 || seconds != 0) {
      parts.add(sprintf('%02d', [minutes.abs()]));
    }
    if (seconds != 0) {
      parts.add(sprintf('%02d', [seconds.abs()]));
    }
    return parts.join(':');
  }

  /// Equality operator.
  ///
  /// Two [ZoneOffset]s are equal if and only if [hours] == [minutes].
  @override
  bool operator ==(Object other) =>
      (other is ZoneOffset) && hours == other.hours && minutes == other.minutes;

  @override
  int get hashCode => Object.hash(hours, minutes);
}