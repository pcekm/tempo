import 'dart:io';

import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  group('Constructors and basic getters:', () {
    test('Default', () {
      var d = LocalDate(2000, 1, 2);
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
    });

    test('Invalid dates', () {
      expect(() => LocalDate(1999, 0, 1), throwsArgumentError);
      expect(() => LocalDate(1999, 13, 1), throwsArgumentError);
      expect(() => LocalDate(1999, 1, 0), throwsArgumentError);
      expect(() => LocalDate(1999, 1, 1), returnsNormally);
      expect(() => LocalDate(1999, 1, 31), returnsNormally);
      expect(() => LocalDate(1999, 2, 29), throwsArgumentError);
      expect(() => LocalDate(2000, 2, 29), returnsNormally);
      expect(() => LocalDate(2000, 2, 30), throwsArgumentError);
      expect(() => LocalDate(1999, 3, 31), returnsNormally);
      expect(() => LocalDate(1999, 3, 32), throwsArgumentError);
      expect(() => LocalDate(1999, 4, 30), returnsNormally);
      expect(() => LocalDate(1999, 4, 31), throwsArgumentError);
      expect(() => LocalDate(1999, 5, 31), returnsNormally);
      expect(() => LocalDate(1999, 5, 32), throwsArgumentError);
      expect(() => LocalDate(1999, 6, 30), returnsNormally);
      expect(() => LocalDate(1999, 6, 31), throwsArgumentError);
      expect(() => LocalDate(1999, 7, 31), returnsNormally);
      expect(() => LocalDate(1999, 7, 32), throwsArgumentError);
      expect(() => LocalDate(1999, 8, 31), returnsNormally);
      expect(() => LocalDate(1999, 8, 32), throwsArgumentError);
      expect(() => LocalDate(1999, 9, 30), returnsNormally);
      expect(() => LocalDate(1999, 9, 31), throwsArgumentError);
      expect(() => LocalDate(1999, 10, 31), returnsNormally);
      expect(() => LocalDate(1999, 10, 32), throwsArgumentError);
      expect(() => LocalDate(1999, 11, 30), returnsNormally);
      expect(() => LocalDate(1999, 11, 31), throwsArgumentError);
      expect(() => LocalDate(1999, 12, 31), returnsNormally);
      expect(() => LocalDate(1999, 12, 32), throwsArgumentError);
    });

    test('fromDateTime()', () {
      var d = LocalDate.fromDateTime(DateTime(2000, 1, 2));
      expect(d.year, 2000, reason: 'Year mismatch');
      expect(d.month, 1, reason: 'Month mismatch');
      expect(d.day, 2, reason: 'Day mismatch');
    });

    test('now() smoke test', () {
      var d = LocalDate.now();
      expect(d.year, greaterThanOrEqualTo(2023));
    });
  });

  group('replace()', () {
    test('year', () {
      expect(LocalDate(2023, 1, 2).replace(year: 1998), LocalDate(1998, 1, 2));
    });

    test('month', () {
      expect(LocalDate(2023, 1, 2).replace(month: 11), LocalDate(2023, 11, 2));
    });

    test('day', () {
      expect(LocalDate(2023, 1, 2).replace(day: 31), LocalDate(2023, 1, 31));
    });

    test('combined', () {
      expect(LocalDate(2023, 1, 2).replace(year: 1985, month: 7, day: 19),
          LocalDate(1985, 7, 19));
    });

    test('day adjustment, shorter month', () {
      expect(LocalDate(2023, 1, 31).replace(month: 6), LocalDate(2023, 6, 30));
    });

    test('day adjustment, leap year', () {
      expect(
          LocalDate(2000, 2, 29).replace(year: 2001), LocalDate(2001, 2, 28));
    });
  });

  group('Comparison operator', () {
    test('== (and hash equality)', () {
      var d1 = LocalDate(2000, 1, 2);
      var d2 = LocalDate(2000, 1, 2);
      expect(d1, d2);
      expect(d1.hashCode, d2.hashCode, reason: 'Hash mismatch');
    });

    test('!= (and hash inequality)', () {
      var d1 = LocalDate(2000, 1, 2);
      var d2 = LocalDate(20001, 1, 3);
      expect(d1, isNot(equals(d2)));
      expect(d1.hashCode, isNot(equals(d2.hashCode)), reason: 'Hashes equal');
    });

    test('>', () {
      var d1 = LocalDate(2000, 1, 2);
      var d2 = LocalDate(2000, 1, 1);
      expect(d1 > d2, true);
      expect(d1 > d1, false);
    });

    test('>=', () {
      var d1 = LocalDate(2000, 1, 2);
      var d2 = LocalDate(2000, 1, 1);
      expect(d1 >= d2, true);
      expect(d1 >= d1, true);
    });

    test('<', () {
      var d1 = LocalDate(2000, 1, 1);
      var d2 = LocalDate(2000, 1, 2);
      expect(d1 < d2, true);
      expect(d1 < d1, false);
    });

    test('<=', () {
      var d1 = LocalDate(2000, 1, 1);
      var d2 = LocalDate(2000, 1, 2);
      expect(d1 <= d2, true);
      expect(d1 <= d1, true);
    });
  });

  test('weekday', () {
    // A date which will live in infamy.
    expect(LocalDate(1941, 12, 7).weekday, Weekday.sunday);
    expect(LocalDate(2023, 4, 10).weekday, Weekday.monday);
    expect(LocalDate(2023, 4, 11).weekday, Weekday.tuesday);
    expect(LocalDate(2023, 4, 12).weekday, Weekday.wednesday);
    expect(LocalDate(2023, 4, 13).weekday, Weekday.thursday);
    expect(LocalDate(2023, 4, 14).weekday, Weekday.friday);
    expect(LocalDate(2023, 4, 15).weekday, Weekday.saturday);
    expect(LocalDate(2023, 4, 16).weekday, Weekday.sunday);
  });

  test('toString()', () {
    expect(LocalDate(2023, 4, 10).toString(), '2023-04-10');
    expect(LocalDate(1).toString(), '0001-01-01');
    expect(LocalDate(0).toString(), '+0000-01-01'); // 1 BC
    expect(LocalDate(-2000).toString(), '-2000-01-01');
    expect(LocalDate(9999).toString(), '9999-01-01');
    expect(LocalDate(10000).toString(), '+10000-01-01');
  });

  test('ordinalDay', () {
    expect(LocalDate(2023, 4, 10).ordinalDay, 100);
    expect(LocalDate(2023, 1, 1).ordinalDay, 1);
    expect(LocalDate(2023, 12, 31).ordinalDay, 365);
  });

  test('isLeapYear', () {
    expect(LocalDate(1900).isLeapYear, false, reason: 'year = 1900');
    expect(LocalDate(1904).isLeapYear, true, reason: 'year = 1904');
    expect(LocalDate(1996).isLeapYear, true, reason: 'year = 1996');
    expect(LocalDate(1997).isLeapYear, false, reason: 'year = 1997');
    expect(LocalDate(2000).isLeapYear, true, reason: 'year = 2000');
  });

  group('Timespan arithmetic:', () {
    test('plusTimespan()', () {
      expect(LocalDate(2000).plusTimespan(Timespan(days: 1)),
          LocalDate(2000, 1, 2));
      expect(LocalDate(2000).plusTimespan(Timespan(days: -1)),
          LocalDate(1999, 12, 31));
      expect(
          LocalDate(2000).plusTimespan(Timespan(hours: 23)), LocalDate(2000));
      expect(LocalDate(2000).plusTimespan(Timespan(hours: -23)),
          LocalDate(1999, 12, 31));
      expect(LocalDate(2000).plusTimespan(Timespan(seconds: -1)),
          LocalDate(1999, 12, 31));
    });

    test('minusTimespan()', () {
      expect(LocalDate(2000).minusTimespan(Timespan(days: 1)),
          LocalDate(1999, 12, 31));
      expect(LocalDate(2000).minusTimespan(Timespan(days: -1)),
          LocalDate(2000, 1, 2));
      expect(
          LocalDate(2000).minusTimespan(Timespan(hours: -23)), LocalDate(2000));
      expect(LocalDate(2000).minusTimespan(Timespan(hours: 23)),
          LocalDate(1999, 12, 31));
      expect(LocalDate(2000).minusTimespan(Timespan(seconds: 1)),
          LocalDate(1999, 12, 31));
    });
  });

  group('Period arithmetic:', () {
    test('single fields', () {
      var d = LocalDate(2001, 2, 3);
      expect(d.plusPeriod(Period(days: 1)), LocalDate(2001, 2, 4));
      expect(d.plusPeriod(Period(days: 28)), LocalDate(2001, 3, 3));
      expect(d.plusPeriod(Period(months: 1)), LocalDate(2001, 3, 3));
      expect(d.plusPeriod(Period(months: 12)), LocalDate(2002, 2, 3));
      expect(d.plusPeriod(Period(years: 4)), LocalDate(2005, 2, 3));
    });

    test('negative single fields', () {
      var d = LocalDate(2001, 2, 3);
      expect(d.plusPeriod(Period(days: -1)), LocalDate(2001, 2, 2));
      expect(d.plusPeriod(Period(days: -3)), LocalDate(2001, 1, 31));
      expect(d.plusPeriod(Period(months: -1)), LocalDate(2001, 1, 3));
      expect(d.plusPeriod(Period(months: -12)), LocalDate(2000, 2, 3));
      expect(d.plusPeriod(Period(years: -4)), LocalDate(1997, 2, 3));
    });

    test('order of operations', () {
      expect(LocalDate(2023, 1, 31).plusPeriod(Period(months: 1, days: 1)),
          LocalDate(2023, 3, 1));
    });

    test('months increment year', () {
      var d = LocalDate(2000, 12, 1);
      expect(d.plusPeriod(Period(months: 1)), LocalDate(2001, 1, 1));
    });

    test('months decrement year', () {
      var d = LocalDate(2001, 1, 1);
      expect(d.plusPeriod(Period(months: -1)), LocalDate(2000, 12, 1));
    });

    test('month clamping', () {
      var d = LocalDate(1999, 1, 31);
      expect(d.plusPeriod(Period(months: 1)), LocalDate(1999, 2, 28));
      expect(d.plusPeriod(Period(months: -2)), LocalDate(1998, 11, 30));
      expect(d.plusPeriod(Period(years: 1, months: 1)), LocalDate(2000, 2, 29));
    });
  });

  group('periodUntil():', () {
    test('simple positive cases', () {
      expect(
          LocalDate(2023, 4, 10).periodUntil(LocalDate(2023, 4, 10)), Period());
      expect(LocalDate(2022, 4, 10).periodUntil(LocalDate(2023, 4, 10)),
          Period(years: 1));
      expect(LocalDate(2023, 3, 10).periodUntil(LocalDate(2023, 4, 10)),
          Period(months: 1));
      expect(LocalDate(2023, 4, 9).periodUntil(LocalDate(2023, 4, 10)),
          Period(days: 1));
    });

    test('simple negative cases', () {
      expect(LocalDate(2023, 4, 10).periodUntil(LocalDate(2022, 4, 10)),
          Period(years: -1));
      expect(LocalDate(2023, 4, 10).periodUntil(LocalDate(2023, 3, 10)),
          Period(months: -1));
      expect(LocalDate(2023, 4, 10).periodUntil(LocalDate(2023, 4, 9)),
          Period(days: -1));
    });

    test('months and days', () {
      expect(LocalDate(2000, 1, 1).periodUntil(LocalDate(2000, 3, 2)),
          Period(months: 2, days: 1));
      expect(LocalDate(2000, 3, 2).periodUntil(LocalDate(2000, 1, 1)),
          Period(months: -2, days: -1));
    });

    test('year boundaries', () {
      expect(LocalDate(2022, 12, 31).periodUntil(LocalDate(2023, 1, 1)),
          Period(days: 1));
      expect(LocalDate(2023, 1, 1).periodUntil(LocalDate(2022, 12, 31)),
          Period(days: -1));
    });

    test('ragged month ends, shorter second', () {
      expect(LocalDate(2023, 5, 31).periodUntil(LocalDate(2023, 6, 30)),
          Period(days: 30));
      expect(LocalDate(2023, 6, 30).periodUntil(LocalDate(2023, 5, 31)),
          Period(days: -30));
    });

    test('ragged month ends, shorter first', () {
      expect(LocalDate(2023, 6, 30).periodUntil(LocalDate(2023, 7, 31)),
          Period(months: 1, days: 1));
      expect(LocalDate(2023, 7, 31).periodUntil(LocalDate(2023, 6, 30)),
          Period(months: -1, days: -1));
    });

    test('days between mid shorter to mid longer month', () {
      expect(LocalDate(2022, 6, 10).periodUntil(LocalDate(2023, 12, 13)),
          Period(years: 1, months: 6, days: 3));
      expect(LocalDate(2022, 6, 10).periodUntil(LocalDate(2023, 3, 13)),
          Period(months: 9, days: 3));
      expect(LocalDate(2022, 2, 10).periodUntil(LocalDate(2023, 3, 13)),
          Period(years: 1, months: 1, days: 3));
      expect(LocalDate(2022, 2, 10).periodUntil(LocalDate(2023, 3, 29)),
          Period(years: 1, months: 1, days: 19));
      expect(LocalDate(2023, 12, 13).periodUntil(LocalDate(2022, 6, 10)),
          Period(years: -1, months: -6, days: -3));
      expect(LocalDate(2023, 3, 13).periodUntil(LocalDate(2022, 6, 10)),
          Period(months: -9, days: -3));
      expect(LocalDate(2023, 3, 13).periodUntil(LocalDate(2022, 2, 10)),
          Period(years: -1, months: -1, days: -3));
      expect(LocalDate(2023, 3, 29).periodUntil(LocalDate(2022, 2, 10)),
          Period(years: -1, months: -1, days: -19));
    });

    test('days between mid longer to mid shorter month', () {
      expect(LocalDate(2022, 7, 10).periodUntil(LocalDate(2023, 11, 13)),
          Period(years: 1, months: 4, days: 3));
      expect(LocalDate(2022, 7, 10).periodUntil(LocalDate(2023, 6, 13)),
          Period(months: 11, days: 3));
      expect(LocalDate(2022, 7, 10).periodUntil(LocalDate(2023, 2, 13)),
          Period(months: 7, days: 3));
      expect(LocalDate(2022, 7, 28).periodUntil(LocalDate(2023, 2, 13)),
          Period(months: 6, days: 16));
      expect(LocalDate(2023, 11, 13).periodUntil(LocalDate(2022, 7, 10)),
          Period(years: -1, months: -4, days: -3));
      expect(LocalDate(2023, 6, 13).periodUntil(LocalDate(2022, 7, 10)),
          Period(months: -11, days: -3));
      expect(LocalDate(2023, 2, 13).periodUntil(LocalDate(2022, 7, 10)),
          Period(months: -7, days: -3));
      expect(LocalDate(2023, 2, 13).periodUntil(LocalDate(2022, 7, 28)),
          Period(months: -6, days: -16));
    });

    test('leap years', () {
      expect(LocalDate(2000, 1, 31).periodUntil(LocalDate(2000, 2, 29)),
          Period(days: 29));
      expect(LocalDate(2000, 2, 29).periodUntil(LocalDate(2000, 1, 31)),
          Period(days: -29));
      expect(LocalDate(2000, 2, 29).periodUntil(LocalDate(2000, 3, 1)),
          Period(days: 1));
      expect(LocalDate(2000, 3, 1).periodUntil(LocalDate(2000, 2, 29)),
          Period(days: -1));
    });

    // Regression test of a weird bug that was rather hard to trigger.
    test('weird regression', () {
      expect(LocalDate(1985, 4, 20).periodUntil(LocalDate(1986, 2, 9)),
          Period(months: 9, days: 20));
      expect(LocalDate(1999, 1, 2).periodUntil(LocalDate(1999, 3, 1)),
          Period(months: 1, days: 27));
    });

    test('long period', () {
      expect(LocalDate(1910, 4, 20).periodUntil(LocalDate(1986, 2, 9)),
          Period(years: 75, months: 9, days: 20));
      expect(LocalDate(1986, 2, 9).periodUntil(LocalDate(1910, 4, 20)),
          Period(years: -75, months: -9, days: -20));
    });

    test('doc examples', () {
      expect(
          LocalDate(2000, 1, 1).periodUntil(LocalDate(2000, 3, 2)) ==
              Period(months: 2, days: 1),
          true);
      expect(
          LocalDate(2000, 3, 2).periodUntil(LocalDate(2000, 1, 1)) ==
              Period(months: -2, days: -1),
          true);
      expect(
          LocalDate(2000, 1, 2).periodUntil(LocalDate(2000, 3, 1)) ==
              Period(months: 1, days: 28),
          true);
      expect(
          LocalDate(2001, 1, 2).periodUntil(LocalDate(2001, 3, 1)) ==
              Period(months: 1, days: 27),
          true);
      expect(
          LocalDate(2000, 1, 1).periodUntil(LocalDate(2010, 2, 3)) ==
              Period(years: 10, months: 1, days: 2),
          true);
    });

    // This is excluded by default. To run it use 'dart test -P all'
    test('golden file', () {
      var dateRe = RegExp(r'(\d+)-(\d+)-(\d+)');
      var periodRe = RegExp(r'P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)D)?');
      var file = File('test/goodtime/localdate_period_until_testcases.txt');
      for (var line in file.readAsLinesSync()) {
        var parts = line.split(' ');
        var d1Match = dateRe.firstMatch(parts[0]);
        var d1 = LocalDate(int.parse(d1Match!.group(1)!),
            int.parse(d1Match.group(2)!), int.parse(d1Match.group(3)!));
        var d2Match = dateRe.firstMatch(parts[1]);
        var d2 = LocalDate(int.parse(d2Match!.group(1)!),
            int.parse(d2Match.group(2)!), int.parse(d2Match.group(3)!));
        var periodMatch = periodRe.firstMatch(parts[2]);
        var want = Period(
            years: int.parse(periodMatch!.group(1) ?? '0'),
            months: int.parse(periodMatch.group(2) ?? '0'),
            days: int.parse(periodMatch.group(3) ?? '0'));
        if (d1 == d2) {
          continue;
        }
        expect(d1.periodUntil(d2), want, reason: '$d1 until $d2');
        expect(d2.periodUntil(d1), -want, reason: '$d2 until $d1');
      }
    }, tags: ['slow']);
  });

  test('timespanUntil()', () {
    expect(LocalDate(2000).timespanUntil(LocalDate(2001)), Timespan(days: 366));
    expect(LocalDate(2001).timespanUntil(LocalDate(2002)), Timespan(days: 365));
    expect(LocalDate(2000).timespanUntil(LocalDate(1999, 12, 1)),
        Timespan(days: -31));
  });
}
