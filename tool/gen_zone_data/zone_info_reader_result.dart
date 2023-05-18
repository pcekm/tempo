import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tempo/src/timezone/zone_transition.dart';
import 'package:tempo/src/timezone/zone_transition_rule.dart';

part 'zone_info_reader_result.g.dart';

/// Contains the results of reading a zoneinfo file. This will be copied
/// into a [ZoneRules] later.
abstract class ZoneInfoReaderResult
    implements Built<ZoneInfoReaderResult, ZoneInfoReaderResultBuilder> {
  static Serializer<ZoneInfoReaderResult> get serializer =>
      _$zoneInfoReaderResultSerializer;

  BuiltList<ZoneTransition> get transitions;
  ZoneTransitionRule get rule;

  ZoneInfoReaderResult._();
  factory ZoneInfoReaderResult(
          [void Function(ZoneInfoReaderResultBuilder) updates]) =
      _$ZoneInfoReaderResult;
}
