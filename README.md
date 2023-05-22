![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/pcekm/tempo/dart.yml)

A complete time and date solution that replaces Dart's core
[`DateTime`][DateTime] with a rich set of date and time
classes, advanced arithmetic features and full time zone
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

## Quick start

```dart
import 'package:tempo/tempo.dart';
```

We'll use a local datetime to get started, but all of the classes largely
work the same. First, these all create the exact same date and time
of May 1, 2023 at 12:00 PM:

```dart
LocalDateTime(2023, 5, 1, 12, 0);
LocalDateTime.parse('2023-05-01T12:00');
LocalDateTime.fromDateTime(DateTime(2023, 5, 1, 12, 0));
```

You can also get the current date and time:

```dart
LocalDateTime.now();
```

And you can convert back to a Dart core [`DateTime`][DateTime] if necessary:

```dart
LocalDateTime(2023, 5, 1, 12, 0).toDateTime() == DateTime(2023, 5, 1, 12, 0);
```

Add a fixed [`Timespan`][Timespan] of 30 days, 3 minutes (`Timespan` replaces
the Dart core [`Duration`][Duration] class):

```dart
var dt = LocalDateTime(2023, 5, 1, 12, 0);
var span = Timespan(days: 30, minutes: 3);
dt.plusTimespan(span) == LocalDateTime(2023, 5, 31, 12, 3);
```

Find the amount of time between two dates:

```dart
var dt1 = LocalDateTime(2023, 5, 1, 12, 0);
var dt2 = LocalDateTime(2023, 6, 1, 14, 3);
dt1.timespanUntil(dt2) == Timespan(days: 31, hours: 2, minutes: 3);
```

Comparisons:

```dart
var dt1 = LocalDateTime(2023, 5, 6, 12, 0);
var dt2 = LocalDateTime(2023, 5, 6, 13, 0);
dt1 != dt2;
dt1 < dt2;
dt2 > dt1;
dt1.compareTo(dt2) == -1;
```

Add a [`Period`][Period] of 1 month. Unlike `Timespan`, the exact
amount of time a `Period` covers varies. Some months are shorter than others:

```dart
var dt = LocalDateTime(2023, 5, 1, 12, 0);
var period = Period(months: 1);
dt.plusPeriod(period) == LocalDateTime(2023, 6, 1, 12, 0);
```

Find the [`Period`][Period] between one [`LocalDate`][LocalDate] and another
(this works for any combination of `LocalDate` and `LocalDateTime`):

```dart
var date1 = LocalDate(2023, 1, 1);
var date2 = LocalDate(2024, 3, 2);
date1.periodUntil(date2) == Period(years: 1, months: 2, days: 1);
```

An [`OffsetDateTime`][OffsetDateTime] with a fixed offset from [UTC][UTC]:

```dart
var offset = ZoneOffset(-7);
OffsetDateTime(offset, 2000, 4, 21, 12, 30);
```

A [`ZonedDateTime`][ZonedDateTime] with a proper time zone:

```dart
ZonedDateTime('America/Los_Angeles', 2023, 5, 9, 10, 47);
```

Both [`OffsetDateTime`][OffsetDateTime] and [`ZonedDateTime`][ZonedDateTime]
contain an offset from [UTC][UTC] and represent an absolute moment in time.
This moment is stored in an [`Instant`][Instant]:

```dart
Instant.now();
Instant.fromUnix(Timespan(seconds: 1683654985));
OffsetDateTime(ZoneOffset(3), 2023, 1, 2, 3).asInstant;
ZonedDateTime('America/Los_Angeles', 2023, 1, 2, 3).asInstant;
```

You can get a list of time zones nearest to a geographical
location, optionally filtered by country. All of these functions return
a list of [`ZoneDescription`][ZoneDescription]:

```dart
timeZonesByProximity(latitude, longitude);
timeZonesByProximity(latitude, longitude, country: 'US');
```

You can list all time zones in a given country:

```dart
timeZonesForCountry('CA');
```

Or you can just list them all:

```dart
allTimeZones();
```

## Testing

This package also contains a [`testing`][testing] library with a useful set
of matchers for your unit tests that produce helpful error messages.

```dart
import 'package:tempo/testing.dart';

var dt = LocalDateTime(2020, 1, 2, 3, 4);
expect(dt, hasYear(2020));
expect(dt, hasHour(4));
expect(dt, hasDate(2020, 1, 2));
expect(dt, hasTime(3, 4));
```

## Additional information

- [Tempo API documentation][tempo]
- [Testing API documentation][testing]
- [File a bug][bug]

[tempo]: https://pub.dev/documentation/tempo/latest/tempo/tempo-library.html
[testing]: https://pub.dev/documentation/tempo/latest/testing/testing-library.html
[bug]: https://github.com/pcekm/tempo/issues/new/choose
[UTC]: https://en.wikipedia.org/wiki/UTC
[DateTime]: https://api.dart.dev/stable/dart-core/DateTime-class.html
[Duration]: https://api.dart.dev/stable/dart-core/Duration-class.html
[LocalDateTime]: https://pub.dev/documentation/tempo/latest/tempo/LocalDateTime-class.html
[LocalDate]: https://pub.dev/documentation/tempo/latest/tempo/LocalDate-class.html
[LocalTime]: https://pub.dev/documentation/tempo/latest/tempo/LocalTime-class.html
[Instant]: https://pub.dev/documentation/tempo/latest/tempo/Instant-class.html
[OffsetDateTime]: https://pub.dev/documentation/tempo/latest/tempo/OffsetDateTime-class.html
[ZonedDateTime]: https://pub.dev/documentation/tempo/latest/tempo/ZonedDateTime-class.html
[Period]: https://pub.dev/documentation/tempo/latest/tempo/Period-class.html
[Timespan]: https://pub.dev/documentation/tempo/latest/tempo/Timespan-class.html
[allTimeZones]: https://pub.dev/documentation/tempo/latest/timezone/allTimeZones.html
[timeZonesForCountry]: https://pub.dev/documentation/tempo/latest/timezone/timeZonesForCountry.html
[timeZonesByProximity]: https://pub.dev/documentation/tempo/latest/timezone/timeZonesByProximity.html
[ZoneDescription]: https://pub.dev/documentation/tempo/latest/timezone/ZoneDescription-class.html
