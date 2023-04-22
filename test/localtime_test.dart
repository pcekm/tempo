import 'package:goodtime/src/localtime.dart';
import 'package:goodtime/src/timespan.dart';
import 'package:test/test.dart';

void main() {
  group('Constructors and basic getters:', () {
    test('Default', () {
      var t = LocalTime(3, 4, 5, 6);
      expect(t.hour, 3, reason: 'Hour mismatch');
      expect(t.minute, 4, reason: 'Minute mismatch');
      expect(t.second, 5, reason: 'Second mismatch');
      expect(t.nanosecond, 6, reason: 'Nanosecond mismatch');
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
        expect(t.hour, 3, reason: 'Hour mismatch');
        expect(t.minute, 4, reason: 'Minute mismatch');
        expect(t.second, 5, reason: 'Second mismatch');
        // Only test milliseconds, since that's all js can do.
        expect(t.nanosecond, 6000000, reason: 'Nanosecond mismatch');
      });

      test('vm platforms', () {
        // No nanoseconds in a DateTime.
        var dt = DateTime(2000, 1, 2, 3, 4, 5, 6, 7);
        var t = LocalTime.fromDateTime(dt);
        expect(t.hour, 3, reason: 'Hour mismatch');
        expect(t.minute, 4, reason: 'Minute mismatch');
        expect(t.second, 5, reason: 'Second mismatch');
        expect(t.nanosecond, 6007000, reason: 'Nanosecond mismatch');
      }, testOn: '!js');
    });

    test('now() smoke test', () {
      var t = LocalTime.now();
      expect(t.hour, greaterThanOrEqualTo(0));
      expect(t.minute, greaterThanOrEqualTo(0));
      expect(t.second, greaterThanOrEqualTo(0));
      expect(t.nanosecond, greaterThanOrEqualTo(0));
    });
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
    expect(LocalTime(1, 2, 3, 4).toString(), '01:02:03.000000004');
  });
}
