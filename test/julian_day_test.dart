import 'package:tuple/tuple.dart';
import 'package:test/test.dart';
import 'package:goodtime/src/julian_day.dart';

const int nano = 1000000000;
const int dayNano = 86400 * nano;
const int halfDayNano = dayNano ~/ 2;

class HasDayFraction extends CustomMatcher {
  HasDayFraction(day, fraction)
      : super('JulianDay with [day, fraction]', '[day, fraction]',
            [day, fraction]);
  featureValueOf(actual) {
    var jd = actual as JulianDay;
    return [jd.day, jd.fraction];
  }
}

void main() {
  test('Default Constructor', () {
    expect(JulianDay(), HasDayFraction(0, 0));
    expect(JulianDay(0, 1), HasDayFraction(0, 1));
    expect(JulianDay(0, halfDayNano), HasDayFraction(0, halfDayNano));
    expect(JulianDay(1), HasDayFraction(1, 0));
    expect(JulianDay(1, 1), HasDayFraction(1, 1));
    expect(JulianDay(1, halfDayNano), HasDayFraction(1, halfDayNano));
    expect(JulianDay(1, dayNano + 1), HasDayFraction(2, 1));
    expect(JulianDay(1, 2 * dayNano + 1), HasDayFraction(3, 1));

    expect(JulianDay(0, -1), HasDayFraction(-1, dayNano - 1));
    expect(JulianDay(0, -halfDayNano), HasDayFraction(-1, halfDayNano));
    expect(JulianDay(0, -dayNano + 1), HasDayFraction(-1, 1));
    expect(JulianDay(-1), HasDayFraction(-1, 0));
    expect(JulianDay(-1, -1), HasDayFraction(-2, dayNano - 1));
    expect(JulianDay(-1, 1), HasDayFraction(-1, 1));
    expect(JulianDay(-1, -(dayNano + 1)), HasDayFraction(-3, dayNano - 1));
    expect(JulianDay(-1, -(2 * dayNano + 1)), HasDayFraction(-4, dayNano - 1));
  });

  group('toGregorian()', () {
    test('small positive', () {
      expect(JulianDay().toGregorian(), Gregorian(-4713, 11, 24, halfDayNano),
          reason: 'JD = 0');
      expect(
          JulianDay(0, halfDayNano).toGregorian(), Gregorian(-4713, 11, 25, 0),
          reason: 'JD = 0.5');
      expect(
          JulianDay(1, 0).toGregorian(), Gregorian(-4713, 11, 25, halfDayNano),
          reason: 'JD = 1');
      expect(
          JulianDay(1, halfDayNano).toGregorian(), Gregorian(-4713, 11, 26, 0),
          reason: 'JD = 1.5');
    });

    test('small negative', () {
      expect(
          JulianDay(-1, halfDayNano).toGregorian(), Gregorian(-4713, 11, 24, 0),
          reason: 'JD = -0.5');
      expect(
          JulianDay(-1, 0).toGregorian(), Gregorian(-4713, 11, 23, halfDayNano),
          reason: 'JD = -1');
      expect(
          JulianDay(-2, halfDayNano).toGregorian(), Gregorian(-4713, 11, 23, 0),
          reason: 'JD = -1.5');
      expect(
          JulianDay(-2, 0).toGregorian(), Gregorian(-4713, 11, 22, halfDayNano),
          reason: 'JD = -2');
    });

    test('range limits', () {
      expect(JulianDay(5373483, halfDayNano).toGregorian(),
          Gregorian(9999, 12, 31));
      expect(JulianDay(-1930999, -halfDayNano).toGregorian(),
          Gregorian(-9999, 1, 1, 0));
    });

    test('important epochs', () {
      // Some important epoch dates.
      // Source: Baum, Peter. (2017). Date Algorithms.
      expect(
          JulianDay(1721425, halfDayNano).toGregorian(), Gregorian(1, 1, 1, 0),
          reason: 'Rata Die epoch, 0001-01-01');
      expect(JulianDay(2299160, halfDayNano).toGregorian(),
          Gregorian(1582, 10, 15, 0),
          reason: 'Gregorian reform, 1582-10-15');
      expect(JulianDay(2440587, halfDayNano).toGregorian(),
          Gregorian(1970, 1, 1, 0),
          reason: 'Unix epoch, 1970-01-01');
    });
  });

  test('fromGregorian()', () {
    expect(JulianDay.fromGregorian(Gregorian(-4713, 11, 24, halfDayNano)),
        JulianDay(0));
    expect(JulianDay.fromGregorian(Gregorian(-4713, 11, 24, 0)),
        JulianDay(0, -halfDayNano));

    // Some important epoch dates.
    // Source: Baum, Peter. (2017). Date Algorithms.
    expect(JulianDay.fromGregorian(Gregorian(1, 1, 1, 0)),
        JulianDay(1721425, halfDayNano),
        reason: 'Rata Die epoch, 0001-01-01');
    expect(JulianDay.fromGregorian(Gregorian(1582, 10, 15, 0)),
        JulianDay(2299160, halfDayNano),
        reason: 'Gregorian reform, 1582-10-15');
    expect(JulianDay.fromGregorian(Gregorian(1970, 1, 1, 0)),
        JulianDay(2440587, halfDayNano),
        reason: 'Unix epoch, 1970-01-01');
  });

  test('Bidirectional conversion -9999-01-01 to +9999-12-31 inclusive', () {
    const int start = -1930999; // -9999-01-01
    const int end = 5373484; // 10000-01-01
    for (int jd = start; jd < end; ++jd) {
      var date = JulianDay(jd).toGregorian();
      var gotJD = JulianDay.fromGregorian(date);
      expect(gotJD, HasDayFraction(jd, 0),
          reason: 'JD = $jd, intermediate = $date');
    }
  }, tags: ['slow']);

  test('toDouble()', () {
    expect(JulianDay(0).toDouble(), 0);
    expect(JulianDay(0, halfDayNano).toDouble(), 0.5);
    expect(JulianDay(0, -halfDayNano).toDouble(), -0.5);
    expect(JulianDay(1721424, halfDayNano).toDouble(), 1721424.5);
  });

  test('toString()', () {
    expect(JulianDay(1, 2, 3).toString(), '[1 + 2 / 3]');
  });
}
