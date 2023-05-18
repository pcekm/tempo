import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'zone_tab_row.g.dart';

/// Information about a single time zone.
abstract class ZoneTabRow implements Built<ZoneTabRow, ZoneTabRowBuilder> {
  static Serializer<ZoneTabRow> get serializer => _$zoneTabRowSerializer;

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

  ZoneTabRow._();
  factory ZoneTabRow([void Function(ZoneTabRowBuilder) updates]) = _$ZoneTabRow;
}
