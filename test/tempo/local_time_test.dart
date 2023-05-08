import 'package:tempo/tempo.dart';
import 'package:tempo/testing.dart';
import 'package:test/test.dart';

void main() {
  group('Constructors and basic getters:', () {
    test('Default', () {
      var t = LocalTime(3, 4, 5, 6);
      expect(t, hasTime(3, 4, 5, 6));
    });

    test('Default examples', () {
      expect(LocalTime(12, 60, 0), LocalTime(13, 0, 0));
      expect(LocalTime(12, 1, 60), LocalTime(12, 2, 0));
      expect(LocalTime(23, 60, 0), LocalTime(0, 0, 0));
      expect(LocalTime(0, 0, -1), LocalTime(23, 59, 59));
    });

    test('wrapping', () {
      expect(LocalTime(23, 59, 59, 1000000000), LocalTime());
      expect(LocalTime(0, 0, 0, -1), LocalTime(23, 59, 59, 999999999));
    });

    group('fromDateTime()', () {
      test('all platforms', () {
        // No nanoseconds in a DateTime.
        var dt = DateTime(2000, 1, 2, 3, 4, 5, 6);
        var t = LocalTime.fromDateTime(dt);
        // Only test milliseconds, since that's all js can do.
        expect(t, hasTime(3, 4, 5, 6000000));
      });

      test('vm platforms', () {
        // No nanoseconds in a DateTime.
        var dt = DateTime(2000, 1, 2, 3, 4, 5, 6, 7);
        var t = LocalTime.fromDateTime(dt);
        expect(t, hasTime(3, 4, 5, 6007000));
      }, testOn: '!js');
    });

    test('now() smoke test', () {
      var t = LocalTime.now();
      expect(t, hasHour(greaterThanOrEqualTo(0)));
      expect(t, hasMinute(greaterThanOrEqualTo(0)));
      expect(t, hasSecond(greaterThanOrEqualTo(0)));
      expect(t, hasNanosecond(greaterThanOrEqualTo(0)));
    });
  });

  group('parse()', () {
    test('complete', () {
      expect(LocalTime.parse('01:02:03.000000004'), hasTime(1, 2, 3, 4));
      expect(LocalTime.parse('010203.000000004'), hasTime(1, 2, 3, 4));
    });

    test('fraction truncation', () {
      expect(LocalTime.parse('00:00:00.0000000019'), hasTime(0, 0, 0, 1));
    });

    test('fewer fractional digits', () {
      expect(LocalTime.parse('00:00:00.1'), hasTime(0, 0, 0, 100000000));
    });

    test('hour minute', () {
      expect(LocalTime.parse('01:02'), hasTime(1, 2));
      expect(LocalTime.parse('0102'), hasTime(1, 2));
    });

    test('hour minute second', () {
      expect(LocalTime.parse('01:02:03'), hasTime(1, 2, 3));
      expect(LocalTime.parse('010203'), hasTime(1, 2, 3));
    });

    test('T prefix', () {
      expect(LocalTime.parse('T01'), hasTime(1));
      expect(LocalTime.parse('T0102'), hasTime(1, 2));
      expect(LocalTime.parse('T010203'), hasTime(1, 2, 3));
      expect(LocalTime.parse('T010203.000000004'), hasTime(1, 2, 3, 4));
    });

    test('invalid', () {
      const bad = ['', '0102junk'];
      for (var s in bad) {
        expect(() => LocalTime.parse(s), throwsFormatException, reason: s);
      }
    });
  });

  test('replace()', () {
    var t = LocalTime(1, 2, 3, 4);
    expect(t.replace(hour: 10), LocalTime(10, 2, 3, 4));
    expect(t.replace(minute: 10), LocalTime(1, 10, 3, 4));
    expect(t.replace(second: 10), LocalTime(1, 2, 10, 4));
    expect(t.replace(nanosecond: 10), LocalTime(1, 2, 3, 10));
    expect(t.replace(hour: 5, minute: 6, second: 7, nanosecond: 8),
        LocalTime(5, 6, 7, 8));
  });

  test('timespanUntil()', () {
    var t = LocalTime(12);
    expect(t.timespanUntil(t), Timespan());
    expect(t.timespanUntil(LocalTime(13)), Timespan(hours: 1));
    expect(t.timespanUntil(LocalTime(11)), Timespan(hours: -1));
    expect(t.timespanUntil(LocalTime(12, 0, 1)), Timespan(seconds: 1));
    expect(t.timespanUntil(LocalTime(11, 59, 59)), Timespan(seconds: -1));
    expect(t.timespanUntil(LocalTime(12, 0, 0, 001000000)),
        Timespan(milliseconds: 1));
    expect(t.timespanUntil(LocalTime(11, 59, 59, 999000000)),
        Timespan(milliseconds: -1));
    expect(t.timespanUntil(LocalTime(12, 0, 0, 000001000)),
        Timespan(microseconds: 1));
    expect(t.timespanUntil(LocalTime(11, 59, 59, 999999000)),
        Timespan(microseconds: -1));
    expect(t.timespanUntil(LocalTime(12, 0, 0, 000000001)),
        Timespan(nanoseconds: 1));
    expect(t.timespanUntil(LocalTime(11, 59, 59, 999999999)),
        Timespan(nanoseconds: -1));
  });

  group('Comparison operator', () {
    test('== (and hash equality)', () {
      var t1 = LocalTime(3, 4, 5, 6);
      var t2 = LocalTime(3, 4, 5, 6);
      expect(t1, t2);
      expect(t1.hashCode, t2.hashCode, reason: 'Hash mismatch');
    });

    test('!= (and hash inequality)', () {
      var t1 = LocalTime(3, 4, 5, 6);
      var t2 = LocalTime(3, 4, 5, 7);
      expect(t1, isNot(equals(t2)));
      expect(t1.hashCode, isNot(equals(t2.hashCode)), reason: 'Hashes match');
    });

    test('>', () {
      var t1 = LocalTime(0, 0, 0, 2);
      var t2 = LocalTime(0, 0, 0, 1);
      expect(t1 > t2, true);
      expect(t1 > t1, false);
    });

    test('>=', () {
      var t1 = LocalTime(0, 0, 0, 2);
      var t2 = LocalTime(0, 0, 0, 1);
      expect(t1 >= t2, true);
      expect(t1 >= t1, true);
    });

    test('<', () {
      var t1 = LocalTime(0, 0, 0, 1);
      var t2 = LocalTime(0, 0, 0, 2);
      expect(t1 < t2, true);
      expect(t1 < t1, false);
    });

    test('<=', () {
      var t1 = LocalTime(0, 0, 0, 1);
      var t2 = LocalTime(0, 0, 0, 2);
      expect(t1 <= t2, true);
      expect(t1 <= t1, true);
    });
  });

  test('compareTo()', () {
    var t1 = LocalTime(0, 0, 0, 1);
    var t2 = LocalTime(0, 0, 0, 2);
    expect(t1.compareTo(t1), 0);
    expect(t1.compareTo(t2), -1);
    expect(t2.compareTo(t1), 1);
  });

  test('toString()', () {
    expect(LocalTime(1, 0).toString(), '01:00');
    expect(LocalTime(1, 2).toString(), '01:02');
    expect(LocalTime(1, 2, 3).toString(), '01:02:03');
    expect(LocalTime(1, 2, 3, 400000000).toString(), '01:02:03.4');
    expect(LocalTime(1, 2, 3, 4000000).toString(), '01:02:03.004');
    expect(LocalTime(1, 2, 3, 4000).toString(), '01:02:03.000004');
    expect(LocalTime(1, 2, 3, 4).toString(), '01:02:03.000000004');
    expect(LocalTime(23, 59, 59, 999999999).toString(), '23:59:59.999999999');
  });
}
