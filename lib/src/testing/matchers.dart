part of '../../testing.dart';

/// Matches the instant from a [HasInstant].
Matcher hasInstant(Object? matcher) =>
    isA<HasInstant>().having((t) => t.toInstant(), 'instant', matcher);

/// Matches the unix timestamp of a [HasInstant].
Matcher hasUnix(
        {Object seconds = anything,
        Object milliseconds = anything,
        Object microseconds = anything,
        Object nanoseconds = anything}) =>
    isA<HasInstant>().having(
        (t) => t.toInstant().unixTimestamp,
        'unixTimestamp',
        isTimespan(
            seconds: seconds,
            milliseconds: milliseconds,
            microseconds: microseconds,
            nanoseconds: nanoseconds));

/// Matches a [Timespan] that covers the given times.
///
/// Be wary when testing large values of smaller units such as [microseconds]
/// and [nanoseconds]. They may overflow.
Matcher isTimespan({
  Object days = anything,
  Object hours = anything,
  Object minutes = anything,
  Object seconds = anything,
  Object milliseconds = anything,
  Object microseconds = anything,
  Object nanoseconds = anything,
}) =>
    isA<Timespan>()
        .having((t) => t.inDays, 'days', days)
        .having((t) => t.inHours, 'hours', hours)
        .having((t) => t.inMinutes, 'minutes', minutes)
        .having((t) => t.inSeconds, 'seconds', seconds)
        .having((t) => t.inMilliseconds, 'milliseconds', milliseconds)
        .having((t) => t.inMicroseconds, 'microseconds', microseconds)
        .having((t) => t.inNanoseconds, 'nanoseconds', nanoseconds);

/// Matches the year from a [HasDate].
Matcher hasYear(Object? matcher) =>
    isA<HasDate>().having((d) => d.year, 'year', matcher);

/// Matches the month from a [HasDate].
Matcher hasMonth(Object? matcher) =>
    isA<HasDate>().having((d) => d.month, 'month', matcher);

/// Matches the day from a [HasDate].
Matcher hasDay(Object? matcher) =>
    isA<HasDate>().having((d) => d.day, 'day', matcher);

/// Matches the weekday from a [HasDate].
Matcher hasWeekday(Object? matcher) =>
    isA<HasDate>().having((d) => d.weekday, 'weekday', matcher);

/// Matches the hour from a [HasTime].
Matcher hasHour(Object? matcher) =>
    isA<HasTime>().having((d) => d.hour, 'hour', matcher);

/// Matches the minute from a [HasTime].
Matcher hasMinute(Object? matcher) =>
    isA<HasTime>().having((d) => d.minute, 'minute', matcher);

/// Matches the second from a [HasTime].
Matcher hasSecond(Object? matcher) =>
    isA<HasTime>().having((t) => t.second, 'second', matcher);

/// Matches the nanosecond from a [HasTime].
Matcher hasNanosecond(Object? matcher) =>
    isA<HasTime>().having((t) => t.nanosecond, 'nanosecond', matcher);

/// Matches the date from a [HasDate].
Matcher hasDate(Object? year, [Object? month = 1, Object? day = 1]) =>
    allOf(hasYear(year), hasMonth(month), hasDay(day));

/// Matches the time from a [HasTime].
Matcher hasTime(Object? hour,
        [Object? minute = 0, Object? second = 0, Object? nanosecond = 0]) =>
    allOf(hasHour(hour), hasMinute(minute), hasSecond(second),
        hasNanosecond(nanosecond));

/// Matches the values the time zone offset of an [OffsetDateTime] or
/// [ZonedDateTime].
Matcher hasOffset(Object? hours,
    [Object? minutes = isZero, Object? seconds = isZero]) {
  return anyOf(
    isA<OffsetDateTime>()
        .having((d) => d.offset.hours, 'hours', hours)
        .having((d) => d.offset.minutes, 'minutes', minutes)
        .having((d) => d.offset.seconds, 'seconds', seconds),
    isA<ZonedDateTime>()
        .having((d) => d.offset.hours, 'hours', hours)
        .having((d) => d.offset.minutes, 'minutes', minutes)
        .having((d) => d.offset.seconds, 'seconds', seconds),
  );
}
