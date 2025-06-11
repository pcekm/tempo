Unlike the local classes, these are tied to an absolute moment of time in
[UTC](https://en.wikipedia.org/wiki/UTC), and to a specific location or time
zone. (In the case of `Instant`, that time zone is UTC itself).

Use them when the time zone is not obvious, when coordinating between different
geographic locations, or whenever a local time would be ambiguous. For example:

- Video chat or conference call schedule
- Shared calendars
- Log timestamps (`Instant` in particular)

```dart
var instant = Instant.fromUnix(Timespan(seconds: 946872306));
instant.toString() == '2000-01-03T04:05:06Z';

var odt = OffsetDateTime(ZoneOffset(-1), 2000, 1, 3, 3, 5, 6);
odt.toString() == '2000-01-03T03:05:06-0100';
odt.asInstant == instant;

var zdt = ZonedDateTime.fromInstant(instant, 'America/Los_Angeles');
zdt.toString() == '2000-01-02T20:05:06-0800';
zdt.timeZone == 'PST';
zdt.offset == ZoneOffset(-8);
zdt.asInstant == instant;
```
