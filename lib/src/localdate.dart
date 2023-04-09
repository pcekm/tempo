/// Contains local date with no associated time zone.
class LocalDate {
  final int year;
  final int month;
  final int day;

  const LocalDate(this.year, [this.month = 1, this.day = 1]);
}
