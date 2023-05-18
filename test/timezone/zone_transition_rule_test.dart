import 'package:tempo/src/timezone/zone_transition_rule.dart';
import 'package:tempo/tempo.dart';
import 'package:test/test.dart';

final jan1 = LocalDateTime(2023, 1, 1);
final feb19 = LocalDateTime(2023, 2, 19); // 3rd Sunday in Feb
final jun1 = LocalDateTime(2023, 6, 1);
final jul10 = LocalDateTime(2023, 7, 10); // 2nd Monday in Jul
final dec31 = LocalDateTime(2023, 12, 31);

final rule = ZoneTransitionRule((b) => b
  ..stdName = 'PST'
  ..stdOffset = ZoneOffset(-8)
  ..dstName = 'PDT'
  ..dstStartRule.month = 2
  ..dstStartRule.week = 3
  ..dstStartRule.day = Weekday.sunday
  ..stdStartRule.month = 7
  ..stdStartRule.week = 2
  ..stdStartRule.day = Weekday.monday);

class HasName extends CustomMatcher {
  HasName(Object? valueOrMatcher)
      : super('NamedZoneOffset with a name of', 'name', valueOrMatcher);

  @override
  Object? featureValueOf(dynamic actual) => actual.name;
}

class HasOffsetInSeconds extends CustomMatcher {
  HasOffsetInSeconds(Object? valueOrMatcher)
      : super('NamedZoneOffset with an offset in seconds of',
            'asTimespan.inSeconds', valueOrMatcher);

  @override
  Object? featureValueOf(dynamic actual) => actual.asTimespan.inSeconds;
}

class HasOffsetInHours extends CustomMatcher {
  HasOffsetInHours(Object? valueOrMatcher)
      : super('NamedZoneOffset with an offset in hours of',
            'asTimespan.inHours', valueOrMatcher);

  @override
  Object? featureValueOf(dynamic actual) => actual.asTimespan.inHours;
}

class HasIsDst extends CustomMatcher {
  HasIsDst(Object? valueOrMatcher)
      : super('NamedZoneOffset with isDst', 'isDst', valueOrMatcher);

  @override
  Object? featureValueOf(dynamic actual) => actual.isDst;
}

// Convenience function that offsets a local datetime.
OffsetDateTime offset(LocalDateTime dt, int hours, [int minutes = 0]) =>
    OffsetDateTime.fromLocalDateTime(dt, ZoneOffset(hours, minutes));

