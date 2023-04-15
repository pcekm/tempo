import 'package:fixnum/fixnum.dart';
import 'package:goodtime/src/util.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

final Int64 _micro = Int64(1000000);
final Int64 _wholeDay = Int64(86400) * _micro;
final Int64 _halfDay = _wholeDay ~/ 2;

// Equality matcher that looks for
Matcher eqMicro(int want) =>
    predicate((Int64 n) => n == (_micro * want), 'Int64:<${_micro * want}>');

void main() {
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

  test('epochUsecToDay()', () {
    expect(epochUsecToDay(Int64(0)), 0);
    expect(epochUsecToDay(Int64(1)), 0);
    expect(epochUsecToDay(_wholeDay - 1), 0);
    expect(epochUsecToDay(_wholeDay), 1);
    expect(epochUsecToDay(_wholeDay * 2 - 1), 1);
    expect(epochUsecToDay(_wholeDay * 2), 2);

    expect(epochUsecToDay(Int64(-1)), -1);
    expect(epochUsecToDay(-_wholeDay + 1), -1);
    expect(epochUsecToDay(-_wholeDay), -2);
    expect(epochUsecToDay(_wholeDay * -2 + 1), -2);
    expect(epochUsecToDay(_wholeDay * -2), -3);
  });

  group('Julian Days:', () {
    test('gregorianToJulianDayUsec()', () {
      expect(gregorianToJulianDayUsec(-4713, 11, 24), eqMicro(0));
      expect(gregorianToJulianDayUsec(-4713, 11, 24, 12), eqMicro(0));
      expect(gregorianToJulianDayUsec(-4713, 11, 24, 13), eqMicro(3600));
      expect(gregorianToJulianDayUsec(-4713, 11, 24, 12, 1), eqMicro(60));
      expect(gregorianToJulianDayUsec(-4713, 11, 24, 12, 0, 1), eqMicro(1));

      expect(gregorianToJulianDayUsec(-4713, 11, 24, 11), eqMicro(-3600));
      expect(gregorianToJulianDayUsec(-4713, 11, 24, 11, 59), eqMicro(-60));
      expect(gregorianToJulianDayUsec(-4713, 11, 24, 11, 59, 59), eqMicro(-1));

      // Some important epoch dates.
      // Source: Baum, Peter. (2017). Date Algorithms.
      expect(gregorianToJulianDayUsec(1, 1, 1, 0),
          Int64(1721425) * _wholeDay + _halfDay,
          reason: 'Rata Die epoch, 0001-01-01');
      expect(gregorianToJulianDayUsec(1582, 10, 15, 0),
          Int64(2299160) * _wholeDay + _halfDay,
          reason: 'Gregorian reform, 1582-10-15');
      expect(gregorianToJulianDayUsec(1970, 1, 1, 0),
          Int64(2440587) * _wholeDay + _halfDay,
          reason: 'Unix epoch, 1970-01-01');
    });

    test('julianDayUsecToGregorian()', () {
      expect(
          julianDayUsecToGregorian(Int64(0)),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 12, 0, 0, 0));
      expect(
          julianDayUsecToGregorian(_micro * 3600),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 13, 0, 0, 0));
      expect(
          julianDayUsecToGregorian(_micro * 60),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 12, 1, 0, 0));
      expect(
          julianDayUsecToGregorian(_micro * 1),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 12, 0, 1, 0));
      expect(
          julianDayUsecToGregorian(Int64(1)),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 12, 0, 0, 1));

      expect(
          julianDayUsecToGregorian(_micro * -3600),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 11, 0, 0, 0));
      expect(
          julianDayUsecToGregorian(_micro * -60),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 11, 59, 0, 0));
      expect(
          julianDayUsecToGregorian(_micro * -1),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 11, 59, 59, 0));
      expect(
          julianDayUsecToGregorian(Int64(-1)),
          Tuple7<int, int, int, int, int, int, int>(
              -4713, 11, 24, 11, 59, 59, 999999));

      // Some important epoch dates.
      // Source: Baum, Peter. (2017). Date Algorithms.
      expect(julianDayUsecToGregorian(Int64(1721425) * _wholeDay + _halfDay),
          Tuple7<int, int, int, int, int, int, int>(1, 1, 1, 0, 0, 0, 0),
          reason: 'Rata Die epoch, 0001-01-01');
      expect(julianDayUsecToGregorian(Int64(2299160) * _wholeDay + _halfDay),
          Tuple7<int, int, int, int, int, int, int>(1582, 10, 15, 0, 0, 0, 0),
          reason: 'Gregorian reform, 1582-10-15');
      expect(julianDayUsecToGregorian(Int64(2440587) * _wholeDay + _halfDay),
          Tuple7<int, int, int, int, int, int, int>(1970, 1, 1, 0, 0, 0, 0),
          reason: 'Unix epoch, 1970-01-01');
    });

    test('Bidirectional conversion -9999-01-01 to +9999-12-31 inclusive', () {
      const int start = -1930999; // -9999-01-01
      const int end = 5373484; // 10000-01-01
      for (int jd = start; jd < end; ++jd) {
        var date = julianDayUsecToGregorian(_wholeDay * jd);
        var gotJD = gregorianToJulianDayUsec(date.item1, date.item2, date.item3,
            date.item4, date.item5, date.item6, date.item7);
        expect(gotJD, _wholeDay * jd, reason: 'JD = $jd, intermediate = $date');
      }
    }, tags: ['slow']);
  });

  test('gregorianToRataDieUsec()', () {
    expect(gregorianToRataDieUsec(1, 1, 1), _wholeDay);
    expect(gregorianToRataDieUsec(2000, 12, 20), _wholeDay * 730474);
    expect(gregorianToRataDieUsec(0, 1, 1), _wholeDay * -365);
  });

  test('rataDieUsecToGregorian()', () {
    expect(rataDieUsecToGregorian(_wholeDay),
        Tuple7<int, int, int, int, int, int, int>(1, 1, 1, 0, 0, 0, 0));
    expect(rataDieUsecToGregorian(_wholeDay * 730474),
        Tuple7<int, int, int, int, int, int, int>(2000, 12, 20, 0, 0, 0, 0));
    expect(rataDieUsecToGregorian(_wholeDay * -365),
        Tuple7<int, int, int, int, int, int, int>(0, 1, 1, 0, 0, 0, 0));
  });
}
