These are naïve types without time zones that rely on external context to
provide meaning. Think of them like a clock or a calendar on a wall. Nobody asks
what time zone a wall clock is displaying—it's obvious from the location of the
clock and the observer.

Use them when the time zone is obvious from the context, or it would add
unnecessary complexity. For example:

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
