import 'package:goodtime/zoneinfo.dart';
import 'package:test/test.dart';

void main() {
  test('smoke test', () {
    var got = lookupZoneInfo('Europe/Tallinn');
    expect(got, isNotNull);
    expect(got!.name, 'Europe/Tallinn');
  });

  test('id normalization', () {
    var got = lookupZoneInfo('   America/Los _ Angeles   ');
    expect(got, isNotNull);
    expect(got!.name, 'America/Los Angeles');
  });
}
