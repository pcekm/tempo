import 'package:goodtime/goodtime.dart';
import 'package:goodtime/zoneinfo.dart';
import 'package:test/test.dart';

final jan1 = LocalDateTime(2023, 1, 1);
final feb19 = LocalDateTime(2023, 2, 19); // 3rd Sunday in Feb
final jun1 = LocalDateTime(2023, 6, 1);
final jul10 = LocalDateTime(2023, 7, 10); // 2nd Monday in Jul
final dec31 = LocalDateTime(2023, 12, 31);

// Convenience function that offsets a local datetime.
OffsetDateTime offset(LocalDateTime dt, int hours, [int minutes = 0]) =>
    OffsetDateTime.fromLocalDateTime(dt, ZoneOffset(hours, minutes));

void main() {
  test('correct std just before dst', () {
    var tz = PosixTz('PST8PDT,M2.3.0,M7.2.1');
    var stdZone = tz.timeZoneFor(
        offset(feb19.replace(hour: 1, minute: 59, second: 59), -8));
    expect(stdZone.designation, 'PST');
    expect(stdZone.offset.inSeconds, -28800);
    expect(stdZone.isDst, false, reason: 'isDst');
  });

  test('correct std just after dst', () {
    var tz = PosixTz('PST8PDT,M2.3.0,M7.2.1');
    var stdZone =
        tz.timeZoneFor(offset(jul10.replace(hour: 2), -7)); // 2 AM PDT
    expect(stdZone.designation, 'PST');
    expect(stdZone.offset.inSeconds, -28800);
    expect(stdZone.isDst, false, reason: 'isDst');
  });

  test('correct dst just after std', () {
    var tz = PosixTz('PST8PDT,M2.3.0,M7.2.1');
    var dstZone = tz.timeZoneFor(offset(feb19.replace(hour: 3), -7));
    expect(dstZone.designation, 'PDT');
    expect(dstZone.offset.inSeconds, -25200);
    expect(dstZone.isDst, true, reason: 'isDst');
  });

  test('correct dst just before std', () {
    var tz = PosixTz('PST8PDT,M2.3.0,M7.2.1');
    var dstZone = tz.timeZoneFor(offset(
        jul10.replace(hour: 1, minute: 59, second: 59), -7)); // 1:59:59 AM PDT
    expect(dstZone.designation, 'PDT');
    expect(dstZone.offset.inSeconds, -25200);
    expect(dstZone.isDst, true, reason: 'isDst');
  });

  test('eastern offset', () {
    var tz = PosixTz('FOO-5BAR,M2.3.0,M7.2.1');
    var dstZone = tz.timeZoneFor(offset(jun1, 5));
    expect(dstZone.designation, 'BAR');
    expect(dstZone.offset.inHours, 6);
    var stdZone = tz.timeZoneFor(offset(dec31, 5));
    expect(stdZone.designation, 'FOO');
    expect(stdZone.offset.inHours, 5);
  });

  test('Dublin time', () {
    // Ireland uses "winter time" instead of "summer time," so the
    // TZ string is backwards from what's usual:
    var tz = PosixTz('IST-1GMT0,M10.5.0,M3.5.0/1');
    var stdZone = tz.timeZoneFor(offset(jun1, 1));
    expect(stdZone.designation, 'IST');
    expect(stdZone.isDst, false);
    expect(stdZone.offset.inHours, 1);
    var dstZone = tz.timeZoneFor(offset(dec31, 0));
    expect(dstZone.designation, 'GMT');
    expect(dstZone.isDst, true);
    expect(dstZone.offset.inHours, 0);
  });

  test('5th Xday = last Xday of month', () {
    var tz = PosixTz('FOO8BAR,M1.5.4,M3.5.3');

    // Jan 2023 has 4 Thursdays. The 26th is the last one. If 5 weeks gets
    // blindly added, then DST would mistakenly start later.
    var dstZone = tz.timeZoneFor(offset(LocalDateTime(2023, 1, 26, 2), -8));
    expect(dstZone.isDst, true);

    // March 2023 has 5 Wednesdays. The 29th is the 5th one. Time should
    // switch back to standard on that day.
    var stdZone = tz.timeZoneFor(offset(LocalDateTime(2023, 3, 29, 2), -7));
    expect(stdZone.isDst, false);
  });

  test('nonstandard change times', () {
    var tz = PosixTz('FOO8BAR,M3.2.0/3,M11.1.0/5:24:36');
    expect(
        tz.timeZoneFor(offset(LocalDateTime(2023, 3, 12, 2, 59, 59), -8)).isDst,
        false);
    expect(
        tz.timeZoneFor(offset(LocalDateTime(2023, 3, 12, 3), -8)).isDst, true);

    expect(
        tz.timeZoneFor(offset(LocalDateTime(2023, 11, 5, 5, 24, 35), -7)).isDst,
        true);
    expect(
        tz.timeZoneFor(offset(LocalDateTime(2023, 11, 5, 5, 24, 36), -7)).isDst,
        false);
  });

  test('invalid input', () {
    expect(() => PosixTz('PST'), throwsFormatException);
    expect(() => PosixTz('PT8'), throwsFormatException);
    expect(() => PosixTz('PST8PDT'), throwsFormatException);
    expect(() => PosixTz('PST8PDT,'), throwsFormatException);
    expect(() => PosixTz('PST8PDT,M'), throwsFormatException);
    expect(() => PosixTz('PST8PDT,M2.1.0'), throwsFormatException);
    expect(() => PosixTz('PST8PDT,M2.1.0,'), throwsFormatException);
    expect(() => PosixTz('PST8PDT,M2.1,0,M3.1.0'), throwsFormatException);
    expect(() => PosixTz('PST8PDT,M2.1.0,M3.1.0  extra junk'),
        throwsFormatException);
  });

  test('permits leading and trailing whitespace', () {
    expect(PosixTz(' PST8PDT,M2.1.0,M3.1.0'), anything);
    expect(PosixTz('PST8PDT,M2.1.0,M3.1.0 '), anything);
  });

  test('names in angle brackets', () {
    var tz = PosixTz('<+02>-2<+03>,M2.3.0,M7.2.1');
    expect(tz.timeZoneFor(offset(jan1, 2)).designation, '+02');
    expect(tz.timeZoneFor(offset(jun1, 2)).designation, '+03');
  });
}