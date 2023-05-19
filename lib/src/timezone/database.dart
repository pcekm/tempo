import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';

import 'serializers.dart';
import 'zone_info.dart';
import 'zone_rules.dart';
import 'zone_tab_row.dart';

part 'database.data.dart';

/// Default time zone database.
final timeZones = Database();

/// Returns all possible time zones in unspecified order.
allZoneRules() => timeZones.allZoneRules();

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
timeZonesByProximity(double latitude, double longitude,
        [String? country = null]) =>
    timeZones.byProximity(latitude, longitude, country);

/// Provides a list of time zones relevant to a specific country.
///
/// The [country] arg is an [ISO 3166 2-letter
/// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
/// For example, US = United States, CA = Canada, EE = Estonia, etc.
timeZonesForCountry(String country) => timeZones.forCountry(country);

/// Contains all known time zones, and provides methods for finding them.
class Database {
  /// Looks up a set of time zone rules by [zoneId].
  ///
  /// The [zoneId] arg is typically in the form "<continent>/<city>".
  /// For example, "America/Los_Angeles" and "Europe/Tallinn".
  ///
  /// Returns `null` if no matching zone is found.
  ZoneRules? zoneRulesFor(String zoneId) => _zoneInfo.rules[zoneId];

  /// Returns all possible time zones in unspecified order.
  Iterable<ZoneTabRow> allZoneRules() => _zoneInfo.zoneTab;

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
  List<ZoneTabRow> byProximity(double latitude, double longitude,
      [String? country]) {
    var zones = _zoneInfo.zoneTab.toList();
    if (country != null) {
      zones = forCountry(country).toList();
    }
    zones.sortByCompare((x) => x, _compareByProximityTo(latitude, longitude));
    return zones;
  }

  /// Provides a list of time zones relevant to a specific country.
  ///
  /// The [country] arg is an [ISO 3166 2-letter
  /// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  /// For example, US = United States, CA = Canada, EE = Estonia, etc.
  List<ZoneTabRow> forCountry(String country) =>
      _zoneInfo.zoneTabByCountry[country.toUpperCase()].toList();

  /// Returns a [Comparator] that compares two ZoneDescriptions by their
  /// proximity to the specified geographic coordinates.
  static Comparator<ZoneTabRow> _compareByProximityTo(
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
