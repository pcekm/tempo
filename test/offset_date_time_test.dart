import 'package:test/test.dart';
import 'package:goodtime/src/offset_date_time.dart';
import 'package:goodtime/src/localdatetime.dart';
import 'package:goodtime/src/instant.dart';
import 'package:goodtime/src/zone_offset.dart';
import 'package:goodtime/src/timespan.dart';
import 'package:goodtime/src/period.dart';

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
  final ndtOffset = ZoneOffset(-3, -30);
  final ndtTime = OffsetDateTime(ndtOffset, 2001);

  // Difference between nepalTime and ndtTime:
  final delta = Timespan(days: 365, seconds: 22254, nanoseconds: nano - 6);

  test('Default constructor', () {
    var dt = OffsetDateTime(
        nepalOffset,
        nepalTime.year,
        nepalTime.month,
        nepalTime.day,
        nepalTime.hour,
        nepalTime.minute,
        nepalTime.second,
        nepalTime.nanosecond);
    expect(dt.year, 2000, reason: 'year');
    expect(dt.month, 1, reason: 'month');
    expect(dt.day, 2, reason: 'day');
    expect(dt.hour, 3, reason: 'hour');
    expect(dt.minute, 4, reason: 'minute');
    expect(dt.second, 5, reason: 'second');
    expect(dt.nanosecond, 6, reason: 'nanosecond');
    expect(dt.offset, ZoneOffset(5, 45));
    expect(dt.asInstant, nepalInstant);
  });

  test('fromLocalDateTime()', () {
    var dt = OffsetDateTime.fromLocalDateTime(nepalTime, nepalOffset);
    expect(dt.year, 2000, reason: 'year');
    expect(dt.month, 1, reason: 'month');
    expect(dt.day, 2, reason: 'day');
    expect(dt.hour, 3, reason: 'hour');
    expect(dt.minute, 4, reason: 'minute');
    expect(dt.second, 5, reason: 'second');
    expect(dt.nanosecond, 6, reason: 'nanosecond');
    expect(dt.offset, ZoneOffset(5, 45));
    expect(dt.asInstant, nepalInstant);
  });

  test('fromDateTime()', () {
    var dt = DateTime(2000, 1, 2, 3, 4, 5, 6, 7);
    var offset = ZoneOffset.fromDuration(dt.timeZoneOffset);
    var want = OffsetDateTime(offset, 2000, 1, 2, 3, 4, 5, 006007000);
    expect(OffsetDateTime.fromDateTime(dt), want);
  });

  test('now() smoke test', () {
    var got = OffsetDateTime.now();
    expect(got.year, greaterThanOrEqualTo(2023));
  });

  test('fromInstant()', () {
    var dt = OffsetDateTime.fromInstant(nepalInstant, nepalOffset);
    expect(dt.year, 2000, reason: 'year');
    expect(dt.month, 1, reason: 'month');
    expect(dt.day, 2, reason: 'day');
    expect(dt.hour, 3, reason: 'hour');
    expect(dt.minute, 4, reason: 'minute');
    expect(dt.second, 5, reason: 'second');
    expect(dt.nanosecond, 6, reason: 'nanosecond');
    expect(dt.offset, ZoneOffset(5, 45));
    expect(dt.asInstant, nepalInstant);
  });

  test('toDateTime()', () {
    var want = DateTime.fromMicrosecondsSinceEpoch(
        nepalInstant.unixTimestamp.inMicroseconds);
    expect(nepalOffsetTime.toDateTime(), want);
  });

  test('timespanUntil()', () {
    expect(nepalOffsetTime.timespanUntil(ndtTime), delta);
  });

  test('plusTimespan()', () {
    var got = nepalOffsetTime.plusTimespan(delta);
    expect(got.asInstant, ndtTime.asInstant);
  });

  test('minusTimespan()', () {
    var got = ndtTime.minusTimespan(delta);
    expect(got.asInstant, nepalOffsetTime.asInstant);
  });

  test('plusPeriod()', () {
    expect(ndtTime.plusPeriod(Period(months: 1)),
        OffsetDateTime(ndtOffset, 2001, 2, 1));
  });

  test('minusPeriod()', () {
    expect(ndtTime.minusPeriod(Period(months: 1)),
        OffsetDateTime(ndtOffset, 2000, 12, 1));
  });

  test('compareTo()', () {
    expect(nepalOffsetTime.compareTo(ndtTime), -1);
  });

  test('operator>()', () {
    expect(ndtTime > nepalOffsetTime, true);
    expect(ndtTime > ndtTime, false);
  });

  test('operator>=()', () {
    expect(ndtTime >= nepalOffsetTime, true);
    expect(ndtTime >= ndtTime, true);
  });

  test('operator<()', () {
    expect(nepalOffsetTime < ndtTime, true);
    expect(nepalOffsetTime < nepalOffsetTime, false);
  });

  test('operator<=()', () {
    expect(nepalOffsetTime <= ndtTime, true);
    expect(nepalOffsetTime <= nepalOffsetTime, true);
  });

  test('toString()', () {
    expect(nepalOffsetTime.toString(), "2000-01-02T03:04:05.000000006+0545");
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
