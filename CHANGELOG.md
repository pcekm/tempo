## Unreleased changes

- Added some missing conversion methods, and standardized the existing ones (see
  the library docs for a list of conversion method names)
- **Breaking changes**:
  - DateTime extension method toLocal() has been renamed toLocalDateTime() to
    avoid shadowing an existing method
  - ZonedDateTime.toOffset() changed to a getter, `asOffsetDateTime` to better
    distinguish it from the standardized `atOffset` method.
  - `toDateTime()` no longer a part of the `HasDate` interface

## 0.6.0

- Minimum Dart SDK is now 3.0.0
- Added `us` and `iso` getters to Weekday for weekday numbers
- Added extension methods on DateTime and Duration to convert to Tempo objects
- Made zoneId optional for ZonedDateTime creation. **Breaking change**
  - This is seamless with one exception:
  - **Breaking change**: Removed zoneId arg from ZonedDateTime(). Use
    ZonedDateTime.withZoneId() if you want to specify a time zone.
  - ZonedDateTime now has a settable defaultZoneId field that will be used if
    none is provided.
- Documentation improvements

## 0.5.4

- Updated to tzdb-2025b
- Minimum Dart SDK is now 2.19.0

## 0.5.3

- Updated to tzdb-2024a.

## 0.5.2

- Added unixTimestamp and inTimezone() to HasInstant interface.

## 0.5.1

- Fixed broken links in README.md

## 0.5.0

- Initial version.
