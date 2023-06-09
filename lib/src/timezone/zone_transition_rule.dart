import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../tempo.dart';
import '../../timezone.dart';

part 'zone_transition_rule.g.dart';

/// A general rule for when the time changes in a time zone.
///
/// This is used to determine future transitions after the fixed
/// [ZoneTransition] values.
abstract class ZoneTransitionRule
    implements Built<ZoneTransitionRule, ZoneTransitionRuleBuilder> {
  static Serializer<ZoneTransitionRule> get serializer =>
      _$zoneTransitionRuleSerializer;

  /// The name of the standard time zone. For example, "PST", "EST", "CET".
  String get stdName;

  /// The offset of the standard time zone from UTC.
  ZoneOffset get stdOffset;

  /// The name of the daylight savings time zone (if any). For example,
  /// "PDT", "EDT", "CEST". Null for fixed-offset rules.
  String? get dstName;

  /// The daylight savings offset from UTC. Defaults to [stdOffset] + 1 hour
  /// if [dstName] is set. Null for fixed-offset rules.
  ZoneOffset? get dstOffset;

  /// The rule for when the time switches to daylight savings in a given year.
  /// Null for fixed-offset rules.
  TimeChangeRule? get dstStartRule;

  /// The rule for when the time switches to standard time in a given year.
  /// Null for fixed-offset rules.
  TimeChangeRule? get stdStartRule;

  ZoneTransitionRule._();
  factory ZoneTransitionRule(
          [void Function(ZoneTransitionRuleBuilder) updates]) =
      _$ZoneTransitionRule;

  @BuiltValueHook(finalizeBuilder: true)
  static void _setDefaultOffset(ZoneTransitionRuleBuilder b) {
    if (b.dstName != null && b.dstOffset == null) {
      b.dstOffset =
          ZoneOffset.fromTimespan(b.stdOffset!.asTimespan + Timespan(hours: 1));
    }
  }

  @BuiltValueHook(finalizeBuilder: true)
  static void _checkConsistency(ZoneTransitionRuleBuilder b) {
    if ((b.dstName == null) != (b.dstOffset == null) ||
        (b.dstName == null) != (b._dstStartRule == null) ||
        (b.dstName == null) != (b._stdStartRule == null)) {
      throw ArgumentError(
          'dstName, dstOffset, dstStartRule and stdStartRule must all be null '
          'or non-null together.');
    }
  }

  NamedZoneOffset offsetFor(HasInstant instant) {
    var namedStdOffset =
        NamedZoneOffset.fromZoneOffset(stdName, false, stdOffset);
    if (dstName == null) {
      return namedStdOffset;
    }

    var namedDstOffset =
        NamedZoneOffset.fromZoneOffset(dstName!, true, dstOffset!);

    var std = OffsetDateTime.fromInstant(instant, stdOffset).toLocal();
    var dst = OffsetDateTime.fromInstant(instant, dstOffset!).toLocal();
    var dstStart = dstStartRule!.forYear(std.year);
    var stdStart = stdStartRule!.forYear(std.year);

    if (dstStart < stdStart) {
      if (std >= dstStart && dst < stdStart) {
        return namedDstOffset;
      } else {
        return namedStdOffset;
      }
    } else {
      // "Winter time." Hello, Ireland. :-)
      if (std >= stdStart && dst < dstStart) {
        return namedStdOffset;
      } else {
        return namedDstOffset;
      }
    }
  }
}
