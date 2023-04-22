part of '../goodtime.dart';

/// Interface implemented by classes that can add and subtract [Period]s.
abstract class _PeriodArithmetic<T> {
  /// Adds a [Period] of time.
  ///
  /// Increments (or decrements) the date by a specific number of months
  /// or years while—as much as possible—keeping the day (and time, if any)
  /// the same. When this is not possible the result will be the last day of
  /// the month. For  example, adding one month to `2023-01-31` gives
  ///`2023-01-28`.
  ///
  /// The days part is applied last. For example, adding one month and one day
  /// to `2023-01-31` first adds one month to get `2023-02-28` and then
  /// adds one day for a final result of `2023-03-01`.
  T plusPeriod(Period p);

  /// Subtracts a [Period] of time.
  ///
  /// Decrements (or increments) the date by a specific number of months
  /// or years while—as much as possible—keeping the day (and time, if any)
  /// the same. When this is not possible the result will be the last day of
  /// the month. For example, adding one month to `2023-01-31` gives
  /// `2023-01-28`.
  ///
  /// The days part is applied last. For example, subtracting one month and
  /// one day from `2023-03-31` first subtracts one month to get `2023-02-28`
  /// and then subtracts one day for a final result of `2023-02-27`.
  T minusPeriod(Period p);
}
