/// Low-level functions for manipulating dates and times.

const List<int> _daysInMonthTable = [
  0,
  31, // Jan
  29, // Feb; non-leap years are a special case
  31, // Mar
  30, // Apr
  31, // May
  30, // Jun
  31, // Jul
  31, // Aug
  30, // Sep
  31, // Oct
  30, // Nov
  31, // Dec
];

/// Determines if a year is a leap year.
bool checkLeapYear(int year) =>
    year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

/// Returns the days in a given month.
int daysInMonth(int year, int month) {
  return _daysInMonthTable[month] -
      (month == 2 && !checkLeapYear(year) ? 1 : 0);
}
