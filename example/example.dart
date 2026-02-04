import 'package:tempo/tempo.dart';

/// Same day and time next month.
LocalDateTime nextMonth(LocalDateTime date) => date + Period(months: 1);

/// Same day and time next year.
LocalDateTime nextYear(LocalDateTime date) => date + Period(years: 1);

/// Exactly 24 hours from now.
ZonedDateTime add24h(ZonedDateTime date) => date + Timespan(days: 1);

/// Also exactly 24 hours from now.
ZonedDateTime alsoAdd24h(ZonedDateTime date) => date + Timespan(hours: 24);

/// The exact same time tomorrow. This works even if there's a time change
/// and the local time gains or loses an hour.
ZonedDateTime addOneDay(ZonedDateTime date) => date + Period(days: 1);

/// Calls [func] with each day between [start] and [end].
void forEachDay(LocalDate start, LocalDate end, void Function(LocalDate) func) {
  for (var date = start;
      date < end;
      // Since LocalDate has no time changes, adding a Timespan would also work:
      date = date + Period(days: 1)) {
    func(date);
  }
}

/// Counts the number of days until another date.
int daysUntil(LocalDate date) => LocalDate.now().periodUntil(date).days;

/// Prints a calendar for the given year and month.
void printCalendar(int year, int month) {
  final monthStart = LocalDate(year, month);
  final offset = monthStart.weekday.us;
  final calendarStart = monthStart - Period(days: offset);
  final monthEnd = monthStart + Period(months: 1);
  print('Sun Mon Tue Wed Thu Fri Sat');
  var row = [];
  for (var date = calendarStart;
      date < monthEnd;
      date = date + Period(days: 1)) {
    if (row.length >= 7) {
      print(row.join(' '));
      row = [];
    }
    if (date < monthStart) {
      row.add('   ');
    } else {
      row.add('${date.day}'.padLeft(3));
    }
  }
  if (row.isNotEmpty) {
    print(row.join(' '));
  }
}
