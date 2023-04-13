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

    test('wrapping times', () {
      expect(LocalDateTime(2000, 1, 1, 49), LocalDateTime(2000, 1, 3, 1));
      expect(LocalDateTime(2000, 1, 1, 25), LocalDateTime(2000, 1, 2, 1));
      expect(LocalDateTime(2000, 1, 1, 24, 1), LocalDateTime(2000, 1, 2, 0, 1));
      expect(LocalDateTime(2000, 1, 1, 24, 0, 1),
          LocalDateTime(2000, 1, 2, 0, 0, 1));
      expect(LocalDateTime(2000, 1, 1, 24, 0, 0, 1),
          LocalDateTime(2000, 1, 2, 0, 0, 0, 1));
      expect(LocalDateTime(2000, 1, 1, 24, 0, 0, 0, 1),
          LocalDateTime(2000, 1, 2, 0, 0, 0, 0, 1));

      expect(LocalDateTime(2000, 1, 1, 0, 0, 0, 0, -1),
          LocalDateTime(1999, 12, 31, 23, 59, 59, 999, 999));
      expect(LocalDateTime(2000, 1, 1, 0, 0, 0, -1),
          LocalDateTime(1999, 12, 31, 23, 59, 59, 999));
      expect(LocalDateTime(2000, 1, 1, 0, 0, -1),
          LocalDateTime(1999, 12, 31, 23, 59, 59));
      expect(LocalDateTime(2000, 1, 1, 0, -1),
          LocalDateTime(1999, 12, 31, 23, 59));
      expect(LocalDateTime(2000, 1, 1, -1), LocalDateTime(1999, 12, 31, 23));
      expect(LocalDateTime(2000, 1, 1, -24), LocalDateTime(1999, 12, 30));
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

    test('combine()', () {
      var d = LocalDateTime.combine(
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

  test('minimum and maximum', () {
    expect(LocalDateTime.minimum.toString(), '-4713-11-24T00:00:00.000000');
    expect(LocalDateTime.safeMaximum.toString(),
        '+24660873948184-12-03T23:59:59.999999');
  });

  group('weekday', () {
    // In the current implementation, morning and afternoon aren't treated
    // any differently. But in case some future me decides to switch to
    // fractional Julian days, test both.

    test('morning', () {
      // A date which will live in infamy.
      expect(LocalDateTime(1941, 12, 7).weekday, Weekday.sunday);
      expect(LocalDateTime(2023, 4, 10).weekday, Weekday.monday);
      expect(LocalDateTime(2023, 4, 11).weekday, Weekday.tuesday);
      expect(LocalDateTime(2023, 4, 12).weekday, Weekday.wednesday);
      expect(LocalDateTime(2023, 4, 13).weekday, Weekday.thursday);
      expect(LocalDateTime(2023, 4, 14).weekday, Weekday.friday);
      expect(LocalDateTime(2023, 4, 15).weekday, Weekday.saturday);
      expect(LocalDateTime(2023, 4, 16).weekday, Weekday.sunday);
    });

    test('afternoon', () {
      // A date which will live in infamy.
      expect(LocalDateTime(1941, 12, 7, 12).weekday, Weekday.sunday);
      expect(LocalDateTime(2023, 4, 10, 12).weekday, Weekday.monday);
      expect(LocalDateTime(2023, 4, 11, 12).weekday, Weekday.tuesday);
      expect(LocalDateTime(2023, 4, 12, 12).weekday, Weekday.wednesday);
      expect(LocalDateTime(2023, 4, 13, 12).weekday, Weekday.thursday);
      expect(LocalDateTime(2023, 4, 14, 12).weekday, Weekday.friday);
      expect(LocalDateTime(2023, 4, 15, 12).weekday, Weekday.saturday);
      expect(LocalDateTime(2023, 4, 16, 12).weekday, Weekday.sunday);
    });
  });

  group('addition operator:', () {
    test('Duration', () {
      var d = LocalDateTime(2000);
      expect(d + Duration(seconds: 1), LocalDateTime(2000, 1, 1, 0, 0, 1));
      expect(d + Duration(days: 1, seconds: 1),
          LocalDateTime(2000, 1, 2, 0, 0, 1));
      expect(
          d + Duration(seconds: -1), LocalDateTime(1999, 12, 31, 23, 59, 59));
      expect(d + Duration(days: -1, seconds: -1),
          LocalDateTime(1999, 12, 30, 23, 59, 59));
    });

    test('Period', () {
      var d = LocalDateTime(2000);
      expect(d + Period(months: 1), LocalDateTime(2000, 2));
      expect(d + Period(months: -1), LocalDateTime(1999, 12));
    });
  });

  group('Comparison operator', () {
    test('== (and hash code)', () {
      var d1 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6, 7);
      var d2 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6, 7);
      expect(d1, d2);
      expect(d1.hashCode, d2.hashCode, reason: 'Hash mismatch');
    });

    test('!= (and hash code)', () {
      var d1 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6, 7);
      var d2 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6, 8);
      expect(d1, isNot(equals(d2)));
      expect(d1.hashCode, isNot(equals(d2.hashCode)), reason: 'Hashes match');
    });

    test('> — different day', () {
      var d1 = LocalDateTime(2000, 1, 2, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      expect(d1 > d2, true);
      expect(d1 > d1, false);
    });

    test('> — different time', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 2);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      expect(d1 > d2, true);
      expect(d1 > d1, false);
    });

    test('>= — different day', () {
      var d1 = LocalDateTime(2000, 1, 2, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      expect(d1 >= d2, true);
      expect(d1 >= d1, true);
    });

    test('>= — different time', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 2);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      expect(d1 >= d2, true);
      expect(d1 >= d1, true);
    });

    test('< — different day', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 2, 0, 0, 0, 1);
      expect(d1 < d2, true);
      expect(d1 < d1, false);
    });

    test('< — different time', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 2);
      expect(d1 < d2, true);
      expect(d1 < d1, false);
    });

    test('<= — different day', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 2, 0, 0, 0, 1);
      expect(d1 <= d2, true);
      expect(d1 <= d1, true);
    });

    test('<= — different time', () {
      var d1 = LocalDateTime(2000, 1, 1, 0, 0, 0, 1);
      var d2 = LocalDateTime(2000, 1, 1, 0, 0, 0, 2);
      expect(d1 <= d2, true);
      expect(d1 <= d1, true);
    });
  });

  test('toString()', () {
    expect(LocalDateTime(2023, 4, 10, 1, 2, 3, 4, 5).toString(),
        '2023-04-10T01:02:03.004005');
    expect(LocalDateTime(1).toString(), '0001-01-01T00:00:00.000000');
    expect(LocalDateTime(0).toString(), '+0000-01-01T00:00:00.000000'); // 1 BC
    expect(LocalDateTime(-4711).toString(), '-4711-01-01T00:00:00.000000');
    expect(LocalDateTime(9999).toString(), '9999-01-01T00:00:00.000000');
    expect(LocalDateTime(10000).toString(), '+10000-01-01T00:00:00.000000');
  });
}
