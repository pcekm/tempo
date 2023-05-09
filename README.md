A complete time and date solution that replaces Dart's core
[`DateTime`][DateTime] class with a rich set of date and time
classes with advanced arithmetic features and full time zone
support.

## Features

Everything [`DateTime`][DateTime] can do, plus:

- Local and zoned date and time classes
- Period arithmetic:
  - Add and subtract months or years without changing the day or time
  - Count the number of years, months and days between two dates
- Create and parse ISO 8601 strings
- Easy conversion to and from [`DateTime`][DateTime]
- Lookup time zones by name, country and geographic coordinates
- Nanosecond precision

## Usage

This package can be broken down into four main categories:

- Local dates and times
- Absolute dates and times
- Periods and Timespans
- Time zone lookups

### Local dates and times

- [`LocalDate`][LocalDate]
- [`LocalTime`][LocalTime]
- [`LocalDateTime`][LocalDateTime]

These are naïve types without time zones that rely on
external context to provide meaning. Think of them like
a clock or a calendar on a wall. Nobody asks what time zone
a wall clock is displaying—it's obvious from the location
of the clock and the observer.

Use them when the time zone is obvious from the context, or
actively distracting. For example:

- Personal reminders
- Alarm clocks
- Bus schedules

```dart
var dt = LocalDateTime(2023, 1, 1, 12, 30);
dt.toString() == '2023-01-01T12:30';
var date = LocalDate(2023, 2, 3);
var time = LocalTime(12, 30, 15);
LocalDateTime.fromParts(date, time) ==
  LocalDateTime(2023, 2, 3, 12, 30, 15);
```

### Absolute dates and times

- [`Instant`][Instant]
- [`OffsetDateTime`][OffsetDateTime]
- [`Timespan`][Timespan]

Unlike the [local](#local-dates-and-times) classes, these are tied to an absolute
moment in time in [UTC][UTC], and to a specific location or time zone.
(In the case of `Instant`, that time zone is UTC itself).

Use them when the time zone is not obvious, when coordinating
between different geographic locations, or when you need an
absolute moment in time. For example:

- Video chat or conference call schedule
- Shared calendars
- Log timestamps (`Instant` in particular)

```dart
var instant = Instant.fromUnixTimestamp(Timespan(seconds: 946872306));
instant.toString() == '2000-01-03T04:05:06Z';

var odt = OffsetDateTime(ZoneOffset(-1), 2000, 1, 3, 3, 5, 6);
odt.toString() == '2000-01-03T03:05:06-0100';
odt.toInstant() == instant;

var zdt = ZonedDateTime.fromInstant(instant, "America/Los Angeles");
zdt.toString() == '2000-01-02T20:05:06-0800';
zdt.timeZone == 'PST';
zdt.offset == ZoneOffset(-8);
```

### Periods and Timespans

- [`Period`][Period]
- [`Timespan`][Timespan]

`Period` and `Timespan` represent relative times. In other words, "how long" between two times. They replace [`Duration`][Duration]
in the Dart core library. `Timespan` always represents an exact
amount of time, while the time covered by a `Period` is more fluid.

Use `Timespan` when you want to work with an exact number of days,
hours, minutes, seconds, or nanoseconds. For example:

```dart
var span = Timespan(days: 10, hours: 2);
var dt = LocalDateTime(2023, 1, 1, 10);
dt.plusTimespan(span) == LocalDateTime(2023, 1, 11, 12);
```

Use `Period` when you want to work with years, months or days
without changing the day or time (more than necessary). For example:

```dart
var period = Period(years: 1, months: 3);
var dt = LocalDate(2023, 1, 1);
dt.plusPeriod(period) == LocalDate(2024, 4, 1);
```

In cases where the starting day would be invalid in the resulting
month, the day will be adjusted to the end of the month. For example:

```dart
var period = Period(months: 1);
var dt = LocalDate(2023, 1, 31);
dt.plusPeriod(period) == LocalDate(2023, 2, 28);
```

### Time zone lookups

- [`allTimeZones`][allTimeZones]
- [`timeZonesByProximity`][timeZonesByProximity]
- [`timeZonesForCountry`][timeZonesForCountry]

These functions provide different ways of listing the available
time zones. They all return a list of
[`ZoneDescription`][ZoneDescription] objects, which contains an
ID string suitable for passing to [`ZonedDateTime`][ZonedDateTime]
along with other information that may be helpful in choosing
a time zone.

## Testing

This package also contains a [`testing`][testing] library with a
useful set of [`Matcher`][Matcher]s for help with your unit tests.

## Additional information

- [File a bug](https://github.com/pcekm/tempo/issues/new/choose)

[UTC]: https://en.wikipedia.org/wiki/UTC
[DateTime]: https://api.dart.dev/stable/dart-core/DateTime-class.html
[Duration]: https://api.dart.dev/stable/dart-core/Duration-class.html
[testing]: https://pub.dev/documentation/tempo/latest/testing/
[LocalDateTime]: https://pub.dev/documentation/tempo/latest/tempo/LocalDateTime-class.html
[LocalDate]: https://pub.dev/documentation/tempo/latest/tempo/LocalDate-class.html
[LocalTime]: https://pub.dev/documentation/tempo/latest/tempo/LocalTime-class.html
[Instant]: https://pub.dev/documentation/tempo/latest/tempo/Instant-class.html
[OffsetDateTime]: https://pub.dev/documentation/tempo/latest/tempo/OffsetDateTime-class.html
[ZonedDateTime]: https://pub.dev/documentation/tempo/latest/tempo/ZonedDateTime-class.html
[Period]: https://pub.dev/documentation/tempo/latest/tempo/Period-class.html
[Timespan]: https://pub.dev/documentation/tempo/latest/tempo/Timespan-class.html
[allTimeZones]: https://pub.dev/documentation/tempo/latest/tempo/allTimeZones.html
[timeZonesByProximity]: https://pub.dev/documentation/tempo/latest/tempo/timeZonesByProximity.html
[timeZonesForCountry]: https://pub.dev/documentation/tempo/latest/tempo/timeZonesForCountry.html
[ZoneDescription]: https://pub.dev/documentation/tempo/latest/tempo/ZoneDescription-class.html
