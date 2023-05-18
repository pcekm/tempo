import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tempo/timezone.dart';

part 'zone_info.g.dart';

/// Encapsulates all zoneinfo data.
abstract class ZoneInfo implements Built<ZoneInfo, ZoneInfoBuilder> {
  static Serializer<ZoneInfo> get serializer => _$zoneInfoSerializer;

  BuiltMap<String, ZoneRules> get rules;
  BuiltList<ZoneTabRow> get zoneTab;
  BuiltListMultimap<String, ZoneTabRow> get zoneTabByCountry;

  ZoneInfo._();
  factory ZoneInfo([void Function(ZoneInfoBuilder) updates]) = _$ZoneInfo;
}
