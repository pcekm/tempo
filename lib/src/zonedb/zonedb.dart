part of '../zonedb.dart';

/// Looks up the time zone that applies to a given time zone id at a
/// specific instant in time.
///
/// The [zoneId] arg is typically in the form "<continent>/<city>".
/// For example, "America/Los Angeles" and "Europe/Tallinn".
///
/// Returns `null` if no matching zone is found.
TimeZone? lookupTimeZone(String zoneId, HasInstant instant) {
  var rules = Database().zoneRulesFor(zoneId);
  if (rules == null) {
    return null;
  }
  return TimeZone._fromOffset(rules.offsetFor(instant));
}

// Normalizes and humanizes a zone id.
String _humanizeId(String name) =>
    name.trim().replaceAll(RegExp(r'(\s|_)+'), ' ');

ZoneDescription _zoneTabRowToDesc(ZoneTabRow row) => ZoneDescription((b) => b
  ..zoneId = row.zoneId
  ..countries.addAll(row.countries)
  ..latitude = row.latitude
  ..longitude = row.longitude
  ..comments = row.comments);

/// Provides a list of all possible time zones in unspecified order.
List<ZoneDescription> allTimeZones() =>
    Database().allZoneRules().map(_zoneTabRowToDesc).toList();

/// Provides a list of time zones sorted by proximity to a given set of
/// geographic coordinates. Optionally filters by country.
///
/// The proximity sort is deliberately biased towards locations on similar
/// longitudes, since time zones tend to be much narrower in the east-west
/// direction.
///
/// The [country] arg is an [ISO 3166 2-letter
/// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
/// For example, US = United States, CA = Canada, EE = Estonia, etc.
List<ZoneDescription> timeZonesByProximity(double latitude, double longitude,
        [String? country]) =>
    Database()
        .byProximity(latitude, longitude, country)
        .map(_zoneTabRowToDesc)
        .toList();

/// Provides a list of time zones relevant to a specific country.
///
/// The [country] arg is an [ISO 3166 2-letter
/// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
/// For example, US = United States, CA = Canada, EE = Estonia, etc.
List<ZoneDescription> timeZonesForCountry(String country) =>
    Database().forCountry(country).map(_zoneTabRowToDesc).toList();
