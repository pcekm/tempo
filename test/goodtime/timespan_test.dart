import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

const int nano = 1000000000;
const int microsecondNano = nano ~/ 1000000;
const int millisecondNano = nano ~/ 1000;
const int secondNano = nano;
const int minuteNano = 60 * nano;
const int hourNano = 3600 * nano;
const int dayNano = 86400 * nano;
const int halfDayNano = dayNano ~/ 2;

class HasDayFraction extends CustomMatcher {
  HasDayFraction(day, fraction)
      : super('Timespan with [day, fraction]', '[day, fraction]',
            [day, fraction]);
  @override
  featureValueOf(actual) {
    var jd = actual as Timespan;
    return [jd.dayPart, jd.nanosecondPart];
  }
}

void main() {
  group('Default constructor', () {
    test('arg conversions', () {
      expect(Timespan(days: 5), HasDayFraction(5, 0));
      expect(Timespan(hours: 5), HasDayFraction(0, 5 * hourNano));
      expect(Timespan(minutes: 5), HasDayFraction(0, 5 * minuteNano));
      expect(Timespan(seconds: 5), HasDayFraction(0, 5 * nano));
      expect(Timespan(milliseconds: 5), HasDayFraction(0, 5 * millisecondNano));
      expect(Timespan(microseconds: 5), HasDayFraction(0, 5 * microsecondNano));
      expect(Timespan(nanoseconds: 5), HasDayFraction(0, 5));
      expect(
          Timespan(
              days: 1,
              hours: 2,
              minutes: 3,
              seconds: 4,
              milliseconds: 5,
              microseconds: 6,
              nanoseconds: 7),
          HasDayFraction(1, 2 * hourNano + 3 * minuteNano + 4005006007));
    });

    test('normalization', () {
      expect(Timespan(), HasDayFraction(0, 0));
      expect(Timespan(days: 0, nanoseconds: 1), HasDayFraction(0, 1));
      expect(Timespan(days: 0, nanoseconds: halfDayNano),
          HasDayFraction(0, halfDayNano));
      expect(Timespan(days: 1), HasDayFraction(1, 0));
      expect(Timespan(days: 1, nanoseconds: 1), HasDayFraction(1, 1));
      expect(Timespan(days: 1, nanoseconds: halfDayNano),
          HasDayFraction(1, halfDayNano));
      expect(Timespan(days: 1, nanoseconds: dayNano + 1), HasDayFraction(2, 1));
      expect(Timespan(days: 1, nanoseconds: 2 * dayNano + 1),
          HasDayFraction(3, 1));

      expect(
          Timespan(days: 10, nanoseconds: -1), HasDayFraction(9, dayNano - 1));

      expect(Timespan(days: 0, nanoseconds: -1), HasDayFraction(0, -1));
      expect(Timespan(days: 0, nanoseconds: -halfDayNano),
          HasDayFraction(0, -halfDayNano));
      expect(Timespan(days: 0, nanoseconds: -dayNano + 1),
          HasDayFraction(0, -dayNano + 1));
      expect(Timespan(days: -1), HasDayFraction(-1, 0));
      expect(Timespan(days: -1, nanoseconds: -1), HasDayFraction(-1, -1));
      expect(
          Timespan(days: -1, nanoseconds: 1), HasDayFraction(0, -dayNano + 1));
      expect(Timespan(days: -1, nanoseconds: -(dayNano + 1)),
          HasDayFraction(-2, -1));
      expect(Timespan(days: -1, nanoseconds: -(2 * dayNano + 1)),
          HasDayFraction(-3, -1));
    });

    test("large components don't overflow", () {
      const int trillion = 1000000000000;
      expect(Timespan(hours: trillion),
          HasDayFraction(41666666666, 16 * hourNano));
      expect(Timespan(minutes: trillion),
          HasDayFraction(694444444, 640 * minuteNano));
      expect(Timespan(seconds: trillion),
          HasDayFraction(11574074, 6400 * secondNano));
      expect(Timespan(milliseconds: trillion),
          HasDayFraction(11574, 6400000 * millisecondNano));
      expect(Timespan(microseconds: trillion),
          HasDayFraction(11, 49600000000 * microsecondNano));
      expect(Timespan(nanoseconds: trillion), HasDayFraction(0, 1000000000000));
    });
  });

  group('conversion', () {
    test('inDays', () {
      expect(Timespan().inDays, 0);
      expect(Timespan(days: 10, nanoseconds: 1).inDays, 10);
      expect(Timespan(days: -10, nanoseconds: -1).inDays, -10);
    });

    test('inHours', () {
      expect(Timespan().inHours, 0);
      expect(Timespan(hours: 10, nanoseconds: 1).inHours, 10);
      expect(Timespan(hours: -10, nanoseconds: -1).inHours, -10);
    });

    test('inMinutes', () {
      expect(Timespan().inMinutes, 0);
      expect(Timespan(minutes: 10, nanoseconds: 1).inMinutes, 10);
      expect(Timespan(minutes: -10, nanoseconds: -1).inMinutes, -10);
    });

    test('inSeconds', () {
      expect(Timespan().inSeconds, 0);
      expect(Timespan(seconds: 10, nanoseconds: 1).inSeconds, 10);
      expect(Timespan(seconds: -10, nanoseconds: -1).inSeconds, -10);
    });

    test('inMilliseconds', () {
      expect(Timespan().inMilliseconds, 0);
      expect(Timespan(milliseconds: 10, nanoseconds: 1).inMilliseconds, 10);
      expect(Timespan(milliseconds: -10, nanoseconds: -1).inMilliseconds, -10);
    });

    test('inMicroseconds', () {
      expect(Timespan().inMicroseconds, 0);
      expect(Timespan(microseconds: 10, nanoseconds: 1).inMicroseconds, 10);
      expect(Timespan(microseconds: -10, nanoseconds: -1).inMicroseconds, -10);
    });

    test('inNanoseconds', () {
      expect(Timespan().inNanoseconds, 0);
      expect(Timespan(nanoseconds: 1).inNanoseconds, 1);
      expect(Timespan(nanoseconds: -1).inNanoseconds, -1);
    });
  });

  group('arithmetic', () {
    test('operator+', () {
      var t = Timespan(days: -10);
      expect(t + Timespan(days: 1), HasDayFraction(-9, 0));
      expect(t + Timespan(days: 5), HasDayFraction(-5, 0));
      expect(t + Timespan(days: 10), HasDayFraction(0, 0));
      expect(t + Timespan(days: 11), HasDayFraction(1, 0));

      expect(t + Timespan(nanoseconds: 1), HasDayFraction(-9, -dayNano + 1));
      expect(t + Timespan(nanoseconds: dayNano - 1), HasDayFraction(-9, -1));
      expect(t + Timespan(nanoseconds: dayNano), HasDayFraction(-9, 0));
      expect(
          t + Timespan(nanoseconds: 2 * dayNano - 1), HasDayFraction(-8, -1));
      expect(t + Timespan(nanoseconds: 2 * dayNano), HasDayFraction(-8, 0));
      expect(t + Timespan(nanoseconds: 2 * dayNano + 1),
          HasDayFraction(-7, -dayNano + 1));

      expect(
          t + Timespan(nanoseconds: 10 * dayNano - 1), HasDayFraction(0, -1));
      expect(t + Timespan(nanoseconds: 10 * dayNano), HasDayFraction(0, 0));
      expect(t + Timespan(nanoseconds: 10 * dayNano + 1), HasDayFraction(0, 1));

      expect(t + Timespan(nanoseconds: 20 * dayNano - 1),
          HasDayFraction(9, dayNano - 1));
      expect(t + Timespan(nanoseconds: 20 * dayNano), HasDayFraction(10, 0));
      expect(
          t + Timespan(nanoseconds: 20 * dayNano + 1), HasDayFraction(10, 1));
    });

    test('operator-', () {
      var t = Timespan(days: 10);
      expect(t - Timespan(days: 1), HasDayFraction(9, 0));
      expect(t - Timespan(days: 5), HasDayFraction(5, 0));
      expect(t - Timespan(days: 10), HasDayFraction(0, 0));
      expect(t - Timespan(days: 11), HasDayFraction(-1, 0));

      expect(t - Timespan(nanoseconds: 1), HasDayFraction(9, dayNano - 1));
      expect(t - Timespan(nanoseconds: dayNano - 1), HasDayFraction(9, 1));
      expect(t - Timespan(nanoseconds: dayNano), HasDayFraction(9, 0));
      expect(t - Timespan(nanoseconds: 2 * dayNano - 1), HasDayFraction(8, 1));
      expect(t - Timespan(nanoseconds: 2 * dayNano), HasDayFraction(8, 0));
      expect(t - Timespan(nanoseconds: 2 * dayNano + 1),
          HasDayFraction(7, dayNano - 1));

      expect(t - Timespan(nanoseconds: 10 * dayNano - 1), HasDayFraction(0, 1));
      expect(t - Timespan(nanoseconds: 10 * dayNano), HasDayFraction(0, 0));
      expect(
          t - Timespan(nanoseconds: 10 * dayNano + 1), HasDayFraction(0, -1));

      expect(t - Timespan(nanoseconds: 20 * dayNano - 1),
          HasDayFraction(-9, -dayNano + 1));
      expect(t - Timespan(nanoseconds: 20 * dayNano), HasDayFraction(-10, 0));
      expect(
          t - Timespan(nanoseconds: 20 * dayNano + 1), HasDayFraction(-10, -1));
    });

    test('operator*', () {
      expect(Timespan(days: 1) * 2, HasDayFraction(2, 0));
      expect(Timespan(days: -1) * 2, HasDayFraction(-2, 0));
      expect(Timespan(days: 1, nanoseconds: 2) * 2, HasDayFraction(2, 4));
      expect(Timespan(days: -1, nanoseconds: 2) * 2,
          HasDayFraction(-1, -dayNano + 4));
      expect(Timespan(days: 1, nanoseconds: 2) * -2, HasDayFraction(-2, -4));
      expect(Timespan(days: -1, nanoseconds: 2) * -2,
          HasDayFraction(1, dayNano - 4));
      expect(Timespan(days: -1, nanoseconds: -2) * 2, HasDayFraction(-2, -4));
      expect(Timespan(days: -1, nanoseconds: -2) * -2, HasDayFraction(2, 4));

      expect(Timespan(days: 10, nanoseconds: 3) * 0.5, HasDayFraction(5, 1));
      expect(
          Timespan(days: -10, nanoseconds: -3) * 0.5, HasDayFraction(-5, -1));
    });

    test('operator~/', () {
      expect(Timespan(days: 2) ~/ 2, HasDayFraction(1, 0));
      expect(Timespan(days: 2) ~/ -2, HasDayFraction(-1, 0));
      expect(Timespan(days: -2) ~/ 2, HasDayFraction(-1, 0));
      expect(Timespan(days: -2) ~/ -2, HasDayFraction(1, 0));

      expect(Timespan(nanoseconds: 2) ~/ 2, HasDayFraction(0, 1));
      expect(Timespan(nanoseconds: 2) ~/ -2, HasDayFraction(0, -1));
      expect(Timespan(nanoseconds: -2) ~/ 2, HasDayFraction(0, -1));
      expect(Timespan(nanoseconds: -2) ~/ -2, HasDayFraction(0, 1));

      expect(Timespan(days: 2, nanoseconds: 4) ~/ 2, HasDayFraction(1, 2));
      expect(Timespan(days: 2, nanoseconds: 4) ~/ -2, HasDayFraction(-1, -2));
      expect(Timespan(days: -2, nanoseconds: -4) ~/ 2, HasDayFraction(-1, -2));
      expect(Timespan(days: -2, nanoseconds: -4) ~/ -2, HasDayFraction(1, 2));
    });
  });

  group('comparison', () {
    var a = Timespan(days: 2, nanoseconds: 3);
    var b = Timespan(days: 2, nanoseconds: 2);
    var c = Timespan(days: 1, nanoseconds: 2);
    test('operator<', () {
      expect(a, isNot(lessThan(a)));

      expect(a, isNot(lessThan(b)));
      expect(b, lessThan(a));

      expect(a, isNot(lessThan(c)));
      expect(c, lessThan(a));

      expect(b, isNot(lessThan(c)));
      expect(c, lessThan(b));
    });

    test('operator=<', () {
      expect(a, lessThanOrEqualTo(a));

      expect(a, isNot(lessThanOrEqualTo(b)));
      expect(b, lessThanOrEqualTo(a));

      expect(a, isNot(lessThanOrEqualTo(c)));
      expect(c, lessThanOrEqualTo(a));

      expect(b, isNot(lessThanOrEqualTo(c)));
      expect(c, lessThanOrEqualTo(b));
    });

    test('operator>', () {
      expect(a, isNot(greaterThan(a)));

      expect(a, greaterThan(b));
      expect(b, isNot(greaterThan(a)));

      expect(a, greaterThan(c));
      expect(c, isNot(greaterThan(a)));

      expect(b, greaterThan(c));
      expect(c, isNot(greaterThan(b)));
    });

    test('operator>=', () {
      expect(a, greaterThanOrEqualTo(a));

      expect(a, greaterThanOrEqualTo(b));
      expect(b, isNot(greaterThanOrEqualTo(a)));

      expect(a, greaterThanOrEqualTo(c));
      expect(c, isNot(greaterThanOrEqualTo(a)));

      expect(b, greaterThanOrEqualTo(c));
      expect(c, isNot(greaterThanOrEqualTo(b)));
    });

    test('compareTo()', () {
      expect(a.compareTo(a), 0);
      expect(a.compareTo(b), 1);
      expect(b.compareTo(a), -1);
      expect(a.compareTo(c), 1);
      expect(c.compareTo(a), -1);
      expect(b.compareTo(c), 1);
      expect(c.compareTo(b), -1);
    });
  });

  test('operator- (unary negation)', () {
    expect(-Timespan(days: 2, nanoseconds: 1), HasDayFraction(-2, -1));
    expect(-Timespan(days: -2, nanoseconds: -1), HasDayFraction(2, 1));
  });

  test('abs()', () {
    expect(Timespan(days: 2, nanoseconds: 3).abs(), HasDayFraction(2, 3));
    expect(Timespan(days: -2, nanoseconds: -3).abs(), HasDayFraction(2, 3));
  });

  test('isNegative', () {
    expect(Timespan().isNegative, false);
    expect(Timespan(days: 1).isNegative, false);
    expect(Timespan(days: -1).isNegative, true);
    expect(Timespan(microseconds: 1).isNegative, false);
    expect(Timespan(microseconds: -1).isNegative, true);
  });

  test('toString()', () {
    expect(Timespan().toString(), 'P0D');
    expect(Timespan(days: 2).toString(), 'P2D');
    expect(Timespan(hours: 2).toString(), 'PT2H');
    expect(Timespan(minutes: 2).toString(), 'PT2M');
    expect(Timespan(seconds: 2).toString(), 'PT2S');
    expect(Timespan(milliseconds: 2).toString(), 'PT0.002000000S');
    expect(Timespan(microseconds: 2).toString(), 'PT0.000002000S');
    expect(Timespan(nanoseconds: 2).toString(), 'PT0.000000002S');
    expect(
        Timespan(
                days: 1,
                hours: 2,
                minutes: 3,
                seconds: 4,
                milliseconds: 5,
                microseconds: 6,
                nanoseconds: 7)
            .toString(),
        'P1DT2H3M4.005006007S');

    expect(Timespan().toString(), 'P0D');
    expect(Timespan(days: -2).toString(), 'P-2D');
    expect(Timespan(hours: -2).toString(), 'PT-2H');
    expect(Timespan(minutes: -2).toString(), 'PT-2M');
    expect(Timespan(seconds: -2).toString(), 'PT-2S');
    expect(Timespan(milliseconds: -2).toString(), 'PT-0.002000000S');
    expect(Timespan(microseconds: -2).toString(), 'PT-0.000002000S');
    expect(Timespan(nanoseconds: -2).toString(), 'PT-0.000000002S');
    expect(
        Timespan(
                days: -1,
                hours: -2,
                minutes: -3,
                seconds: -4,
                milliseconds: -5,
                microseconds: -6,
                nanoseconds: -7)
            .toString(),
        'P-1DT-2H-3M-4.005006007S');
  });

  test('operator==', () {
    expect(Timespan(), Timespan());
    expect(Timespan(days: 1), Timespan(days: 1));
    expect(Timespan(nanoseconds: 1), Timespan(nanoseconds: 1));
    expect(
        Timespan(days: 1, nanoseconds: 2), Timespan(days: 1, nanoseconds: 2));

    expect(Timespan(days: 1), isNot(Timespan(days: 2)));
    expect(Timespan(nanoseconds: 1), isNot(Timespan(nanoseconds: 2)));
    expect(Timespan(days: 1, nanoseconds: 2),
        isNot(Timespan(days: 2, nanoseconds: 1)));
  });

  test('hashCode', () {
    expect(Timespan().hashCode, Timespan().hashCode);
    expect(Timespan(days: 1).hashCode, Timespan(days: 1).hashCode);
    expect(
        Timespan(nanoseconds: 1).hashCode, Timespan(nanoseconds: 1).hashCode);
    expect(Timespan(days: 1, nanoseconds: 2).hashCode,
        Timespan(days: 1, nanoseconds: 2).hashCode);

    expect(Timespan(days: 1).hashCode, isNot(Timespan(days: 2).hashCode));
    expect(Timespan(nanoseconds: 1).hashCode,
        isNot(Timespan(nanoseconds: 2).hashCode));
    expect(Timespan(days: 1, nanoseconds: 2).hashCode,
        isNot(Timespan(days: 2, nanoseconds: 1).hashCode));
  });
}
