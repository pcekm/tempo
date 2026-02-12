import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:tempo/tempo.dart';
import 'package:tempo/testing.dart';

Matcher hasDst(bool dst) =>
    isA<ZonedDateTime>().having((d) => d.isDst, 'isDst', dst);

final isDst = hasDst(true);
final isNotDst = hasDst(false);

Matcher hasZoneId(Object zoneId) =>
    isA<ZonedDateTime>().having((d) => d.zoneId, 'zoneId', zoneId);

void main() {
  setUp(() {
    defaultZoneId = 'Pacific/Kiritimati';
  });

  group('construction', () {
    test('fromInstant', () {
      var instant =
          Instant.fromUnix(Timespan(seconds: 1672657445, nanoseconds: 6));
      var dt = ZonedDateTime.fromInstant(instant, 'America/Los_Angeles');
      expect(dt, hasDateAndTime(2023, 1, 2, 3, 4, 5, 6));
      expect(dt, isNotDst);
      expect(dt.timeZone, 'PST');
      expect(dt.zoneId, 'America/Los_Angeles');
    });

    test('fromUnix', () {
      var unixTimestamp = Timespan(seconds: 1672657445, nanoseconds: 6);
      var dt = ZonedDateTime.fromUnix(unixTimestamp, 'America/Los_Angeles');
      expect(dt, hasDateAndTime(2023, 1, 2, 3, 4, 5, 6));
      expect(dt, isNotDst);
      expect(dt.timeZone, 'PST');
      expect(dt.zoneId, 'America/Los_Angeles');
    });

    group('parse', () {
      group('provided zone id', () {
        test('provided offset', () {
          final dt = ZonedDateTime.parse(
              '2025-01-02T03:04-0500', 'America/Los_Angeles');
          expect(dt, hasDateAndTime(2025, 1, 2, 0, 4));
          expect(dt.zoneId, 'America/Los_Angeles');
        });

        test('no offset', () {
          final dt =
              ZonedDateTime.parse('2025-01-02T03:04', 'America/Los_Angeles');
          expect(dt, hasDateAndTime(2025, 1, 2, 3, 4));
          expect(dt.zoneId, 'America/Los_Angeles');
        });
      });

      group('default zone id', () {
        setUp(() {
          defaultZoneId = 'America/Los_Angeles';
        });

        test('provided offset', () {
          final dt = ZonedDateTime.parse('2025-01-02T03:04-0500');
          expect(dt, hasDateAndTime(2025, 1, 2, 0, 4));
          expect(dt.zoneId, 'America/Los_Angeles');
        });

        test('no offset', () {
          final dt =
              ZonedDateTime.parse('2025-01-02T03:04', 'America/Los_Angeles');
          expect(dt, hasDateAndTime(2025, 1, 2, 3, 4));
          expect(dt.zoneId, 'America/Los_Angeles');
        });
      });
    });

    group('from components', () {
      group('west', () {
        setUp(() {
          defaultZoneId = 'America/Los_Angeles';
        });

        test('normal std', () {
          var got = ZonedDateTime(2023, 1, 1, 2, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1672567384, nanoseconds: 5))));
          expect(got, hasDateAndTime(2023, 1, 1, 2, 3, 4, 5));
          expect(got, isNotDst);
          expect(got.timeZone, 'PST');
        });
        test('normal dst', () {
          var got = ZonedDateTime(2023, 6, 1, 2, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1685610184, nanoseconds: 5))));
          expect(got, hasYear(2023));
          expect(got, hasTime(2, 3, 4, 5));
          expect(got, isDst);
          expect(got.timeZone, 'PDT');
        });

        test('spring forward into null space', () {
          var got = ZonedDateTime(2023, 3, 12, 2, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1678615384, nanoseconds: 5))));
          expect(got, hasHour(3));
          expect(got, isDst);
        });

        test('fall back into ambiguity', () {
          var got = ZonedDateTime(2023, 11, 5, 1, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1699171384, nanoseconds: 5))));
          expect(got, hasHour(1));
          expect(got, isDst);
        });

        test('spring forward over time change', () {
          var got = ZonedDateTime(2023, 3, 12, 3, 4, 5, 6);

          expect(got, hasHour(3));
          expect(got, isDst);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1678615445, nanoseconds: 6))));
        });

        test('fall back over time change', () {
          var got = ZonedDateTime(2023, 11, 5, 2, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1699178584, nanoseconds: 5))));
          expect(got, isNotDst);
        });
      });

      group('east', () {
        setUp(() {
          defaultZoneId = 'Europe/Tallinn';
        });
        test('normal std', () {
          var got = ZonedDateTime(2023, 1, 1, 2, 3, 4, 5);
          expect(got, hasDateAndTime(2023, 1, 1, 2, 3, 4, 5));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1672531384, nanoseconds: 5))));
          expect(got, isNotDst);
          expect(got.timeZone, 'EET');
        });
        test('normal dst', () {
          var got = ZonedDateTime(2023, 6, 1, 2, 3, 4, 5);
          expect(got, hasDateAndTime(2023, 6, 1, 2, 3, 4, 5));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1685574184, nanoseconds: 5))));
          expect(got, isDst);
          expect(got.timeZone, 'EEST');
        });

        test('spring forward into null space', () {
          var got = ZonedDateTime(2023, 3, 26, 3, 4, 5, 6);
          expect(got, hasHour(4));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1679792645, nanoseconds: 6))));
          expect(got, isDst);
        });

        test('fall back into ambiguity', () {
          var got = ZonedDateTime(2023, 10, 29, 3, 4, 5, 6);
          expect(got, hasHour(3));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1698537845, nanoseconds: 6))));
          expect(got, isDst);
        });

        test('spring forward over time change', () {
          var got = ZonedDateTime(2023, 3, 26, 4, 5, 6, 7);
          expect(got, hasHour(4));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1679792706, nanoseconds: 7))));
          expect(got, isDst);
        });

        test('fall back over time change', () {
          var got = ZonedDateTime(2023, 10, 29, 4, 5, 6, 7);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1698545106, nanoseconds: 7))));
          expect(got, isNotDst);
        });
      });
    });

    test('withZoneId()', () {
      var got =
          ZonedDateTime.withZoneId('America/St_Johns', 2000, 1, 2, 3, 4, 5, 6);
      expect(got, hasDate(2000, 1, 2));
      expect(got.zoneId, equals('America/St_Johns'));
    });

    group('now())', () {
      test('default time zone', () {
        var got = withClock(
            Clock.fixed(DateTime.fromMillisecondsSinceEpoch(1765694800)),
            () => ZonedDateTime.now());
        expect(got, hasUnixMilliseconds(1765694800));
        expect(got.zoneId, defaultZoneId);
      });

      test('specified time zone', () {
        var got = withClock(
            Clock.fixed(DateTime.fromMillisecondsSinceEpoch(1765694800)),
            () => ZonedDateTime.now('America/Denver'));
        expect(got, hasUnixMilliseconds(1765694800));
        expect(got.zoneId, 'America/Denver');
      });
    });

    test('fromDateTime() native', () {
      var got = ZonedDateTime.fromDateTime(
          DateTime.utc(2000, 1, 2, 3, 4, 5, 6, 7), 'UTC');
      expect(got, hasDateAndTime(2000, 1, 2, 3, 4, 5, 6007000));
      expect(got.zoneId, 'UTC');
    }, testOn: '!js');

    test('fromDateTime() js', () {
      var got = ZonedDateTime.fromDateTime(
          DateTime.utc(2000, 1, 2, 3, 4, 5, 6), 'UTC');
      expect(got, hasDateAndTime(2000, 1, 2, 3, 4, 5, 6000000));
      expect(got.zoneId, 'UTC');
    }, testOn: 'js');
  });

  group('time zone info', () {
    setUp(() {
      defaultZoneId = 'Europe/Zurich';
    });

    test('timeZone', () {
      expect(ZonedDateTime(2000, 1, 2).timeZone, "CET");
      expect(ZonedDateTime(2000, 6, 2).timeZone, "CEST");
    });

    test('offset', () {
      expect(ZonedDateTime(2000, 1, 2), hasOffset(1));
      expect(ZonedDateTime(2000, 6, 2), hasOffset(2));
    });

    test('isDst', () {
      expect(ZonedDateTime(2000, 1, 2), isNotDst);
      expect(ZonedDateTime(2000, 6, 2), isDst);
    });
  });

  group('replace()', () {
    test('all fields', () {
      var dt = ZonedDateTime.withZoneId("America/Denver", 1, 2, 3, 4, 5, 6, 7);
      var repl = dt.replace(
          year: 7,
          month: 6,
          day: 5,
          hour: 4,
          minute: 3,
          second: 2,
          nanosecond: 1);
      expect(repl, hasDateAndTime(7, 6, 5, 4, 3, 2, 1));
      expect(repl.zoneId, "America/Denver");
    });

    test('offset', () {
      var dt = ZonedDateTime.withZoneId("Europe/Tallinn", 1, 2, 3, 4, 5, 6, 7);
      var repl = dt.replace(zoneId: "America/Los_Angeles");
      expect(repl, hasDateAndTime(1, 2, 3, 4, 5, 6, 7));
      expect(repl.zoneId, "America/Los_Angeles");
    });

    test('invalid day of month', () {
      var dt = ZonedDateTime(2025, 12, 31, 4, 3, 2, 1);
      var repl = dt.replace(month: 2);
      expect(repl, hasDateAndTime(2025, 2, 28, 4, 3, 2, 1));
    });
  });

  test('inLeapYear', () {
    expect(ZonedDateTime(1900).inLeapYear, false, reason: 'year = 1900');
    expect(ZonedDateTime(1904).inLeapYear, true, reason: 'year = 1904');
    expect(ZonedDateTime(1996).inLeapYear, true, reason: 'year = 1996');
    expect(ZonedDateTime(1997).inLeapYear, false, reason: 'year = 1997');
    expect(ZonedDateTime(2000).inLeapYear, true, reason: 'year = 2000');
  });

  group('conversions', () {
    test('toLocal', () {
      var local = ZonedDateTime.withZoneId(
              'America/Los_Angeles', 2000, 1, 2, 3, 4, 5, 6)
          .toLocal();
      expect(local, isA<LocalDateTime>());
      expect(local, hasDateAndTime(2000, 1, 2, 3, 4, 5, 6));
    });

    test('asOffsetDateTime', () {
      var odt =
          ZonedDateTime.withZoneId('America/Toronto', 2000, 1, 2, 3, 4, 5, 6)
              .asOffsetDateTime;
      expect(odt, isA<OffsetDateTime>());
      expect(odt, hasDateAndTime(2000, 1, 2, 3, 4, 5, 6));
      expect(odt, hasOffset(-5));
    });

    test('atOffset() with no offset', () {
      defaultZoneId = 'America/Toronto';
      expect(ZonedDateTime.withZoneId('UTC', 1970, 1, 1, 0).atOffset(),
          OffsetDateTime.withOffset(ZoneOffset(-5), 1969, 12, 31, 19));
    });

    test('atOffset() with given offset', () {
      expect(
          ZonedDateTime.withZoneId('UTC', 1970, 1, 1, 0)
              .atOffset(ZoneOffset(1)),
          OffsetDateTime.withOffset(ZoneOffset(1), 1970, 1, 1, 1));
    });

    test('toDateTime', () {
      // A bit involved: Create a date in UTC, convert it to a local DateTime,
      // then convert that back to UTC. Unfortunately it's not possible to
      // learn the local time zone in a portable way.
      var dt = ZonedDateTime.withZoneId('UTC', 2000, 1, 2, 3, 4, 5, 006007000)
          .toDateTime()
          .toUtc();
      expect(dt, DateTime.utc(2000, 1, 2, 3, 4, 5, 6, 7));
    });

    test('toDateTime rounds down', () {
      expect(
          ZonedDateTime.withZoneId('UTC', 2000, 1, 2, 23, 59, 59, 999999999)
              .toDateTime()
              .toUtc(),
          DateTime.utc(2000, 1, 2, 23, 59, 59, 999, 999));
    });

    test('toInstant', () {
      var dt = ZonedDateTime.withZoneId(
          'America/Los_Angeles', 2000, 1, 2, 3, 4, 5, 6);
      expect(dt.toInstant(),
          Instant.fromUnix(Timespan(seconds: 946811045, nanoseconds: 6)));
    });
  });

  test('timespanUntil', () {
    var dt1 = ZonedDateTime.fromInstant(
        Instant.fromUnix(Timespan(seconds: 2000)), 'America/Los_Angeles');
    var dt2 = ZonedDateTime.fromInstant(
        Instant.fromUnix(Timespan(seconds: 3000)), 'Australia/Sydney');
    expect(dt1.timespanUntil(dt2), Timespan(seconds: 1000));
  });

  group('Timespan arithmetic', () {
    setUp(() {
      defaultZoneId = 'America/Los_Angeles';
    });

    test('addition', () {
      var dt = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
      var got = dt + Timespan(days: 120);
      // One hour ahead because of DST:
      expect(got, hasDateAndTime(2000, 5, 1, 4, 4, 5, 6));
    });

    test('subtraction', () {
      var dt = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
      var got = dt - Timespan(days: 120);
      // One hour ahead because of DST:
      expect(got, hasDateAndTime(1999, 9, 4, 4, 4, 5, 6));
    });

    test('plusTimespan', () {
      var dt = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
      // ignore: deprecated_member_use_from_same_package
      var got = dt.plusTimespan(Timespan(days: 120));
      // One hour ahead because of DST:
      expect(got, hasDateAndTime(2000, 5, 1, 4, 4, 5, 6));
    });

    test('minusTimespan', () {
      var dt = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
      // ignore: deprecated_member_use_from_same_package
      var got = dt.minusTimespan(Timespan(days: 120));
      // One hour ahead because of DST:
      expect(got, hasDateAndTime(1999, 9, 4, 4, 4, 5, 6));
    });
  });

  group('Period arithmetic', () {
    setUp(() {
      defaultZoneId = 'America/Los_Angeles';
    });

    test('plusPeriod', () {
      var dt = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
      var got = dt + Period(months: 6);
      // Remains unchanged in spite of DST.
      expect(got, hasDateAndTime(2000, 7, 2, 3, 4, 5, 6));
    });

    test('minusPeriod', () {
      var dt = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
      var got = dt - Period(months: 6);
      // Remains unchanged in spite of DST.
      expect(got, hasDateAndTime(1999, 7, 2, 3, 4, 5, 6));
    });

    test('plusPeriod', () {
      var dt = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
      // ignore: deprecated_member_use_from_same_package
      var got = dt.plusPeriod(Period(months: 6));
      // Remains unchanged in spite of DST.
      expect(got, hasDateAndTime(2000, 7, 2, 3, 4, 5, 6));
    });

    test('minusPeriod', () {
      var dt = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
      // ignore: deprecated_member_use_from_same_package
      var got = dt.minusPeriod(Period(months: 6));
      // Remains unchanged in spite of DST.
      expect(got, hasDateAndTime(1999, 7, 2, 3, 4, 5, 6));
    });

    group('periodUntil', () {
      test('same timezone', () {
        var dt1 = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
        var dt2 = ZonedDateTime(2001, 3, 5, 6, 7, 8, 9);
        expect(dt1.periodUntil(dt2), Period(years: 1, months: 2, days: 3));
      });

      test('different timezones', () {
        var dt1 = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
        var dt2 =
            ZonedDateTime.withZoneId('Atlantic/Azores', 2001, 3, 5, 6, 7, 8, 9);
        expect(() => dt1.periodUntil(dt2), throwsA(isA<ArgumentError>()));
      });

      test('OffsetDateTime', () {
        var dt1 = ZonedDateTime(2000, 1, 2, 3, 4, 5, 6);
        var dt2 = dt1.asOffsetDateTime;
        expect(() => dt1.periodUntil(dt2), throwsA(isA<ArgumentError>()));
      });
    });
  });

  group('quantize', () {
    final zoneId = "Etc/GMT-8";

    test('examples', () {
      final date = ZonedDateTime.withZoneId(
          "America/Los_Angeles", 2021, 2, 3, 4, 5, 6, 7);
      expect(date.quantize(Period(years: 5)), hasDateAndTime(2020, 1, 1));
      expect(date.quantize(Period(days: 7)), hasDateAndTime(2021, 1, 31));
      expect(date.quantize(Timespan(hours: 3)), hasDateAndTime(2021, 2, 3, 4));
      expect(date.quantize(Timespan(minutes: 10)),
          hasDateAndTime(2021, 2, 3, 4, 0));
    });

    group('by Timespan', () {
      test('positive RD by positive Timespan', () {
        expect(
            ZonedDateTime.withZoneId(zoneId, 5000, 2, 3, 4, 34, 35, 36)
                .quantize(Timespan(minutes: 5)),
            allOf(hasDateAndTime(5000, 2, 3, 4, 30), hasZoneId(zoneId)));
      });

      test('negative RD by positive Timespan', () {
        expect(
            ZonedDateTime.withZoneId(zoneId, -5000, 2, 3, 4, 34, 35, 36)
                .quantize(Timespan(minutes: 5)),
            allOf(hasDateAndTime(-5000, 2, 3, 4, 30), hasZoneId(zoneId)));
      });

      test('positive RD by negative Timespan', () {
        expect(
            ZonedDateTime.withZoneId(zoneId, 5000, 2, 3, 4, 34, 35, 36)
                .quantize(-Timespan(minutes: 5)),
            allOf(hasDateAndTime(5000, 2, 3, 4, 35), hasZoneId(zoneId)));
      });

      test('negative RD by negative Timespan', () {
        expect(
            ZonedDateTime.withZoneId(zoneId, -5000, 2, 3, 4, 34, 35, 36)
                .quantize(-Timespan(minutes: 5)),
            allOf(hasDateAndTime(-5000, 2, 3, 4, 35), hasZoneId(zoneId)));
      });
    });

    group('by Period', () {
      test('positive RD by positive Period', () {
        final date = ZonedDateTime.withZoneId(zoneId, 2025, 2, 3, 4, 5, 6, 7);
        expect(date.quantize(Period(days: 7)),
            allOf(hasDateAndTime(2025, 2, 2), hasZoneId(zoneId)));
        expect(date.quantize(Period(months: 3)),
            allOf(hasDateAndTime(2025, 1, 1), hasZoneId(zoneId)));
        expect(date.quantize(Period(years: 10)),
            allOf(hasDateAndTime(2020), hasZoneId(zoneId)));
      });

      test('negative RD by positive Period', () {
        final date = ZonedDateTime.withZoneId(zoneId, -2025, 2, 3, 4, 5, 6, 7);
        expect(date.quantize(Period(days: 7)),
            allOf(hasDateAndTime(-2025, 2, 2), hasZoneId(zoneId)));
        expect(date.quantize(Period(months: 3)),
            allOf(hasDateAndTime(-2025, 1, 1), hasZoneId(zoneId)));
        expect(date.quantize(Period(years: 10)),
            allOf(hasDateAndTime(-2030), hasZoneId(zoneId)));
      });

      test('positive RD by negative Period', () {
        final date = ZonedDateTime.withZoneId(zoneId, 2025, 2, 3, 4, 5, 6, 7);
        expect(date.quantize(-Period(days: 7)),
            allOf(hasDateAndTime(2025, 2, 9), hasZoneId(zoneId)));
        expect(date.quantize(-Period(months: 3)),
            allOf(hasDateAndTime(2025, 4, 1), hasZoneId(zoneId)));
        expect(date.quantize(-Period(years: 10)),
            allOf(hasDateAndTime(2030), hasZoneId(zoneId)));
      });

      test('negative RD by negative Period', () {
        final date = ZonedDateTime.withZoneId(zoneId, -2025, 2, 3, 4, 5, 6, 7);
        expect(date.quantize(-Period(days: 7)),
            allOf(hasDateAndTime(-2025, 2, 9), hasZoneId(zoneId)));
        expect(date.quantize(-Period(months: 3)),
            allOf(hasDateAndTime(-2025, 4, 1), hasZoneId(zoneId)));
        expect(date.quantize(-Period(years: 10)),
            allOf(hasDateAndTime(-2020), hasZoneId(zoneId)));
      });
    });
  });

  // Basic tests. The heavy lifting (and more thorough tests) are done
  // by Instant.
  group('comparisons', () {
    // Same wall time, two adjacent time zones (EST, CET):
    var dt1 =
        ZonedDateTime.withZoneId('Europe/Tallinn', 2000, 1, 2, 3, 4, 5, 6);
    var dt2 = ZonedDateTime.withZoneId('Europe/Zurich', 2000, 1, 2, 3, 4, 5, 6);

    test('operator<', () {
      expect(dt1, lessThan(dt2));
    });

    test('operator>', () {
      expect(dt2, greaterThan(dt1));
    });

    test('operator<=', () {
      expect(dt1, lessThanOrEqualTo(dt2));
    });

    test('operator>=', () {
      expect(dt2, greaterThanOrEqualTo(dt1));
    });

    test('compareTo', () {
      expect(dt1.compareTo(dt2), isNegative);
    });
  });

  test('format()', () {
    final d =
        ZonedDateTime.withZoneId('Europe/Tallinn', 2000, 1, 2, 3, 4, 5, 6);
    final format = DateFormat.yMd().add_Hms();
    expect(d.format(format), '1/2/2000 03:04:05');
  });

  test('toString()', () {
    expect(
        ZonedDateTime.withZoneId('America/Los_Angeles', 2000, 1, 2, 3, 4)
            .toString(),
        '2000-01-02T03:04-0800');
    expect(
        ZonedDateTime.withZoneId('Europe/Tallinn', 2000, 1, 2, 3, 4).toString(),
        '2000-01-02T03:04+0200');
    expect(
        ZonedDateTime.withZoneId('Europe/Tallinn', 2000, 1, 2, 3, 4, 5, 6)
            .toString(),
        '2000-01-02T03:04:05.000000006+0200');
  });

  group('equality and hashCode', () {
    // Same instant, two adjacent time zones (EST, CET):
    var dt1 =
        ZonedDateTime.withZoneId('Europe/Tallinn', 2000, 1, 2, 4, 4, 5, 6);
    var dt2 = ZonedDateTime.withZoneId('Europe/Zurich', 2000, 1, 2, 3, 4, 5, 6);
    var dt3 = ZonedDateTime.withZoneId('Europe/Zurich', 2000, 1, 2, 3, 4, 5, 6);

    test('operator== different zones', () {
      expect(dt1, isNot(dt2)); // Different zones means !=
      expect(dt1.toInstant(), dt2.toInstant());
    });

    test('operator== same zones', () {
      expect(dt2, dt3);
    });

    test('hashCode different zones', () {
      expect(dt1.hashCode, isNot(dt2.hashCode));
    });

    test('hashCode same zones', () {
      expect(dt2.hashCode, dt3.hashCode);
    });
  });
}
