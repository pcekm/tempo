part of '../../zonedb.dart';

/// Contains information about each time zone.
class _ZoneDescriptionTable {
  static _ZoneDescriptionTable? _instance;

  /// Zone descriptions in the default order.
  ///
  /// The default order is how they appear in zone1970.tab, which is sorted by
  /// the first country listed and then, more or less, from east to west.
  final UnmodifiableListView<ZoneDescription> _zoneDescriptions;

  /// Zone descriptions grouped by country.
  final UnmodifiableMapView<String, List<ZoneDescription>> _byCountry;

  _ZoneDescriptionTable._(this._zoneDescriptions)
      : _byCountry = _groupByCountry(_zoneDescriptions);

  factory _ZoneDescriptionTable() {
    _instance ??= _ZoneDescriptionTable._(_loadZonetab());
    return _instance!;
  }

  static UnmodifiableListView<ZoneDescription> _loadZonetab() {
    var file = _zoneInfoData.findFile('zoneinfo/zone1970.tab');
    var lines = LineSplitter()
        .convert(utf8.decode(file!.content))
        .where((line) => !line.startsWith('#'));
    return UnmodifiableListView(
        lines.map((line) => ZoneDescription._fromLine(line)));
  }

  static UnmodifiableMapView<String, List<ZoneDescription>> _groupByCountry(
      List<ZoneDescription> zoneInfo) {
    var result = <String, List<ZoneDescription>>{};
    for (var zi in zoneInfo) {
      for (var country in zi.countries) {
        result.putIfAbsent(country, () => []).add(zi);
      }
    }
    return UnmodifiableMapView(result);
  }

  /// Lists the zone descriptions for a single country.
  ///
  /// The country is an [ISO 3166 2-letter
  /// code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  /// For example, US = United States, CA = Canada, EE = Estonia, etc.
  List<ZoneDescription> forCountry(String country) =>
      _byCountry[country.toUpperCase()] ?? [];

  /// Returns zone descriptions sorted by their proximity to a given
  /// geographic location. Optionally filters the results by [country].
  List<ZoneDescription> byProximity(double latitude, double longitude,
      [String? country]) {
    var descriptions = _zoneDescriptions.toList();
    if (country != null) {
      descriptions = forCountry(country);
    }
    descriptions.sortByCompare(
        (x) => x, ZoneDescription._compareByProximityTo(latitude, longitude));
    return descriptions;
  }
}

/// Information about a single time zone.
class ZoneDescription {
  static final _latLongRe =
      RegExp(r'^([+-])(\d{2})(\d{2})(\d{2})?([+-])(\d{3})(\d{2})(\d{2})?$');

  String zoneId;
  Set<String> countries;
  double latitude;
  double longitude;
  String comments;

  ZoneDescription(this.zoneId, this.countries, this.latitude, this.longitude,
      this.comments);

  factory ZoneDescription._fromLine(String line) {
    var fields = line.split('\t');
    var latLong = _latLongRe.firstMatch(fields[1]);
    return ZoneDescription(
        _humanizeId(fields[2]),
        fields[0].split(',').toSet(),
        _dmsToDouble(latLong!.group(1), latLong.group(2), latLong.group(3),
            latLong.group(4)),
        _dmsToDouble(latLong.group(5), latLong.group(6), latLong.group(7),
            latLong.group(8)),
        fields.length >= 4 ? fields[3] : '');
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
  /// The numbers this returns are useless for anything other than
  /// sorting time zones.
  ///
  /// It assumes that geographic coordinates are actually points on a
  /// cartesian plane and returns the square of the distance between
  /// them. It weights differences in longitude more heavily than latitude
  /// since time zones tend to be long and skinny along the north-south axis.
  ///
  /// Similar formulas that actually work OK in the general case do exist.
  /// These apply a cosine correction to account for fact that distance
  /// changes between degrees of longitude depending on the latitude. This
  /// does _not_ do that. The sort works acceptably without it, because
  /// time zones that extend to the poles follow lines of longitude.
  static double _distance(
      double lat1, double long1, double lat2, double long2) {
    // lat1 = 180 - lat1;
    long1 %= 360;
    // lat2 = 180 - lat2;
    long2 %= 360;
    return (pow(lat2 - lat1, 2) + pow(2 * (long2 - long1), 2)).toDouble();
  }

  @override
  String toString() =>
      '[$zoneId, $countries, ($latitude, $longitude), $comments]';

  @override
  bool operator ==(Object other) =>
      other is ZoneDescription &&
      zoneId == other.zoneId &&
      countries == other.countries &&
      latitude == other.latitude &&
      longitude == other.longitude &&
      comments == other.comments;

  @override
  int get hashCode =>
      Object.hash(zoneId, countries, latitude, longitude, comments);
}
