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

  // TODO: move these methods elsewhere?
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
}
