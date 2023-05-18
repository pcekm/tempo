import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../tempo.dart';

part 'time_change_rule.g.dart';

/// A rule for determining what day and time a [ZoneTransitionRule] occurs at
/// for a given year.
abstract class TimeChangeRule
    implements Built<TimeChangeRule, TimeChangeRuleBuilder> {
  static Serializer<TimeChangeRule> get serializer =>
      _$timeChangeRuleSerializer;

  static final LocalTime _defaultTime = LocalTime(2);

  /// The month the change occurs.
  int get month;

  /// The week of the month. Week 5 means "the last [day] of the month"
  int get week;

  /// The weekday.
  Weekday get day;

  /// The time the change occurs. Defaults to 02:00 AM.
  LocalTime get time;

  TimeChangeRule._();
  factory TimeChangeRule([void Function(TimeChangeRuleBuilder) updates]) =
      _$TimeChangeRule;

  @BuiltValueHook(initializeBuilder: true)
  static void _setDefaults(TimeChangeRuleBuilder b) => b..time = _defaultTime;

  LocalDateTime forYear(int year) {
    var startOfWeek = LocalDateTime(
        year, month, 7 * (week - 1) + 1, time.hour, time.minute, time.second);
    var changeTime = startOfWeek.plusTimespan(
        Timespan(days: (day.index - startOfWeek.weekday.index) % 7));
    if (changeTime.month != month) {
      // This will only occur for week == 5, which means "the last day"
      // of the same month. Since the shortest month has exactly 4 * 7 = 28
      // days, then if skipping to the 5th week rolls over to the next month
      // we will always have to subtract exactly one week.
      changeTime = changeTime.minusTimespan(Timespan(days: 7));
    }
    return changeTime;
  }
}
