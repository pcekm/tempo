part of '../goodtime.dart';

/// A time zone offset from UTC.
///
/// Zone offsets can range from UTC-23:59 to UTC+23:59, although as of this
/// writing, the largest offset is UTC+14:00 for the easternmost islands
/// of Kiribati.
class ZoneOffset {
  /// UTC offset hours `[-23 to +23]`.
  final int hours;

  /// UTC offset minutes `[-59 to +59]`.
  final int minutes;

  ZoneOffset._(this.hours, this.minutes);

  /// Construct a new ZoneOffset.
  ///
  /// Will be normalized such that
  ///    * `-23 <= hours <= 23`
  ///    * `-59 <= minutes <= 59`
  ///    * `hours.sign == minutes.sign` (Changes [minutes] to match [hours]).
  ///
  factory ZoneOffset(int hours, [int minutes = 0]) {
    hours += minutes ~/ 60;
    minutes = minutes.remainder(60);
    if (hours < 0 && minutes > 0) {
      hours++;
      minutes -= 60;
    } else if (hours > 0 && minutes < 0) {
      hours--;
      minutes += 60;
    }
    return ZoneOffset._(hours.remainder(24), minutes);
  }

  /// Constructs a new ZoneOffset from a Duration.
  ///
  /// This will be normalized as described in [ZoneOffset].
  // TODO: Hide this.
  factory ZoneOffset.fromDuration(Duration amount) {
    return ZoneOffset(0, amount.inMinutes);
  }

  /// Provides the platform's current default zone offset.
  factory ZoneOffset.local() {
    return ZoneOffset.fromDuration(DateTime.now().timeZoneOffset);
  }

  /// The offset in minutes.
  int get inMinutes => hours * 60 + minutes;

  /// The offset in fractional hours.
  double get inHours => hours + minutes / 60;

  @override
  String toString() => sprintf('%+03d%02d', [hours, minutes.abs()]);

  /// Equality operator.
  ///
  /// Two [ZoneOffset]s are equal if and only if [hours] == [minutes].
  @override
  bool operator ==(Object other) =>
      (other is ZoneOffset) && hours == other.hours && minutes == other.minutes;

  @override
  int get hashCode => Object.hash(hours, minutes);
}
