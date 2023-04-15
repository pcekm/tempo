// Interfaces used throughout this library.

import 'package:fixnum/fixnum.dart';

/// Interface for date/time objects that provide an absolute date/time
/// relative to 0001-01-01 of the ISO 8601 calendar.
abstract class HasRataDie {
  /// Microseconds relative to midnight local time on `0001-01-01`.
  ///
  /// Note that "relative to" does not mean "since," which may
  /// be confusing to those used to Unix times. Rata Die
  /// numbers days starting at 1. So this actually measures microseconds since
  /// midnight `0000-12-31`.
  ///
  /// It's also important to realize that while this is relative to a fixed
  /// date and time, that fixed date and time is _not_ relative to any
  /// particular time zone.
  Int64 get rataDieUsec;
}

/// Interface for date/time objects that have an ISO 8601 date.
abstract class HasDate implements HasRataDie {
  /// An ISO 8601 year number which may be zero or negative.
  ///
  /// `year == 0` means 1 BCE, `year == -1` means 2 BCE, and in general
  /// `year <= 0` means year - 1 BCE. This is also called astronomical
  /// year numbering.
  int get year;

  /// Months range from 1 to 12 inclusive.
  int get month;

  /// Days range from 1 to 31 inclusive (depending on the year and month).
  int get day;
}
