import 'package:test/test.dart';

import '../../tempo.dart';

class _HasInstant extends CustomMatcher {
  _HasInstant(matcher) : super('Has instant that is', 'instant', matcher);
  @override
  Instant featureValueOf(dynamic actual) => actual.asInstant;
}

/// Matches the instant from a [HasInstant].
Matcher hasInstant(Object? matcher) => _HasInstant(matcher);

class _HasYear extends CustomMatcher {
  _HasYear(matcher) : super('Has year that is', 'year', matcher);
  @override
  int featureValueOf(dynamic actual) => actual.year;
}

/// Matches the year from a [HasDate].
Matcher hasYear(Object? matcher) => _HasYear(matcher);

class _HasMonth extends CustomMatcher {
  _HasMonth(matcher) : super('Has month that is', 'month', matcher);
  @override
  int featureValueOf(dynamic actual) => actual.month;
}

/// Matches the month from a [HasDate].
Matcher hasMonth(Object? matcher) => _HasMonth(matcher);

class _HasDay extends CustomMatcher {
  _HasDay(matcher) : super('Has day that is', 'day', matcher);
  @override
  int featureValueOf(dynamic actual) => actual.day;
}

/// Matches the day from a [HasDate].
Matcher hasDay(Object? matcher) => _HasDay(matcher);

class _HasHour extends CustomMatcher {
  _HasHour(matcher) : super('Has hour that is', 'hour', matcher);
  @override
  int featureValueOf(dynamic actual) => actual.hour;
}

/// Matches the hour from a [HasTime].
Matcher hasHour(Object? matcher) => _HasHour(matcher);

class _HasWeekday extends CustomMatcher {
  _HasWeekday(matcher) : super('Has weekday that is', 'weekday', matcher);
  @override
  Weekday featureValueOf(dynamic actual) => actual.weekday;
}

/// Matches the weekday from a [HasDate].
Matcher hasWeekday(Object? matcher) => _HasWeekday(matcher);

class _HasMinute extends CustomMatcher {
  _HasMinute(matcher) : super('Has minute that is', 'minute', matcher);
  @override
  int featureValueOf(dynamic actual) => actual.minute;
}

/// Matches the minute from a [HasTime].
Matcher hasMinute(Object? matcher) => _HasMinute(matcher);

class _HasSecond extends CustomMatcher {
  _HasSecond(matcher) : super('Has second that is', 'second', matcher);
  @override
  int featureValueOf(dynamic actual) => actual.second;
}

/// Matches the second from a [HasTime].
Matcher hasSecond(Object? matcher) => _HasSecond(matcher);

class _HasNanosecond extends CustomMatcher {
  _HasNanosecond(matcher)
      : super('Has nanosecond that is', 'nanosecond', matcher);
  @override
  int featureValueOf(dynamic actual) => actual.nanosecond;
}

/// Matches the nanosecond from a [HasTime].
Matcher hasNanosecond(Object? matcher) => _HasNanosecond(matcher);

/// Matches the date from a [HasDate].
Matcher hasDate(Object? year, [Object? month, Object? day]) => allOf(
    hasYear(year),
    month != null ? hasMonth(month) : null,
    day != null ? hasDay(day) : null);

/// Matches the time from a [HasTime].
Matcher hasTime(Object? hour,
        [Object? minute, Object? second, Object? nanosecond]) =>
    allOf(
        hasHour(hour),
        minute != null ? hasMinute(minute) : null,
        second != null ? hasSecond(second) : null,
        nanosecond != null ? hasNanosecond(nanosecond) : null);
