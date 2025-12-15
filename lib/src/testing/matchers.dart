part of '../../testing.dart';

/// Matches the instant from a [HasInstant].
Matcher hasInstant(Object? matcher) =>
    isA<HasInstant>().having((t) => t.toInstant(), 'instant', matcher);

/// Matches the Unix seconds of a [HasInstant].
Matcher hasUnixSeconds(Object matcher) => isA<HasInstant>().having(
    (t) => t.toInstant().unixTimestamp.inSeconds, 'unix seconds', matcher);

/// Matches the Unix milliseconds of a [HasInstant].
Matcher hasUnixMilliseconds(Object matcher) => isA<HasInstant>().having(
    (t) => t.toInstant().unixTimestamp.inMilliseconds,
    'unix milliseconds',
    matcher);

/// Matches the Unix microseconds of a [HasInstant].
Matcher hasUnixMicroseconds(Object matcher) => isA<HasInstant>().having(
    (t) => t.toInstant().unixTimestamp.inMicroseconds,
    'unix microseconds',
    matcher);

/// Matches the full precision Unix time of a [HasInstant].
///
/// The seconds and nanoseconds parts must be matched separately to avoid
/// overflow.
Matcher hasUnixNanoseconds(Object seconds, Object nanoseconds) =>
    isA<HasInstant>().having(
        (t) => t.toInstant().unixTimestamp,
        'unixTimestamp',
        isA<Timespan>()
            .having((u) => u.seconds, 'seconds', seconds)
            .having((u) => u.nanosecondPart, 'nanosecondPart', nanoseconds));

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
    isA<HasDate>()
        .having((d) => d.year, 'year', year)
        .having((d) => d.month, 'month', month)
        .having((d) => d.day, 'day', day);

/// Matches the time from a [HasTime].
Matcher hasTime(Object? hour,
        [Object? minute = 0, Object? second = 0, Object? nanosecond = 0]) =>
    isA<HasTime>()
        .having((t) => t.hour, 'hour', hour)
        .having((t) => t.minute, 'minute', minute)
        .having((t) => t.second, 'second', second)
        .having((t) => t.nanosecond, 'nanosecond', nanosecond);

/// Matches the date and time from a [HasDateTime].
Matcher hasDateAndTime(Object year,
        [Object month = 1,
        Object day = 1,
        Object hour = 0,
        Object minute = 0,
        Object second = 0,
        Object nanosecond = 0]) =>
    isA<HasDateTime>()
        .having((d) => d.year, 'year', year)
        .having((d) => d.month, 'month', month)
        .having((d) => d.day, 'day', day)
        .having((t) => t.hour, 'hour', hour)
        .having((t) => t.minute, 'minute', minute)
        .having((t) => t.second, 'second', second)
        .having((t) => t.nanosecond, 'nanosecond', nanosecond);

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
