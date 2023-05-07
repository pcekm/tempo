import 'package:test/test.dart';
import 'package:goodtime/goodtime.dart';
import 'package:goodtime/testing.dart';

class _HasDst extends CustomMatcher {
  _HasDst(matcher) : super('Has isDst that is', 'isDst', matcher);
  @override
  bool featureValueOf(dynamic actual) => actual.isDst;
}

final isDst = _HasDst(true);
final isNotDst = _HasDst(false);

void main() {
  group('construction', () {
    test('fromInstant', () {
      var instant =
          Instant.fromUnix(Timespan(seconds: 1672657445, nanoseconds: 6));
      var dt = ZonedDateTime.fromInstant(instant, "America/Los Angeles");
      expect(dt, hasDate(2023, 1, 2));
      expect(dt, hasTime(3, 4, 5, 6));
      expect(dt, isNotDst);
      expect(dt.timeZone, 'PST');
      expect(dt.zoneId, 'America/Los Angeles');
    });

    group('default (from components)', () {
      group('west', () {
        test('normal std', () {
          var got =
              ZonedDateTime('America/Los Angeles', 2023, 1, 1, 2, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1672567384, nanoseconds: 5))));
          expect(got, hasDate(2023, 1, 1));
          expect(got, hasTime(2, 3, 4, 5));
          expect(got, isNotDst);
          expect(got.timeZone, 'PST');
        });
        test('normal dst', () {
          var got =
              ZonedDateTime('America/Los Angeles', 2023, 6, 1, 2, 3, 4, 5);
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
          var got =
              ZonedDateTime('America/Los Angeles', 2023, 3, 12, 2, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1678615384, nanoseconds: 5))));
          expect(got, hasHour(3));
          expect(got, isDst);
        });

        test('fall back into ambiguity', () {
          var got =
              ZonedDateTime('America/Los Angeles', 2023, 11, 5, 1, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1699171384, nanoseconds: 5))));
          expect(got, hasHour(1));
          expect(got, isDst);
        });

        test('spring forward over time change', () {
          var got =
              ZonedDateTime('America/Los Angeles', 2023, 3, 12, 3, 4, 5, 6);

          expect(got, hasHour(3));
          expect(got, isDst);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1678615445, nanoseconds: 6))));
        });

        test('fall back over time change', () {
          var got =
              ZonedDateTime('America/Los Angeles', 2023, 11, 5, 2, 3, 4, 5);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1699178584, nanoseconds: 5))));
          expect(got, isNotDst);
        });
      });

      group('east', () {
        test('normal std', () {
          var got = ZonedDateTime('Europe/Tallinn', 2023, 1, 1, 2, 3, 4, 5);
          expect(got, hasDate(2023, 1, 1));
          expect(got, hasTime(2, 3, 4, 5));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1672531384, nanoseconds: 5))));
          expect(got, isNotDst);
          expect(got.timeZone, 'EET');
        });
        test('normal dst', () {
          var got = ZonedDateTime('Europe/Tallinn', 2023, 6, 1, 2, 3, 4, 5);
          expect(got, hasDate(2023, 6, 1));
          expect(got, hasTime(2, 3, 4, 5));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1685574184, nanoseconds: 5))));
          expect(got, isDst);
          expect(got.timeZone, 'EEST');
        });

        test('spring forward into null space', () {
          var got = ZonedDateTime('Europe/Tallinn', 2023, 3, 26, 3, 4, 5, 6);
          expect(got, hasHour(4));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1679792645, nanoseconds: 6))));
          expect(got, isDst);
        });

        test('fall back into ambiguity', () {
          var got = ZonedDateTime('Europe/Tallinn', 2023, 10, 29, 3, 4, 5, 6);
          expect(got, hasHour(3));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1698537845, nanoseconds: 6))));
          expect(got, isDst);
        });

        test('spring forward over time change', () {
          var got = ZonedDateTime('Europe/Tallinn', 2023, 3, 26, 4, 5, 6, 7);
          expect(got, hasHour(4));
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1679792706, nanoseconds: 7))));
          expect(got, isDst);
        });

        test('fall back over time change', () {
          var got = ZonedDateTime('Europe/Tallinn', 2023, 10, 29, 4, 5, 6, 7);
          expect(
              got,
              hasInstant(Instant.fromUnix(
                  Timespan(seconds: 1698545106, nanoseconds: 7))));
          expect(got, isNotDst);
        });
      });
    });

    test('now() smoke test', () {
      var got = ZonedDateTime.now('America/Denver');
      expect(got, hasYear(greaterThanOrEqualTo(2023)));
      expect(got.zoneId, 'America/Denver');
    });

    test('fromDateTime', () {
      var got = ZonedDateTime.fromDateTime(
          DateTime.utc(2000, 1, 2, 3, 4, 5, 6, 7), 'UTC');
      expect(got, hasDate(2000, 1, 2));
      expect(got, hasTime(3, 4, 5, 6007000));
      expect(got.zoneId, 'UTC');
    });
  });

  group('time zone info', () {
    test('timeZone', () {
      expect(ZonedDateTime('Europe/Zurich', 2000, 1, 2).timeZone, "CET");
      expect(ZonedDateTime('Europe/Zurich', 2000, 6, 2).timeZone, "CEST");
    });

    test('offset', () {
      expect(ZonedDateTime('Europe/Zurich', 2000, 1, 2).offset, ZoneOffset(1));
      expect(ZonedDateTime('Europe/Zurich', 2000, 6, 2).offset, ZoneOffset(2));
    });

    test('isDst', () {
      expect(ZonedDateTime('Europe/Zurich', 2000, 1, 2), isNotDst);
      expect(ZonedDateTime('Europe/Zurich', 2000, 6, 2), isDst);
    });
  });

  group('conversions', () {
    test('toLocal', () {
      var local = ZonedDateTime('America/Los Angeles', 2000, 1, 2, 3, 4, 5, 6)
          .toLocal();
      expect(local, isA<LocalDateTime>());
      expect(local, hasDate(2000, 1, 2));
      expect(local, hasTime(3, 4, 5, 6));
    });

    test('toOffset', () {
      var odt =
          ZonedDateTime('America/Toronto', 2000, 1, 2, 3, 4, 5, 6).toOffset();
      expect(odt, isA<OffsetDateTime>());
      expect(odt, hasDate(2000, 1, 2));
      expect(odt, hasTime(3, 4, 5, 6));
      expect(odt.offset, ZoneOffset(-5));
    });

    test('toDateTime', () {
      // A bit involved: Create a date in UTC, convert it to a local DateTime,
      // then convert that back to UTC. Unfortunately it's not possible to
      // learn the local time zone in a portable way.
      var dt = ZonedDateTime('UTC', 2000, 1, 2, 3, 4, 5, 006007000)
          .toDateTime()
          .toUtc();
      expect(dt, DateTime.utc(2000, 1, 2, 3, 4, 5, 6, 7));
    });

    test('asInstant', () {
      var dt = ZonedDateTime('America/Los Angeles', 2000, 1, 2, 3, 4, 5, 6);
      expect(
          dt,
          hasInstant(
              Instant.fromUnix(Timespan(seconds: 946811045, nanoseconds: 6))));
    });
  });

  group('Timespan arithmetic', () {
    test('plusTimespan', () {
      var dt = ZonedDateTime('America/Los Angeles', 2000, 1, 2, 3, 4, 5, 6);
      var got = dt.plusTimespan(Timespan(days: 120));
      expect(got, hasDate(2000, 5, 1));
      // One hour ahead because of DST:
      expect(got, hasTime(4, 4, 5, 6));
    });

    test('minusTimespan', () {
      var dt = ZonedDateTime('America/Los Angeles', 2000, 1, 2, 3, 4, 5, 6);
      var got = dt.minusTimespan(Timespan(days: 120));
      expect(got, hasDate(1999, 9, 4));
      // One hour ahead because of DST:
      expect(got, hasTime(4, 4, 5, 6));
    });
  });

  group('Period arithmetic', () {
    test('plusPeriod', () {
      var dt = ZonedDateTime('America/Los Angeles', 2000, 1, 2, 3, 4, 5, 6);
      var got = dt.plusPeriod(Period(months: 6));
      expect(got, hasDate(2000, 7, 2));
      // Remains unchanged in spite of DST.
      expect(got, hasTime(3, 4, 5, 6));
    });

    test('minusPeriod', () {
      var dt = ZonedDateTime('America/Los Angeles', 2000, 1, 2, 3, 4, 5, 6);
      var got = dt.minusPeriod(Period(months: 6));
      expect(got, hasDate(1999, 7, 2));
      // Remains unchanged in spite of DST.
      expect(got, hasTime(3, 4, 5, 6));
    });
  });

  // Basic tests. The heavy lifiting (and more thorough tests) are done
  // by Instant.
  group('comparisons', () {
    // Same wall time, two adjacent time zones (EST, CET):
    var dt1 = ZonedDateTime('Europe/Tallinn', 2000, 1, 2, 3, 4, 5, 6);
    var dt2 = ZonedDateTime('Europe/Zurich', 2000, 1, 2, 3, 4, 5, 6);

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
      expect(dt1.compareTo(dt2), -1);
    });
  });

  test('toString()', () {
    expect(ZonedDateTime('America/Los Angeles', 2000, 1, 2, 3, 4).toString(),
        '2000-01-02T03:04-0800');
    expect(ZonedDateTime('Europe/Tallinn', 2000, 1, 2, 3, 4).toString(),
        '2000-01-02T03:04+0200');
    expect(ZonedDateTime('Europe/Tallinn', 2000, 1, 2, 3, 4, 5, 6).toString(),
        '2000-01-02T03:04:05.000000006+0200');
  });

  group('equality and hashCode', () {
    // Same instant, two adjacent time zones (EST, CET):
    var dt1 = ZonedDateTime('Europe/Tallinn', 2000, 1, 2, 4, 4, 5, 6);
    var dt2 = ZonedDateTime('Europe/Zurich', 2000, 1, 2, 3, 4, 5, 6);
    var dt3 = ZonedDateTime('Europe/Zurich', 2000, 1, 2, 3, 4, 5, 6);

    test('operator== different zones', () {
      expect(dt1, isNot(dt2)); // Different zones means !=
      expect(dt1.asInstant, dt2.asInstant);
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
