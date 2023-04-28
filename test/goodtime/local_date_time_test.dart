import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  group('Constructors and basic getters:', () {
    test('Default', () {
      var d = LocalDateTime(2000, 1, 2, 3, 4, 5, 6);
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
      expect(d.hour, 3, reason: 'Hour mismatch');
      expect(d.minute, 4, reason: 'Minute mismatch');
      expect(d.second, 5, reason: 'Second mismatch');
      expect(d.nanosecond, 6, reason: 'Nanosecond mismatch');
    });

    test('wrapping times', () {
      expect(LocalDateTime(2000, 1, 1, 49), LocalDateTime(2000, 1, 3, 1));
      expect(LocalDateTime(2000, 1, 1, 25), LocalDateTime(2000, 1, 2, 1));
      expect(LocalDateTime(2000, 1, 1, 24, 1), LocalDateTime(2000, 1, 2, 0, 1));
      expect(LocalDateTime(2000, 1, 1, 24, 0, 1),
          LocalDateTime(2000, 1, 2, 0, 0, 1));
      expect(LocalDateTime(2000, 1, 1, 24, 0, 0, 1),
          LocalDateTime(2000, 1, 2, 0, 0, 0, 1));

      expect(LocalDateTime(2000, 1, 1, 0, 0, 0, -1),
          LocalDateTime(1999, 12, 31, 23, 59, 59, 999999999));
      expect(LocalDateTime(2000, 1, 1, 0, 0, -1),
          LocalDateTime(1999, 12, 31, 23, 59, 59));
      expect(LocalDateTime(2000, 1, 1, 0, -1),
          LocalDateTime(1999, 12, 31, 23, 59));
      expect(LocalDateTime(2000, 1, 1, -1), LocalDateTime(1999, 12, 31, 23));
      expect(LocalDateTime(2000, 1, 1, -24), LocalDateTime(1999, 12, 31));
    });

    group('fromDateTime()', () {
      test('fromDateTime()', () {
        var d = LocalDateTime.fromDateTime(DateTime(2000, 1, 2, 3, 4, 5, 6));
        expect(d.year, 2000, reason: 'Year mismatch');
        expect(d.month, 1, reason: 'Month mismatch');
        expect(d.day, 2, reason: 'Day mismatch');
        expect(d.hour, 3, reason: 'Hour mismatch');
        expect(d.minute, 4, reason: 'Minute mismatch');
        expect(d.second, 5, reason: 'Second mismatch');
        // JS platforms can't handle more than milliseconds.
        expect(d.nanosecond, 006000000, reason: 'Nanosecond mismatch');
      });

      test('vm platforms', () {
        var d = LocalDateTime.fromDateTime(DateTime(2000, 1, 2, 3, 4, 5, 6, 7));
        expect(d.year, 2000, reason: 'Year mismatch');
        expect(d.month, 1, reason: 'Month mismatch');
        expect(d.day, 2, reason: 'Day mismatch');
        expect(d.hour, 3, reason: 'Hour mismatch');
        expect(d.minute, 4, reason: 'Minute mismatch');
        expect(d.second, 5, reason: 'Second mismatch');
        expect(d.nanosecond, 006007000, reason: 'Nanosecond mismatch');
      }, testOn: '!js');
    });
    test('combine()', () {
      var d =
          LocalDateTime.combine(LocalDate(2000, 1, 2), LocalTime(3, 4, 5, 6));
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
      expect(d.hour, 3, reason: 'Hour mismatch');
      expect(d.minute, 4, reason: 'Minute mismatch');
      expect(d.second, 5, reason: 'Second mismatch');
      expect(d.nanosecond, 6, reason: 'Nanosecond mismatch');
    });

    test('now() smoke test', () {
      var d = LocalDateTime.now();
      expect(d.year, greaterThanOrEqualTo(2023));
    });
  });

  test('replace()', () {
    var dt = LocalDateTime(1, 2, 3, 4, 5, 6, 7);
    var repl = dt.replace(
        year: 7,
        month: 6,
        day: 5,
        hour: 4,
        minute: 3,
        second: 2,
        nanosecond: 1);
    var want = LocalDateTime(7, 6, 5, 4, 3, 2, 1);
    expect(repl, want);
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

  test('toDateTime', () {
    var dt = LocalDateTime(2000, 1, 2, 3, 4, 5, 006007000);
    var want = DateTime(2000, 1, 2, 3, 4, 5, 6, 7);
    expect(dt.toDateTime(), want);
  });

  test('timespanUntil():', () {
    expect(
        LocalDateTime(2000).timespanUntil(LocalDateTime(2001, 1, 1, 0, 0, 1)),
        Timespan(days: 366, seconds: 1));
    expect(
        LocalDateTime(2000).timespanUntil(LocalDateTime(1999, 1, 1, 0, 0, 1)),
        -Timespan(days: 364, hours: 23, minutes: 59, seconds: 59));
  });

  test('plusTimespan', () {
    var d = LocalDateTime(2000);
    expect(d.plusTimespan(Timespan(seconds: 1)),
        LocalDateTime(2000, 1, 1, 0, 0, 1));
    expect(d.plusTimespan(Timespan(days: 1, seconds: 1)),
        LocalDateTime(2000, 1, 2, 0, 0, 1));
    expect(d.plusTimespan(Timespan(nanoseconds: 1)),
        LocalDateTime(2000, 1, 1, 0, 0, 0, 1));
    expect(d.plusTimespan(Timespan(seconds: -1)),
        LocalDateTime(1999, 12, 31, 23, 59, 59));
    expect(d.plusTimespan(Timespan(days: -1, seconds: -1)),
        LocalDateTime(1999, 12, 30, 23, 59, 59));
    expect(d.plusTimespan(Timespan(nanoseconds: -1)),
        LocalDateTime(1999, 12, 31, 23, 59, 59, 999999999));
  });

  test('minusTimespan', () {
    var d = LocalDateTime(2000);
    expect(d.minusTimespan(Timespan(seconds: -1)),
        LocalDateTime(2000, 1, 1, 0, 0, 1));
    expect(d.minusTimespan(Timespan(days: -1, seconds: -1)),
        LocalDateTime(2000, 1, 2, 0, 0, 1));
    expect(d.minusTimespan(Timespan(nanoseconds: -1)),
        LocalDateTime(2000, 1, 1, 0, 0, 0, 1));
    expect(d.minusTimespan(Timespan(seconds: 1)),
        LocalDateTime(1999, 12, 31, 23, 59, 59));
    expect(d.minusTimespan(Timespan(days: 1, seconds: 1)),
        LocalDateTime(1999, 12, 30, 23, 59, 59));
    expect(d.minusTimespan(Timespan(nanoseconds: 1)),
        LocalDateTime(1999, 12, 31, 23, 59, 59, 999999999));
  });

  test('plusPeriod', () {
    var d = LocalDateTime(2000);
    expect(d.plusPeriod(Period(months: 1)), LocalDateTime(2000, 2));
    expect(d.plusPeriod(Period(months: -1)), LocalDateTime(1999, 12));
  });

  test('minusPeriod', () {
    var d = LocalDateTime(2000);
    expect(d.minusPeriod(Period(months: -1)), LocalDateTime(2000, 2));
    expect(d.minusPeriod(Period(months: 1)), LocalDateTime(1999, 12));
  });

  group('Comparison operator', () {
    test('== (and hash code)', () {
      var d1 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6);
      var d2 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6);
      expect(d1, d2);
      expect(d1.hashCode, d2.hashCode, reason: 'Hash mismatch');
    });

    test('!= (and hash code)', () {
      var d1 = LocalDateTime(2000, 1, 2, 3, 4, 5, 6);
      var d2 = LocalDateTime(2000, 1, 2, 3, 4, 5, 7);
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
    expect(LocalDateTime(2023, 4, 10, 1, 2, 3, 4).toString(),
        '2023-04-10T01:02:03.000000004');
    expect(LocalDateTime(1).toString(), '0001-01-01T00:00:00.000000000');
    expect(
        LocalDateTime(0).toString(), '+0000-01-01T00:00:00.000000000'); // 1 BC
    expect(LocalDateTime(-4711).toString(), '-4711-01-01T00:00:00.000000000');
    expect(LocalDateTime(9999).toString(), '9999-01-01T00:00:00.000000000');
    expect(LocalDateTime(10000).toString(), '+10000-01-01T00:00:00.000000000');
  });
}
