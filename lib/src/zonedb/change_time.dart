part of '../zonedb.dart';

/// A time at which a switch to or from daylight savings occurrs.
abstract class ChangeTime implements Built<ChangeTime, ChangeTimeBuilder> {
  static Serializer<ChangeTime> get serializer => _$changeTimeSerializer;
  int get month;
  int get week;
  Weekday get weekday;
  LocalTime get time;

  ChangeTime._();
  factory ChangeTime([void Function(ChangeTimeBuilder) updates]) = _$ChangeTime;

  LocalDateTime forYear(int year) {
    var startOfWeek = LocalDateTime(
        year, month, 7 * (week - 1) + 1, time.hour, time.minute, time.second);
    var changeTime = startOfWeek.plusTimespan(
        Timespan(days: (weekday.index - startOfWeek.weekday.index) % 7));
    if (changeTime.month != month) {
      // This will only occur for week == 5, which means "the last day"
      // of the same month. Since the shortest month has exactly 4 * 7 = 28
      // days, then if skipping to the 5th week rolls over to the next month
      // we will always have to subtract exactly one week.
      changeTime = changeTime.minusTimespan(Timespan(days: 7));
    }
    return changeTime;
  }

  @override
  String toString() => '$month.$week.$weekday/$time';
}
