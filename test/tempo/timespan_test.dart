import 'package:tempo/tempo.dart';
import 'package:test/test.dart';

const int _nano = 1000000000;
const int _microsecondNano = _nano ~/ 1000000;
const int _millisecondNano = _nano ~/ 1000;
const int _secondNano = _nano;
const int _minuteSecs = 60;
const int _hourSecs = 3600;
const int _daySecs = 86400;

const int _halfSecondNano = _nano ~/ 2;

Matcher hasParts(int seconds, nanosecondPart) => isA<Timespan>()
    .having((t) => t.seconds, 'seconds', seconds)
    .having((t) => t.nanosecondPart, 'nanosecondPart', nanosecondPart);

void main() {
  group('Default constructor', () {
    test('arg conversions', () {
      expect(Timespan(days: 5), hasParts(5 * _daySecs, 0));
      expect(Timespan(hours: 5), hasParts(5 * _hourSecs, 0));
      expect(Timespan(minutes: 5), hasParts(5 * _minuteSecs, 0));
      expect(Timespan(seconds: 5), hasParts(5, 0));
      expect(Timespan(milliseconds: 5), hasParts(0, 5 * _millisecondNano));
      expect(Timespan(microseconds: 5), hasParts(0, 5 * _microsecondNano));
      expect(Timespan(nanoseconds: 5), hasParts(0, 5));
      expect(
          Timespan(
              days: 1,
              hours: 2,
              minutes: 3,
              seconds: 4,
              milliseconds: 5,
              microseconds: 6,
              nanoseconds: 7),
          hasParts(
              1 * _daySecs + 2 * _hourSecs + 3 * _minuteSecs + 4, 5006007));
    });

    test('normalization', () {
      expect(Timespan(), hasParts(0, 0));
      expect(Timespan(seconds: 0, nanoseconds: 1), hasParts(0, 1));
      expect(Timespan(seconds: 0, nanoseconds: _halfSecondNano),
          hasParts(0, _halfSecondNano));
      expect(Timespan(seconds: 1), hasParts(1, 0));
      expect(Timespan(seconds: 1, nanoseconds: 1), hasParts(1, 1));
      expect(Timespan(seconds: 1, nanoseconds: _halfSecondNano),
          hasParts(1, _halfSecondNano));
      expect(Timespan(seconds: 1, nanoseconds: _nano + 1), hasParts(2, 1));
      expect(Timespan(seconds: 1, nanoseconds: 2 * _nano + 1), hasParts(3, 1));

      expect(Timespan(seconds: 10, nanoseconds: -1), hasParts(9, _nano - 1));

      expect(Timespan(seconds: 0, nanoseconds: -1), hasParts(0, -1));
      expect(Timespan(seconds: 0, nanoseconds: -_halfSecondNano),
          hasParts(0, -_halfSecondNano));
      expect(Timespan(seconds: 0, nanoseconds: -_nano + 1),
          hasParts(0, -_nano + 1));
      expect(Timespan(seconds: -1), hasParts(-1, 0));
      expect(Timespan(seconds: -1, nanoseconds: -1), hasParts(-1, -1));
      expect(Timespan(seconds: -1, nanoseconds: 1), hasParts(0, -_nano + 1));
      expect(
          Timespan(seconds: -1, nanoseconds: -(_nano + 1)), hasParts(-2, -1));
      expect(Timespan(seconds: -1, nanoseconds: -(2 * _nano + 1)),
          hasParts(-3, -1));
    });

    group('component overflow', () {
      test('positive', () {
        // These numbers are the highest they can be without overflowing in
        // javascript (2^53).
        expect(Timespan(days: 104249991374), hasParts(9007199254713600, 0));
        expect(Timespan(hours: 2501999792983), hasParts(9007199254738800, 0));
        expect(
            Timespan(minutes: 150119987579016), hasParts(9007199254740960, 0));
        expect(
            Timespan(seconds: 9007199254740992), hasParts(9007199254740992, 0));
        expect(Timespan(milliseconds: 9007199254740992),
            hasParts(9007199254740, 992000000));
        expect(Timespan(microseconds: 9007199254740992),
            hasParts(9007199254, 740992000));
        expect(Timespan(nanoseconds: 9007199254740992),
            hasParts(9007199, 254740992));
      });

      test('negative', () {
        // These numbers are the lowest they can be without overflowing in
        // javascript (-2^52).
        expect(Timespan(days: -52124995688), hasParts(-4503599627443200, 0));
        expect(Timespan(hours: -1250999896492), hasParts(-4503599627371200, 0));
        expect(
            Timespan(minutes: -75059993789509), hasParts(-4503599627370540, 0));
        expect(Timespan(seconds: -4503599627370496),
            hasParts(-4503599627370496, 0));
        expect(Timespan(milliseconds: -4503599627370496),
            hasParts(-4503599627370, -496000000));
        expect(Timespan(microseconds: -4503599627370496),
            hasParts(-4503599627, -370496000));
        expect(Timespan(nanoseconds: -4503599627370496),
            hasParts(-4503599, -627370496));
      });
    });
  });

  test('parse', () {
    expect(Timespan.parse('P1DT2H3M4S'),
        Timespan(days: 1, hours: 2, minutes: 3, seconds: 4));
    expect(Timespan.parse('P-1DT-2H-3M-4S'),
        -Timespan(days: 1, hours: 2, minutes: 3, seconds: 4));
    expect(Timespan.parse('P1YT2H'), Timespan(hours: 2),
        reason: "Didn't ignore years");
    expect(
        Timespan.parse('PT1.2S'), Timespan(seconds: 1, nanoseconds: 200000000));
    expect(Timespan.parse('PT-1.2S'),
        -Timespan(seconds: 1, nanoseconds: 200000000));
    expect(Timespan.parse('PT0.2S'), Timespan(nanoseconds: 200000000));
    expect(Timespan.parse('PT-0.2S'), Timespan(nanoseconds: -200000000));
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
    group('operator+', () {
      final t = Timespan(seconds: -10);
      test('seconds', () {
        expect(t + Timespan(seconds: 1), hasParts(-9, 0));
        expect(t + Timespan(seconds: 5), hasParts(-5, 0));
        expect(t + Timespan(seconds: 10), hasParts(0, 0));
        expect(t + Timespan(seconds: 11), hasParts(1, 0));
      });

      test('nanoseconds', () {
        expect(t + Timespan(nanoseconds: 1), hasParts(-9, -_secondNano + 1));
        expect(t + Timespan(nanoseconds: _secondNano - 1), hasParts(-9, -1));
        expect(t + Timespan(nanoseconds: _secondNano), hasParts(-9, 0));
        expect(
            t + Timespan(nanoseconds: 2 * _secondNano - 1), hasParts(-8, -1));
        expect(t + Timespan(nanoseconds: 2 * _secondNano), hasParts(-8, 0));
        expect(t + Timespan(nanoseconds: 2 * _secondNano + 1),
            hasParts(-7, -_secondNano + 1));

        expect(
            t + Timespan(nanoseconds: 10 * _secondNano - 1), hasParts(0, -1));
        expect(t + Timespan(nanoseconds: 10 * _secondNano), hasParts(0, 0));
        expect(t + Timespan(nanoseconds: 10 * _secondNano + 1), hasParts(0, 1));

        expect(t + Timespan(nanoseconds: 20 * _secondNano - 1),
            hasParts(9, _secondNano - 1));
        expect(t + Timespan(nanoseconds: 20 * _secondNano), hasParts(10, 0));
        expect(
            t + Timespan(nanoseconds: 20 * _secondNano + 1), hasParts(10, 1));
      });

      test('carries', () {
        expect(
          Timespan(nanoseconds: 1) + Timespan(nanoseconds: _secondNano - 1),
          hasParts(1, 0),
        );
      });

      test('borrows', () {
        expect(
          Timespan(seconds: 1) + Timespan(nanoseconds: -(_secondNano - 1)),
          hasParts(0, 1),
        );
      });

      test('large but precise', () {
        expect(Timespan(seconds: 9007199254740991) + Timespan(nanoseconds: 1),
            hasParts(9007199254740991, 1));
        expect(Timespan(seconds: 9007199254740991) + Timespan(nanoseconds: -1),
            hasParts(9007199254740990, 999999999));

        expect(Timespan(seconds: -4503599627370496) + Timespan(nanoseconds: 1),
            hasParts(-4503599627370495, -999999999));
        expect(Timespan(seconds: -4503599627370496) + Timespan(nanoseconds: -1),
            hasParts(-4503599627370496, -1));
      });
    });

    group('operator-', () {
      final t = Timespan(seconds: 10);

      test('seconds', () {
        expect(t - Timespan(seconds: 1), hasParts(9, 0));
        expect(t - Timespan(seconds: 5), hasParts(5, 0));
        expect(t - Timespan(seconds: 10), hasParts(0, 0));
        expect(t - Timespan(seconds: 11), hasParts(-1, 0));
      });

      test('nanoseconds', () {
        expect(t - Timespan(nanoseconds: 1), hasParts(9, _secondNano - 1));
        expect(t - Timespan(nanoseconds: _secondNano - 1), hasParts(9, 1));
        expect(t - Timespan(nanoseconds: _secondNano), hasParts(9, 0));
        expect(t - Timespan(nanoseconds: 2 * _secondNano - 1), hasParts(8, 1));
        expect(t - Timespan(nanoseconds: 2 * _secondNano), hasParts(8, 0));
        expect(t - Timespan(nanoseconds: 2 * _secondNano + 1),
            hasParts(7, _secondNano - 1));

        expect(t - Timespan(nanoseconds: 10 * _secondNano - 1), hasParts(0, 1));
        expect(t - Timespan(nanoseconds: 10 * _secondNano), hasParts(0, 0));
        expect(
            t - Timespan(nanoseconds: 10 * _secondNano + 1), hasParts(0, -1));

        expect(t - Timespan(nanoseconds: 20 * _secondNano - 1),
            hasParts(-9, -_secondNano + 1));
        expect(t - Timespan(nanoseconds: 20 * _secondNano), hasParts(-10, 0));
        expect(
            t - Timespan(nanoseconds: 20 * _secondNano + 1), hasParts(-10, -1));
      });

      test('carries', () {
        expect(
          Timespan(seconds: 1) - Timespan(nanoseconds: _secondNano - 1),
          hasParts(0, 1),
        );
      });

      test('borrows', () {
        expect(
          Timespan(nanoseconds: 1) - Timespan(nanoseconds: -(_secondNano - 1)),
          hasParts(1, 0),
        );
      });

      test('large but precise', () {
        expect(Timespan(seconds: 9007199254740991) - Timespan(nanoseconds: -1),
            hasParts(9007199254740991, 1));
        expect(Timespan(seconds: 9007199254740991) - Timespan(nanoseconds: 1),
            hasParts(9007199254740990, 999999999));

        expect(Timespan(seconds: -4503599627370496) - Timespan(nanoseconds: -1),
            hasParts(-4503599627370495, -999999999));
        expect(Timespan(seconds: -4503599627370496) - Timespan(nanoseconds: 1),
            hasParts(-4503599627370496, -1));
      });
    });

    test('operator*', () {
      expect(Timespan(seconds: 1) * 2, hasParts(2, 0));
      expect(Timespan(seconds: -1) * 2, hasParts(-2, 0));
      expect(Timespan(seconds: 1, nanoseconds: 2) * 2, hasParts(2, 4));
      expect(Timespan(seconds: -1, nanoseconds: 2) * 2,
          hasParts(-1, -_secondNano + 4));
      expect(Timespan(seconds: 1, nanoseconds: 2) * -2, hasParts(-2, -4));
      expect(Timespan(seconds: -1, nanoseconds: 2) * -2,
          hasParts(1, _secondNano - 4));
      expect(Timespan(seconds: -1, nanoseconds: -2) * 2, hasParts(-2, -4));
      expect(Timespan(seconds: -1, nanoseconds: -2) * -2, hasParts(2, 4));

      expect(Timespan(seconds: 10, nanoseconds: 3) * 0.5, hasParts(5, 1));
      expect(Timespan(seconds: -10, nanoseconds: -3) * 0.5, hasParts(-5, -1));
    });

    test('operator~/', () {
      expect(Timespan(seconds: 2) ~/ 2, hasParts(1, 0));
      expect(Timespan(seconds: 2) ~/ -2, hasParts(-1, 0));
      expect(Timespan(seconds: -2) ~/ 2, hasParts(-1, 0));
      expect(Timespan(seconds: -2) ~/ -2, hasParts(1, 0));

      expect(Timespan(nanoseconds: 2) ~/ 2, hasParts(0, 1));
      expect(Timespan(nanoseconds: 2) ~/ -2, hasParts(0, -1));
      expect(Timespan(nanoseconds: -2) ~/ 2, hasParts(0, -1));
      expect(Timespan(nanoseconds: -2) ~/ -2, hasParts(0, 1));

      expect(Timespan(seconds: 2, nanoseconds: 4) ~/ 2, hasParts(1, 2));
      expect(Timespan(seconds: 2, nanoseconds: 4) ~/ -2, hasParts(-1, -2));
      expect(Timespan(seconds: -2, nanoseconds: -4) ~/ 2, hasParts(-1, -2));
      expect(Timespan(seconds: -2, nanoseconds: -4) ~/ -2, hasParts(1, 2));
    });
  });

  group('comparison', () {
    var a = Timespan(seconds: 2, nanoseconds: 3);
    var b = Timespan(seconds: 2, nanoseconds: 2);
    var c = Timespan(seconds: 1, nanoseconds: 2);
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
    expect(-Timespan(seconds: 2, nanoseconds: 1), hasParts(-2, -1));
    expect(-Timespan(seconds: -2, nanoseconds: -1), hasParts(2, 1));
  });

  test('abs()', () {
    expect(Timespan(seconds: 2, nanoseconds: 3).abs(), hasParts(2, 3));
    expect(Timespan(seconds: -2, nanoseconds: -3).abs(), hasParts(2, 3));
  });

  test('isNegative', () {
    expect(Timespan().isNegative, false);
    expect(Timespan(seconds: 1).isNegative, false);
    expect(Timespan(seconds: -1).isNegative, true);
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
    expect(Timespan(seconds: 1), Timespan(seconds: 1));
    expect(Timespan(nanoseconds: 1), Timespan(nanoseconds: 1));
    expect(Timespan(seconds: 1, nanoseconds: 2),
        Timespan(seconds: 1, nanoseconds: 2));

    expect(Timespan(seconds: 1), isNot(Timespan(seconds: 2)));
    expect(Timespan(nanoseconds: 1), isNot(Timespan(nanoseconds: 2)));
    expect(Timespan(seconds: 1, nanoseconds: 2),
        isNot(Timespan(seconds: 2, nanoseconds: 1)));
  });

  test('hashCode', () {
    expect(Timespan().hashCode, Timespan().hashCode);
    expect(Timespan(seconds: 1).hashCode, Timespan(seconds: 1).hashCode);
    expect(
        Timespan(nanoseconds: 1).hashCode, Timespan(nanoseconds: 1).hashCode);
    expect(Timespan(seconds: 1, nanoseconds: 2).hashCode,
        Timespan(seconds: 1, nanoseconds: 2).hashCode);

    expect(Timespan(seconds: 1).hashCode, isNot(Timespan(seconds: 2).hashCode));
    expect(Timespan(nanoseconds: 1).hashCode,
        isNot(Timespan(nanoseconds: 2).hashCode));
    expect(Timespan(seconds: 1, nanoseconds: 2).hashCode,
        isNot(Timespan(seconds: 2, nanoseconds: 1).hashCode));
  });
}
