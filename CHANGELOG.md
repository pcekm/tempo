# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased] - YYYY-MM-DD

### Added

- `operator+` and `operator-` operators on all datetime types that work on both
  `Timespan` and `Period`
- New, experimental `quantize` call. This can be use to round a datetime down
  (or up) to a specific precision. The specifics of how this works may change in
  the future.

### Changed

- The `Period` constructor automatically normalizes values.

### Fixed

- `Period` normalization now correctly handles negative values of year and
  month.
- `Timespan` normalization now correctly handles negative milli-, micro- and
  nanosecond values that exactly divide one second.

### Deprecated

- `Period.normalize()` is now a no-op. Any calls can be safely removed.
- All methods for adding and subtracting `Timespan` and `Period`. Use the +
  and - operators instead.

## [1.1.0] - 2026-02-02

### Added

- `periodUntil` methods on `OffsetDateTime` and `ZonedDateTime`

### Changed

- `now()` constructors for `LocalTime`, `LocalDate` and `LocalDateTime` use
  `defaultZoneId` instead of `DateTime`'s default.

### Fixed

- A bug when truncating values involving a very large number of nanoseconds to
  microseconds:
  - Converting a recent to `DateTime` from times that were closer than 1 µs to
    midnight would incorrectly result in midnight the next day, instead of 1 µs
    to midnight on the same day.
  - Converting a large `Timespan` to microseconds would sometimes round up when
    the nanosecond part was within 1 µs of the next second.

## [1.0.1] - 2026-01-15

### Fixed

- Fixed a bug in `LocalDate` when it was returned by `LocalDateTime.date`. They
  were not correctly pinned to midnight internally, which caused incorrect
  results in some cases.

## [1.0.0] - 2026-01-03

### Added

- New matchers for `HasInstant` classes that match the Unix timestamp:
  - `hasUnixSeconds`
  - `hasUnixMilliseeconds`
  - `hasUnixMicroseconds`
  - `hasUnixNanoseconds`
  - `hasDateAndTime`
- Added `format()` methods that take a `DateFormat` from the intl package and
  return a string.
- All date and datetime objects have an `inLeapYear` property.
- `replace()` methods on `OffsetDateTime` and `ZonedDateTime` that replace
  individual fields in the object.

### Changed

- Made some constructors `const`:
  - `Timespan()`
  - `Instant.fromUnix()`
  - `ZoneOffset()`
  - `LocalDate()`
  - `LocalTime()`
  - `LocalDateTime()`
  - `OffsetDateTime.withOffset()`
- All `minimum` and `maximum` date time values are `const` instead of `final`.
- Using [`clock` package](https://pub.dev/packages/clock) for all `now()`
  constructors.
- Improved failure output of `hasDate` and `hasTime`
- Constructors no longer throw exceptions when given an invalid date, but they
  do guarantee a valid, albeit unspecified, result. (Other than `ZonedDateTime`,
  which will still throw for invalid zone ids.)

### Deprecated

- `LocalDate.isLeapYear`: Use `inLeapYear` instead.

### Removed

- **Breaking**: `ZoneOffset.local()` removed. Use `offset` on a `ZonedDateTime`
  instead. For example: `ZonedDateTime.now().offset`.

### Fixed

- `ZoneOffset` equals and hash code methods now correctly include the `seconds`
  component.
- `OffsetDateTime.now()` now matches its documentation by returning times and
  offsets in `defaultZoneId`.

## [0.7.1] - 2025-12-10

### Changed

- Updated to timezone database version 2025c

## [0.7.0] - 2025-08-02

### Added

- Missing conversion methods, and standardized the existing ones (see the
  library docs for a list of conversion method names)
- New ISO 8601 `parse()` constructors for `Instant` and `ZonedDateTime`
- Parses ISO date times with either a space or no separator instead of a 'T'

### Changed

- **Breaking**: `ZonedDateTime.defaultZoneId` moved to a top-level getter/setter
  pair
- Setting `defaultZoneId` to an invalid value now throws an exception
- **Breaking**: `ZonedDateTime.toOffset()` changed to a getter,
  `asOffsetDateTime`
- **Breaking**: `toDateTime()` no longer a part of the `HasDate` interface
- **Breaking**: `HasInstant` now uses `toInstant()` method instead of
  `asInstant` getter
- **Breaking**: `OffsetDateTime` now defaults to `defaultZoneId` instead of UTC:
  - Removed `offset` arg from the unnamed constructor. Use `withOffset`
    constructor instead
  - All other `offset` constructor and conversion method args are now optional
    and default to the time zone in `defaultZoneId`
  - One exception: the `fromDateTime` constructor continues to use the offset
    from the `DateTime` it's given

### Removed

- **Breaking**: All `asInstant` getters removed. Use `toInstant()` instead.

### Fixed

- **Breaking**: DateTime extension method `toLocal()` renamed to
  `toLocalDateTime()` so it doesn't shadow an existing method
- Test matchers `hasDate` and `hasTime` no longer ignore unspecified fields, and
  instead check for expected defaults. For example,
  `expect(LocalTime(4, 30), hasTime(4))` used to pass. Now it fails, since the
  unspecified minute matcher defaults to 0.

## [0.6.0] - 2025-06-11

### Added

- Added `us` and `iso` getters to Weekday for weekday numbers
- Added extension methods on DateTime and Duration to convert to Tempo objects

### Changed

- Minimum Dart SDK is now 3.0.0
- Made zoneId optional for ZonedDateTime creation. This is seamless with one
  exception (see below)
- **Breaking**: Removed zoneId arg from ZonedDateTime(). Use
  ZonedDateTime.withZoneId() if you want to specify a time zone.
- ZonedDateTime now has a settable defaultZoneId field that will be used if none
  is provided.
- Improved documentation; assigned objects to categories and created category
  documentation pages.

## [0.5.4] - 2025-05-22

### Changed

- Updated to tzdb-2025b
- Minimum Dart SDK is now 2.19.0

## [0.5.3] - 2024-08-03

### Changed

- Updated to tzdb-2024a.

## [0.5.2] - 2023-05-26

### Added

- Added unixTimestamp and inTimezone() to HasInstant interface.

## [0.5.1] - 2023-05-21

### Changed

- Fixed broken links in README.md

## [0.5.0] - 2023-05-21

### Added

- Initial version.