void main() {
  test('correct std just before dst', () {
    var stdZone = rule
        .offsetFor(offset(feb19.replace(hour: 1, minute: 59, second: 59), -8));
    expect(stdZone, HasName('PST'));
    expect(stdZone, HasOffsetInSeconds(-28800));
    expect(stdZone, HasIsDst(false));
  });

  test('correct std just after dst', () {
    var stdZone =
        rule.offsetFor(offset(jul10.replace(hour: 2), -7)); // 2 AM PDT
    expect(stdZone, HasName('PST'));
    expect(stdZone, HasOffsetInSeconds(-28800));
    expect(stdZone, HasIsDst(false));
  });

  test('correct dst just after std', () {
    var dstZone = rule.offsetFor(offset(feb19.replace(hour: 3), -7));
    expect(dstZone, HasName('PDT'));
    expect(dstZone, HasOffsetInSeconds(-25200));
    expect(dstZone, HasIsDst(true));
  });

  test('correct dst just before std', () {
    var dstZone = rule.offsetFor(offset(
        jul10.replace(hour: 1, minute: 59, second: 59), -7)); // 1:59:59 AM PDT
    expect(dstZone, HasName('PDT'));
    expect(dstZone, HasOffsetInSeconds(-25200));
    expect(dstZone, HasIsDst(true));
  });

  test('eastern offset', () {
    final eastern = rule.rebuild((b) => b
      ..stdName = 'FOO'
      ..stdOffset = ZoneOffset(5)
      ..dstName = 'BAR'
      ..dstOffset = null);
    var dstZone = eastern.offsetFor(offset(jun1, 5));
    expect(dstZone, HasName('BAR'));
    expect(dstZone, HasOffsetInHours(6));
    var stdZone = eastern.offsetFor(offset(dec31, 5));
    expect(stdZone, HasName('FOO'));
    expect(stdZone, HasOffsetInHours(5));
  });

  test('no DST', () {
    var rule = ZoneTransitionRule((b) => b
      ..stdName = 'FOO'
      ..stdOffset = ZoneOffset(3));
    var zone = rule.offsetFor(offset(jun1, 3));
    expect(zone, HasName('FOO'));
    expect(zone, HasOffsetInHours(3));
    expect(zone, HasIsDst(false));
  });

  test('Dublin time', () {
    // Ireland uses "winter time" instead of "summer time," so everything
    // is backwards from what's usual. This corresponds to the posix TZ
    // string:
    //
    //   IST-1GMT0,M10.5.0,M3.5.0/1
    var rule = ZoneTransitionRule((b) => b
      ..stdName = 'IST'
      ..stdOffset = ZoneOffset(1)
      ..dstName = 'GMT'
      ..dstOffset = ZoneOffset(0)
      ..dstStartRule.month = 10
      ..dstStartRule.week = 5
      ..dstStartRule.day = Weekday.sunday
      ..stdStartRule.month = 3
      ..stdStartRule.week = 5
      ..stdStartRule.day = Weekday.sunday
      ..stdStartRule.time = LocalTime(1));
    var stdZone = rule.offsetFor(offset(jun1, 1));
    expect(stdZone, HasName('IST'));
    expect(stdZone, HasIsDst(false));
    expect(stdZone, HasOffsetInHours(1));
    var dstZone = rule.offsetFor(offset(dec31, 0));
    expect(dstZone, HasName('GMT'));
    expect(dstZone, HasIsDst(true));
    expect(dstZone, HasOffsetInHours(0));
  });

  test('Nuk, Greenland (negative hour start)', () {
    // TZ = "<-02>2<-01>,M3.5.0/-1,M10.5.0/0"
    var rule = ZoneTransitionRule((b) => b
      ..stdName = '-02'
      ..stdOffset = ZoneOffset(-2)
      ..dstName = '-01'
      ..dstStartRule.month = 3
      ..dstStartRule.week = 5
      ..dstStartRule.day = Weekday.sunday
      ..dstStartRule.time = LocalTime(-1)
      ..stdStartRule.month = 10
      ..stdStartRule.week = 5
      ..stdStartRule.day = Weekday.sunday
      ..stdStartRule.time = LocalTime(0));
    var stdZone = rule.offsetFor(offset(jan1, 2));
    expect(stdZone, HasName('-02'));
    expect(stdZone, HasOffsetInHours(-2));
    expect(stdZone, HasIsDst(false));
    var dstZone = rule.offsetFor(offset(jun1, 1));
    expect(dstZone, HasName('-01'));
    expect(dstZone, HasOffsetInHours(-1));
    expect(dstZone, HasIsDst(true));
  });

  test('5th Xday = last Xday of month', () {
    // TZ = "FOO8BAR,M1.5.4,M3.5.3"
    var rule = ZoneTransitionRule((b) => b
      ..stdName = 'FOO'
      ..stdOffset = ZoneOffset(-8)
      ..dstName = 'BAR'
      ..dstStartRule.month = 1
      ..dstStartRule.week = 5
      ..dstStartRule.day = Weekday.thursday
      ..stdStartRule.month = 3
      ..stdStartRule.week = 5
      ..stdStartRule.day = Weekday.wednesday);

    // Jan 2023 has 4 Thursdays. The 26th is the last one. If 5 weeks gets
    // blindly added, then DST would mistakenly start later.
    var dstZone = rule.offsetFor(offset(LocalDateTime(2023, 1, 26, 2), -8));
    expect(dstZone, HasIsDst(true));

    // March 2023 has 5 Wednesdays. The 29th is the 5th one. Time should
    // switch back to standard on that day.
    var stdZone = rule.offsetFor(offset(LocalDateTime(2023, 3, 29, 2), -7));
    expect(stdZone, HasIsDst(false));
  });

  test('nonstandard change times', () {
    // TZ="FOO8BAR,M3.2.0/3,M11.1.0/5:24:36"
    var rule = ZoneTransitionRule((b) => b
      ..stdName = 'FOO'
      ..stdOffset = ZoneOffset(-8)
      ..dstName = 'BAR'
      ..dstStartRule.month = 3
      ..dstStartRule.week = 2
      ..dstStartRule.day = Weekday.sunday
      ..dstStartRule.time = LocalTime(3)
      ..stdStartRule.month = 11
      ..stdStartRule.week = 1
      ..stdStartRule.day = Weekday.sunday
      ..stdStartRule.time = LocalTime(5, 24, 36));
    expect(rule.offsetFor(offset(LocalDateTime(2023, 3, 12, 2, 59, 59), -8)),
        HasIsDst(false));
    expect(rule.offsetFor(offset(LocalDateTime(2023, 3, 12, 3), -8)),
        HasIsDst(true));

    expect(rule.offsetFor(offset(LocalDateTime(2023, 11, 5, 5, 24, 35), -7)),
        HasIsDst(true));
    expect(rule.offsetFor(offset(LocalDateTime(2023, 11, 5, 5, 24, 36), -7)),
        HasIsDst(false));
  });
}
