import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
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
      expect(LocalTime(12, 60, 0), hasTime(13, 0, 0));
      expect(LocalTime(12, 1, 60), hasTime(12, 2, 0));
      expect(LocalTime(23, 60, 0), hasTime(0, 0, 0));
      expect(LocalTime(0, 0, -1), hasTime(23, 59, 59));
    });

    test('wrapping', () {
      expect(LocalTime(23, 59, 59, 1000000000), hasTime(0));
      expect(LocalTime(0, 0, 0, -1), hasTime(23, 59, 59, 999999999));
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

    test('now()', () {
      // This is a bit tricky. We need to ensure that now() tracks
      // defaultZoneId and not whatever time zone DateTime happens to be using.
      // (Which, unfortunately, can't be portably discovered in Dart.)
      //
      // Here's what's happening:
      //
      //   - Set defaultZoneId to a value that's unlikely to be DateTime's
      //     default
      //   - Set the clock to midnight in that unlikely timezone
      //
      // Assuming the time zones disagree, the test should fail if it tracks
      // DateTime and not defaultZoneId.
      defaultZoneId = 'Pacific/Kiritimati';
      var d = withClock(
          Clock.fixed(DateTime.utc(2026, 1, 2, 3, 4, 5, 6, 7)
              .subtract(Duration(hours: 14)) // Kiritimati's UTC offset
              .toLocal()),
          () => LocalTime.now());
      expect(d, hasTime(3, 4, 5, 6007000));
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
    expect(t.replace(hour: 10), hasTime(10, 2, 3, 4));
    expect(t.replace(minute: 10), hasTime(1, 10, 3, 4));
    expect(t.replace(second: 10), hasTime(1, 2, 10, 4));
    expect(t.replace(nanosecond: 10), hasTime(1, 2, 3, 10));
    expect(t.replace(hour: 5, minute: 6, second: 7, nanosecond: 8),
        hasTime(5, 6, 7, 8));
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

  test('plusTimespan()', () {
    var t = LocalTime(12);
    expect(
        t.plusTimespan(
            Timespan(hours: 1, minutes: 2, seconds: 3, nanoseconds: 4)),
        LocalTime(13, 2, 3, 4));
  });

  test('minusTimespan()', () {
    var t = LocalTime(12);
    expect(
        t.minusTimespan(
            Timespan(hours: 1, minutes: 2, seconds: 3, nanoseconds: 4)),
        LocalTime(10, 57, 56, 999999996));
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

  test('format()', () {
    final d = LocalTime(3, 4, 5, 6);
    final format = DateFormat.Hms();
    expect(d.format(format), '03:04:05');
  });
}
