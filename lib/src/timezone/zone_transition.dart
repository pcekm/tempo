import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../tempo.dart';

part 'zone_transition.g.dart';

/// A transition in the time for a time zone.
///
/// For example, a switch from daylight savings to standard time, or
/// a change in the offset from UTC.
abstract class ZoneTransition
    implements Built<ZoneTransition, ZoneTransitionBuilder> {
  static Serializer<ZoneTransition> get serializer =>
      _$zoneTransitionSerializer;

  Instant get transitionTime;
  NamedZoneOffset get offset;
  bool get isDst;

  ZoneTransition._();
  factory ZoneTransition([void Function(ZoneTransitionBuilder) updates]) =
      _$ZoneTransition;
}
