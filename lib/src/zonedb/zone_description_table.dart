part of '../zonedb.dart';

/// Contains information about each time zone.
abstract class ZoneDescriptionTable
    implements Built<ZoneDescriptionTable, ZoneDescriptionTableBuilder> {
  static Serializer<ZoneDescriptionTable> get serializer =>
      _$zoneDescriptionTableSerializer;

  static ZoneDescriptionTable? _instance;

  /// Zone descriptions in the default order.
  ///
  /// The default order is how they appear in zone1970.tab, which is sorted by
  /// the first country listed and then, more or less, from east to west.
  BuiltList<ZoneDescription> get zoneDescriptions;

  /// Zone descriptions grouped by country.
  BuiltListMultimap<String, ZoneDescription> get byCountry;

  ZoneDescriptionTable._();
  factory ZoneDescriptionTable._fromBuilder(
          [void Function(ZoneDescriptionTableBuilder) updates]) =
      _$ZoneDescriptionTable;

  factory ZoneDescriptionTable() {
    _instance ??= _loadZonetab();
    return _instance!;
  }

  static ZoneDescriptionTable _loadZonetab() {
    var file = _zoneInfoData.findFile('zoneinfo/zone1970.tab');
    var lines = LineSplitter()
        .convert(utf8.decode(file!.content))
        .where((line) => !line.startsWith('#'));
    var zoneDescriptions = lines.map((line) => ZoneDescription._fromLine(line));
    return ZoneDescriptionTable._fromBuilder((b) => b
      ..zoneDescriptions.addAll(zoneDescriptions)
      ..byCountry = _groupByCountry(zoneDescriptions));
  }

  static ListMultimapBuilder<String, ZoneDescription> _groupByCountry(
      Iterable<ZoneDescription> zoneInfo) {
    var b = ListMultimapBuilder<String, ZoneDescription>();
    for (var zi in zoneInfo) {
      for (var country in zi.countries) {
        b.add(country, zi);
      }
    }
    return b;
  }

  /// Lists the zone descriptions for a single country.
  ///
  /// The country is an [ISO 3166 2-letter
  /// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  /// For example, US = United States, CA = Canada, EE = Estonia, etc.
  List<ZoneDescription> forCountry(String country) =>
      byCountry[country.toUpperCase()].toList();

  /// Returns zone descriptions sorted by their proximity to a given
  /// geographic location. Optionally filters the results by [country].
  List<ZoneDescription> byProximity(double latitude, double longitude,
      [String? country]) {
    var descriptions = zoneDescriptions.toList();
    if (country != null) {
      descriptions = forCountry(country);
    }
    descriptions.sortByCompare(
        (x) => x, ZoneDescription._compareByProximityTo(latitude, longitude));
    return descriptions;
  }
}
