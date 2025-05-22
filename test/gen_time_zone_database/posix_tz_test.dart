@TestOn('!js')
library;

import 'package:tempo/tempo.dart';
import 'package:tempo/timezone.dart';
import 'package:test/test.dart';

import '../../tool/gen_time_zone_database/posix_tz.dart';

final jan1 = LocalDateTime(2023, 1, 1);
final feb19 = LocalDateTime(2023, 2, 19); // 3rd Sunday in Feb
final jun1 = LocalDateTime(2023, 6, 1);
final jul10 = LocalDateTime(2023, 7, 10); // 2nd Monday in Jul
final dec31 = LocalDateTime(2023, 12, 31);

void main() {
  test('negative offset, no custom time"', () {
    var tz = PosixTz('PST8PDT,M2.3.0,M7.2.1');
    expect(
        tz.rule,
        ZoneTransitionRule((b) => b
          ..stdName = 'PST'
          ..stdOffset = ZoneOffset(-8)
          ..dstName = 'PDT'
          ..dstOffset = ZoneOffset(-7)
          ..dstStartRule.update((b) => b
            ..month = 2
            ..week = 3
            ..day = Weekday.sunday)
          ..stdStartRule.update((b) => b
            ..month = 7
            ..week = 2
            ..day = Weekday.monday)));
  });

  test('positive offset, no custom time', () {
    var tz = PosixTz('FOO-3BAR,M2.3.0,M7.2.1');
    expect(
        tz.rule,
        ZoneTransitionRule((b) => b
          ..stdName = 'FOO'
          ..stdOffset = ZoneOffset(3)
          ..dstName = 'BAR'
          ..dstOffset = ZoneOffset(4)
          ..dstStartRule.update((b) => b
            ..month = 2
            ..week = 3
            ..day = Weekday.sunday)
          ..stdStartRule.update((b) => b
            ..month = 7
            ..week = 2
            ..day = Weekday.monday)));
  });

  test('fixed offset', () {
    var tz = PosixTz('MST7');
    expect(
        tz.rule,
        ZoneTransitionRule((b) => b
          ..stdName = 'MST'
          ..stdOffset = ZoneOffset(-7)));
  });

  test('custom hour starts', () {
    var tz = PosixTz('FOO2BAR,M3.5.0/-1,M10.5.0/5:30:25');
    expect(
        tz.rule,
        ZoneTransitionRule((b) => b
          ..stdName = 'FOO'
          ..stdOffset = ZoneOffset(-2)
          ..dstName = 'BAR'
          ..dstOffset = ZoneOffset(-1)
          ..dstStartRule.update((b) => b
            ..month = 3
            ..week = 5
            ..day = Weekday.sunday
            ..time = LocalTime(23, 0, 0))
          ..stdStartRule.update((b) => b
            ..month = 10
            ..week = 5
            ..day = Weekday.sunday
            ..time = LocalTime(5, 30, 25))));
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
    expect(tz.rule.stdName, '+02');
    expect(tz.rule.dstName, '+03');
  });
}
