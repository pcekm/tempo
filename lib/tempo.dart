/// A date and time library that replaces the standard
/// `dart:core` [DateTime] and [Duration] classes.
///
/// This is heavily inspired by the `java.time` package in Java 8+,
/// although there are plenty of differences.
///
/// # Overview
///
/// This library can be broken down into four main categories:
/// local dates and times, absolute dates and times, periods and
/// timespans, time zone lookups.
///
/// ## Local dates and times
///
/// - [LocalDate]
/// - [LocalTime]
/// - [LocalDateTime]
///
/// These are naïve types without time zones that rely on
/// external context to provide meaning. Think of them like
/// a clock or a calendar on a wall. Nobody asks what time zone
/// a wall clock is displaying—it's obvious from the location
/// of the clock and the observer.
///
/// Use them when the time zone is obvious from the context, or
/// it would add unnecessary complexity. For example:
///
/// - Personal reminders
/// - Alarm clocks
/// - Bus schedules
///
/// ```dart
/// var dt = LocalDateTime(2023, 1, 1, 12, 30);
/// dt.toString() == '2023-01-01T12:30';
/// var date = LocalDate(2023, 2, 3);
/// var time = LocalTime(12, 30, 15);
/// LocalDateTime.fromParts(date, time) ==
///   LocalDateTime(2023, 2, 3, 12, 30, 15);
/// ```
///
/// ## Absolute dates and times
///
/// - [Instant]
/// - [OffsetDateTime]
/// - [Timespan]
///
/// Unlike the local classes, these are tied to an absolute
/// moment in time in [UTC](https://en.wikipedia.org/wiki/UTC), and to
/// a specific location or time zone. (In the case of `Instant`, that
/// time zone is UTC itself).
///
/// Use them when the time zone is not obvious, when coordinating
/// between different geographic locations, or when you need an
/// absolute moment in time. For example:
///
/// - Video chat or conference call schedule
/// - Shared calendars
/// - Log timestamps (`Instant` in particular)
///
/// ```dart
/// var instant = Instant.fromUnix(Timespan(seconds: 946872306));
/// instant.toString() == '2000-01-03T04:05:06Z';
///
/// var odt = OffsetDateTime(ZoneOffset(-1), 2000, 1, 3, 3, 5, 6);
/// odt.toString() == '2000-01-03T03:05:06-0100';
/// odt.asInstant == instant;
///
/// var zdt = ZonedDateTime.fromInstant(instant, "America/Los Angeles");
/// zdt.toString() == '2000-01-02T20:05:06-0800';
/// zdt.timeZone == 'PST';
/// zdt.offset == ZoneOffset(-8);
/// zdt.asInstant == instant;
/// ```
///
/// ## Periods and Timespans
///
/// - [Period]
/// - [Timespan]
///
/// `Period` and `Timespan` represent relative times. In other words, "how
/// long" between two times. They replace [Duration]
/// in the Dart core library. `Timespan` always represents an exact
/// amount of time, while the time covered by a `Period` is more fluid.
///
/// Use `Timespan` when you want to work with an exact number of days,
/// hours, minutes, seconds, or nanoseconds. For example:
///
/// ```dart
/// var span = Timespan(days: 10, hours: 2);
/// var dt = LocalDateTime(2023, 1, 1, 10);
/// dt.plusTimespan(span) == LocalDateTime(2023, 1, 11, 12);
/// ```
///
/// Use `Period` when you want to work with years, months or days
/// without changing the day or time (more than necessary). For example:
///
/// ```dart
/// var period = Period(years: 1, months: 3);
/// var dt = LocalDate(2023, 1, 1);
/// dt.plusPeriod(period) == LocalDate(2024, 4, 1);
/// ```
///
/// In cases where the starting day would be invalid in the resulting
/// month, the day will be adjusted to the end of the month. For example:
///
/// ```dart
/// var period = Period(months: 1);
/// var dt = LocalDate(2023, 1, 31);
/// dt.plusPeriod(period) == LocalDate(2023, 2, 28);
/// ```
///
/// ## Time zone lookups
///
/// - [allTimeZones]
/// - [timeZonesByProximity]
/// - [timeZonesForCountry]
///
/// These functions provide different ways of listing the available
/// time zones. They all return a list of [ZoneDescription] objects,
/// which contains an ID string suitable for passing to [ZonedDateTime]
/// along with other information that may be helpful in choosing
/// a time zone.
library tempo;

import 'dart:math';

import 'package:string_scanner/string_scanner.dart';

import 'src/tempo/common.dart';
import 'src/tempo/julian_day.dart';
import 'src/zonedb.dart';

export 'src/zonedb.dart'
    show
        ZoneDescription,
        allTimeZones,
        timeZonesByProximity,
        timeZonesForCountry;

part 'src/tempo/__period_arithmetic.dart';
part 'src/tempo/iso8601.dart';
part 'src/tempo/has_date_time.dart';
part 'src/tempo/has_date.dart';
part 'src/tempo/has_instant.dart';
part 'src/tempo/has_time.dart';
part 'src/tempo/instant.dart';
part 'src/tempo/local_date_time.dart';
part 'src/tempo/local_date.dart';
part 'src/tempo/local_time.dart';
part 'src/tempo/offset_date_time.dart';
part 'src/tempo/period.dart';
part 'src/tempo/timespan.dart';
part 'src/tempo/weekday.dart';
part 'src/tempo/zone_offset.dart';
part 'src/tempo/zoned_date_time.dart';
