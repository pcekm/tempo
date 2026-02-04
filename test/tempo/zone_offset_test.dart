import 'package:tempo/tempo.dart';
import 'package:test/test.dart';

Matcher isOffset(int hours, [int? minutes, int? seconds]) => isA<ZoneOffset>()
    .having((z) => z.hours, 'hours', hours)
    .having((z) => z.minutes, 'minutes', minutes ?? anything)
    .having((z) => z.seconds, 'seconds', seconds ?? anything);

void main() {
  test('normalization', () {
    expect(ZoneOffset(24, -30), isOffset(23, 30));
    expect(ZoneOffset(24, -30, -1), isOffset(23, 29, 59));
    expect(ZoneOffset(24, 30), isOffset(0, 30));
    expect(ZoneOffset(48, 0), isOffset(0, 0));
    expect(ZoneOffset(-24, 30), isOffset(-23, -30));
    expect(ZoneOffset(-48, 0), isOffset(0, 0));
    expect(ZoneOffset(-24), isOffset(0));
    expect(ZoneOffset(0, -60), isOffset(-1));
    expect(ZoneOffset(0, 0, -60), isOffset(0, -1));
  });

  test('fromDuration()', () {
    expect(ZoneOffset.fromDuration(Duration(hours: 1, minutes: 25)),
        isOffset(1, 25));
    expect(ZoneOffset.fromDuration(Duration(hours: -1, minutes: -30)),
        isOffset(-1, -30));
    expect(ZoneOffset.fromDuration(Duration(hours: -1, minutes: 30)),
        isOffset(0, -30));
    expect(
        ZoneOffset.fromDuration(Duration(hours: -1, minutes: 30, seconds: 1)),
        isOffset(0, -29, -59));
  });

  group('parse()', () {
    test('complete', () {
      expect(ZoneOffset.parse('+02:03:04'), isOffset(2, 3, 4));
      expect(ZoneOffset.parse('+020304'), isOffset(2, 3, 4));
    });

    test('negative', () {
      expect(ZoneOffset.parse('-02:03:04'), isOffset(-2, -3, -4));
      expect(ZoneOffset.parse('-020304'), isOffset(-2, -3, -4));
    });

    test('hour minute', () {
      expect(ZoneOffset.parse('+02:03'), isOffset(2, 3));
      expect(ZoneOffset.parse('+0203'), isOffset(2, 3));
    });

    test('hour only', () {
      expect(ZoneOffset.parse('+02'), isOffset(2));
      expect(ZoneOffset.parse('+02'), isOffset(2));
    });

    test('zulu', () {
      expect(ZoneOffset.parse('+00'), isOffset(0));
      expect(ZoneOffset.parse('-00'), isOffset(0));
      expect(ZoneOffset.parse('Z'), isOffset(0));
    });

    test('invalid', () {
      const bad = ['', '1', '01', 'x', '01x'];
      for (var s in bad) {
        expect(() => ZoneOffset.parse(s), throwsFormatException, reason: s);
      }
    });
  });

  test('asTimespan', () {
    expect(ZoneOffset(1, 2, 3).asTimespan,
        Timespan(hours: 1, minutes: 2, seconds: 3));
  });

  test('equality', () {
    expect(ZoneOffset(1, 2, 3) == ZoneOffset(1, 2, 3), isTrue);
    expect(ZoneOffset(1, 2, 3) == ZoneOffset(0, 2, 3), isFalse);
    expect(ZoneOffset(1, 2, 3) == ZoneOffset(1, 0, 3), isFalse);
    expect(ZoneOffset(1, 2, 3) == ZoneOffset(1, 2, 0), isFalse);
  });

  test('hashCode', () {
    expect(ZoneOffset(1, 2, 3).hashCode, ZoneOffset(1, 2, 3).hashCode);
    expect(ZoneOffset(1, 2, 3).hashCode, isNot(ZoneOffset(0, 2, 3).hashCode));
    expect(ZoneOffset(1, 2, 3).hashCode, isNot(ZoneOffset(1, 0, 3).hashCode));
    expect(ZoneOffset(1, 2, 3).hashCode, isNot(ZoneOffset(1, 2, 0).hashCode));
  });

  test('toString()', () {
    expect(ZoneOffset(0).toString(), '+0000');
    expect(ZoneOffset(5).toString(), '+0500');
    expect(ZoneOffset(-3).toString(), '-0300');
    expect(ZoneOffset(05, 45).toString(), '+0545');
    expect(ZoneOffset(-03, -30).toString(), '-0330');
    expect(ZoneOffset(03, 05).toString(), '+0305');
    expect(ZoneOffset(-3, -4, -5).toString(), '-030405');
  });
}
