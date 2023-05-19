import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:collection/collection.dart';

import '../../tempo.dart';
import '../../timezone.dart';

part 'zone_rules.g.dart';

/// Time zone rules for a specific location.
abstract class ZoneRules implements Built<ZoneRules, ZoneRulesBuilder> {
  static Serializer<ZoneRules> get serializer => _$zoneRulesSerializer;

  /// A list of time transitions for this time zone in ascending order by
  /// transition time.
  BuiltList<ZoneTransition> get transitions;

  /// The general rule for time transitions to use afte the last entry in
  /// [transitions].
  ZoneTransitionRule get rule;

  ZoneRules._();
  factory ZoneRules([void Function(ZoneRulesBuilder) updates]) = _$ZoneRules;

  /// Finds the zone offset that applies at the given [instant].
  NamedZoneOffset offsetFor(HasInstant instant) {
    var i = transitions.toList().lowerBoundBy<HasInstant>(
        ZoneTransition((b) => b
          ..transitionTime = instant.asInstant
          ..offset = NamedZoneOffset('', false, 0)),
        (t) => t.transitionTime);
    if (i == transitions.length) {
      return rule.offsetFor(instant);
    }
    return transitions[max(0, i - 1)].offset;
  }
}
