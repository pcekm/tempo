import 'package:tempo/tempo.dart';
import 'package:tempo/testing.dart';
import 'package:test/test.dart';

void main() {
  const int nano = 1000000000;

  // Yes, Nepal really is UTC+0545:
  final nepalOffset = ZoneOffset(5, 45);
  final nepalTime = LocalDateTime(2000, 1, 2, 3, 4, 5, 6);
  final nepalOffsetTime =
      OffsetDateTime.fromLocalDateTime(nepalTime, nepalOffset);
  final nepalInstant =
      Instant.fromUnix(Timespan(seconds: 946761545, nanoseconds: 6));

  // Newfoundland in the winter is UTC-0330:
  final nstOffset = ZoneOffset(-3, -30);
  final nstTime = OffsetDateTime(nstOffset, 2001);

  // Difference between nepalTime and ndtTime:
  final delta = Timespan(days: 365, seconds: 22254, nanoseconds: nano - 6);

  group('Default constructor', () {
    test('hour+minute offset', () {
      var dt = OffsetDateTime(
          nepalOffset,
          nepalTime.year,
          nepalTime.month,
          nepalTime.day,
          nepalTime.hour,
          nepalTime.minute,
          nepalTime.second,
          nepalTime.nanosecond);
      expect(dt, hasDate(2000, 1, 2));
      expect(dt, hasTime(3, 4, 5, 6));
      expect(dt.offset, ZoneOffset(5, 45));
      expect(dt, hasInstant(nepalInstant));
    });

    test('hour+minute+second offset', () {
      var dt = OffsetDateTime(ZoneOffset(1, 2, 3), 1970);
      expect(dt, hasDate(1970, 1, 1));
      expect(dt, hasTime(0));
      expect(dt.offset, ZoneOffset(1, 2, 3));
      expect(
          dt,
          hasInstant(
              Instant.fromUnix(-Timespan(hours: 1, minutes: 2, seconds: 3))));
    });
  });

  test('fromLocalDateTime()', () {
    var dt = OffsetDateTime.fromLocalDateTime(nepalTime, nepalOffset);
    expect(dt, hasDate(2000, 1, 2));
    expect(dt, hasTime(3, 4, 5, 6));
    expect(dt.offset, ZoneOffset(5, 45));
    expect(dt, hasInstant(nepalInstant));
  });

  group('fromDateTime()', () {
    test('fromDateTime() microsecond precision', () {
      var dt = DateTime(2000, 1, 2, 3, 4, 5, 6, 7);
      var offset = ZoneOffset.fromDuration(dt.timeZoneOffset);
      var want = OffsetDateTime(offset, 2000, 1, 2, 3, 4, 5, 006007000);
      expect(OffsetDateTime.fromDateTime(dt), want);
    }, testOn: '!js');

    test('fromDateTime() millisecond precision', () {
      var dt = DateTime(2000, 1, 2, 3, 4, 5, 6);
      var offset = ZoneOffset.fromDuration(dt.timeZoneOffset);
      var want = OffsetDateTime(offset, 2000, 1, 2, 3, 4, 5, 006000000);
      expect(OffsetDateTime.fromDateTime(dt), want);
    }, testOn: 'js');
  });

  test('now() smoke test', () {
    var got = OffsetDateTime.now();
    expect(got.year, greaterThanOrEqualTo(2023));
  });

  group('fromInstant()', () {
    test('hour+minute offset', () {
      var dt = OffsetDateTime.fromInstant(nepalInstant, nepalOffset);
      expect(dt, hasDate(2000, 1, 2));
      expect(dt, hasTime(3, 4, 5, 6));
      expect(dt.offset, ZoneOffset(5, 45));
      expect(dt, hasInstant(nepalInstant));
    });

    test('hour+minute+second offset', () {
      var instant = Instant.fromUnix(Timespan(seconds: 0));
      var dt = OffsetDateTime.fromInstant(instant, ZoneOffset(1, 2, 3));
      expect(dt, hasDate(1970, 1, 1));
      expect(dt, hasTime(1, 2, 3));
      expect(dt.offset, ZoneOffset(1, 2, 3));
      expect(dt, hasInstant(instant));
    });
  });

  group('parse()', () {
    test('all fields', () {
      var dt = OffsetDateTime.parse('1000-02-03T04:05:06.000000007+08:09:10');
      expect(dt, hasDate(1000, 2, 3));
      expect(dt, hasTime(4, 5, 6, 7));
      expect(dt.offset, ZoneOffset(8, 9, 10));
    });

    test('no offset', () {
      var dt = OffsetDateTime.parse('1000-02-03T04:05:06.000000007');
      expect(dt, hasDate(1000, 2, 3));
      expect(dt, hasTime(4, 5, 6));
      expect(dt.offset, ZoneOffset(0));
    });

    test('just date', () {
      var dt = OffsetDateTime.parse('1000-02-03');
      expect(dt, hasDate(1000, 2, 3));
      expect(dt, hasTime(0));
      expect(dt.offset, ZoneOffset(0));
    });

    test('positive', () {
      var dt = OffsetDateTime.parse('+0000-02-03');
      expect(dt, hasDate(0, 2, 3));
    });

    test('negative', () {
      var dt = OffsetDateTime.parse('-1000-02-03');
      expect(dt, hasDate(-1000, 2, 3));
    });
  });

  test('toLocal()', () {
    expect(nepalOffsetTime.toLocal(), nepalTime);
  });

  test('toDateTime()', () {
    var want = DateTime.fromMicrosecondsSinceEpoch(
        nepalInstant.unixTimestamp.inMicroseconds);
    expect(nepalOffsetTime.toDateTime(), want);
  });

  test('timespanUntil()', () {
    expect(nepalOffsetTime.timespanUntil(nstTime), delta);
  });

  test('plusTimespan()', () {
    var got = nepalOffsetTime.plusTimespan(delta);
    expect(got.asInstant, nstTime.asInstant);
  });

  test('minusTimespan()', () {
    var got = nstTime.minusTimespan(delta);
    expect(got.asInstant, nepalOffsetTime.asInstant);
  });

  test('plusPeriod()', () {
    expect(nstTime.plusPeriod(Period(months: 1)),
        OffsetDateTime(nstOffset, 2001, 2, 1));
  });

  test('minusPeriod()', () {
    expect(nstTime.minusPeriod(Period(months: 1)),
        OffsetDateTime(nstOffset, 2000, 12, 1));
  });

  test('compareTo()', () {
    expect(nepalOffsetTime.compareTo(nstTime), -1);
  });

  test('operator>()', () {
    expect(nstTime > nepalOffsetTime, true);
    expect(nstTime > nstTime, false);
  });

  test('operator>=()', () {
    expect(nstTime >= nepalOffsetTime, true);
    expect(nstTime >= nstTime, true);
  });

  test('operator<()', () {
    expect(nepalOffsetTime < nstTime, true);
    expect(nepalOffsetTime < nepalOffsetTime, false);
  });

  test('operator<=()', () {
    expect(nepalOffsetTime <= nstTime, true);
    expect(nepalOffsetTime <= nepalOffsetTime, true);
  });

  test('toString()', () {
    expect(OffsetDateTime(ZoneOffset(-7), 2020, 3, 4).toString(),
        '2020-03-04T00:00-0700');
    expect(nepalOffsetTime.toString(), '2000-01-02T03:04:05.000000006+0545');
  });

  test('operator== / hashCode', () {
    var sameOffset = OffsetDateTime.fromInstant(nepalInstant, nepalOffset);
    var differentOffset =
        OffsetDateTime.fromInstant(nepalInstant, ZoneOffset(0));
    expect(nepalOffsetTime, sameOffset);
    expect(nepalOffsetTime.hashCode, sameOffset.hashCode);
    expect(nepalOffsetTime, isNot(differentOffset));
    expect(nepalOffsetTime.hashCode, isNot(differentOffset.hashCode));
  });

  test('operator== examples', () {
    var d1 = OffsetDateTime(ZoneOffset(0), 2023, 1, 1);
    var d2 = OffsetDateTime(ZoneOffset(-1), 2022, 12, 31, 23);

    expect(d1, isNot(d2));
    expect(d1.compareTo(d2), 0);
    expect(d1.asInstant, d2.asInstant);
  });
}
