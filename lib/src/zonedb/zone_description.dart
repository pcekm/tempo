part of '../zonedb.dart';

/// Information about a single time zone.
abstract class ZoneDescription
    implements Built<ZoneDescription, ZoneDescriptionBuilder> {
  static Serializer<ZoneDescription> get serializer =>
      _$zoneDescriptionSerializer;

  static final _latLongRe =
      RegExp(r'^([+-])(\d{2})(\d{2})(\d{2})?([+-])(\d{3})(\d{2})(\d{2})?$');

  /// A string that uniquely identifies the time zone.
  ///
  /// Use this with [ZonedDateTime].
  String get zoneId;

  /// The countries that use this time zone.
  BuiltSet<String> get countries;

  /// The latitude of the city this time zone is named for.
  double get latitude;

  /// The longitude of the city this time zone is named for.
  double get longitude;

  /// Additional comments that may help an end user decide if this is
  /// the time zone they're looking for.
  String get comments;

  ZoneDescription._();
  factory ZoneDescription([void Function(ZoneDescriptionBuilder) updates]) =
      _$ZoneDescription;

  factory ZoneDescription._fromLine(String line) {
    var fields = line.split('\t');
    var latLong = _latLongRe.firstMatch(fields[1]);
    return ZoneDescription((b) => b
      ..zoneId = _humanizeId(fields[2])
      ..countries.addAll(fields[0].split(','))
      ..latitude = _dmsToDouble(latLong!.group(1), latLong.group(2),
          latLong.group(3), latLong.group(4))
      ..longitude = _dmsToDouble(latLong.group(5), latLong.group(6),
          latLong.group(7), latLong.group(8))
      ..comments = fields.length >= 4 ? fields[3] : '');
  }

  static double _dmsToDouble(
          String? sign, String? degrees, String? minutes, String? seconds) =>
      (sign == '-' ? -1 : 1) *
      (int.parse(degrees ?? '0') +
          int.parse(minutes ?? '0') / 60 +
          int.parse(seconds ?? '0') / 3600);

  /// Returns a [Comparator] that compares two ZoneDescriptions by their
  /// proximity to the specified geographic coordinates.
  static Comparator<ZoneDescription> _compareByProximityTo(
          double latitude, double longitude) =>
      (a, b) => Comparable.compare(
            _distance(latitude, longitude, a.latitude, a.longitude),
            _distance(latitude, longitude, b.latitude, b.longitude),
          );

  /// Returns the "distance" between two coordinates for sorting purposes.
  ///
  /// As a generic "distance from a to b" calculation it's absolutely terrible.
  /// The numbers this returns are useless for anything other than sorting
  /// time zones.
  ///
  /// It assumes that geographic coordinates are actually points on a
  /// cartesian plane and returns the square of the distance between
  /// them. It weights differences in longitude more heavily than latitude
  /// since time zones tend to be long and skinny along the north-south axis.
  ///
  /// Similar formulas that actually work OK in the general case do exist.
  /// These apply a cosine correction to account for fact that distance
  /// changes between degrees of longitude depending on the latitude. This
  /// does _not_ do that. The sort works acceptably without it because
  /// time zones that extend to the poles usually follow lines of longitude.
  static double _distance(
      double lat1, double long1, double lat2, double long2) {
    const longitudeWeight = 2;
    long1 %= 360;
    long2 %= 360;
    return (pow(lat2 - lat1, 2) + pow(longitudeWeight * (long2 - long1), 2))
        .toDouble();
  }
}
