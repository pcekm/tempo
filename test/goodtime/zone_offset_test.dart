import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  test('normalization', () {
    expect(ZoneOffset(24, -30), ZoneOffset(23, 30));
    expect(ZoneOffset(24, -30, -1), ZoneOffset(23, 29, 59));
    expect(ZoneOffset(24, 30), ZoneOffset(0, 30));
    expect(ZoneOffset(48, 0), ZoneOffset(0, 0));
    expect(ZoneOffset(-24, 30), ZoneOffset(-23, -30));
    expect(ZoneOffset(-48, 0), ZoneOffset(0, 0));
  });

  test('fromDuration()', () {
    expect(ZoneOffset.fromDuration(Duration(hours: 1, minutes: 25)),
        ZoneOffset(1, 25));
    expect(ZoneOffset.fromDuration(Duration(hours: -1, minutes: -30)),
        ZoneOffset(-1, -30));
    expect(ZoneOffset.fromDuration(Duration(hours: -1, minutes: 30)),
        ZoneOffset(0, -30));
    expect(
        ZoneOffset.fromDuration(Duration(hours: -1, minutes: 30, seconds: 1)),
        ZoneOffset(0, -29, -59));
  });

  test('inSeconds', () {
    expect(ZoneOffset(1, 2, 3).inSeconds, 3723);
  });

  test('inMinutes', () {
    expect(ZoneOffset(1, 2, 59).inMinutes, 62);
  });

  test('inHours', () {
    expect(ZoneOffset(1, 59, 59).inHours, 1);
  });

  test('local() smoke test', () {
    expect(ZoneOffset.local(), anything);
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
