import 'package:tempo/tempo.dart';
import 'package:tempo/timezone.dart';
import 'package:test/test.dart';

void main() {
  test('basic', () {
    var rule = TimeChangeRule((b) => b
      ..month = 1
      ..week = 2
      ..day = Weekday.wednesday
      ..time = LocalTime(4, 5, 6));
    expect(rule.forYear(1984), LocalDateTime(1984, 1, 11, 4, 5, 6));
  });

  test('default time', () {
    var rule = TimeChangeRule((b) => b
      ..month = 1
      ..week = 3
      ..day = Weekday.sunday);
    expect(rule.forYear(1984), LocalDateTime(1984, 1, 15, 2));
  });

  group('5 = last week:', () {
    test('without 5th week', () {
      // Jan 2023 has 4 Thursdays. The 26th is the last one. If 5 weeks gets
      // blindly added, this would return a day in February.
      var rule = TimeChangeRule((b) => b
        ..month = 1
        ..week = 5
        ..day = Weekday.thursday);
      expect(rule.forYear(2023), LocalDateTime(2023, 1, 26, 2));
    });

    test('with 5th week', () {
      // March 2023 has 5 Wednesdays. The 29th is the 5th one, which is what
      // should be returned.
      var rule = TimeChangeRule((b) => b
        ..month = 3
        ..week = 5
        ..day = Weekday.wednesday);
      expect(rule.forYear(2023), LocalDateTime(2023, 3, 29, 2));
    });
  });
}
