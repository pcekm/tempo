part of '../zonedb.dart';

/// Contains information about each time zone.
class ZoneDescriptionTable {
  // static ZoneDescriptionTable _loadZonetab() {
  //   var file = _zoneInfoData.findFile('zoneinfo/zone1970.tab');
  //   var lines = LineSplitter()
  //       .convert(utf8.decode(file!.content))
  //       .where((line) => !line.startsWith('#'));
  //   var zoneDescriptions = lines.map((line) => ZoneDescription._fromLine(line));
  //   return ZoneDescriptionTable._fromBuilder((b) => b
  //     ..zoneDescriptions.addAll(zoneDescriptions)
  //     ..byCountry = _groupByCountry(zoneDescriptions));
  // }

  // static ListMultimapBuilder<String, ZoneDescription> _groupByCountry(
  //     Iterable<ZoneDescription> zoneInfo) {
  //   var b = ListMultimapBuilder<String, ZoneDescription>();
  //   for (var zi in zoneInfo) {
  //     for (var country in zi.countries) {
  //       b.add(country, zi);
  //     }
  //   }
  //   return b;
  // }

  /// Lists the zone descriptions for a single country.
  ///
  /// The country is an [ISO 3166 2-letter
  /// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  /// For example, US = United States, CA = Canada, EE = Estonia, etc.
  List<ZoneDescription> forCountry(String country) => Database()
      .forCountry(country)
      .map((e) => ZoneDescription((b) => b
        ..zoneId = e.zoneId
        ..countries.addAll(e.countries)
        ..latitude = e.latitude
        ..longitude = e.longitude
        ..comments = e.comments))
      .toList();

  /// Returns zone descriptions sorted by their proximity to a given
  /// geographic location. Optionally filters the results by [country].
  List<ZoneDescription> byProximity(double latitude, double longitude,
          [String? country]) =>
      Database()
          .byProximity(latitude, longitude, country)
          .map((e) => ZoneDescription((b) => b
            ..zoneId = e.zoneId
            ..countries.addAll(e.countries)
            ..latitude = e.latitude
            ..longitude = e.longitude
            ..comments = e.comments))
          .toList();
}
