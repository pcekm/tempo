import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
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
  final nepalUnixSeconds = 946761545;
  final nepalUnixNanoseconds = 6;
  final nepalInstant =
      Instant.fromUnix(Timespan(seconds: 946761545, nanoseconds: 6));

  // Newfoundland in the winter is UTC-0330:
  final nstOffset = ZoneOffset(-3, -30);
  final nstTime = OffsetDateTime.withOffset(nstOffset, 2001);
  final nstUnixSeconds = 978319800;
  final nstUnixNanoseconds = 0;

  // Difference between nepalTime and ndtTime:
  final delta = Timespan(days: 365, seconds: 22254, nanoseconds: nano - 6);

  setUp(() {
    // Unlikely to be the system local time zone:
    defaultZoneId = 'Pacific/Kiritimati';
  });

  test('Default constructor', () {
    defaultZoneId = 'Asia/Kathmandu';
    var dt = OffsetDateTime(
        nepalTime.year,
        nepalTime.month,
        nepalTime.day,
        nepalTime.hour,
        nepalTime.minute,
        nepalTime.second,
        nepalTime.nanosecond);
    expect(dt, hasDateAndTime(2000, 1, 2, 3, 4, 5, 6));
    expect(dt.offset, nepalOffset);
    expect(dt, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
  });

  group('withOffset', () {
    test('hour+minute offset', () {
      var dt = OffsetDateTime.withOffset(
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
      expect(dt, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
    });

    test('hour+minute+second offset', () {
      var dt = OffsetDateTime.withOffset(ZoneOffset(1, 2, 3), 1970);
      expect(dt, hasDate(1970, 1, 1));
      expect(dt, hasTime(0));
      expect(dt.offset, ZoneOffset(1, 2, 3));
      expect(
          dt,
          hasInstant(
              Instant.fromUnix(-Timespan(hours: 1, minutes: 2, seconds: 3))));
    });
  });

  group('fromLocalDateTime()', () {
    test('specified offset', () {
      var dt = OffsetDateTime.fromLocalDateTime(nepalTime, nepalOffset);
      expect(dt, hasDate(2000, 1, 2));
      expect(dt, hasTime(3, 4, 5, 6));
      expect(dt.offset, ZoneOffset(5, 45));
      expect(dt, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
    });

    test('default offset', () {
      defaultZoneId = 'Asia/Kathmandu';
      var dt = OffsetDateTime.fromLocalDateTime(nepalTime);
      expect(dt, hasDate(2000, 1, 2));
      expect(dt, hasTime(3, 4, 5, 6));
      expect(dt.offset, ZoneOffset(5, 45));
      expect(dt, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
    });

    test('default just before time change', () {
      defaultZoneId = 'America/Los_Angeles';
      var dt =
          OffsetDateTime.fromLocalDateTime(LocalDateTime(2025, 3, 9, 1, 59));
      expect(dt, hasDate(2025, 3, 9));
      expect(dt, hasTime(1, 59));
      expect(dt, hasOffset(-8));
      expect(dt, hasUnixSeconds(1741514340));
    });

    test('default just after time change', () {
      defaultZoneId = 'America/Los_Angeles';
      var dt =
          OffsetDateTime.fromLocalDateTime(LocalDateTime(2025, 3, 9, 3, 0));
      expect(dt, hasDate(2025, 3, 9));
      expect(dt, hasTime(3, 0));
      expect(dt, hasOffset(-7));
      expect(dt, hasUnixSeconds(1741514400));
    });
  });

  group('fromDateTime()', () {
    test('microsecond precision', () {
      var dt = DateTime(2000, 1, 2, 3, 4, 5, 6, 7);
      var offset = ZoneOffset.fromDuration(dt.timeZoneOffset);
      var want =
          OffsetDateTime.withOffset(offset, 2000, 1, 2, 3, 4, 5, 006007000);
      expect(OffsetDateTime.fromDateTime(dt), want);
    }, testOn: '!js');

    test('millisecond precision', () {
      var dt = DateTime(2000, 1, 2, 3, 4, 5, 6);
      var offset = ZoneOffset.fromDuration(dt.timeZoneOffset);
      var want =
          OffsetDateTime.withOffset(offset, 2000, 1, 2, 3, 4, 5, 006000000);
      expect(OffsetDateTime.fromDateTime(dt), want);
    });
  });

  test('now()', () {
    defaultZoneId = 'Asia/Kathmandu';
    var got = withClock(
        Clock.fixed(DateTime.fromMillisecondsSinceEpoch(1765694800000)),
        () => OffsetDateTime.now());
    expect(got, hasUnixMilliseconds(1765694800000));
    expect(got, hasOffset(5, 45));
  });

  group('fromInstant()', () {
    test('hour+minute offset', () {
      var dt = OffsetDateTime.fromInstant(nepalInstant, nepalOffset);
      expect(dt, hasDate(2000, 1, 2));
      expect(dt, hasTime(3, 4, 5, 6));
      expect(dt.offset, ZoneOffset(5, 45));
      expect(dt, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
    });

    test('hour+minute+second offset', () {
      var instant = Instant.fromUnix(Timespan(seconds: 0));
      var dt = OffsetDateTime.fromInstant(instant, ZoneOffset(1, 2, 3));
      expect(dt, hasDate(1970, 1, 1));
      expect(dt, hasTime(1, 2, 3));
      expect(dt.offset, ZoneOffset(1, 2, 3));
      expect(dt, hasUnixSeconds(0));
    });
  });

  test('fromInstant() default offset', () {
    defaultZoneId = 'Asia/Kathmandu';
    var dt = OffsetDateTime.fromInstant(nepalInstant);
    expect(dt, hasDate(2000, 1, 2));
    expect(dt, hasTime(3, 4, 5, 6));
    expect(dt.offset, ZoneOffset(5, 45));
    expect(dt, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
  });

  group('fromUnix()', () {
    test('hour+minute offset', () {
      var dt = OffsetDateTime.fromUnix(nepalInstant.unixTimestamp, nepalOffset);
      expect(dt, hasDate(2000, 1, 2));
      expect(dt, hasTime(3, 4, 5, 6));
      expect(dt.offset, ZoneOffset(5, 45));
      expect(dt, hasInstant(nepalInstant));
      expect(dt, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
    });

    test('hour+minute+second offset', () {
      var instant = Instant.fromUnix(Timespan(seconds: 0));
      var dt =
          OffsetDateTime.fromUnix(instant.unixTimestamp, ZoneOffset(1, 2, 3));
      expect(dt, hasDate(1970, 1, 1));
      expect(dt, hasTime(1, 2, 3));
      expect(dt.offset, ZoneOffset(1, 2, 3));
      expect(dt, hasInstant(instant));
      expect(dt, hasUnixSeconds(0));
    });

    test('default offset', () {
      defaultZoneId = 'Asia/Kathmandu';
      var dt = OffsetDateTime.fromUnix(nepalInstant.unixTimestamp);
      expect(dt, hasDate(2000, 1, 2));
      expect(dt, hasTime(3, 4, 5, 6));
      expect(dt.offset, ZoneOffset(5, 45));
      expect(dt, hasInstant(nepalInstant));
    });
  });

  group('parse()', () {
    test('all fields', () {
      var dt = OffsetDateTime.parse('1000-02-03T04:05:06.000000007+08:09:10');
      expect(dt, hasDate(1000, 2, 3));
      expect(dt, hasTime(4, 5, 6, 7));
      expect(dt, hasOffset(8, 9, 10));
    });

    test('no offset assumes local zone', () {
      var dt = OffsetDateTime.parse('2000-02-03T04:05:06.000000007');
      expect(dt, hasDate(2000, 2, 3));
      expect(dt, hasTime(4, 5, 6, 7));
      expect(dt, hasOffset(14));
    });

    test('just date', () {
      var dt = OffsetDateTime.parse('2000-02-03');
      expect(dt, hasDate(2000, 2, 3));
      expect(dt, hasTime(0));
      expect(dt, hasOffset(14));
    });

    test('positive', () {
      var dt = OffsetDateTime.parse('+0000-02-03');
      expect(dt, hasDate(0, 2, 3));
    });

    test('negative', () {
      var dt = OffsetDateTime.parse('-1000-02-03');
      expect(dt, hasDate(-1000, 2, 3));
    });

    test('minimal delimiters, standards compliant', () {
      var dt = OffsetDateTime.parse('10000203T040506.000000007+080910');
      expect(dt, hasDate(1000, 2, 3));
      expect(dt, hasTime(4, 5, 6, 7));
      expect(dt, hasOffset(8, 9, 10));
    });

    test('space separator', () {
      // Technically not allowed by the most recent version of ISO 8601, but
      // common enough to be worth parsing.
      var dt = OffsetDateTime.parse('2001-02-03 04:05:06');
      expect(dt, hasDate(2001, 2, 3));
      expect(dt, hasTime(4, 5, 6));
    });

    test('no separators at all', () {
      // Technically not allowed by the most recent version of ISO 8601, but
      // common enough to be worth parsing.
      var dt = OffsetDateTime.parse('20010203040506');
      expect(dt, hasDate(2001, 2, 3));
      expect(dt, hasTime(4, 5, 6));
    });
  });

  group('replace()', () {
    test('all date fields', () {
      var dt = OffsetDateTime.withOffset(nepalOffset, 1, 2, 3, 4, 5, 6, 7);
      var repl = dt.replace(
          year: 7,
          month: 6,
          day: 5,
          hour: 4,
          minute: 3,
          second: 2,
          nanosecond: 1);
      expect(repl, hasDateAndTime(7, 6, 5, 4, 3, 2, 1));
      expect(repl.offset, nepalOffset);
    });

    test('offset', () {
      var dt = OffsetDateTime.withOffset(nepalOffset, 1, 2, 3, 4, 5, 6, 7);
      var repl = dt.replace(offset: nstOffset);
      expect(repl, hasDateAndTime(1, 2, 3, 4, 5, 6, 7));
      expect(repl.offset, nstOffset);
    });

    test('invalid day of month', () {
      var dt = OffsetDateTime(2025, 12, 31, 4, 3, 2, 1);
      var repl = dt.replace(month: 2);
      expect(repl, hasDateAndTime(2025, 2, 28, 4, 3, 2, 1));
    });
  });

  test('inLeapYear', () {
    expect(OffsetDateTime(1900).inLeapYear, false, reason: 'year = 1900');
    expect(OffsetDateTime(1904).inLeapYear, true, reason: 'year = 1904');
    expect(OffsetDateTime(1996).inLeapYear, true, reason: 'year = 1996');
    expect(OffsetDateTime(1997).inLeapYear, false, reason: 'year = 1997');
    expect(OffsetDateTime(2000).inLeapYear, true, reason: 'year = 2000');
  });

  group('conversions', () {
    test('atOffset()', () {
      expect(
          OffsetDateTime.withOffset(ZoneOffset(0), 1970, 1, 1, 0)
              .atOffset(ZoneOffset(1)),
          OffsetDateTime.withOffset(ZoneOffset(1), 1970, 1, 1, 1));
    });

    test('toLocal()', () {
      expect(nepalOffsetTime.toLocal(), nepalTime);
    });

    test('toDateTime()', () {
      var want =
          DateTime.fromMicrosecondsSinceEpoch(nepalUnixSeconds * 1000000);
      expect(nepalOffsetTime.toDateTime(), want);
    });

    test('toInstant()', () {
      expect(nepalOffsetTime.toInstant(),
          hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
    });

    test('inTimezone()', () {
      final got = nepalOffsetTime.inTimezone();
      expect(got, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
      expect(got.zoneId, defaultZoneId);
    });

    test('inTimezone() with time zone', () {
      final got = nepalOffsetTime.inTimezone('America/Los_Angeles');
      expect(got, hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
      expect(got.zoneId, 'America/Los_Angeles');
    });
  });

  test('timespanUntil()', () {
    expect(nepalOffsetTime.timespanUntil(nstTime), delta);
  });

  test('plusTimespan()', () {
    var got = nepalOffsetTime.plusTimespan(delta);
    expect(got, hasUnixNanoseconds(nstUnixSeconds, nstUnixNanoseconds));
  });

  test('minusTimespan()', () {
    var got = nstTime.minusTimespan(delta);
    expect(got.toInstant(),
        hasUnixNanoseconds(nepalUnixSeconds, nepalUnixNanoseconds));
  });

  test('plusPeriod()', () {
    expect(nstTime.plusPeriod(Period(months: 1)),
        OffsetDateTime.withOffset(nstOffset, 2001, 2, 1));
  });

  test('minusPeriod()', () {
    expect(nstTime.minusPeriod(Period(months: 1)),
        OffsetDateTime.withOffset(nstOffset, 2000, 12, 1));
  });

  test('compareTo()', () {
    expect(nepalOffsetTime.compareTo(nstTime), isNegative);
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

  test('format()', () {
    final d = OffsetDateTime.withOffset(ZoneOffset(2), 2000, 1, 2, 3, 4, 5, 6);
    final format = DateFormat.yMd().add_Hms();
    expect(d.format(format), '1/2/2000 03:04:05');
  });

  test('toString()', () {
    expect(OffsetDateTime.withOffset(ZoneOffset(-7), 2020, 3, 4).toString(),
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
    var d1 = OffsetDateTime.withOffset(ZoneOffset(0), 2023, 1, 1);
    var d2 = OffsetDateTime.withOffset(ZoneOffset(-1), 2022, 12, 31, 23);

    expect(d1, isNot(d2));
    expect(d1.compareTo(d2), 0);
    expect(d1.toInstant(), d2.toInstant());
  });
}
