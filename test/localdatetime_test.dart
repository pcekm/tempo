import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  group('Constructors and basic getters:', () {
    test('Default', () {
      var d = LocalDateTime(2000, 1, 2, 3, 4, 5, 6, 7);
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
      expect(d.hour, 3, reason: 'Hour mismatch');
      expect(d.minute, 4, reason: 'Minute mismatch');
      expect(d.second, 5, reason: 'Second mismatch');
      expect(d.millisecond, 6, reason: 'Millisecond mismatch');
      expect(d.microsecond, 7, reason: 'Microsecond mismatch');
    });

    test('fromDateTime()', () {
      var d = LocalDateTime.fromDateTime(DateTime(2000, 1, 2, 3, 4, 5, 6, 7));
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
      expect(d.hour, 3, reason: 'Hour mismatch');
      expect(d.minute, 4, reason: 'Minute mismatch');
      expect(d.second, 5, reason: 'Second mismatch');
      expect(d.millisecond, 6, reason: 'Millisecond mismatch');
      expect(d.microsecond, 7, reason: 'Microsecond mismatch');
    });

    test('fromLocals()', () {
      var d = LocalDateTime.fromLocals(
          LocalDate(2000, 1, 2), LocalTime(3, 4, 5, 6, 7));
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
      expect(d.hour, 3, reason: 'Hour mismatch');
      expect(d.minute, 4, reason: 'Minute mismatch');
      expect(d.second, 5, reason: 'Second mismatch');
      expect(d.millisecond, 6, reason: 'Millisecond mismatch');
      expect(d.microsecond, 7, reason: 'Microsecond mismatch');
    });

    test('now() smoke test', () {
      var d = LocalDateTime.now();
      expect(d.year, greaterThanOrEqualTo(2023));
    });
  });

  group('Comparison operator', () {
    test('==', () {
      var d1 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6, 7);
      var d2 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6, 7);
      expect(d1 == d2, true);
    });

    test('> — different Julian seconds', () {
      var d1 = LocalDateTime(2000, 1, 2, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      expect(d1 > d2, true);
      expect(d1 > d1, false);
    });

    test('> — different Julian microseconds', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 2);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      expect(d1 > d2, true);
      expect(d1 > d1, false);
    });

    test('>= — different Julian seconds', () {
      var d1 = LocalDateTime(2000, 1, 2, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      expect(d1 >= d2, true);
      expect(d1 >= d1, true);
    });

    test('>= — different Julian microseconds', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 2);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      expect(d1 >= d2, true);
      expect(d1 >= d1, true);
    });

    test('< — different Julian seconds', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 2, 0, 0, 0, 1);
      expect(d1 < d2, true);
      expect(d1 < d1, false);
    });

    test('< — different Julian microseconds', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 2);
      expect(d1 < d2, true);
      expect(d1 < d1, false);
    });

    test('<= — different Julian seconds', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 2, 0, 0, 0, 1);
      expect(d1 <= d2, true);
      expect(d1 <= d1, true);
    });

    test('<= — different Julian microseconds', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 2);
      expect(d1 <= d2, true);
      expect(d1 <= d1, true);
    });
  });

  group('weekday', () {
    test('morning', () {
      // A date which will live in infamy.
      expect(LocalDateTime(1941, 12, 6).weekday, Weekday.sunday);
      expect(LocalDateTime(2023, 4, 10).weekday, Weekday.monday);
      expect(LocalDateTime(2023, 4, 11).weekday, Weekday.tuesday);
      expect(LocalDateTime(2023, 4, 12).weekday, Weekday.wednesday);
      expect(LocalDateTime(2023, 4, 13).weekday, Weekday.thursday);
      expect(LocalDateTime(2023, 4, 14).weekday, Weekday.friday);
      expect(LocalDateTime(2023, 4, 15).weekday, Weekday.saturday);
      expect(LocalDateTime(2023, 4, 16).weekday, Weekday.sunday);
    });

    test('afternoon', () {
      expect(LocalDateTime(1941, 12, 6, 12).weekday, Weekday.sunday);
      expect(LocalDateTime(2023, 4, 10, 12).weekday, Weekday.monday);
      expect(LocalDateTime(2023, 4, 11, 12).weekday, Weekday.tuesday);
      expect(LocalDateTime(2023, 4, 12, 12).weekday, Weekday.wednesday);
      expect(LocalDateTime(2023, 4, 13, 12).weekday, Weekday.thursday);
      expect(LocalDateTime(2023, 4, 14, 12).weekday, Weekday.friday);
      expect(LocalDateTime(2023, 4, 15, 12).weekday, Weekday.saturday);
      expect(LocalDateTime(2023, 4, 16, 12).weekday, Weekday.sunday);
    });
  });
}
