import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  group('Constructors and basic getters:', () {
    test('Default', () {
      var t = LocalTime(3, 4, 5, 6, 7);
      expect(t.hour, 3, reason: 'Hour mismatch');
      expect(t.minute, 4, reason: 'Minute mismatch');
      expect(t.second, 5, reason: 'Second mismatch');
      expect(t.millisecond, 6, reason: 'Millisecond mismatch');
      expect(t.microsecond, 7, reason: 'Microsecond mismatch');
    });

    test('Default examples', () {
      expect(LocalTime(12, 60, 0), LocalTime(13, 0, 0));
      expect(LocalTime(12, 1, 60), LocalTime(12, 2, 0));
      expect(LocalTime(23, 60, 0), LocalTime(0, 0, 0));
      expect(LocalTime(0, 0, -1), LocalTime(23, 59, 59));
    });

    test('wrapping', () {
      expect(LocalTime(23, 59, 59, 999, 1000), LocalTime());
      expect(LocalTime(0, 0, 0, 0, -1), LocalTime(23, 59, 59, 999, 999));
    });

    test('fromDateTime()', () {
      var t = LocalTime.fromDateTime(DateTime(2000, 1, 2, 3, 4, 5, 6, 7));
      expect(t.hour, 3, reason: 'Hour mismatch');
      expect(t.minute, 4, reason: 'Minute mismatch');
      expect(t.second, 5, reason: 'Second mismatch');
      expect(t.millisecond, 6, reason: 'Millisecond mismatch');
      expect(t.microsecond, 7, reason: 'Microsecond mismatch');
    });

    test('now() smoke test', () {
      var t = LocalTime.now();
      expect(t.hour, greaterThanOrEqualTo(0));
      expect(t.minute, greaterThanOrEqualTo(0));
      expect(t.second, greaterThanOrEqualTo(0));
      expect(t.millisecond, greaterThanOrEqualTo(0));
      expect(t.microsecond, greaterThanOrEqualTo(0));
    });
  });

  test('durationUntil()', () {
    var t = LocalTime(12);
    expect(t.durationUntil(t), Duration());
    expect(t.durationUntil(LocalTime(13)), Duration(hours: 1));
    expect(t.durationUntil(LocalTime(11)), Duration(hours: -1));
    expect(t.durationUntil(LocalTime(12, 0, 1)), Duration(seconds: 1));
    expect(t.durationUntil(LocalTime(11, 59, 59)), Duration(seconds: -1));
    expect(t.durationUntil(LocalTime(12, 0, 0, 1)), Duration(milliseconds: 1));
    expect(t.durationUntil(LocalTime(11, 59, 59, 999)),
        Duration(milliseconds: -1));
    expect(
        t.durationUntil(LocalTime(12, 0, 0, 0, 1)), Duration(microseconds: 1));
    expect(t.durationUntil(LocalTime(11, 59, 59, 999, 999)),
        Duration(microseconds: -1));
  });

  test('adding Duration', () {
    var t = LocalTime(12);
    expect(t + Duration(hours: 1), LocalTime(13));
    expect(t + Duration(hours: -1), LocalTime(11));
    expect(t + Duration(seconds: 1), LocalTime(12, 0, 1));
    expect(t + Duration(seconds: -1), LocalTime(11, 59, 59));
    expect(t + Duration(milliseconds: 1), LocalTime(12, 0, 0, 1));
    expect(t + Duration(milliseconds: -1), LocalTime(11, 59, 59, 999));
    expect(t + Duration(microseconds: 1), LocalTime(12, 0, 0, 0, 1));
    expect(t + Duration(microseconds: -1), LocalTime(11, 59, 59, 999, 999));
    expect(t + Duration(days: 1), t);
    expect(t + Duration(days: -1), t);
    expect(t + Duration(days: 1, hours: 1), LocalTime(13));
    expect(t + Duration(days: -1, hours: 1), LocalTime(13));
    expect(t + Duration(days: 1, hours: -1), LocalTime(11));
    expect(t + Duration(days: -1, hours: -1), LocalTime(11));
  });

  group('Comparison operator', () {
    test('== (and hash equality)', () {
      var t1 = LocalTime(3, 4, 5, 6, 7);
      var t2 = LocalTime(3, 4, 5, 6, 7);
      expect(t1, t2);
      expect(t1.hashCode, t2.hashCode, reason: 'Hash mismatch');
    });

    test('!= (and hash inequality)', () {
      var t1 = LocalTime(3, 4, 5, 6, 7);
      var t2 = LocalTime(3, 4, 5, 6, 8);
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

  test('toString()', () {
    expect(LocalTime(1, 2, 3, 4, 5).toString(), '01:02:03.004005');
  });
}
