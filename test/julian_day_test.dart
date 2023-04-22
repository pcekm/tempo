import 'package:test/test.dart';
import 'package:goodtime/goodtime.dart';
import 'package:goodtime/src/julian_day.dart';

const int nano = 1000000000;
const int dayNano = 86400 * nano;
const int halfDayNano = dayNano ~/ 2;

void main() {
  group('julianDayToGregorian()', () {
    Gregorian jdToGregorian(int day, int hours) =>
        julianDayToGregorian(Timespan(days: day, hours: hours));

    test('small positive', () {
      expect(jdToGregorian(0, 0), Gregorian(-4713, 11, 24, halfDayNano),
          reason: 'JD = 0');
      expect(jdToGregorian(0, 12), Gregorian(-4713, 11, 25, 0),
          reason: 'JD = 0.5');
      expect(jdToGregorian(1, 0), Gregorian(-4713, 11, 25, halfDayNano),
          reason: 'JD = 1');
      expect(jdToGregorian(1, 12), Gregorian(-4713, 11, 26, 0),
          reason: 'JD = 1.5');
    });

    test('small negative', () {
      expect(jdToGregorian(-1, 12), Gregorian(-4713, 11, 24, 0),
          reason: 'JD = -0.5');
      expect(jdToGregorian(-1, 0), Gregorian(-4713, 11, 23, halfDayNano),
          reason: 'JD = -1');
      expect(jdToGregorian(-2, 12), Gregorian(-4713, 11, 23, 0),
          reason: 'JD = -1.5');
      expect(jdToGregorian(-2, 0), Gregorian(-4713, 11, 22, halfDayNano),
          reason: 'JD = -2');
    });

    test('range limits', () {
      expect(jdToGregorian(5373483, 12), Gregorian(9999, 12, 31));
      expect(jdToGregorian(-1930999, -12), Gregorian(-9999, 1, 1, 0));
    });

    test('important epochs', () {
      // Some important epoch dates.
      // Source: Baum, Peter. (2017). Date Algorithms.
      expect(jdToGregorian(1721425, 12), Gregorian(1, 1, 1, 0),
          reason: 'Rata Die epoch, 0001-01-01');
      expect(jdToGregorian(2299160, 12), Gregorian(1582, 10, 15, 0),
          reason: 'Gregorian reform, 1582-10-15');
      expect(jdToGregorian(2440587, 12), Gregorian(1970, 1, 1, 0),
          reason: 'Unix epoch, 1970-01-01');
    });
  });

  test('gregorianToJulianDay()', () {
    expect(gregorianToJulianDay(Gregorian(-4713, 11, 24, halfDayNano)),
        Timespan(days: 0));
    expect(gregorianToJulianDay(Gregorian(-4713, 11, 24, 0)),
        Timespan(days: 0, hours: -12));

    // Some important epoch dates.
    // Source: Baum, Peter. (2017). Date Algorithms.
    expect(gregorianToJulianDay(Gregorian(1, 1, 1, 0)),
        Timespan(days: 1721425, hours: 12),
        reason: 'Rata Die epoch, 0001-01-01');
    expect(gregorianToJulianDay(Gregorian(1582, 10, 15, 0)),
        Timespan(days: 2299160, hours: 12),
        reason: 'Gregorian reform, 1582-10-15');
    expect(gregorianToJulianDay(Gregorian(1970, 1, 1, 0)),
        Timespan(days: 2440587, hours: 12),
        reason: 'Unix epoch, 1970-01-01');
  });

  test('Bidirectional conversion -9999-01-01 to +9999-12-31 inclusive', () {
    const int start = -1930999; // -9999-01-01
    const int end = 5373484; // 10000-01-01
    for (int jd = start; jd < end; ++jd) {
      var date = julianDayToGregorian(Timespan(days: jd));
      var gotJD = gregorianToJulianDay(date);
      expect(gotJD.inDays, jd, reason: 'JD = $jd, intermediate = $date');
    }
  }, tags: ['slow']);

  test('weekdayForJulianDay', () {
    expect(weekdayForJulianDay(Timespan(days: 0, hours: -12)), Weekday.monday);
    expect(weekdayForJulianDay(Timespan(days: 0)), Weekday.monday);
    expect(weekdayForJulianDay(Timespan(days: 0, hours: 12)), Weekday.tuesday);
    expect(weekdayForJulianDay(Timespan(days: 2430335, hours: 12)),
        Weekday.sunday);
    expect(weekdayForJulianDay(Timespan(days: 2460053, hours: 12)),
        Weekday.wednesday);
  });
}
