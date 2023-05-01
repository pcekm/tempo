import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  var timeline = Map.unmodifiable({
    -2: Instant.fromUnix(Timespan(seconds: -2)),
    -1: Instant.fromUnix(Timespan(seconds: -1)),
    0: Instant.fromUnix(Timespan(seconds: 0)),
    1: Instant.fromUnix(Timespan(seconds: 1)),

    /// Jan 3, 2000 at 04:05:06.123456789 UTC:
    946872306:
        Instant.fromUnix(Timespan(seconds: 946872306, nanoseconds: 123456789)),
  });

  test('fromDateTime()', () {
    var dt = DateTime.fromMicrosecondsSinceEpoch(1234567890);
    expect(Instant.fromDateTime(dt).unixTimestamp,
        Timespan(microseconds: 1234567890));
  });

  test('now() smoke test', () {
    var dt = DateTime.now();
    expect(Instant.fromDateTime(dt).unixTimestamp,
        greaterThan(Timespan(seconds: 1682977179)));
  });

  test('timespanUntil()', () {
    expect(timeline[-1].timespanUntil(timeline[1]), Timespan(seconds: 2));
    expect(timeline[1].timespanUntil(timeline[-1]), Timespan(seconds: -2));
    expect(timeline[0].timespanUntil(timeline[0]), Timespan(seconds: 0));
  });

  test('plusTimespan()', () {
    expect(timeline[-1].plusTimespan(Timespan(seconds: 2)), timeline[1]);
    expect(timeline[-1].plusTimespan(Timespan(seconds: -1)), timeline[-2]);
  });

  test('minusTimespan()', () {
    expect(timeline[-1].minusTimespan(Timespan(seconds: 1)), timeline[-2]);
    expect(timeline[-1].minusTimespan(Timespan(seconds: -2)), timeline[1]);
  });

  group('Comparisons:', () {
    test('compareTo()', () {
      expect(timeline[-1].compareTo(timeline[1]), -1);
      expect(timeline[1].compareTo(timeline[-1]), 1);
      expect(timeline[1].compareTo(timeline[1]), 0);
    });

    test('operator >', () {
      expect(timeline[-1], greaterThan(timeline[-2]));
      expect(timeline[-1], isNot(greaterThan(timeline[-1])));
      expect(timeline[-1], isNot(greaterThan(timeline[0])));
      expect(timeline[-1], isNot(greaterThan(timeline[1])));
    });

    test('operator >=', () {
      expect(timeline[-1], greaterThanOrEqualTo(timeline[-2]));
      expect(timeline[-1], greaterThanOrEqualTo(timeline[-1]));
      expect(timeline[-1], isNot(greaterThanOrEqualTo(timeline[0])));
      expect(timeline[-1], isNot(greaterThanOrEqualTo(timeline[1])));
    });
    test('operator <', () {
      expect(timeline[-1], isNot(lessThan(timeline[-2])));
      expect(timeline[-1], isNot(lessThan(timeline[-1])));
      expect(timeline[-1], lessThan(timeline[0]));
      expect(timeline[-1], lessThan(timeline[1]));
    });
    test('operator <=', () {
      expect(timeline[-1], isNot(lessThanOrEqualTo(timeline[-2])));
      expect(timeline[-1], lessThanOrEqualTo(timeline[-1]));
      expect(timeline[-1], lessThanOrEqualTo(timeline[0]));
      expect(timeline[-1], lessThanOrEqualTo(timeline[1]));
    });
  });

  test('toString()', () {
    expect(timeline[-1].toString(), '1969-12-31T23:59:59.000000000Z');
    expect(timeline[0].toString(), '1970-01-01T00:00:00.000000000Z');
    expect(timeline[1].toString(), '1970-01-01T00:00:01.000000000Z');
    expect(timeline[1].toString(), '1970-01-01T00:00:01.000000000Z');
    expect(timeline[946872306].toString(), '2000-01-03T04:05:06.123456789Z');
  });

  test('toString() extremes', () {
    expect(
        Instant.fromUnix(
                Timespan(seconds: 253402300799, nanoseconds: 999999999))
            .toString(),
        "9999-12-31T23:59:59.999999999Z");
    expect(Instant.fromUnix(Timespan(seconds: -377705116800)).toString(),
        "-9999-01-01T00:00:00.000000000Z");
  });

  test('operator==', () {
    expect(Instant.fromUnix(Timespan(days: 1, nanoseconds: 2)),
        Instant.fromUnix(Timespan(days: 1, nanoseconds: 2)));
    expect(Instant.fromUnix(Timespan(days: 1, nanoseconds: 2)),
        isNot(Instant.fromUnix(Timespan(days: 1, nanoseconds: 3))));
  });

  test('hashCode', () {
    expect(Instant.fromUnix(Timespan(days: 1, nanoseconds: 2)).hashCode,
        Instant.fromUnix(Timespan(days: 1, nanoseconds: 2)).hashCode);
    expect(Instant.fromUnix(Timespan(days: 1, nanoseconds: 2)).hashCode,
        isNot(Instant.fromUnix(Timespan(days: 1, nanoseconds: 3)).hashCode));
  });
}
