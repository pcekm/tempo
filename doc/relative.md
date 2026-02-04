[Period](../tempo/Period-class.html) and
[Timespan](../tempo/Timespan-class.html) represent relative times. In other
words, "how long" between two times. They replace
[Duration](https://api.flutter.dev/flutter/dart-core/Duration-class.html) in the
Dart core library. `Timespan` always represents an exact amount of time, while
the time covered by a `Period` is more fluid.

Use `Timespan` when you want to work with an exact number of days, hours,
minutes, seconds, or nanoseconds. For example:

```dart
var span = Timespan(days: 10, hours: 2);
var dt = LocalDateTime(2023, 1, 1, 10);
dt + span == LocalDateTime(2023, 1, 11, 12);
```

Use `Period` when you want to work with years, months or days without changing
the day or time (more than necessary). For example:

```dart
var period = Period(years: 1, months: 3);
var dt = LocalDate(2023, 1, 1);
dt + period == LocalDate(2024, 4, 1);
```

In cases where the starting day would be invalid in the resulting month, the day
will be adjusted to the end of the month. For example:

```dart
var period = Period(months: 1);
var dt = LocalDate(2023, 1, 31);
dt + period == LocalDate(2023, 2, 28);
```
