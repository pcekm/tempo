part of '../../zoneinfo.dart';

/// Contains information about a specific time zone.
///
/// This consists of the [offset] from UTC, a [designation] string, and a
/// boolean [isDst].
///
/// Also see [ZoneInfoRecord], which contains a set of rules about which
/// time zones apply to a specific instant of time in a specific geographic
/// location.
class TimeZone {
  /// The offset from UTC.
  final ZoneOffset offset;

  /// A short string describing the time zone.
  ///
  /// For example, "PDT" for Pacific Daylight Time, "EST" for Eastern Standard
  /// Time, "CEST" for Central European Summer Time.
  ///
  /// Note that these are typically common abbreviations used and understood
  /// by people in specific areas, but they are _not_ unique.
  final String designation;

  /// True if daylight savings (or summer) time is in effect.
  final bool isDst;

  /// Constructs a [TimeZone].
  TimeZone(this.offset, this.designation, this.isDst);

  @override
  String toString() => '[$designation, $offset, ${isDst ? "DST" : "STD"}]';

  @override
  bool operator ==(Object other) =>
      other is TimeZone &&
      offset == other.offset &&
      designation == other.designation &&
      isDst == other.isDst;

  @override
  int get hashCode => Object.hash(offset, designation, isDst);
}
