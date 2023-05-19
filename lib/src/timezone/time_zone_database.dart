import 'dart:convert';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:collection/collection.dart';
import 'package:tempo/timezone.dart';

import 'serializers.dart';

part 'time_zone_database.data.dart';
part 'time_zone_database.g.dart';

/// Returns a table of time zones with information usedful for choosing one.
List<ZoneDescription> allTimeZones() =>
    TimeZoneDatabase().descriptions.toList();

/// Provides a list of time zones sorted by proximity to a given set of
/// geographic coordinates. Optionally filters by country.
///
/// The proximity sort is deliberately biased towards locations on similar
/// longitudes since time zones tend to be much narrower in the east-west
/// direction.
///
/// The [country] arg is an [ISO 3166 2-letter
/// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
/// For example, US = United States, CA = Canada, EE = Estonia, etc.
List<ZoneDescription> timeZonesByProximity(double latitude, double longitude,
        [String? country]) =>
    TimeZoneDatabase().byProximity(latitude, longitude, country);

/// Provides a list of time zones relevant to a specific country.
///
/// The [country] arg is an [ISO 3166 2-letter
/// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
/// For example, US = United States, CA = Canada, EE = Estonia, etc.
List<ZoneDescription> timeZonesForCountry(String country) =>
    TimeZoneDatabase().descriptionsByCountry[country.toUpperCase()].toList();

/// Contains all known time zones, and provides methods for finding them.
abstract class TimeZoneDatabase
    implements Built<TimeZoneDatabase, TimeZoneDatabaseBuilder> {
  static Serializer<TimeZoneDatabase> get serializer =>
      _$timeZoneDatabaseSerializer;

  /// The version of the ARIN database this contains.
  String get version;

  /// A map of all known time zone rules indexed by zone id.
  ///
  /// The zone id is typically in the form "<continent>/<city>".
  /// For example, "America/Los_Angeles" and "Europe/Tallinn".
  BuiltMap<String, ZoneRules> get rules;

  /// A table of additional information used for choosing a time zone.
  BuiltList<ZoneDescription> get descriptions;

  /// A list of additional information used for choosing a time zone,
  /// indexed by country.
  ///
  /// The [country] arg is an [ISO 3166 2-letter
  /// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  /// For example, US = United States, CA = Canada, EE = Estonia, etc.
  BuiltListMultimap<String, ZoneDescription> get descriptionsByCountry;

  TimeZoneDatabase._();

  /// Constructs a new TimeZoneDatabase.
  ///
  /// Uses a compiled in copy of the ARIN
  /// [Time Zone Database](https://www.iana.org/time-zones)
  factory TimeZoneDatabase() => _defaultTimeZoneDatabase;

  /// Constructs a new TimeZoneDatabase using custom data.
  factory TimeZoneDatabase.build(
      void Function(TimeZoneDatabaseBuilder) updates) = _$TimeZoneDatabase;

  /// Provides a list of time zones sorted by proximity to a given set of
  /// geographic coordinates. Optionally filters by country.
  ///
  /// The proximity sort is deliberately biased towards locations on similar
  /// longitudes since time zones tend to be much narrower in the east-west
  /// direction.
  ///
  /// The [country] arg is an [ISO 3166 2-letter
  /// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  /// For example, US = United States, CA = Canada, EE = Estonia, etc.
  List<ZoneDescription> byProximity(double latitude, double longitude,
      [String? country]) {
    var zones = descriptions.toList();
    if (country != null) {
      zones = descriptionsByCountry[country].toList();
    }
    zones.sortByCompare((x) => x, _compareByProximityTo(latitude, longitude));
    return zones;
  }

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
