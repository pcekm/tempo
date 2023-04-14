import 'package:goodtime/src/util.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

const int _wholeDay = 86400;
const int _halfDay = 86400 ~/ 2;

void main() {
  group('Julian Days:', () {
    test('checkLeapYear()', () {
      expect(checkLeapYear(2023), false);
      expect(checkLeapYear(2024), true); // modulo 4 rule
      expect(checkLeapYear(1900), false); // modulo 100 rule
      expect(checkLeapYear(2000), true); // modulo 400 rule
    });

    test('daysInMonth()', () {
      expect(daysInMonth(2023, 1), 31);
      expect(daysInMonth(2023, 2), 28);
      expect(daysInMonth(2024, 2), 29);
      expect(daysInMonth(2024, 12), 31);
    });

    test('epochSecondsToDay()', () {
      expect(epochSecondsToDay(0), 0);
      expect(epochSecondsToDay(1), 0);
      expect(epochSecondsToDay(_wholeDay - 1), 0);
      expect(epochSecondsToDay(_wholeDay), 1);
      expect(epochSecondsToDay(2 * _wholeDay - 1), 1);
      expect(epochSecondsToDay(2 * _wholeDay), 2);

      expect(epochSecondsToDay(-1), -1);
      expect(epochSecondsToDay(-_wholeDay + 1), -1);
      expect(epochSecondsToDay(-_wholeDay), -2);
      expect(epochSecondsToDay(-2 * _wholeDay + 1), -2);
      expect(epochSecondsToDay(-2 * _wholeDay), -3);
    });

    test('gregorianToJulianDaySeconds()', () {
      expect(gregorianToJulianDaySeconds(-4713, 11, 24), 0);
      expect(gregorianToJulianDaySeconds(-4713, 11, 24, 12), 0);
      expect(gregorianToJulianDaySeconds(-4713, 11, 24, 13), 3600);
      expect(gregorianToJulianDaySeconds(-4713, 11, 24, 12, 1), 60);
      expect(gregorianToJulianDaySeconds(-4713, 11, 24, 12, 0, 1), 1);

      expect(gregorianToJulianDaySeconds(-4713, 11, 24, 11), -3600);
      expect(gregorianToJulianDaySeconds(-4713, 11, 24, 11, 59), -60);
      expect(gregorianToJulianDaySeconds(-4713, 11, 24, 11, 59, 59), -1);

      // Some important epoch dates.
      // Source: Baum, Peter. (2017). Date Algorithms.
      expect(gregorianToJulianDaySeconds(1, 1, 1, 0),
          1721425 * _wholeDay + _halfDay,
          reason: 'Rata Die epoch, 0001-01-01');
      expect(gregorianToJulianDaySeconds(1582, 10, 15, 0),
          2299160 * _wholeDay + _halfDay,
          reason: 'Gregorian reform, 1582-10-15');
      expect(gregorianToJulianDaySeconds(1970, 1, 1, 0),
          2440587 * _wholeDay + _halfDay,
          reason: 'Unix epoch, 1970-01-01');
    });

    test('julianDaySecondsToGregorian()', () {
      expect(julianDaySecondsToGregorian(0),
          Tuple6<int, int, int, int, int, int>(-4713, 11, 24, 12, 0, 0));
      expect(julianDaySecondsToGregorian(3600),
          Tuple6<int, int, int, int, int, int>(-4713, 11, 24, 13, 0, 0));
      expect(julianDaySecondsToGregorian(60),
          Tuple6<int, int, int, int, int, int>(-4713, 11, 24, 12, 1, 0));
      expect(julianDaySecondsToGregorian(1),
          Tuple6<int, int, int, int, int, int>(-4713, 11, 24, 12, 0, 1));

      expect(julianDaySecondsToGregorian(-3600),
          Tuple6<int, int, int, int, int, int>(-4713, 11, 24, 11, 0, 0));
      expect(julianDaySecondsToGregorian(-60),
          Tuple6<int, int, int, int, int, int>(-4713, 11, 24, 11, 59, 0));
      expect(julianDaySecondsToGregorian(-1),
          Tuple6<int, int, int, int, int, int>(-4713, 11, 24, 11, 59, 59));

      // Some important epoch dates.
      // Source: Baum, Peter. (2017). Date Algorithms.
      expect(julianDaySecondsToGregorian(1721425 * _wholeDay + _halfDay),
          Tuple6<int, int, int, int, int, int>(1, 1, 1, 0, 0, 0),
          reason: 'Rata Die epoch, 0001-01-01');
      expect(julianDaySecondsToGregorian(2299160 * _wholeDay + _halfDay),
          Tuple6<int, int, int, int, int, int>(1582, 10, 15, 0, 0, 0),
          reason: 'Gregorian reform, 1582-10-15');
      expect(julianDaySecondsToGregorian(2440587 * _wholeDay + _halfDay),
          Tuple6<int, int, int, int, int, int>(1970, 1, 1, 0, 0, 0),
          reason: 'Unix epoch, 1970-01-01');
    });

    test('Bidirectional conversion -9999-01-01 to +9999-12-31 inclusive', () {
      const int start = -1930999; // -9999-01-01
      const int end = 5373484; // 10000-01-01
      for (int jd = start; jd < end; ++jd) {
        var date = julianDaySecondsToGregorian(jd * _wholeDay + _halfDay);
        var gotJD = gregorianToJulianDaySeconds(date.item1, date.item2,
            date.item3, date.item4, date.item5, date.item6);
        expect((gotJD - _halfDay) ~/ _wholeDay, jd);
      }
    });
  });

  test('gregorianToRataDieSeconds()', () {
    expect(gregorianToRataDieSeconds(1, 1, 1), _wholeDay);
    expect(gregorianToRataDieSeconds(2000, 12, 20), 730474 * _wholeDay);
    expect(gregorianToRataDieSeconds(0, 1, 1), -365 * _wholeDay);
  });

  test('rataDieSecondsToGregorian()', () {
    expect(rataDieSecondsToGregorian(_wholeDay),
        Tuple6<int, int, int, int, int, int>(1, 1, 1, 0, 0, 0));
    expect(rataDieSecondsToGregorian(730474 * _wholeDay),
        Tuple6<int, int, int, int, int, int>(2000, 12, 20, 0, 0, 0));
    expect(rataDieSecondsToGregorian(-365 * _wholeDay),
        Tuple6<int, int, int, int, int, int>(0, 1, 1, 0, 0, 0));
  });
}
