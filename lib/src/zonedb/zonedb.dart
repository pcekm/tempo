part of '../zonedb.dart';

/// Looks up the time zone that applies to a given time zone id at a
/// specific instant in time.
///
/// The [zoneId] arg is typically in the form "<continent>/<city>".
/// For example, "America/Los Angeles" and "Europe/Tallinn".
///
/// Returns `null` if no matching zone is found.
TimeZone? lookupTimeZone(String zoneId, HasInstant instant) {
  return _lookupZoneInfo(zoneId)?.timeZoneFor(instant);
}

ZoneInfoRecord? _lookupZoneInfo(String id) {
  var file = _zoneInfoData.findFile('zoneinfo/${_escapeId(id)}');
  if (file == null) {
    return null;
  }
  return ZoneInfoReader(_humanizeId(id), file.content).read();
}

// Normalizes, converts spaces to underscores in a zone id.
String _escapeId(String name) =>
    name.trim().replaceAll(RegExp(r'(\s|_)+'), '_');

// Normalizes and humanizes a zone id.
String _humanizeId(String name) =>
    name.trim().replaceAll(RegExp(r'(\s|_)+'), ' ');

/// Provides a list of all possible time zones in unspecified order.
List<ZoneDescription> allTimeZones() =>
    _ZoneDescriptionTable()._zoneDescriptions;

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
    _ZoneDescriptionTable().byProximity(latitude, longitude, country);

/// Provides a list of time zones relevant to a specific country.
///
/// The [country] arg is an [ISO 3166 2-letter
/// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
/// For example, US = United States, CA = Canada, EE = Estonia, etc.
List<ZoneDescription> timeZonesForCountry(String country) =>
    _ZoneDescriptionTable().forCountry(country);
