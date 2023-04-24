import 'package:goodtime/goodtime.dart';
import 'package:test/test.dart';

void main() {
  test('normalization', () {
    expect(ZoneOffset(24, -30), ZoneOffset(23, 30));
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
  });

  test('local() smoke test', () {
    expect(ZoneOffset.local(), anything);
  });

  test('toString()', () {
    expect(ZoneOffset(05, 45).toString(), '+0545');
    expect(ZoneOffset(-03, -30).toString(), '-0330');
    expect(ZoneOffset(03, 05).toString(), '+0305');
  });
}
