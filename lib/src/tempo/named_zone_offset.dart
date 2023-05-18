part of '../../tempo.dart';

/// A [ZoneOffset] with an associated [name].
///
/// This can be used interchangeably with a [ZoneOffset] and compares
/// identically regardless of the [name] or [isDst].
class NamedZoneOffset extends ZoneOffset {
  /// The name for this zone offset. Typically this is a non-unique identifier
  /// that describes the time zone, such as "PST" (Pacific Standard Time)
  /// or "CEST" (Central European Summer Time).
  ///
  /// This is strictly informational. It's not used by [operator==], [hashCode],
  /// or [toString].
  final String name;

  /// If true, this is a daylight savings offset.
  final bool isDst;

  /// Constructs a named zone offset from an unnamed one.
  NamedZoneOffset.fromZoneOffset(this.name, this.isDst, ZoneOffset offset)
      : super(offset.hours, offset.minutes, offset.seconds);

  /// Construct a new ZoneOffset.
  ///
  /// Will be normalized such that
  ///    * `-23 <= hours <= 23`
  ///    * `-59 <= minutes <= 59`
  ///    * `-59 <= seconds <= 59`
  ///    * Numeric signs all match (Changes [minutes] and [seconds] to match
  ///      [hours]).
  NamedZoneOffset(this.name, this.isDst, super.hours,
      [super.minutes = 0, super.seconds = 0]);

  /// Constructs a new NamedZoneOffset from a Timespan.
  ///
  /// Will be normalized such that
  ///    * `-23 <= hours <= 23`
  ///    * `-59 <= minutes <= 59`
  ///    * `-59 <= seconds <= 59`
  ///    * Numeric signs all match (Changes [minutes] and [seconds] to match
  ///      [hours]).
  NamedZoneOffset.fromTimespan(this.name, this.isDst, Timespan timespan)
      : super.fromTimespan(timespan);

  /// Constructs a new ZoneOffset from a Duration.
  ///
  /// Will be normalized such that
  ///    * `-23 <= hours <= 23`
  ///    * `-59 <= minutes <= 59`
  ///    * `-59 <= seconds <= 59`
  ///    * Numeric signs all match (Changes [minutes] and [seconds] to match
  ///      [hours]).
  NamedZoneOffset.fromDuration(this.name, this.isDst, Duration amount)
      : super.fromDuration(amount);
}
