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

  group('Comparison operator', () {
    test('==', () {
      var t1 = LocalTime(3, 4, 5, 6, 7);
      var t2 = LocalTime(3, 4, 5, 6, 7);
      expect(t1 == t2, true);
    });

    test('!=', () {
      var t1 = LocalTime(3, 4, 5, 6, 7);
      var t2 = LocalTime(3, 4, 5, 6, 8);
      expect(t1 != t2, true);
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

  test('minimum and maximum', () {
    expect(LocalTime.minimum.toString(), '00:00:00.000000');
    expect(LocalTime.maximum.toString(), '23:59:59.999999');
  });
}
