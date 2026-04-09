part of '../../tempo.dart';

/// The day of the week.
///
/// The ISO weekday number is [iso], and the US weekday number is [us].
/// The [index] of each value is the same as [iso], but you should prefer
/// the latter for clarity.
enum Weekday {
  // ignore: unused_field
  _, // Eats up zero.
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  /// The ISO weekday number.
  ///
  /// ISO weekdays are numbered 1=Monday to 7=Sunday.
  int get iso => index;

  /// The US weekday number.
  ///
  /// US weekdays are numbered 0=Sunday to 6=Saturday.
  int get us => index % 7;

  /// Parses a string to a weekday.
  ///
  /// Takes a lower-case weekday name in English and returns the respective enumerated value.
  factory Weekday.parse(String string) =>
      Weekday.values.skip(1).where((val) => val.name == string).single;
}
